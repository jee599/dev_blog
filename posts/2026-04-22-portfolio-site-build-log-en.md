---
title: "Static Bundle → Astro Native: 3 Prompts, 106 Tool Calls, 14 Components"
published: true
description: "Three vague one-liners sent Claude Code on a 3h26m autonomous rebuild — diagnosing stack incompatibility, pivoting without being asked, and shipping 14 native Astro/React components."
tags: claudecode, astro, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-22-portfolio-site-en
---

Three prompts. 106 tool calls. 3 hours and 26 minutes. Fourteen components rebuilt from scratch.

**TL;DR** The goal was to port an existing Vite+React static bundle into an Astro portfolio. The stacks are structurally incompatible — a static bundle has no path to Astro's Content Collections, shared components, or build pipeline. Claude Code diagnosed this without being told, proposed a native rebuild, and executed it. The user typed three lines total.

## "Apply Everything in the Deploy Folder to Jidonglab"

The full user input for the entire 3h26m session:

> "apply everything in the deploy folder to jidonglab"

> "show me the preview"

> "just do whatever you recommend"

No file paths. No component list. No architecture guidance. Before touching a single file, Claude Code had to parse what each of those sentences actually meant — and in doing so, make every consequential decision in the session.

The first move was finding the `deploy` folder. It wasn't in the expected location. Several Bash calls across different directory paths later, it surfaced: a self-contained Vite+React static bundle with six files, ~103KB total.

```
deploy/
├── app.jsx
├── data.js
├── index.html
├── styles.css
├── tech.jsx
└── thumbnails.jsx
```

Then mapping "jidonglab." That resolved to `~/portfolio/portfolio-site/` — the codebase behind `jidonglab.com`. A structure scan returned: Astro 4 + React + Tailwind, with Content Collections wired up for `build-logs`, `tips`, `ai-news`, and `projects`.

Before writing anything, Claude surfaced a warning:

> "Replacing the existing index.astro (19.2KB of Astro-native home page) with a simple redirect is pretty destructive."

With a clean git working tree confirmed, it ran a safe first attempt anyway — copied the six bundle files into `public/jidonglab-home/` and replaced `src/pages/index.astro` with a 580-byte redirect. Easy to validate, easy to revert.

## Why Dropping a Vite Bundle into Astro Breaks

"Show me the preview" triggered a local HTTP server, headless Chrome, and a screenshot.

The hero section rendered. The rest didn't connect to anything useful.

The issue isn't a missing config. A Vite+React static bundle is a fully self-contained application. Its `index.html` imports JSX directly. Its output assumes its own bundler pipeline. Serving it from Astro via redirect means it runs in a completely separate rendering context:

- **Content Collections are unreachable.** `build-logs`, `tips`, and `ai-news` exist only inside Astro's build-time data layer. A static bundle served from `public/` has no mechanism to query them.
- **Shared components can't be imported.** Existing `PostCard`, `ProjectCard`, and layout components are Astro/React files compiled by Astro. A separate Vite app can't reference them.
- **Tailwind tokens don't cross the boundary.** The bundle's own CSS scopes styles independently — no alignment with the site's design system.
- **Any dynamic data needs a separate fetch layer.** Which defeats the point of Content Collections entirely.

The end result of keeping the bundle: two unrelated applications sharing a domain, with no shared state, no shared components, no shared data. Not a port — a parallel deployment hiding behind a redirect.

## The Architecture Decision Claude Made Without Being Asked

When "just do whatever you recommend" arrived, Claude had everything it needed:

> "The deploy bundle is a static package. Using it as-is completely isolates it from Content Collections. We need to reimplement it natively on the Astro stack."

This is the session's defining moment. The user gave no architectural guidance. Claude Code evaluated the options — keep the bundle (fast, but produces broken integration) versus native rebuild (correct, but significantly more work) — and chose the rebuild. Then executed it.

No proposal. No "here are three approaches." A decision, then implementation.

This is what makes Claude Code useful as an AI automation layer rather than a fancy autocomplete: it can evaluate constraints in context, identify the correct solution, and execute without needing to be guided step-by-step through the reasoning.

## 14 Files, Built in Astro-Native

`src/components/home/` was created from scratch. Components split along a single axis: static rendering vs. interactivity.

| File | Type | Role |
|---|---|---|
| `Hero.tsx` | React | Hero section (interactive) |
| `Lab.tsx` | React | Project gallery |
| `Projects.tsx` | React | Side project list |
| `Thumbnails.tsx` | React | Thumbnail grid |
| `TechBlock.tsx` | React | Tech stack display |
| `About.astro` | Astro | About section |
| `Footer.astro` | Astro | Site footer |
| `NowStrip.astro` | Astro | Current work indicator |
| `ShipLog.astro` | Astro | Recent build log entries |
| `Topbar.astro` | Astro | Top navigation |
| `Wordmark.astro` | Astro | Logo mark |
| `Writing.astro` | Astro | Post list section |

Hardcoded data moved to `src/data/home.ts`. `src/pages/index.astro` became a composition page assembling these components rather than a redirect.

The Astro vs React split is load-bearing, not stylistic. Astro components ship zero JavaScript by default. React only enters the client bundle where interactivity is required — hero animations, gallery state, thumbnail behavior — using `client:load`. Everything else stays in `.astro`.

The result: `ShipLog.astro` and `Writing.astro` read directly from Content Collections at build time. That's functionality the original static bundle had no path to, regardless of how much configuration you threw at it.

## 106 Tool Calls: The Full Breakdown

| Tool | Count | Purpose |
|---|---|---|
| Bash | 40 | Folder discovery, local dev server, headless screenshots |
| Read | 17 | Existing components and schemas |
| Write | 15 | New components and data files |
| TaskUpdate | 14 | Progress tracking |
| TaskCreate | 7 | Subtask decomposition |
| ToolSearch | 4 | Tool schema resolution |
| Glob + Grep | 6 | File traversal |

**Edit count: 0.** Every output file was a fresh `Write` — no diffs applied to existing code. `index.astro` itself went through three complete rewrites across the session:

1. 580-byte redirect pointing to the static bundle
2. Empty composition scaffold (components imported but unstyled)
3. Final rebuilt home page

Each transition was a full `Write`. When direction changed, the file got replaced entirely rather than patched incrementally.

The 40 Bash calls break down roughly: ~15 for folder and repo discovery in the first 20 minutes, ~15 for dev server management and headless screenshot capture, ~10 for miscellaneous checks. There's a failure in the screenshot bucket — Claude tried scroll-capture via Chrome DevTools Protocol, hit permission issues, and fell back to viewport-only screenshots.

## Short Prompts Shift the Exploration Cost to the Agent

This session exposes a specific pattern in how Claude Code handles vague input.

"Apply everything in the deploy folder to jidonglab" required five sequential decisions before a single file was written:

1. Where is the deploy folder?
2. Where is the jidonglab repo?
3. What does the current `index.astro` look like?
4. Are these stacks compatible?
5. If not — what's the alternative, and how should it be built?

A more precise prompt might have pre-answered some of these. It also would have constrained the solution space. If the user had specified "port the deploy bundle by wrapping it in an Astro page component," Claude would have built exactly that — broken Content Collections integration and all. The spec would have been satisfied. The result would have been wrong.

"Just do whatever you recommend" handed over the architecture decision entirely. The 14-component structure, the Astro/React split boundary, where data lives — all of it was the agent's judgment call. The user reviewed the output and accepted it.

Short prompts in Claude Code aren't sloppy. They're a deliberate tradeoff in how you use it as an AI automation tool:

> Set the direction. Delegate the decisions. Short prompts raise the tool call count — they also raise decision-making speed.

The exploration overhead — roughly 20 of 40 Bash calls, concentrated in the first 20 minutes — is the cost of keeping the prompt ambiguous. The payoff: no spec to write, no stack decisions to make upfront, and an architecture that fits the actual constraints of the codebase rather than a prompt written before anyone looked at the code.

106 tool calls across 3.5 hours for a 14-component rebuild isn't inefficiency. It's what Claude Code autonomous execution looks like when input is intentionally sparse — the agent fronts the exploration cost so the user doesn't have to.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
