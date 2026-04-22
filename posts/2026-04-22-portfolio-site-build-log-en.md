---
title: "3 Prompts, 106 Tool Calls: Claude Code Generated 14 Astro Components in One Session"
published: true
description: "A vague 5-word prompt kicked off a 3h 26m Claude Code session — it explored, made a destructive mistake, self-corrected, and shipped 14 Astro components without being told how."
tags: claudecode, astro, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-22-portfolio-site-en
---

The first prompt had a typo. Three hours and 26 minutes later, 14 new files existed that didn't before.

**TL;DR**: Handed a vague "apply the deploy folder to jidonglab" prompt, Claude Code explored the codebase, tried a destructive shortcut (redirect + static bundle copy), recognized it would break Content Collections integration, then self-corrected into a full Astro-native reimplementation. Three user prompts. 106 tool calls. Zero files modified — 14 created from scratch.

## The Shorter the Prompt, the More Claude Explores

The entire first prompt:

> "Apply everything in the deploy folder to jidonglab."

No path. No clarification of what "jidonglab" referred to. No instructions about handling existing code. The typo was in there too.

With no context to work from, Claude started with exploration. It scanned the home directory, checked multiple candidate paths, and eventually found the `deploy` folder. The contents: a self-contained React prototype — `index.html`, `app.jsx`, `styles.css`, `data.js`, `tech.jsx`, `thumbnails.jsx` — roughly 103KB in total.

"Jidonglab" resolved to `portfolio-site`. The existing `src/pages/index.astro` was 19.2KB — a fully integrated Astro home page with Content Collections logic, `PostCard`, `ProjectCard`, and listing components wired to build-logs, tips, and ai-news collections.

Claude's first read on the situation was straightforward: overwrite `index.astro` with a redirect, serve the static bundle from `public/`. Fast. Easy. Wrong.

## The Destructive Approach Ran First

The 19.2KB `index.astro` became a 580-byte redirect. Six static files landed under `public/jidonglab-home/`.

Nothing was technically blocking this. The working tree was clean, the target folder was empty. So it ran.

Prompt two:

> "Show me a preview."

Claude spun up a local HTTP server and attempted a screenshot. Chrome was in read-tier so direct scrolling wasn't available — it fell back to headless Chrome for full-page capture. The hero section rendered correctly.

The problem wasn't the screenshot. It was the structure.

A static bundle served from `public/` runs completely outside Astro's build pipeline. It has no access to Content Collections. `build-logs`, `tips`, `ai-news` — the entire content layer of the site — would disappear. The design would survive the transplant. Everything functional wouldn't.

## "Do It Your Way"

Third prompt:

> "Just do whatever you recommend."

Five words. Claude used them to make the architectural call: scrap the static bundle approach, rebuild natively in Astro.

The process:

1. Analyzed the layout and design of the static bundle section by section
2. Decomposed each piece into its component type — `.tsx` for client-side interactivity, `.astro` for static layout
3. Migrated `data.js` to `src/data/home.ts` with TypeScript types
4. Rebuilt `src/pages/index.astro` as a composition page assembling the new components

Full tool call breakdown for the session:

| Tool | Count |
|------|-------|
| Bash | 40 |
| Read | 17 |
| Write | 15 |
| TaskUpdate | 14 |
| TaskCreate | 7 |
| **Total** | **106** |

## 14 Files, One Session

Here's every file created:

**Client-side components** (`.tsx` — React with state):

| File | Purpose |
|------|---------|
| `Hero.tsx` | Animated hero section |
| `Lab.tsx` | Interactive project gallery |
| `Projects.tsx` | Project cards with hover state |
| `TechBlock.tsx` | Tech stack display |
| `Thumbnails.tsx` | Visual thumbnail grid |

**Static layout components** (`.astro`):

| File | Purpose |
|------|---------|
| `About.astro` | Bio section |
| `Footer.astro` | Site footer |
| `NowStrip.astro` | "Currently working on" strip |
| `ShipLog.astro` | Build-logs listing (Content Collections) |
| `Topbar.astro` | Navigation bar |
| `Wordmark.astro` | Logo/wordmark |
| `Writing.astro` | Tips/ai-news listing (Content Collections) |

**Data and page**:

| File | Purpose |
|------|---------|
| `src/data/home.ts` | Typed TypeScript port of `data.js` |
| `src/pages/index.astro` | Composition page assembling all components |

The Astro vs React split isn't arbitrary. Astro components ship zero JavaScript by default — React only enters the bundle where client-side state is actually needed (`Hero.tsx`, `Lab.tsx`, `Projects.tsx`, `TechBlock.tsx`, `Thumbnails.tsx` with `client:load`). Everything else stays in `.astro` and renders server-side.

`ShipLog.astro` and `Writing.astro` handle Content Collections — written from scratch, wired directly to the existing collection schemas. The content layer that would have gone dark under the static bundle approach stays fully intact.

Files modified: **0**. Files created: **14**.

## The Real Cost of the Wrong Turn

The initial redirect + static copy was never committed. The working tree stayed clean throughout, so reversing course didn't cost much in git terms.

But it cost time. Headless Chrome setup, local server execution, diagnosing why scroll wasn't working — that loop is baked into those 40 `Bash` calls. A more specific initial prompt would have skipped it entirely.

The counterargument is worth taking seriously though. The vague prompt forced Claude to *evaluate* the options rather than execute a prescribed path. "Do it your way," arriving *after* the static bundle approach had been tried and found wanting, is what produced the better outcome.

If the first prompt had said "port the deploy folder into public/," Claude would have done exactly that — and Content Collections would be gone. The spec would be satisfied. The result would be wrong.

The exploration overhead bought something real: Claude independently discovered why the Astro-native approach was worth the extra work. The wrong turn wasn't waste — it was how Claude built the judgment to make the right call.

## Short Prompts as a Deliberate Strategy

This session exposes a specific pattern in how Claude Code handles intentionally vague input.

"Apply everything in the deploy folder to jidonglab" required five decisions before a single file was written:

1. Where is the deploy folder?
2. Where is the jidonglab repo?
3. What does the existing `index.astro` look like?
4. Are the two stacks compatible?
5. If not — what's the alternative, and how should it be built?

A more precise prompt might have pre-answered some of these. It also would have constrained the solution space.

"Just do whatever you recommend" handed the architecture decision over entirely. The 14-component structure, the Astro/React split boundary, where the data layer lives — all Claude's judgment calls. Reviewed and accepted by the user afterward.

The exploration overhead — roughly 20 of 40 `Bash` calls concentrated in the first 20 minutes — is the cost of keeping the prompt ambiguous. The benefit: no spec to write upfront, no stack decisions to make before looking at the code, and an architecture that fits the actual constraints of the codebase rather than the assumptions of a prompt written before any of that was known.

## Model: claude-opus-4-7

This session ran on `claude-opus-4-7`. The workload — explore, attempt, evaluate failure, redesign, implement from scratch — requires holding context across many compounding decisions. A model that loses the thread after 30-40 tool calls would have finished the redirect approach and called it done.

The self-correction happened *before anything was committed*, which means the context window was being used to reason about consequences, not just to execute steps. That's the behavior that made the difference.

106 tool calls across 3h 26m for a 14-component rebuild isn't slow. It's what Claude Code autonomous execution looks like when the input is intentionally sparse — the agent fronts the exploration cost so you don't have to.

---

3h 26min. 14 files. 3 prompts. The redesign shipped. More importantly, the Content Collections integration survived — which it wouldn't have if the first instinct had been allowed to stick.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
