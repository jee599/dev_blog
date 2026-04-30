---
title: "Symphony: Why OpenAI's PRs Jumped 500% in 3 Weeks"
published: true
description: "OpenAI open-sourced Symphony, which turns Linear into a control plane for coding agents. Here is how it works and what a 500% PR lift actually means."
tags: [ai, opensource, productivity, openai]
cover_image: https://r2.jidonglab.com/blog/2026/04/openai-symphony-codex-orchestration-linear-hero.jpg
canonical_url: https://jidonglab.com/blog/openai-symphony-codex-orchestration-linear
series: "Codex April 2026 Deep Dive"
hashnode_url: 'https://plzai.hashnode.dev/2026-04-30-openai-symphony-codex-orchestration-linear'
id: 3592373
date: '2026-04-30T15:01:14.098Z'
---

OpenAI's internal teams landed five times more pull requests in the three weeks after they switched on [Symphony](https://github.com/openai/symphony). Not 50% more. Five hundred percent more, on the same headcount, in 21 days. That single number is why I cloned the repo the day it dropped.

Symphony is OpenAI's open-source orchestration layer that turns a [Linear](https://linear.app) board into a control plane for coding agents, released April 28, 2026 as a reference implementation, not a maintained product. It is small — a few thousand lines of TypeScript wrapped around the [Codex App Server](https://openai.com/index/unlocking-the-codex-harness/) — and it is deliberately opinionated. The core idea is so blunt it almost feels like a prank: stop supervising agents, manage tickets instead.

To understand why that idea is worth open-sourcing, you have to talk about the supervision tax. Anyone who has run a coding agent in anger knows the rhythm. You hand it a task, babysit the diff, nudge it when it loses the plot, re-prompt when it crashes, remember which terminal tab had the half-finished branch. By the time you have shepherded one PR to merge, half the day is gone. The tax is not the model's failure rate. It is the human attention each running agent demands. Multiply by three or four parallel agents and you stop being an engineer and start being a kindergarten teacher with a Slack window.

Symphony's pitch is that the kindergarten part is automatable. The board is already the queue — every Linear team has a backlog with assignees, labels, and acceptance criteria. Symphony reads that board on a poll, takes any ticket marked for an agent, spawns a dedicated workspace, runs the agent until it produces a PR, and links the PR back to the ticket. If the agent crashes mid-run, Symphony notices the dead process and restarts it on the same ticket. The human's job collapses to two verbs: write the ticket, review the PR.

Here is the loop, drawn out so you can see the shape of it.

```
   ┌──────────────┐    poll(30s)    ┌──────────────┐
   │ Linear board │ ───────────────▶│   Symphony   │
   │  (tickets)   │                 │   poller     │
   └──────────────┘                 └──────┬───────┘
          ▲                                │ spawn
          │ comment + PR link              ▼
   ┌──────┴───────┐                 ┌──────────────┐
   │  Pull req    │◀────── push ────│ agent worktree│
   │  on GitHub   │                 │  (Codex/Kata) │
   └──────────────┘                 └──────┬───────┘
                                           │ crash?
                                           ▼
                                    restart same task
```

The actual board read is unsurprising once you see it. Symphony's poller is essentially this, give or take some retry logic.

```ts
const tickets = await linear.issues({
  filter: { state: { name: { eq: "Agent Ready" } } },
});
for (const t of tickets.nodes) {
  if (!workspaces.has(t.id)) spawnAgent(t);
}
```

That is the whole control plane in spirit. A label on a ticket — `Agent Ready` in the default config — is the signal. Symphony walks the list, checks which IDs already have a live workspace, and spawns one for any that does not. No scheduler, no priority queue, no fairness algorithm. The board is the source of truth, and the poller is dumb on purpose. Change the status to `In Review` and Symphony stops handing it to the agent. When the agent opens a PR, it comments back on the Linear issue with the link, and the loop closes.

The piece I found genuinely surprising is the crash handling. Each ticket gets a worktree, each worktree gets a long-running Codex App Server session, and if the session dies Symphony restarts it on the same task with scratch state preserved on disk. That sounds boring until you realize it is exactly the property that lets you walk away. Most ad-hoc agent setups treat a crash as a failure the human has to triage. Symphony treats it like a Kubernetes pod restart — the agent comes back, reads its worktree and the ticket, and keeps going.

{% github openai/symphony %}

Then v1.1.0 shipped on the heels of the launch and the project stopped being an OpenAI thing. v1.1 added support for [Kata CLI](https://github.com/openai/symphony) — based on the open-source pi-coding-agent harness — which means Symphony is now model-agnostic. Point a workspace at [Claude Code](https://www.anthropic.com/claude-code), at [Gemini](https://deepmind.google/technologies/gemini/), at any CLI that speaks the Kata protocol, and the orchestrator does not care. The ticket flows the same way, crash recovery works the same way, and the PR comes back through the same Linear comment hook. For OpenAI, this is generous. For everyone running a non-Codex stack, this is the real headline.

The natural question is why this needs to exist when the alternatives are so visible. [Codex Cloud](https://openai.com/index/introducing-codex/) lets you fan out tasks from chat, a GitHub Actions matrix can fan out from a labeled issue, and a custom Redis-queue orchestrator takes a weekend to build. I have shipped versions of all three. Codex Cloud is excellent for one-off bursts, but it does not own a backlog — every task is something you initiated in a chat, so you are still feeding the queue. Actions matrices are great for parallelism, but the unit of work is a workflow run, not a long-lived agent that survives across runs; the moment a job exceeds 6 hours or needs to ask a question, the abstraction snaps. Custom orchestration solves both, but you rebuild ticket state, worktree management, restart logic, and PR linkage from scratch, and the bus factor is one. Symphony's contribution is not novel infrastructure. It is a reference shape — board, poller, workspace, PR, with crashes as a non-event — small enough to fork and opinionated enough to copy.

Now the 500% number, honestly. The figure comes from OpenAI's own [launch post](https://openai.com/index/open-source-codex-orchestration-symphony/) and refers to internal teams measuring landed PRs across roughly three weeks of Symphony usage versus their pre-Symphony baseline. That is a real measurement, but it deserves asterisks. The engineers were already deep Codex users with strong ticket hygiene — not the average shop. Three weeks is not long enough to wash out novelty effects, and "landed PRs" rewards small mergeable diffs, which agents happen to be good at. None of this means the number is wrong. It means it is the upper bound, and your team will probably see something smaller, with most of the first month going into ticket-writing discipline rather than code.

My read on why it works, though, is unrelated to model quality. Symphony forces a separation most agent setups blur. The ticket is the spec, the agent is the executor, the human is the reviewer. Once those three roles are pinned to three surfaces — Linear, the worktree, GitHub — context-switching friction collapses. You stop wondering what an agent is doing because Linear answers that. You stop tab-hunting because each ticket has its own workspace. The supervision tax does not vanish, but it moves from continuous to event-driven, and event-driven attention is a different mode entirely. That is the part you cannot buy with a faster model.

What would actually convince you to run this on a real team — your existing backlog, your reviewers, your model of choice — and not just a toy repo on a Sunday?

> The board is the queue, the agents are workers, and the only thing left for me to do is write the ticket and merge the PR.

---

Sources: [OpenAI launch post](https://openai.com/index/open-source-codex-orchestration-symphony/) · [Symphony repository](https://github.com/openai/symphony) · [Help Net Security](https://www.helpnetsecurity.com/2026/04/28/openai-symphony-codex-orchestration-linear/) · [InfoWorld](https://www.infoworld.com/article/4164173/openais-symphony-spec-pushes-coding-agents-from-prompts-to-orchestration.html) · [Codex harness internals](https://openai.com/index/unlocking-the-codex-harness/) · [Codex changelog](https://developers.openai.com/codex/changelog)
