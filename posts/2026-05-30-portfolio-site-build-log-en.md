---
title: "17 Sessions, 440 Tool Calls: Rebuilding the Hermes Dashboard into a Real Mission Control"
published: true
description: "I sent the same prompt 7 times. After 17 sessions and 440 tool calls, the Hermes dashboard finally became a real mission control. Here's what went wrong and why brief files fixed it."
tags: claudecode, ai, webdev, javascript
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-30-portfolio-site-en
---

Out of 17 sessions opened, only 5 actually touched a file. The other 12 explored the codebase, hit context limits, retried the same prompt, or returned a single-word status like `CLEAN_OK`. That's a 29% useful-session rate — and it's a completely normal pattern when you're running Claude Code through the Hermes orchestrator.

**TL;DR**: Rebuilt the Hermes local dashboard from a raw-ID display into a proper mission control UI with localized labels, cron output panels, and sequential V2→V3 upgrades. 46 files changed, 440 tool calls across 17 sessions. The real lesson: brief files cut the wasted sessions from 12 to zero.

## Why I Sent the Same Prompt 7 Times

Sessions 1, 3, 4, 5, 7, and 9 all carried essentially the same prompt:

```
Goal: Upgrade the existing Hermes local GUI dashboard into a more visual
mission-control style dashboard for tracking ongoing Hermes/Claude/Codex/Cron work.
```

The loop looked like this: Hermes opens a session → Claude Code spends the session exploring the codebase → hits the context window → the orchestrator decides "that was planning, not implementation" → opens a new session with the same goal.

Session 6 was a `<synthetic>` model that responded only with `Not logged in · Please run /login`. Sessions 8, 10, and 11 were one-liner status checks (`CLEAN_OK`, `CLAUDE_LEAN_OK`, `CLAUDE_FINAL_LEAN_OK`).

Real implementation didn't start until session 12.

This is the core failure mode of open-ended multi-agent prompts. When you give the Hermes orchestrator a vague goal, it interprets exploration as progress. Each session does real work — reading files, understanding architecture, producing a plan — but none of that work persists usably into the next session. The context reconstruction cost gets paid over and over.

## Session 12: Localizing Every Raw ID (49 min, 59 tool calls)

The dashboard was surfacing internal identifiers like `medical-dental-ads-daily-goal`, `telegram-tech-report-html`, and `daily-codex-cli-update` as plain text labels. A user had explicitly complained about this. Session 12's goal was narrow and concrete:

```
Goal: Improve the local Hermes dashboard at http://127.0.0.1:7878 so cron jobs,
skills, sessions, and internal identifiers are explained in clear Korean.
The user specifically complained that entries like `medical-dental-ads-daily-goal`,
`telegram-tech-report-html`, `daily-codex-cli-update` appear as raw text.
```

Codex cross-verification caught two blockers before implementation started. The critical one:

> `CronOutputPanel.tsx` line 161: `{j.name || j.id}` is outputting raw text as the primary label. Need to import `describeCronJob` and display the localized label first.

The fix was a `describeCronJob` helper that maps 7 cron job IDs to human-readable labels. Clean and narrow.

What's interesting here: the main session ran 22 Read calls and 0 Edit calls. All actual file changes were delegated to a `frontend-implementer` sub-agent. The only file the orchestrator session directly modified was `plan.md`. That's Claude Code AI automation working as intended — the orchestrator stays at the planning layer and dispatches implementation down.

## Session 13: V2 Upgrade — and a Security Issue Nobody Asked For (36 min, 93 tool calls)

This is where the brief file pattern first appeared:

```
Read /Users/jidong/.hermes/tmp/hermes-dashboard-v2-brief.md and execute it fully.
Use Opus 4.8 xhigh. Do not modify Hermes Agent source.
Work until verified and committed, or report any blocker.
```

Instead of a goal description, the prompt points at a file. The spec lives in the file. When the session opens, the first thing Claude Code does is read `hermes-dashboard-v2-brief.md` — and then it starts implementing. No exploration loop, no replanning.

While traversing the cron output directory to implement the new panel, the session found something that wasn't on the brief: `~/.hermes/cron/output/<jobId>/<timestamp>.md` files contained a `## Prompt` section with the full prompt text. That means any cron job that included an API key reference, an internal strategy note, or sensitive context would have had that content surfaced directly in the dashboard UI.

The fix was a redaction layer in `allowlists.ts` that strips `## Prompt` sections before serving cron output files.

Files created in session 13: `CronOutputPanel.tsx`, `NowStrip.tsx`, `ActiveWork.tsx`, and a new `/api/cron-output` route. Tool call breakdown: 33 Bash, 31 Read, 17 Edit, 10 Write.

## Session 14: The 2-Hour 20-Minute V3 Full Redesign (122 tool calls)

This was the longest single session. `claude-opus-4-8` xhigh, 2 hours and 20 minutes, 122 tool calls:

```
Read /Users/jidong/.hermes/tmp/hermes-dashboard-v3-brief.md and execute it fully.
Use Opus 4.8 xhigh. Prioritize design quality and human-readable work-progress IA.
Work until verified, committed, and 7878 is restarted if safe.
```

A `[Request interrupted by user]` arrived mid-session. After Codex cross-verification completed, a separate follow-up prompt took over:

```
Codex cross-verification is done and codex-report.md exists. Continue: inspect
the Codex report for any blocking issues. If only minor/non-blocking, do not
over-polish; run final typecheck/build/diff-check, commit with message
'feat: redesign Hermes dashboard work control room', restart the 7878 dashboard safely.
```

New files created in V3:

```
src/
├── components/
│   ├── MissionControl.tsx     # Full layout restructure
│   ├── WorkBoard.tsx          # In-progress work cards
│   ├── AgentProgressPanel.tsx # Claude/Codex agent status
│   ├── CronIssueCards.tsx     # Cron issue card view
│   └── Collapsible.tsx
└── lib/
    ├── workStages.ts          # State → label mapping
    ├── issueTranslator.ts
    ├── workflows.ts
    └── controlRoomTypes.ts
```

The design system from earlier sessions — phosphor annunciator lamps, cool-slate surfaces, semantic glow — was preserved. This wasn't a rewrite; it was a surgical extension. The information architecture changed while the visual language stayed consistent.

Tool breakdown: 39 Bash, 29 Edit, 28 Read, 22 Write.

## Session 15: The Fourth Pass with Workflow Parallelization (44 min, 71 tool calls)

Even after V3, one piece of the original goal was still unmet: making it visually obvious what work is happening right now. Session 15 tackled that, and introduced a new pattern — the `Workflow` tool for fanning out to parallel sub-agents:

```
Build diagrammatic mission-control wall:
contract → parallel components → integrate → typecheck
```

Six agents ran in parallel, each implementing a different component. The main session handled only contract definition and final integration. Read 36, Bash 27.

This is the multi-agent pattern working well: the orchestrator defines the interface contract, dispatches implementation to workers, then integrates. The main context doesn't get polluted with component-level details.

## What 440 Tool Calls Actually Looked Like

| Tool  | Count | Share |
|-------|-------|-------|
| Read  | 191   | 43%   |
| Bash  | 141   | 32%   |
| Edit  | 46    | 10%   |
| Write | 34    | 8%    |
| Agent | 17    | 4%    |
| Other | 11    | 3%    |

Read at 43% is the Opus pattern. Before writing a new component, Claude Code reads 10+ related files. It's slower than just generating something, but the output interfaces correctly with what already exists. The cost of a wrong interface assumption compounds quickly in a codebase with interconnected components.

Bash at 32% is a mix of typechecks, builds, server restarts, and file existence checks. The high Bash count in sessions 13 and 14 reflects the verification-heavy tail of each session — typecheck, build, diff-check, commit, restart.

Agent at 4% (17 calls) represents the sub-agent dispatches: the `frontend-implementer` in session 12, the 6 parallel workers in session 15, and the Codex cross-verification calls.

## Brief Files vs. Open Prompts: The Actual Lesson

Sessions 1 through 11. Zero files modified. Twelve sessions of exploration, planning, and replanning before a single line of production code changed.

The problem with `"Upgrade into a more visual mission-control style dashboard"` as a prompt is that it's a good description of an outcome but a terrible specification for implementation. When the Hermes orchestrator dispatches Claude Code with that goal, Claude does the reasonable thing: reads the codebase, builds a mental model, produces a plan. That plan doesn't make it into the next session. The next session starts cold and does it again.

Brief files short-circuit that loop. When the prompt is `Read /path/to/brief.md and execute it fully`, the session opens, reads the brief, and starts implementing. The spec is the context. There's no rediscovery cost.

> Open-ended goals create exploration loops. An orchestrator will pay the exploration cost on every retry. Brief files collapse that cost to a single file read.

17 sessions wasn't necessary. Starting with a brief file on session 1 would have finished this in 5.

The practical workflow: before dispatching a Claude Code session through Hermes for anything non-trivial, write a brief file first. It doesn't need to be long — the V2 brief that drove session 13 fit in one screen. But it needs to be specific enough that a fresh session can start implementing without rediscovering the codebase.

## What Shipped

The `http://127.0.0.1:7878` local dashboard now:

- Shows all 7 cron jobs with human-readable labels instead of raw IDs
- Serves cron output files with `## Prompt` sections stripped (no accidental secret exposure)
- Displays live Claude/Codex session status cards
- Maintains the phosphor annunciator lamp design system
- Passes typecheck and build clean

29 files created, 17 files modified.

The dashboard went from a developer-only debugging tool to something that actually communicates the state of ongoing AI automation work. That was the original goal. It took longer than it should have, but the brief file pattern is the fix that makes the next project faster.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
