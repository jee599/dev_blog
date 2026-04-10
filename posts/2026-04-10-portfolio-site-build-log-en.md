---
title: "How I Generated a 288-Page SEO Implementation Plan in 10 Minutes with Claude Code"
published: true
description: "Claude Code's writing-plans skill produced a 288-page SEO plan in 10 min — 23 tool calls, 13 reads, 3 parallel agents. Planning first is always faster."
tags: claudecode, ai, webdev, productivity
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-10-portfolio-site-en
---

Asking Claude Code to implement 288 pages directly would have taken hours. Asking it to write a plan first took 10 minutes — and zero source files were modified in the process.

**TL;DR** The `writing-plans` skill makes Claude Code read the entire codebase before touching a single file, then produces a standalone, execution-ready plan. Separating planning from implementation is consistently faster end-to-end.

## 288 SEO Pages and a Spec Doc That Won't Tell You Where to Start

The `saju_global` project needed SEO landing pages for zodiac compatibility. 12 zodiac signs × 12 zodiac signs = 144 combinations, doubled for directionality = 288 pages. A spec doc existed, but the questions that actually matter before writing code were unanswered: which files to touch, how to integrate with existing routing, how to fit the new pages into the content collection schema.

The prompt was deliberately minimal:

```
Implement 288 SEO compatibility landing pages in the saju_global project.
Spec: docs/superpowers/specs/2026-04-09-seo-compatibility-pages-design.md
```

Jumping straight to implementation from here is a reliable way to end up mid-refactor three hours later. Claude Code loaded the `writing-plans` skill instead.

## What writing-plans Does Under the Hood

Once the skill loads, Claude Code enters a full context-gathering phase before any implementation begins. In this session: 23 tool calls total — 13 `Read`, 4 `Glob`, 3 `Agent`, 1 `Skill`, 1 `Bash`, 1 `Write`. More than half the session was spent reading, not writing.

Three agents ran in parallel, each exploring a different domain of the codebase:

| Agent | Domain |
|-------|--------|
| #1 | Routing patterns and dynamic route structure |
| #2 | Existing SEO component architecture |
| #3 | Content collection schema and static path generation |

Instead of sequential exploration, all three ran concurrently and merged findings. The resulting plan contains:

- Every file to create or modify, with explicit reasons for each change
- Ordered execution steps guided by DRY and YAGNI
- Verification approach for each phase
- Commit boundaries — how to split 288 pages into reviewable chunks

The skill's core design constraint is "zero context assumed." The plan must be complete enough that a separate agent in a fresh session can follow it without any guidance from you.

## When the Spec File Isn't Where You Said It Was

The first attempt failed: the spec file wasn't at the path I'd provided. Wrong path.

Claude Code didn't stop to ask. It ran `Glob` over `docs/superpowers/specs/`, found the actual file, and continued.

This autonomous recovery comes from a `CLAUDE.md` rule: "Do not ask questions. Make decisions and proceed." A simple directory scan handles most path errors without pulling you into the agent's problem. The interaction stays uninterrupted.

It's a small thing but it changes the working dynamic. You don't get pulled into the agent's confusion; it handles its own environment and calls you only when truly blocked.

## The Output: 1 File Created, 0 Source Files Modified

After 10 minutes and 23 tool calls:

```
docs/superpowers/plans/2026-04-10-seo-compatibility-pages.md
```

One file created. Zero source files modified.

That looks underwhelming until you consider what it enables. The plan documents every architectural decision up front: which dynamic route file to create, how to generate 288 static paths at build time, which SEO component to extend vs. build from scratch, what the content collection schema needs, how to split the work into reviewable commits.

Without this plan, an implementation session for 288 pages means making assumptions under time pressure, pivoting mid-session when those assumptions break, and accumulated drift that's expensive to unwind. An agent that starts coding immediately and discovers a structural mismatch on page 50 of 288 is in a much worse position than one that discovered it during planning.

The session ended with a question from Claude Code: "Subagent-Driven or Inline Execution for the implementation phase?" The plan was done. All that remained was deciding how to run it.

## Why Separating Planning from Implementation Actually Matters

There's a predictable failure mode in AI-assisted coding: the agent receives a request, starts modifying files immediately, hits an unexpected design constraint halfway through, and either rolls back or continues down a path that made sense locally but is wrong globally. In long sessions, this gets worse — the agent has committed to early choices that compound, and the context window fills with work that may need to be discarded.

`writing-plans` → `executing-plans` as separate sessions is a direct fix. Each session has a single responsibility:

- **Planning session**: read, explore, produce a plan. No file modifications.
- **Execution session**: follow the plan. No exploration, no architectural decisions in flight.

If the plan is wrong, you fix the plan — a text file, not a tangled implementation. If a step turns out to be invalid, the execution session surfaces it cleanly rather than having it corrupt downstream steps.

The multi-agent approach also compresses exploration time. Three agents scanning independent parts of the codebase in parallel is roughly 3× faster than one agent doing it serially — and all that work stays in the planning session, not bleeding into execution context.

This isn't a novel principle. It's "design before code" applied to AI coding agents. The interesting part is that the `writing-plans` skill enforces it as a hard constraint — Claude Code cannot start modifying files until the plan is written. The discipline is baked into the workflow, not left to willpower.

## The Numbers

Full tool call breakdown for the session:

| Tool | Count | What it did |
|------|-------|-------------|
| Read | 13 | Routing files, component structures, schema definitions, SEO patterns |
| Glob | 4 | File discovery, directory scanning, pattern matching |
| Agent | 3 | Parallel codebase exploration across three domains |
| Skill | 1 | Loading writing-plans |
| Bash | 1 | Verification |
| Write | 1 | The plan file itself |
| **Total** | **23** | |

Time: ~10 minutes. Files created: 1. Files modified: 0.

The ratio that matters is Read-to-Write: 13 reads before the single write. That's what planning looks like — far more investment in understanding than in producing output.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
