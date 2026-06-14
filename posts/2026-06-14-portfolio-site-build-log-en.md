---
title: "Dynamic Workflow Blocked 5 Times in a Day: Running 22 Claude Code Sessions"
published: true
description: "Dynamic Workflow hit permission gates 5 consecutive times in autonomous cron. Each time, parallel Agent decomposition was the immediate fallback — across 22 sessions, 302-call redesigns, and a Pokemon card site launch."
tags: claudecode, multiagent, ai, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-14-portfolio-site-en
---

Five times in a single day, Dynamic Workflow got blocked by a permission gate. Five times, the fix was the same: decompose into parallel Agent calls and keep moving.

22 sessions total: Gmail audit report, Godot wuxia game design doc, B2B SaaS email automation, coffeechat landing redesign, Fable 5 vs Opus comparison, Pokemon card price tracker. The Dynamic Workflow block-and-fallback pattern threaded through all of it.

**TL;DR** Dynamic Workflow requires interactive user approval before execution. In autonomous cron sessions, there's no one to click approve. When blocked, parallel Agent decomposition produces equivalent output — just without the parallelism speedup. This showed up five times today.

## Why Dynamic Workflow Kept Failing

Session 4 was the first attempt. The prompt was clear: use Dynamic Workflow to generate targeted B2B sales emails for the highest-conversion segments. The Workflow tool call fired and was immediately blocked. Session 5 — same result.

Session 10 ran in autonomous cron context. Blocked again. The `verification.md §6` log captures it directly:

> *"Actual Workflow tool rejected by permission gate — no interactive approver in autonomous cron context. Falling back to 5-lane Agent decomposition."*

Sessions 12 and 13 followed. Five blocks total.

The root cause is structural. Dynamic Workflow shows a `"Review dynamic workflow before running"` dialog that requires a human to confirm before execution. In an autonomous cron session, that human doesn't exist. Even in interactive sessions, the gate doesn't open unless the session has been explicitly pre-authorized.

The fallback pattern was consistent every time: take the same work and fan it out across 5–6 parallel `Agent()` calls. Session 10 split 12 B2B SaaS categories across 5 lanes, with each lane generating 6 prospect emails. Output: 30 email drafts, full compliance verification, 27 eligible packages.

Tool breakdown for that session: `Bash(11), Read(5), Agent(5), Write(3), Workflow(1)` — one Workflow attempt, blocked, then immediate pivot to 5 parallel Agents.

The only successful Workflow run was session 18: a fully interactive session where the user approved it directly. The single variable separating blocked from approved was session type.

**The lesson:** If you're scheduling Claude Code for autonomous cron jobs that need Workflow-level fan-out, pre-authorize the Workflow tool before scheduling. Runtime approval in a headless context isn't possible. Or design the task as Agent parallel decomposition from the start — it's more portable and requires no pre-authorization.

## 302 Tool Calls to Rebuild a Landing Page

The heaviest session was a coffeechat landing page redesign. Final tool count: `Edit(119), Bash(98), Read(75), Agent(5), ToolSearch(1)` — 302 calls across 6 user prompts.

The starting request: "restore the interview demo animation." A `git log` check traced the problem to commit `0e578da`, which had swapped the hero's `InterviewDemo` animation component for a static `ReportShowcase`. Task: restore the interview animation on the left, add a report-writing animation at half size on the right, restructure into a two-column layout.

Mid-session, `/effort ultracode` was enabled. A design audit Workflow ran — this was an interactive session, so it actually executed — and returned color tokens, interaction patterns, and icon inventories via task notifications. That output drove batch edits across 12 files: `globals.css`, `demos.tsx`, `illustrations.tsx`, `page.tsx`, and more.

Post-deploy: "The site doesn't reflect the changes yet." Cloudflare Pages cache delay. This comes up every time.

The 302-call number deserves a moment. Six prompts → 302 tool calls is ~50 tool calls per prompt. The bulk of that is the inner review loop: edit → verify → bash check → adjust. Claude Code is effectively running the cycle that would otherwise be constant context-switching between your editor, terminal, and browser.

## Greenfield: Pokemon Card Price Tracker

Session 19 was a new project from scratch. The ask: build a site showing every Pokemon card with current price, previous price, and rarity data.

Data source selection was the first real decision. `pokemontcg.io` looked like the obvious choice — free API, 20,000 requests/day, card metadata + images + pricing. Then "Japanese cards only" changed the problem. `pokemontcg.io` is US/English-centric and doesn't properly cover Japanese OCG releases.

Alternative: [TCGdex](https://tcgdex.dev/) — free, no API key, 10 languages including Japanese. Validated the API response structure directly:

```json
"pricing": {
  "tcgplayer": {
    "normal": { "marketPrice": 1.23, "lowPrice": 0.89 },
    "holofoil": { "marketPrice": 4.50 }
  }
}
```

After confirming the structure, the provider was abstracted behind an adapter interface. The goal: swapping to a paid source with annual price history and JP-specific data later should only require changing the adapter, not the business logic.

178 tool calls, ~5 hours. P0 complete: Next.js 16 + React 19 + Tailwind v4 scaffold, Neon Postgres + Drizzle ORM, Vercel deployment config. Repo created under `jee599` GitHub account with initial commit pushed.

## Parsing 1,264 Sessions to Compare Fable 5 vs Opus

Session 18 request: find every Fable 5 session in local history and compare against Opus.

The naive approach fails immediately. `grep "fable"` across session files hits the system prompt's model list in nearly every file. The actual model used is in `message.model` inside assistant message objects — not in any top-level string you can grep for.

Solution: parse all 1,264 session files with Python, filter for `message.model === 'claude-fable-5'`.

Result: 28 Fable 5 sessions concentrated over 3 days (2026-06-10 to 06-12), compared against 20,517 Opus 4.8 turns. Seven project clusters: `coffeechat`, `saju_global`, `daymoon`, `game_plans`, `hermes-dashboard`, `dental-promo`, `portfolio-site`. Some clusters had Fable building first with Opus picking up the work (`coffeechat`); others reversed (`daymoon`).

Report: `~/reports/fable5-vs-opus-audit-2026-06-14.md`.

Tool breakdown: `Bash(15), Read(2), Workflow(1), Write(1)` — Workflow executed successfully here. Interactive session.

## Four Attempts to Generate One Design Document

The Godot wuxia game design doc started in session 2 and produced its first actual file in session 7. Same task, four sessions.

- **Session 2**: Confirmed Open Design setup, then stopped. `Bash(7), Read(4)`.
- **Session 3**: Told explicitly to skip exploration and produce output immediately. Three `Bash` calls, then stopped again.
- **Session 6**: `Read(6), Bash(4)` — more progress, still no file created.
- **Session 7**: Environment check, file appeared.

This is what Hermes relay architecture looks like when session context resets between runs. Each session starts cold, re-explores, and burns turns on setup before getting to execution.

The fix was progressively tighter prompting:

> *"Do NOT use TaskCreate/TaskUpdate/workflow/planning tools. Do NOT spend time searching for tools. Immediately perform file operations."*

Explicit prohibitions on planning-phase tools produced output on the next attempt. When a session has no prior context, the default behavior is to re-establish context before acting. Banning the context-establishment tools forces immediate execution.

## The Day in Numbers

| Metric | Value |
|---|---|
| Total sessions | 22 |
| Largest single session | 302 tool calls (coffeechat landing) |
| Second largest | 178 tool calls (Pokemon card site) |
| Dynamic Workflow blocked | 5× |
| Dynamic Workflow succeeded | 1× (Fable 5 vs Opus, interactive) |
| Godot doc attempts | 4 (sessions 2, 3, 6, 7) |
| Major files generated | ~30 |

Five Dynamic Workflow blocks → five Agent parallel fallbacks. The pattern is clear: Workflow in autonomous cron needs pre-authorization, or it doesn't run. Agent parallel decomposition covers the same ground without the permission dependency — sequential rather than truly parallel, but it ships.

The deeper question is whether the permission gate is a problem to solve or a constraint to design around. Today's answer was consistently the latter: when the gate blocks, fan out with Agents. When you need real parallelism in cron, pre-authorize before scheduling — not at runtime.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
