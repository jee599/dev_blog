---
title: "10 Sessions, 1,000+ Tool Calls on Opus 4.7 Launch Day: System Card Analysis, 10 Parallel Mockups, and a Telegram Bot Deadlock"
published: true
description: "On Opus 4.7 launch day: analyzed the 232-page system card, caught a silent breaking change in the thinking API, shipped two articles, and ran 10 parallel design mockups."
tags: claudecode, ai, multiagent, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-17-portfolio-site-en
---

On April 16, Anthropic shipped Claude Opus 4.7. Within hours, I had read the 232-page system card, identified a silent breaking change in the thinking API, written a migration guide, published it to DEV.to and Hashnode, generated 10 parallel design mockups for a separate project, diagnosed a Vercel env bug without touching a single line of code, and traced a Telegram bot deadlock to a stale polling lock held by a dead process.

10 sessions. ~1,060 tool calls. 4 projects running simultaneously.

**TL;DR** — Opus 4.7 dropped `budget_tokens` from the thinking API with no deprecation warning. I caught it on launch day and shipped a migration article. On the same day: 10 parallel design mockups compared in one session, a Vercel newline bug diagnosed in minutes, and a multi-process Telegram conflict resolved without code changes.

## The Breaking Change Nobody Announced

Anthropic released the official system card (232 pages) alongside the model. I fetched the PDF directly with `WebFetch` and read it.

Model ID: `claude-opus-4-7`. Pricing: same as 4.6 ($5/$25 per MTok). Context: 1M tokens. The headline change is thinking mode — and it breaks existing code silently.

Up through 4.6, you set `budget_tokens` directly inside the `thinking` block:

```typescript
// 4.6 — works fine
{
  thinking: { type: "enabled", budget_tokens: 5000 }
}
```

Opus 4.7 switches to adaptive thinking only. `budget_tokens` is gone. Pass it anyway and you get a **400 error** with no helpful message. It's a quiet breaking change — nothing in the changelog, nothing in the migration guide.

```typescript
// 4.7 — remove budget_tokens entirely
{
  thinking: { type: "enabled" }
}
```

That gap was the article. I traced the timeline from The Information's exclusive leak (April 14) through the official release, wrote the migration guide, and used the `auto-publish` skill to push to DEV.to and Hashnode simultaneously. A second article — OpenAI's duct-tape image model situation — ran in parallel, with separate agents handling each piece.

Session 4 stats: 74 Bash calls, 8 WebFetch calls, 8 Edit calls, 10 TaskUpdate calls.

## Why I Generated 10 Design Mockups Instead of Picking One

The spoonai design refactor was a 3-hour session (session 8, 383 tool calls). Two bugs, one design direction to settle.

The image bug was obvious once I read the code. The `ArchiveEntry` type didn't have an `image` field at all. `getArchiveEntries()` was returning `date`, `title`, and `summary` — and silently dropping `meta.image`. The images weren't broken. They were never rendered.

The design direction was less obvious. Instead of proposing a single layout and iterating on feedback, I dispatched 10 agents in parallel, each producing a full HTML mockup:

```
agent 1 → bento-grid
agent 2 → masonry (pinterest-style)
agent 3 → neo-brutalism
agent 4 → swiss tabular
agent 5 → japanese kinfolk
agent 6 → netflix cinema
agent 7 → Y2K chrome
agent 8 → dashboard ticker
...
```

Each agent generated a self-contained HTML file. All 10 ran locally for side-by-side comparison. When the feedback came back as "none of these," the time cost of that decision was already near zero. We landed on masonry, then worked through `ArticleCard`, `HomeContent`, `SubscribeForm`, and `globals.css` in sequence.

Mobile was in the brief from the start — each agent was told to render both desktop and phone frames.

## The Vercel Password Bug That Wasn't a Code Bug

Session 3: a saju project admin login stopped working. Password `920802`, correct credentials, 401 on every attempt.

The `.env` file was fine. I checked the Vercel dashboard and found `ADMIN_PASSWORD="920802\n"` — a trailing newline had been saved alongside the value. The user types `920802`, the server compares against `920802\n`, gets `!==`, returns 401. Not a code bug. An input artifact.

Diagnosis: 10 Bash calls, 5 Read calls. Fix: re-enter the value in the Vercel dashboard. No code touched.

## Tracing a Telegram Bot to a Dead Process Holding a Polling Lock

Debugged twice — sessions 5 and 9. Symptom: messages from Claude to Telegram worked fine, but messages from Telegram back to Claude weren't arriving in the active session.

Root cause: multi-process conflict. Each Claude session spawns its own `bun server.ts`. Telegram long polling only allows one active connection per token — `getUpdates` returns `409 Conflict` on concurrent calls. When a dead session's process still holds the polling lock, the live session never receives incoming messages.

```bash
ps aux | grep "server.ts" | grep -v grep
# → PID 15622 (3-hour-old dead process)
# → PID 31885 (active process, different session)
```

Fix: kill all `server.ts` processes, then run `/reload-plugins` to let the current session re-acquire the bot. The underlying issue recurs whenever multiple Claude sessions are open simultaneously.

## contextzip Self-Improvement: A CLI Proxy That Cuts Token Usage

Session 10 (249 tool calls) was spent improving contextzip itself. contextzip is a CLI proxy that intercepts common commands like `git` and `npm`, filters out noise, and reduces token consumption in Claude context windows.

I pulled the latest upstream source and layered in new features. Validation ran across 4 parallel sub-agents:

```
agent → playwright_cmd validation
agent → new filter effectiveness analysis
agent → DSL extension feasibility review
agent → context-history layer architecture review
```

Each agent read the code independently and returned a punch-list. Faster than reading it myself, and cheaper on context.

## Harness × Hermes: Deep Research via Parallel Agents

Session 6: parallel deep research on "Claude Code harness design" and the "Hermes agent framework" — two sub-agents each, four running simultaneously.

Two findings mattered. First, Anthropic's official guidance on harness design is **minimalism** — add only after observed failures. At that point, `~/.claude/` had grown to 82 lines of CLAUDE.md, 92KB of MEMORY, and 20+ skills. Heavy. Second, symlinks in `~/.claude/agents` were broken, silently preventing custom sub-agent loading.

Based on the research, I generated 4 hooks (`commit-cleanliness.sh`, `protect-files.sh`, `sticky-rules.sh`, `trajectory-log.sh`), 2 agent files, and 3 commands.

## By the Numbers

| | |
|---|---|
| Sessions | 10 |
| Total tool calls | ~1,060 |
| Longest session | Session 8 (3h 6min, 383 calls) |
| Parallel design mockups | 10 |
| Parallel research agents | 4 |
| Files modified | 40+ |

Running 4 projects in parallel on a single day isn't possible without agent parallelization. The design mockup comparison alone would have taken half a day in a sequential workflow. With 10 agents running simultaneously, the comparison took the same time as generating one.

The pattern that made this day work: agents don't just execute tasks — they absorb the iteration cost. Every round of "try 10 options" that used to take hours becomes a single parallel dispatch.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
