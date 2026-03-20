---
title: "4 Parallel Agents, 197 Tool Calls: Rebuilding Pikachu Volleyball's Physics with Claude Code"
published: true
description: "A 6-word prompt, 4 parallel agents, 197 tool calls, 1h53m — and one complete physics engine rewrite when the first attempt missed the point entirely."
tags: claudecode, ai, multiagent, gamedev
series: "Building with Claude Code: agentochester"
canonical_url: https://jidonglab.com/posts/2026-03-20-agentochester-en
---

Six words. That's all I typed.

"Make Pikachu Volleyball multiplayer."

One hour and fifty-three minutes later, I had a working multiplayer Pikachu Volleyball game — with the original 1997 physics intact. It took 197 tool calls, 4 parallel agents, one completely wrong first attempt, and reverse-engineering a 27-year-old game's source code to fix it.

**TL;DR** I used agentochester (my Claude Code multi-agent dispatch project) to send 4 parallel agents simultaneously — game designer, frontend developer, backend architect, QA engineer — to build a multiplayer version of the classic game. The first output passed all tests but missed the point: agents built a volleyball game with a Pikachu theme, not the actual 1997 Pikachu Volleyball. Fixing it meant sourcing the original open-source code, extracting the physics constants, and rewriting the engine. Total: 197 tool calls, 1h53m.


## "You Call This Pikachu Volleyball?"

The initial dispatch was clean. Three agents went out simultaneously:

- `game_designer` — write the mechanics document
- `frontend_developer` — build the Next.js + Canvas client
- `backend_architect` — set up the WebSocket server

By the time `qa_engineer` finished, the output looked solid. Build passing. 92 tests passing. Server type-check clean.

Then I opened the game.

The problem was obvious in the first 10 seconds. Wrong physics. Wrong sprites. Wrong feel. What the agents built was a volleyball game starring Pikachu — not Pikachu Volleyball. There's a meaningful difference.

The original game shipped in 1997. It has a very specific physics model: the ball arc, the spike detection window, the jump curve. Players who grew up with it have muscle memory for exactly how the ball behaves. None of that existed in the first attempt. The agents had never been told about it, so they built what "volleyball game" means from first principles.

If you've ever run multi-agent Claude Code sessions and gotten technically correct but contextually wrong output, this is exactly that failure.

Each agent optimized for its own interpretation of the task. `game_designer` wrote a generic volleyball ruleset. `frontend_developer` built to that spec. The shared context — "this must match the 1997 original" — was never defined because I never said it.

Fast output with misaligned direction is still wasted work.


## Finding the Original Source

The approach changed here. Instead of patching the existing implementation, I asked the agent to find the original Pikachu Volleyball source and extract the physics.

The original game is open source (shoutout to `gorisanson/pikachu-volleyball`). The agent pulled the source, analyzed it, and returned a comparison: our implementation vs. the original, constant by constant. Ball initial Y position. Spike detection threshold. Jump curve parameters. Every one of them was off.

The diffs weren't large — a few magic numbers, a couple of state flags — but those numbers *are* the game. Change the ball arc by 10% and the feel is completely different.

Two new agents went out in parallel:

- `Rewrite server` — implement original physics
- `Rewrite client` — sync sprites + physics

Both finished with TypeScript strict mode passing and a clean build.

After that, I moved everything to its own repo. Files in `~/agentochester/pikachu-volleyball/` transferred to a new GitHub repo. The prompt: "create a workspace and move all Pikachu Volleyball code there." The agent handled git init, remote setup, and file migration without further direction.


## Reverse-Engineering the Controls

Once the base physics were right, edge-case bugs surfaced. Aerial diving was triggering when it shouldn't. Enter key wasn't registering as a spike. Frame rate was dropping below 60fps.

I asked: "Does the original source handle this? Jump state shouldn't allow aerial dive. Enter + direction should spike toward that direction."

The agent read the full original source and produced a side-by-side comparison for every relevant piece of logic. The original implements 8-directional spiking via arrow key state at the moment of contact. Jump state was tracked with a separate flag that blocked the dive input. Neither existed in our version.

One prompt: "verify against all source files and implement correctly."

The agent rewrote `engine.ts`, `input.ts`, and `game.ts`.


## Breaking Down 197 Tool Calls

The distribution reads as a record of what actually happened in this session:

| Tool | Count | Why |
|------|-------|-----|
| Bash | 84 | Build checks, server restarts, port cleanup |
| Read | 48 | Original source analysis |
| Edit | 36 | Bug-fix iterations |
| Write | 17 | New files (server, client, types) |
| Agent | 12 | Parallel dispatches |

Bash dominated because of environment churn. Port 3001 kept getting held by previous processes — kill and restart cycles alone accounted for a significant chunk. That's invisible when you're moving fast but shows up in the totals.

Read at 48 reflects the reverse-engineering phase. The agent read every relevant file in the original codebase before touching ours. Understand first, change second.

Edit at 36 means the physics fine-tuning loop ran more times than expected. Each iteration was a read → test → edit cycle.

Agent at 12 looks small, but each `Agent` call is itself a session. Those 12 calls contain the actual implementation work. The 197 represents the orchestration layer only.


## What agentochester Actually Does

The project is a Claude Code multi-agent dispatch CLI. The core mechanic: take a prompt, decompose it into roles, dispatch agents in parallel.

The task decomposer takes natural language and returns structured JSON:

```json
[
  {"role": "frontend_developer", "action": "Implement blog site with Next.js + Tailwind CSS"},
  {"role": "seo_specialist", "action": "Optimize meta tags, Open Graph, sitemap.xml"},
  {"role": "ui_designer", "action": "Review layout, typography, responsive design"}
]
```

Roles like `frontend_developer`, `backend_architect`, `qa_engineer`, `security_engineer` are predefined. Complex requests get decomposed into these roles and dispatched simultaneously. The parallel execution is real — a project skeleton comes together substantially faster than sequential work.

This session was the first time I tested the system on a game development task with a known reference. Parallel execution worked. The failure was in the shared context layer. The dispatcher splits work efficiently, but without a shared spec, each agent optimizes for a different interpretation of the same prompt.

The AI automation principle here is simple: speed doesn't help if direction is wrong. Parallel agents amplify both correct and incorrect assumptions.


## What Changes Next

Before dispatching agents on any task with a known reference — a game, an existing product, a spec document — create the shared context document first. Pass it to every agent alongside the role assignment.

"Implement multiplayer Pikachu Volleyball" is ambiguous. "Implement multiplayer Pikachu Volleyball — physics must match the 1997 original, reference `/docs/physics-spec.md`" is not.

The 1h53m would have been shorter. The rewrite phase wouldn't have been necessary. The original source analysis would have happened before implementation, not after.

agentochester needs a context layer: a place to define constraints that every agent in a dispatch receives. That's the next build.

> Build shared context before parallel dispatch. Fast without direction isn't fast — it's expensive redirection.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
