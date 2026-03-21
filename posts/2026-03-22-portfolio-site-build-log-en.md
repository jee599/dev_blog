---
title: "I Redesigned My Portfolio Projects Page 4 Times in One Day with Claude Code"
published: true
description: "Four complete redesigns in a single day: screenshot cards → hover overlays → split panel → iframe preview. What happens when AI automation makes iteration nearly free."
tags: claudecode, ai, webdev, portfolio
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-22-portfolio-site-en
---

Four complete redesigns. One day. Same page.

On March 21, I rebuilt the Projects section of my portfolio from scratch four times. Browser mock screenshot cards, hover overlay reveals, a Finder-style split panel, and finally an iframe live preview. Each iteration took 20–40 minutes with Claude Code.

Without it, this would've been a week of work.

**TL;DR**: When Claude Code compresses iteration cycles to under an hour, speed stops being the constraint. Knowing when to stop and ship becomes the hard part.

## The Starting Point: Browser Mock Screenshots Looked Great on Paper

The first approach was inspired by the pattern you see on Notion's, Linear's, and Vercel's landing pages — product screenshots inside browser chrome frames, with a slow scroll-on-hover animation. When done well, it looks polished and instantly communicates "this is a real product."

My prompt:

```
Active projects: browser mock + scroll animation screenshot
Hero: centered layout + badges + stats
In development: 3-column grid
```

Claude Code wrote 105 lines in commit `02076c1`. The result looked convincing at first glance. Then I hovered over one of the cards.

The scroll animation was broken. `object-fit: cover` and `translateY` were fighting each other. Instead of the image scrolling smoothly inside the container, it was overflowing the bounding box and flying out of frame. Not a subtle glitch — visually jarring.

Two commits (`ef7d70a`, `57f5d09`) to fix the overflow behavior. And while I was debugging the CSS, a more important question surfaced.

"Why am I spending this much attention on scroll animations? Half my projects don't even have screenshots."

That's the real problem with the screenshot approach. It assumes every project has a polished visual to show. In reality, some projects are CLIs. Some are open source libraries. Some are early-stage enough that there's nothing visually interesting to capture yet. The design pattern works great for SaaS landing pages; it breaks down for a portfolio that spans multiple project types.

The animation was fixable. The structural mismatch wasn't.

## First Pivot: The Hover Overlay Trap

Dropped the screenshots entirely. Went card-based instead.

The idea: default state shows the essentials — title, status indicator, and tech stack. Hover reveals the full picture — description, build log links, external links. CSS `opacity` transition at 0.25 seconds, smooth and snappy.

161 lines changed in `ProjectCard.astro`. Mechanically, it worked exactly as designed.

Then I sat with it for about 30 minutes.

The problem wasn't the animation. It was the information architecture. Hover is fundamentally a "hint" interaction — it surfaces a little more context, a preview, a tooltip. It's not designed to carry a full project description plus links plus metadata. When you try to load that much into a hover state, reading it becomes stressful. The user has to hold the mouse still while parsing a wall of text that appears and disappears.

Cards with hover reveals are great for image galleries and navigation menus. They're the wrong pattern for communicating depth about a portfolio project.

Second pivot.

## The Split Panel: Finally Something That Clicked

This is the iteration where the design actually worked.

The mental model came from apps with heavy list-and-detail UX — Finder, Linear, GitHub's file browser. Left side: a scannable list. Right side: a detailed panel that updates when you click something on the left. Sticky panel so the detail view persists as you browse.

The spec I gave Claude Code:

```
Left: project list (color bar by status + name + stack + log count)
Right: detail panel for selected project (description + stack + site/GitHub links + build log list)
Click to switch, sticky right panel
Mobile: stack vertically
```

Commit `e831e42` — `index.astro` single file, 315 lines. 178 added, 137 deleted.

The interaction model is familiar and clean. Click a project in the list, the right panel replaces its content. Status colors give you a quick portfolio read without any clicking — green for live and running, yellow for active development, gray for shipped and done.

One remaining gap: the detail panel was still all text. You'd have to click an external link and open a new tab to see what any of these projects actually look like. The portfolio answered "what did you build?" but not "show me."

## Adding Live iframe Preview to the Right Panel

The fix was direct. Embed an `<iframe>` in the right detail panel. Click a project, see the live site inside the panel without leaving the page.

```astro
<iframe
  src={project.siteUrl}
  class="preview-iframe"
  loading="lazy"
  sandbox="allow-scripts allow-same-origin"
/>
```

Started at 200px height. Too compressed — barely readable. Doubled it to 400px in commit `7587f7c`.

Then added a scroll effect. On hover, the iframe content slowly pans downward using CSS `transform: translateY` with a transition. No JavaScript event listeners, no scroll syncing logic. Pure CSS.

One tooling observation worth noting: Edit dominated throughout this session. Bash appeared only for `astro build` checks. Because `index.astro` was the single file changing across all four iterations, Claude Code could make sequential edits cleanly without file conflicts.

Keeping all the logic in one Astro file (rather than splitting early into sub-components) made the iteration loop faster. Less indirection, fewer files to coordinate. You can refactor for structure after you've validated the direction. While you're still figuring out what the thing should be, a single file is a feature, not a problem.

## Open Source Projects Are a Different Case

agentcrow and contextzip — two of my open source CLI tools — don't have a `siteUrl`. They're GitHub repos with no deployed frontend. The iframe approach doesn't apply.

For these, I added `demoGif` support. Added a field to the content schema in `config.ts`, then referenced it in each project's YAML:

```yaml
# agentcrow.yaml
demoGif: /demos/agentcrow.gif
```

The homepage open source card now renders the GIF — dark background, 16:9 container, `loading="lazy"`. Not as dynamic as a live iframe, but it communicates "here's what this thing actually does" without requiring the visitor to dig through a README.

This change touched 5 files: `config.ts`, `agentcrow.yaml`, `contextzip.yaml`, `projects.ts`, and `index.astro`. Claude Code processed them sequentially, not in parallel — because the schema definition in `config.ts` has to land first before any consuming file can reference the new field correctly.

This pattern comes up constantly in multi-file refactors and AI automation workflows: independent tasks can be parallelized, but dependency chains have to run in order. Getting that distinction right separates fast iteration from broken builds.

## Nav Cleanup

Removed `AI Posts` and `AI News` from the nav in commit `a6fc486`.

A portfolio's job is to communicate what you've built. Auto-generated content feeds dilute that signal. Every nav item is a claim about what the site is — fewer claims, clearer identity.

## The Real Takeaway: Speed Shifts What's Hard

Let me be specific about the economics here, because this is the interesting part.

In a pre-Claude-Code workflow, each of these four design directions would take a day minimum. You write the component, style it, test on mobile, handle edge cases, debug the animations. By the time you've invested that much, you're reluctant to throw it away — even when you suspect it's the wrong direction.

That reluctance is rational. When iteration is expensive, being conservative about pivots is the right call. You're not irrationally attached to your first idea; you're correctly accounting for switching costs.

Claude Code changes that calculation. Each direction took 20–40 minutes from prompt to working implementation. Fast enough to run actual experiments instead of committing based on intuition alone.

The browser screenshot approach: found the structural mismatch, moved on. 30 minutes.

The hover overlay: identified the interaction pattern problem, moved on. 30 minutes.

The split panel: validated it works, extended it. 40 minutes.

The iframe preview: added it, evaluated the result, shipped it. 20 minutes.

There's a side effect worth being honest about. "I can build it fast, so let me just try it" becomes the default posture. That enabled four genuine experiments in one day. But it also means the loop doesn't have a natural stopping condition. You can keep iterating indefinitely without shipping.

The constraint is no longer execution speed. It's judgment — knowing which direction is worth developing, and when "good enough to ship" has arrived.

> Claude Code brings iteration cost close to zero. That makes directional judgment the scarce resource.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
