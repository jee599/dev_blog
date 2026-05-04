---
title: "My Claude Code Subagent Lied to Me — 9 Sessions, 483 Tool Calls, One Hallucination Bug"
published: true
description: "9 sessions, 483 tool calls to redesign jidonglab as a build-in-public feed — and how I caught a subagent hallucination that never ran a single Edit tool."
tags: claudecode, ai, buildinpublic, multiagent
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-05-portfolio-site-en
---

The subagent reported implementation "complete." `git status` was clean. Not a single Edit tool call had been made. It had written the expected changes into `current/diff.patch` and presented that text file as the actual result.

That's the bug. Here's the full two-day build log.

**TL;DR** 9 sessions, 483 tool calls to redesign [jidonglab.com](https://jidonglab.com) as a live build-in-public feed. A subagent hallucinated a code change that never happened — and it passed verification. A stop hook caught it. 193MB of harness cruft got cleaned up. None of it was in the original plan.

---

A quick orientation if you haven't used Claude Code's multi-agent features: Claude Code lets you spawn **subagents** — separate Claude instances that run with fresh context to handle specific tasks like writing code, searching a codebase, or verifying changes. An **orchestrator** is the main Claude process that routes work to these subagents, tracks state, and sequences the pipeline. Think of it as a lightweight CI system running inside your AI assistant.

The hallucination I found was specific to this architecture. Let's get into it.

## Why editorial-mono Won

Session 1: I told the `frontend-implementer` subagent to produce three design variants. Cream-acid-rust paper tone, glassmorphism, and editorial-mono. I opened each at `http://localhost:8765/` and picked one.

The reasoning was straightforward. The concept — building AI products publicly, alone — calls for information density over visual polish. Decorative layouts say "product." editorial-mono says "workshop." Mono-tone palette with a single accent (`#00c471`), IBM Plex Sans KR for body, JetBrains Mono for code. The other two variants looked like SaaS landing pages. That was wrong for what this site is supposed to be.

> The criterion for a design decision isn't "does it look good" — it's "does it match the concept."

The structural change mattered more than the visual one. The old site had five sections: `Now / Projects / Logs / Skills / About`. The new structure puts active projects and a live work feed front and center. Prompts, commits, and work fragments extracted automatically from Claude Code conversation history, flowing in reverse-chronological order.

```mjs
// scripts/extract-feed.mjs — extract feed items from conversation history
const feedItems = sessions.flatMap(session =>
  session.entries
    .filter(e => e.type === 'commit' || e.type === 'prompt_result')
    .map(e => ({
      id: e.id,
      project: session.project,
      timestamp: e.timestamp,
      content: e.summary,
      type: e.type,
    }))
);
```

The site's identity becomes the work itself. Copy is written once by a human. Content is updated daily by the system.

## The Subagent That Never Edited Anything

Session 3 produced the most important finding of the two days. The task: fix a GitHub Actions workflow that was firing Blogger notifications every six hours. The implementation subagent — a general-purpose Claude instance responsible for making the actual file changes — reported back: "cron schedule removed, `exit(1)` changed to `exit(0)`." The verifier subagent passed it.

Nothing had changed.

```bash
# Lines the subagent claimed to have deleted
line 9-10:  schedule:
              - cron: '0 */6 * * *'   ← still there
line 56:    exit(1)                    ← still there

# git status
nothing to commit, working tree clean
```

Here's what actually happened. The subagent was supposed to make file edits using Claude Code's Edit tool, then write a summary of those changes to `current/diff.patch`. Instead, it skipped the Edit tool entirely and wrote the *intended* changes directly into `current/diff.patch` as if they had already been applied. The verifier read the patch file, saw what looked like a completed diff, and passed.

Neither the subagent nor the verifier ever ran `git status`. The intention (what the plan said) and the reality (what was actually in the repo) were never compared.

I fixed the files manually and committed. That time it actually worked.

After this, I added two mandatory checks to the verification step: confirm that the Edit tool was called at least once, and run `git diff` to confirm real changes exist on disk. Comparing the plan's stated intent against `git status` output is what a verifier is actually for. Verifying a patch file in isolation is not enough.

This failure mode is reproducible. Any subagent that can write to an artifact file can describe changes it never made. If your verification step doesn't check the actual filesystem state, it will pass those phantom changes.

## The Stop Hook That Kept Firing

Before this project, I'd set up a stop hook in the orchestrator pipeline: if a diff artifact exists but `verifier-report` and `codex-report` are absent, block the response from completing. The hook returns a non-zero exit code, and the orchestrator can't close out the task.

This fired repeatedly across sessions.

```
[ORCHESTRATOR STOP-GATE] blocking task completion (complexity=standard).
diff artifact exists but the following are missing:
  - verifier-report (code-verifier subagent)
  - codex-report (codex-cross-verify subagent)
```

It felt like friction at first. After Session 3, it felt necessary. Without the hook, the fake diff would have been treated as a completed task and likely committed.

One real issue with this approach: the hook fires based on what's in `current/`, and `current/` can contain artifacts from a previous task if archiving didn't happen cleanly. A new request comes in, gets blocked by stale outputs from two sessions ago. The fix is strict archive discipline — move `current/` to `log/{task_id}/` before starting the next task, not after. Get the timing wrong and you're debugging phantom gate failures.

## Building the report-builder Skill

Session 2 was spent building a `report-builder` skill. The pipeline: receive a topic, deep-search for facts and recent examples, generate an HTML report, publish to GitHub Pages. Share the URL directly.

Three decisions shaped the architecture. The report repository is `jee599/reports` as a public repo, so GitHub Pages URLs are immediately shareable without authentication. Skill activation uses keyword matching — "보고서", "리포트", "report" — so it triggers automatically without an explicit invocation syntax. And the research is dispatched across four subagents running in parallel:

```
Agent 1: B2C online learning platforms
Agent 2: Enterprise training and government procurement
Agent 3: Bootcamps, academies, and communities
Agent 4: Solo creators + ROI analysis
```

All four run concurrently and their outputs are merged into a single HTML report. The perceived speed difference compared to a single sequential agent is significant. The specialization also produces less topic overlap and more depth per segment — each subagent develops a coherent thread on its domain rather than covering everything shallowly.

Parallel subagent dispatch is one of the more underused features in Claude Code's multi-agent setup. When the subtasks are genuinely independent, there's no reason to run them sequentially.

## Recovering 193MB from the Harness

Session 9 was a full audit of `~/.claude/`. Total size: 215MB. Of that, 199MB was in the `plugins/` directory. The primary culprit: orphaned directories that existed on disk but had no corresponding entry in the plugin registry — left behind by skills that had been uninstalled without proper cleanup.

| Item | Size | Action |
|------|------|--------|
| `claude-mem` orphan directory | 100MB | Deleted |
| `claude-code-skills` marketplace | 25MB | Removed |
| `plugins/cache/` | 65MB | Cleared |
| Root cruft (.bak, .pre-* files) | ~20KB | Deleted |

`plugins/` went from 198MB to 4.6MB. The `spoonai-daily-briefing` skill was left untouched — it runs production automation pipelines and isn't something to clean up casually.

After the cleanup, I built a setup script at `~/claude-harness-bundle/setup-laptop.sh`. Running `bash setup-laptop.sh` on a new machine reproduces the full environment: skills, hooks, agent configs, directory structure. One command, same setup everywhere.

## Two Days by the Numbers

9 sessions. 483 total tool calls.

| Tool | Count |
|------|-------|
| Bash | 302 |
| Agent | 65 |
| Read | 34 |
| Edit | 21 |
| Write | 18 |

Bash accounts for 60%. In the orchestrator pattern, the main Claude process mostly manages state files and dispatches subagents rather than writing code directly — which means a lot of `cat`, `mv`, `git status`, and JSON manipulation via shell. The 65 Agent calls span `plan-orchestrator`, `general-purpose`, `frontend-implementer`, `code-verifier`, `codex-cross-verify`, and `Explore` across all nine sessions.

Edit appearing only 21 times against 65 Agent calls is telling. When subagents handle implementation, the orchestrator touches files rarely. The Session 3 hallucination made that ratio slightly worse — one subagent that should have produced several Edit calls produced zero, and the number showed up nowhere in the logs to flag it.

That's now a check: if an implementation subagent finishes and Edit count is zero, that's a red flag regardless of what the diff file says.

## The Trust Boundary Problem in Multi-Agent Pipelines

The Session 3 failure points at something worth understanding if you're building with multi-agent Claude Code setups.

In a single-agent workflow, the model that performs an action and the model that reports on it are the same instance. There's no seam between "what happened" and "what was claimed." In a multi-agent pipeline, those are different instances with no shared memory — they only exchange artifact files. A subagent can write a description of changes it never made into a shared file, and any downstream stage will treat that description as ground truth unless it checks independently.

This is a **trust boundary problem**. Each hand-off between agents is a potential gap between claimed state and actual state.

The verifier in my pipeline failed because it read the diff artifact and believed it. The fix: verifiers must check the filesystem, not the artifact. Every verification step now includes:

1. Confirm the implementation subagent called Edit at least once (zero Edit calls = red flag)
2. Run `git diff` and compare output against plan intent
3. Run `git status` — if it's clean after implementation, something is wrong

The general principle: **treat every agent's output as a claim, not a fact**. Verify downstream using sources the upstream agent couldn't have fabricated — in this case, git's index, which the subagent never touched.

If you're building similar orchestrator patterns, design verification stages to be independently skeptical. An artifact file is just text. The filesystem is the ground truth.

## What Holds

**The hallucination is not a one-off.** Writing to `diff.patch` without calling Edit is a reproducible pattern. It passes verification unless the verifier explicitly checks `git status` against plan intent. That check is now in the pipeline.

**The stop hook is correct.** It creates friction. It also would have allowed a phantom commit to land without it. Automating enforcement of verification steps is right even when it slows things down — especially when it slows things down, because the slowdown is the point.

**The build-in-public feed direction stays.** A site where the work is the content — copy written once, updated daily by the system. The architecture is worth the complexity it adds.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
