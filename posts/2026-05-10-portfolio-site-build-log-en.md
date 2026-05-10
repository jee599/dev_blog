---
title: "5 Parallel Redesigns and the SRI Hash Bug Codex Caught Before Production"
published: true
description: "Redesigned a Korean game-industry mentoring site with 5 parallel Claude Code agents. Codex cross-verification caught an SRI hash mismatch before production. 79 tool calls."
tags: claudecode, ai, multiagent, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-10-portfolio-site-en
---

"None of these look professional. Not a single one."

That was the feedback after 5 complete design variants landed simultaneously — each built by a separate Claude Code agent running in parallel. It's a useful kind of failure. The feedback told me exactly what the original brief was missing.

**TL;DR:** Dispatched 5 `frontend-implementer` subagents in parallel to redesign `coffeechat.it.kr`, a Korean game industry mentoring platform. First round failed the professional-trust test — so the whole brief got reworked. Then Codex cross-verification caught an SRI hash mismatch across 4 files that would have silently broken React in every modern browser before production. Total: 79 tool calls across 2 sessions.

This is a build log from my Claude Code multi-agent workflow. If you're not familiar with the setup: I orchestrate Claude Code agents from a main session, dispatch specialized subagents for parallel or isolated tasks, and use Codex as an external cross-verification layer after internal verification passes.

## Why Site Analysis Has to Come Before the Brief

The project started with a single URL: `coffeechat.it.kr`. Before writing a spec or picking a design direction, I ran `WebFetch` against the live site.

What came back wasn't what I expected. This wasn't a generic networking app where people schedule casual coffee chats. It was a **1:1 mentoring platform specifically for the Korean game industry** — structured sessions with people currently working at major Korean game studios (Nexon, Krafton, NCSoft, Smilegate, Pearl Abyss). The actual product is career acceleration: resume reviews, mock interviews, direct mentorship with verified game industry professionals.

The difference matters enormously for design direction:

- A generic coffee-chat app optimizes for social warmth and low friction
- A career mentoring platform for a specific industry optimizes for **credibility, trust, and demonstrated expertise**

Skip the site analysis and you get generic SaaS templates. Run the analysis first and you know you're designing something that needs to compete for trust against real careers and job decisions.

After the analysis, a `general-purpose` agent built `plan.md` — each variant described in enough specificity that the implementer agents could execute independently without ambiguity. Then all 5 variants went to `frontend-implementer` subagents simultaneously.

| Variant | Mood | Key Design Elements |
|---|---|---|
| V1 Editorial Magazine | Korean indie magazine | Instrument Serif, cream `#f4eee4` background |
| V2 Soft Brutalist | Bold borders, block color | Lime/pink color blocks, strong typographic contrast |
| V3 Motion Dark | Animation-heavy dark theme | Floating gradient blobs, `@keyframes drift`, `#0a0a0f` |
| V4 Minimal Pro | Clean, information-dense | White base, Inflearn-adjacent structure |
| V5 Korean Editorial | Korean editorial print | Vertical type emphasis, structured hierarchy |

## When "All of Them Are Wrong" Is Useful

Five variants finished. The response was: "None of these look professional. Look at Inflearn, or similar education platforms."

At first that's a frustrating feedback format — "none of them" leaves nowhere obvious to go. But it's actually precise. It identifies the category of failure without ambiguity: this doesn't feel like a platform I'd trust with a career decision.

The problem was visible in retrospect. Every variant had been competing on visual distinctiveness — editorial typography, motion design, brutalist grids, dark mode aesthetics. None of them addressed what actually creates trust in an educational or career platform: **evidence of delivered value**.

Inflearn, Class101, and Fastcampus don't just look polished. They build trust through specific repeating UI patterns:
- Enrollment counts with large formatted numbers ("12,847 students")
- Completion rates and student outcome metrics
- Mentor profile cards that show current employer, team, and years of experience
- Verified credentials and review systems
- Structured cohort information that signals a real ongoing community

V1 through V5 had none of this. They were visually interesting — the kind of interesting that makes a designer nod in approval — but missing the signals that make a career-stage user think "I could trust this with my job search."

The fix wasn't a sixth aesthetic variation. Round 2 started with a dedicated Inflearn site analysis as the baseline reference, then built toward the same trust-signal patterns applied to a game industry context.

## The SRI Hash Bug Codex Found That the Verifier Missed

This is the part that made the Codex cross-verification step obviously worth running.

After implementing the second round of variants, `code-verifier` ran first — checking the diff for obvious issues, running lint, checking for common mistakes. It passed.

Then Codex cross-verification read `plan.md`, `diff.patch`, and the verifier report together and found something the verifier hadn't flagged:

V2, V3, V4, and V5 all loaded `react.production.min.js` from a CDN — but the `integrity` attributes were set to SHA-384 hashes computed from `react.development.js`.

```html
<!-- What was actually in the code — wrong hash -->
<script
  src="https://unpkg.com/react@18/umd/react.production.min.js"
  integrity="sha384-[hash from development.js, NOT production.min.js]"
  crossorigin="anonymous"
></script>
```

### Why This Is a Silent Production Killer

Subresource Integrity (SRI) is a browser security feature that validates external scripts before executing them. The browser fetches the file, computes its SHA-384 hash, and compares it to the `integrity` attribute. If they don't match, the script is blocked — no execution, no error thrown to the page, just a console security violation and a non-interactive site.

The production and development React builds have different file contents. The development build includes warnings, helpful error messages, and debug tooling. The production build strips all of that. Different content → different SHA-384 hash.

Loading `react.production.min.js` with a hash that was computed from `react.development.js` means every modern browser would block React from executing entirely. No React runtime. No interactivity. Silent failure — the user sees the HTML shell but nothing works.

This doesn't surface in ESLint (it's valid HTML). It doesn't show up in a visual design review. It doesn't fail a lighthouse audit. It surfaces when someone cross-references file paths against their hash values with enough domain knowledge to know they should match.

Codex caught it by reading the diff with context — not just checking syntax, but verifying that the values used were semantically correct for their purpose. All 4 files were updated with the correct production hashes before anything shipped.

### Takeaway for CDN-loaded Libraries

When loading libraries from a CDN with SRI hashes, verify the hash was computed from the exact file at the exact URL you're loading. The production and development builds of the same library version have different hashes. This is an easy mistake to make when copying from docs or examples that may reference a different build variant.

```bash
# To generate the correct hash for any URL:
curl -sL https://unpkg.com/react@18/umd/react.production.min.js | \
  openssl dgst -sha384 -binary | openssl base64 -A
```

## What Actually Makes Parallel Dispatch Work

5 sequential design variants take 5x as long. Parallel dispatch takes as long as the slowest single agent. The speedup is the obvious part. The non-obvious part is what enables it.

Each `frontend-implementer` agent is completely isolated — no shared state, no communication channel with the other agents, no way to coordinate mid-execution. For all 5 to produce usable, independent output, the `plan.md` has to resolve every decision each agent would otherwise have to block on or make assumptions about.

**Vague (doesn't work for parallel):**
> "V3: Make it look dark and modern with some motion effects."

**Specific enough for independent execution:**
> "V3: Motion dark theme. Background `#0a0a0f`. Hero section uses 3 floating gradient blobs animated via `@keyframes drift` with randomized delays. Canvas particle system behind the main CTA. Font: `Space Grotesk` for all headings, `Inter` for body text. No light mode variant. Primary accent: `#7c3aed`."

The difference is decision surface. Vague briefs produce agents that either make assumptions (inconsistent results) or pause to ask questions (collapsing the parallelism benefit into a sequential bottleneck). Specific specs produce agents that execute and produce comparable output.

The sequencing that worked: delegate `plan.md` creation to a dedicated `general-purpose` agent first, as a separate step. That agent had the space to think through each variant — color systems, font pairings, animation approaches, component structure — and write specs detailed enough that 5 other agents could pick them up cold and run without coordination.

The temptation is to write the plan yourself quickly and skip the delegation. Resist it. The quality of `plan.md` is the ceiling on how well parallel dispatch works.

## The Orchestration Architecture

For readers not familiar with the Claude Code multi-agent setup I'm running:

**Main session (orchestrator):** Handles user interaction, task classification, routing decisions, and final review. Doesn't write implementation code directly on larger tasks.

**Subagents (workers):** Spawned via the `Agent` tool with a fresh context. Each gets a specific task, relevant file paths, and the output location to write to. They can't see each other's work or the main session's context beyond what's in their prompt.

**Verification pipeline:**
1. `code-verifier` — runs lint, checks the diff against the plan, greps for debug artifacts
2. `codex-cross-verify` — external cross-validation using Codex, reads plan + diff + verifier report together

The two-layer verification is worth the overhead for multi-file frontend work. The verifier catches mechanical issues (missing files, lint failures, obvious mistakes). Codex catches semantic issues — things that are syntactically valid but semantically wrong, like a hash that references the wrong file.

## Tool Call Breakdown

**Session 2 (redesign — 79 total):**

| Tool | Calls | What it did |
|---|---|---|
| `Agent` | 28 | Subagent dispatch: 5 parallel implementers, plan agent, verifier, Codex cross-verification |
| `Bash` | 26 | Diff generation, file moves, server checks, directory setup |
| `TaskUpdate` / `TaskCreate` | 13 | Progress tracking across the parallel workload |
| `ToolSearch` | 5 | Schema loading for deferred tools |
| `WebFetch` | 5 | Site analysis (`coffeechat.it.kr`, Inflearn, reference sites) |

**Session 1 (dental ad cron updates — 23 total):**

A separate task that ran before the redesign: 5 file updates to a `dentalad` cron workflow plus an HTML report generation. `claude-opus-4-7` handled it directly in 7 minutes, 23 tool calls, with no subagents.

Small, well-scoped tasks don't benefit from orchestration overhead. The pipeline for simple tasks: read current state → edit → verify. Not: plan → dispatch → verify → cross-verify. Matching the pipeline to the task size matters as much as having the pipeline available.

## What the Output Looks Like

The comparison canvas is a single HTML file at `/Users/jidong/coffee-chat-redesign/`. Each of the 5 variant cards has a "View →" link that opens the variant in a new tab. The point is browser-native comparison: no screenshots, no Figma, no tool switching. The client tabs between full-page renders and picks directly.

Round 2 — professional, education-platform trust signals, Inflearn reference baseline — continues next session.

## What Would Have Broken Without Cross-Verification

React not loading in production, across 4 of the 5 variants, in every modern browser with SRI enforcement. No obvious error to the end user — just a page that renders HTML but does nothing when clicked.

The verifier passed. Design review would have passed. The SRI hash issue is the kind of bug that sits in the diff as a plausible-looking string until someone with context reads it and checks whether the string is correct for its purpose.

That's what Codex cross-verification is for. Not to catch obvious mistakes — to catch the subtle ones that look correct until you check them against what they're supposed to represent.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
