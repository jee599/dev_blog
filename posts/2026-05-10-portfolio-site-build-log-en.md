---
title: "5 Parallel Claude Code Agents, One Hard Pivot, and a SRI Bug Only Codex Found (79 Tool Calls)"
published: true
description: "Dispatched 5 parallel frontend-implementer agents for a coffee chat redesign. Got rejected. Pivoted to education platform tone. Codex caught a SRI hash mismatch code-verifier missed. 79 tool calls."
tags: claudecode, ai, multiagent, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-10-portfolio-site-en
---

The brief was one line: "Redesign the coffee chat site. Give me at least 5 options."

No reference imagery. No target user. No mood direction. Just that.

**TL;DR** Dispatched 5 `frontend-implementer` agents in parallel to generate simultaneous redesign variants for a coffee chat mentoring site. Got "none of these feel professional" feedback, reworked the entire brief around education platform trust signals, ran another 5 in parallel. Codex cross-verification (`codex-cross-verify`) then caught a SRI hash mismatch across 4 files that `code-verifier` had missed — production React would have been silently blocked in every modern browser. 79 tool calls total.

This is a build log from my Claude Code multi-agent workflow. I orchestrate from a main session, dispatch specialized subagents for parallel or isolated tasks, and use Codex as an external cross-verification layer after internal verification passes.

## The Problem with Starting Blind

Jumping straight to 5 designs from a vague brief produces exactly what you'd expect: generic templates that could belong to any product in any industry.

The first real step was running `WebFetch` on the site to understand what it actually was. Not a general networking app — a **1:1 mentoring platform for the Korean game industry**. Current studio employees meet with job seekers for coffee chats, resume reviews, and mock interviews. That's the core product.

With that context captured in `plan.md`, a `general-purpose` agent defined 5 distinct design directions and wrote specs detailed enough that each `frontend-implementer` could run without making judgment calls. Then all 5 went out in parallel:

| Variant | Direction | Key Characteristics |
|---------|-----------|---------------------|
| V1 Editorial Magazine | Korean indie editorial | Serif type, cream background `#f4eee4` |
| V2 Soft Brutalist | Bold borders + pastel accent blocks | High typographic contrast |
| V3 Premium Dark | Motion-heavy | Floating gradient blobs, `@keyframes drift` |
| V4 Neo-Minimal | Clean, information-dense | White base, Inflearn-adjacent layout |
| V5 Retro Arcade | Game industry identity | Pixel aesthetics, nostalgia cues |

Five agents, running concurrently, each building a different visual direction from a clean context.

## "None of These Are Any Good"

All 5 variants came back. The response was blunt: "None of these feel professional. Not one. Go look at Inflearn or similar education platforms."

The problem was visible in retrospect. Every variant had explored aesthetic differentiation — editorial typography, motion gradients, brutalist grids — without touching the actual gap: **educational platform trust signals**. Inflearn and FastCampus don't lead with visual novelty. They lead with credibility, structure, and evidence that the platform has delivered real outcomes.

By anchoring the brief to the game industry identity, the designs had skipped the trust layer that a first-time visitor needs before booking a session with a stranger. They were visually interesting in the way a design portfolio piece is interesting — not in the way that makes someone think "I could trust this platform with my job search."

Reclassified the complexity, rebuilt the plan with education-service credibility as the explicit north star, defined 5 new variants grounded in an Inflearn site analysis, and ran another parallel batch.

## The Bug Codex Found That code-verifier Missed

After round two, `design-reviewer` ran a review pass. Then `codex-cross-verify` ran — and a critical bug surfaced.

Variants V2 through V5 all loaded `react.production.min.js`, but the SRI (Subresource Integrity) hashes in each `<script>` tag were computed from `react.development.js`. When SRI validation fails, the browser blocks the script entirely. The pages looked visually complete — the HTML rendered, the CSS applied — but React wouldn't have loaded in any production browser.

```html
<!-- Bug: production file URL, development build hash -->
<script
  src="https://unpkg.com/react@18/umd/react.production.min.js"
  integrity="sha384-[hash computed from development.js]"
  crossorigin="anonymous"
></script>
```

Production and development builds have different file contents: different minification, source maps stripped, tree-shaking applied differently. Different contents → different SHA-384 hashes. SRI validation is a byte-level comparison — the browser fetches the file, hashes it, and compares against the declared value. One bit off and the script gets blocked.

This doesn't surface in ESLint. It doesn't show up in a design review or a visual regression test. It surfaces when something reads the file with enough context to know what the hash values are *supposed* to reference.

`code-verifier` had missed it — the tooling runs at lint/typecheck level and doesn't cross-reference CDN file hashes against build variant. Codex caught it by reading the diff and checking hash values against the correct build target. All 4 files were updated with the correct production hashes immediately.

If this had shipped, every user with SRI enforcement enabled (every modern browser) would have hit a silently broken experience. No interactive elements, no console errors surfaced to the end user, no obvious signal that something had gone wrong.

## What Makes Parallel Dispatch Actually Work

Five sequential variants take 5× as long as one. Five parallel variants take as long as the slowest single agent. The speedup is obvious. The less obvious requirement is what enables it.

Each `frontend-implementer` agent starts with no shared state and no coordination channel with the others. For all 5 to run independently without stepping on each other or producing near-identical results, `plan.md` has to resolve every decision each agent would otherwise have to make for itself.

The difference:

```
Vague: "Make it look professional and modern."

Specific: "V3: motion dark. Background #0a0a0f.
Hero uses floating gradient blobs via @keyframes drift.
Canvas particle effect behind CTA.
Font: Space Grotesk headings, Inter body.
No light mode variant."
```

Vague briefs produce agents that either fill gaps with assumptions (inconsistent outputs across variants) or pause to ask questions (losing the parallelism entirely). Specific specs produce agents that execute. The planning agent that built `plan.md` before the dispatch was not overhead — it was the precondition for everything else working.

## Tool Call Breakdown

**Session 1 — Coffee chat redesign (79 tool calls):**

| Tool | Count | Purpose |
|------|-------|---------|
| `Agent` | 28 | Subagent dispatch — 2× rounds of 5 parallel implementers, plus orchestration and verification |
| `Bash` | 26 | `diff.patch` generation, state updates, file moves |
| `TaskUpdate` / `TaskCreate` | 13 | Stage tracking |
| `ToolSearch` | 5 | Schema loading for deferred tools |
| `WebFetch` | 5 | Site analysis (coffeechat.it.kr + Inflearn reference) |
| Other | 2 | Miscellaneous |

When you stack two rounds of parallel dispatch on top of the orchestration layer, the `Agent` call count rises fast. 28 `Agent` calls is not unusual when you're running 10 implementer dispatches plus 3 verification layers.

**Session 2 — Dental ad research cron (23 tool calls, 7 minutes):**

A separate session ran a daily update for a dental advertising research workflow. A cron agent read `medical_dental_ads_daily_goal.md`, updated 5 markdown files, and generated an HTML report. Breakdown: `Read` 9×, `Edit` 8×, `Bash` 3×, `Write` 2×.

Small, well-scoped, repeating tasks don't benefit from orchestration overhead. The pipeline is: read, edit, verify — not plan, dispatch, verify, cross-verify. 23 calls, 6 outputs, done.

## Patterns That Held Up Across Both Sessions

**No context, generic output.** Starting with a URL and expecting 5 high-quality designs doesn't work. An explicit site analysis step has to be part of the plan before the design brief is written. This isn't optional — the output quality is bounded by the brief quality, and the brief quality is bounded by product understanding.

**Parallel agents need concrete specs, not vague direction.** Each `frontend-implementer` in a parallel dispatch runs from a clean context. Vague specs collapse back into sequential dependency — each agent fills the gaps differently, and the variants drift toward each other. The spec granularity that enables independent execution is higher than intuition suggests.

**Codex and code-verifier serve different verification layers.** `code-verifier` catches what static analysis catches: test failures, lint errors, type errors. Codex reads for logical consistency across files — relationships between values that tooling doesn't track. The SRI hash mismatch was invisible to `code-verifier` and immediately visible to Codex. Run both, in sequence, when the output is going anywhere a browser will touch it.

> "None of these are any good" was the pivot point. The right response to rejection isn't defense — it's asking what "good" would actually look like, and building that into the brief before dispatching again.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
