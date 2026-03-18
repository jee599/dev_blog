---
title: "Claude Code Fixed a Flipped Typography Hierarchy Across 3 Sections in 2 Minutes"
published: true
description: "Vague report: 'sizes look reversed.' No file, no component. Claude Code diagnosed and fixed the hierarchy inversion in 2 min: 5 reads, 3 edits, 14 tool calls, 1 file changed."
tags: claudecode, ai, webdev, nextjs
series: "Building with Claude Code: uddental"
canonical_url: https://jidonglab.com/posts/2026-03-18-uddental-en
---

The bug report had exactly one sentence.

"진료과목 looks big and 어떤 치료가 필요하세요? looks small."

No file path. No component name. No reproduction steps. Just: the visual sizes look reversed on the homepage.

I handed it to Claude Code with a breadth-first prompt. Fourteen tool calls and two minutes later, the bug was found, fixed, and committed.

**TL;DR** Three homepage sections on a dental clinic site had their heading hierarchy inverted — category labels were `h2`, section titles were `p`. FAQ and subpages were already using the correct eyebrow pattern. Claude Code found the inconsistency by reading the codebase itself, not by being told where to look. One file changed: `app/page.tsx`, 6 lines deleted, 6 lines added.

---

## The Prompt That Matters When You Don't Know Where the Bug Lives

When you don't have a file path, the instinct is to narrow the search. Pick the most likely component. Start there. That instinct is usually wrong.

Here's what I actually sent:

```
[Wed 2026-03-18 09:42 GMT+9] In /Users/jidong/uddental/implementations/claude,
inspect the deployed/UI heading hierarchy issue the user reported.

Problem statement:
On pages, combinations like:
- small heading: "진료과목"
- larger subheading: "어떤 치료가 필요하세요?"
appear with the visual sizes reversed / hierarchy wrong.

Please do the following:
1) Inspect all relevant pages/components in this implementation
   for section eyebrow/title/subtitle typography hierarchy issues.
2) Find every place where the visual order is inverted.
3) Fix all instances to match the correct pattern.
```

Two things make this prompt work:

**First, the symptom is concrete.** Not "the UI looks wrong" — but "the category label is visually larger than the section title." Claude can search for structural patterns when given a specific description of the inversion. Vague symptoms produce vague investigations.

**Second, the scope is explicitly wide.** "Find every place" rather than "look in this component." The difference between those two framings is the difference between a patch and an actual fix.

If I'd pointed Claude at a single file, it might have fixed one section and missed two others with the identical problem. Wide scope turned a targeted bug report into a full audit.

---

## How Claude Diagnosed It Without a File Path

Claude opened `app/page.tsx` first — reasonable for a homepage issue. Five Read tool calls followed: the main page, subpages, shared component files. Scanned sequentially.

The diagnosis came back unambiguous. Three sections — treatment journey, treatment departments, and facility overview — all shared the same inverted pattern:

```tsx
// Before — inverted hierarchy
<h2 className="text-2xl font-bold">진료과목</h2>
<p className="text-sm text-gray-500">어떤 치료가 필요하세요?</p>
```

`진료과목` ("Treatment Departments") was an `h2`. `어떤 치료가 필요하세요?` ("What treatment do you need?") was a plain `p`.

By default, `h2` renders larger. So the category label dominated visually, and the section's real heading got buried. Visual weight was exactly backwards relative to importance.

What made this read phase useful: Claude also checked the FAQ section and subpages, and found they were **already using the correct pattern**. The right implementation existed in the codebase — Claude used it as the reference without being told it was there.

---

## The Fix: Standard Eyebrow Label Pattern

The correct hierarchy is the eyebrow label pattern you see in most modern design systems:

```tsx
// After — correct hierarchy
<p className="text-sm font-semibold text-mint-600 uppercase tracking-wider">
  진료과목
</p>
<h2 className="text-3xl font-bold text-gray-900">
  어떤 치료가 필요하세요?
</h2>
```

Category label → small `p` with `uppercase`, `tracking-wider`, and accent color. Section title → large `h2` with full weight.

Visual hierarchy now matches semantic hierarchy. The label is visually subordinate; the heading is the dominant element.

Three Edit calls — one per broken section, all in `app/page.tsx`. Then `next build` via Bash. No errors. Committed.

**Full tool breakdown:**
Read ×5, Bash ×4, Edit ×3, Agent ×1 = **14 tool calls total**. Session time: 2 minutes. Changed files: 1. Lines modified: 6 deleted, 6 added.

---

## Why Only the Homepage Was Broken

The subpages were built after the design pattern was established. The homepage sections were written earlier, before the eyebrow convention was finalized — and they were never updated. Classic multi-phase development drift.

This kind of inconsistency is hard to catch in code review because each section looks locally reasonable in isolation. A category label *can* be large. A description *can* be small. The problem only becomes visible when you notice the visual weight is inverted relative to importance — exactly the kind of thing that shows up in user reports, not in a linter.

---

## The Underlying Pattern

This session demonstrates something that comes up often with Claude Code: **the model uses the existing codebase as its own specification**.

Claude found the correct implementation in FAQ and subpages, inferred it was the intended design, and applied it to the broken sections — without me describing what "correct" looks like. The codebase contained both the bug and the fix. Claude found both.

If you're writing prompts for debugging tasks, that's the key insight. You don't need to describe the correct behavior from scratch if examples already exist in the codebase. Just ask for an exhaustive scan, and let the model find the pattern.

> When you don't know where the bug is, don't narrow the scope — broaden it, and let the model find the pattern.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
