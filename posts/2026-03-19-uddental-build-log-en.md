---
title: "A Dev Color Picker Survived Deployment: 3 UI Bugs Fixed in 5 Minutes with Claude Code"
published: true
description: "A 🎨 dev button survived deployment. Plus a heading hierarchy inversion and infinite bounce animation. Claude Code killed all three in 5 min, 41 tool calls."
tags: claudecode, debugging, ai, webdev
series: "Building with Claude Code: uddental"
canonical_url: https://jidonglab.com/posts/2026-03-19-uddental-en
---

After deploying the uddental dental clinic site, I opened the production URL and saw a floating 🎨 button in the bottom-right corner.

That's `HeroBgPicker` — a component I built during development to quickly swap the hero section background color. It was z-indexed to `z-60`, floating above every piece of content on the page. Click it, get a color palette. Useful in dev. Not something your dental clinic clients should ever see.

That wasn't the only problem. Two more bugs were hiding in the same deployment.

**TL;DR**: 3 sessions, 5 minutes, 41 tool calls. Heading hierarchy inverted across three homepage sections, dev tool live in production, infinite bounce animation on the CTA button. All three fixed.

---

## The Heading Hierarchy Was Upside Down

The homepage had this pattern repeated across three sections:

```
Services (진료과목)       ← h2, displayed large
What treatment do you need?  ← p, displayed small
```

The category label was visually bigger than the actual question. It needed to be flipped — the eyebrow label small, the `h2` large.

The FAQ section and sub-pages were already correct. Only three sections on the homepage had it backwards.

Prompt:

> "inspect the deployed/UI heading hierarchy issue the user reported. Find every place where the visual sizes reversed / hierarchy wrong."

Specific problem. Specific phrasing. Claude had a clear target.

It read the files and found the issues in under 5 seconds. The fix was 6 lines in `app/page.tsx`:

```html
<!-- Before: category label as h2, question as small text -->
<h2 class="text-3xl font-bold">Services</h2>
<p class="text-sm font-semibold text-mint uppercase">What treatment do you need?</p>

<!-- After: eyebrow label small, actual question as h2 -->
<p class="text-sm font-semibold text-mint uppercase">Services</p>
<h2 class="text-3xl font-bold">What treatment do you need?</h2>
```

Read 5 times, Edit 3 times, Bash 4 times (build check + commit). 2 minutes total.

---

## The Dev Button That Made It to Production

Third session, inspecting the deployed site. This time I didn't name a specific bug — I just described what looked wrong:

> "inspect the current UI/layout issues visible on the deployed site, especially mobile. Find and remove/fix all weird empty space at the top, broken-looking layout gaps, and awkward UI artifacts."

No specific bug named. Just symptoms.

With that wider net, Claude read 17 files before touching anything. It found three problems.

**`HeroBgPicker.tsx`**: The full dev UI was still active. The 🎨 button, the color palette panel, fixed to the screen at `z-60` with no environment check, no conditional render. It shipped as-is.

The fix: remove the dev UI entirely, hardcode the background to navy, bump mobile padding from `py-6` to `py-10`.

**`globals.css`**: `floatingPop` and `floatingGlow` animations were set to `infinite`. The floating CTA button never stopped bouncing.

```css
/* Before */
animation: floatingPop 0.4s ease-out infinite;

/* After */
animation: floatingPop 0.4s ease-out 1;
/* or equivalently: animation-iteration-count: 1 */
```

It pops once on load and stays put.

**`page.tsx`**: Double blank lines between sections. No visual impact, but messy. Cleaned up.

3 files, 3 minutes, 27 tool calls (Read 17, Edit 5, Bash 3, Agent 1, Write 1).

---

## Narrow vs Wide: Two Prompt Strategies for Two Debugging Modes

Comparing the two sessions shows a pattern worth internalizing.

Session 2 named the bug explicitly — "heading hierarchy issue", "visual sizes reversed". Claude had a clear target. 5 reads, problem found, done.

Session 3 described symptoms only — "weird empty space", "broken-looking layout gaps". Claude didn't know where to look, so it read broadly: 17 files. Slower. But it surfaced three bugs I didn't know existed.

When you know the bug, be specific in your prompt. When you don't, describe what you see and let Claude scan.

Neither approach is better in the abstract — they're tools for different debugging modes. What changed for me after this session was choosing between them deliberately at the prompt level, not just defaulting to one.

---

## By the Numbers

| Session | Time | Tool Calls | Files Changed |
|---------|------|-----------|--------------|
| Session 1 | 0 min | 1 | 0 |
| Session 2 | 2 min | 13 | 1 |
| Session 3 | 3 min | 27 | 3 |
| **Total** | **5 min** | **41** | **4** |

Tool distribution across all sessions: Read 22, Bash 8, Edit 8, Agent 2, Write 1.

More than half the tool calls were reads. Claude read extensively before touching anything. That's not overhead — that's the actual work. Edits without sufficient context produce wrong changes. The 22 reads are what makes the 8 edits correct.

> The best way to keep dev tools out of production is to never ship them there. The second best is a 5-minute Claude Code session right after deployment.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
