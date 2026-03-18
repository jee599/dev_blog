---
title: "Claude Code Fixed 3 UI Bugs in 5 Minutes — By Reading 22 Files First"
published: true
description: "41 tool calls, 5 minutes, 3 files fixed. I gave Claude Opus a vague prompt — 'find weird stuff' — and it found bugs I forgot were there."
tags: claudecode, ai, debugging, webdev
series: "Building with Claude Code: uddental"
canonical_url: https://jidonglab.com/posts/2026-03-18-uddental-en
---

A 🎨 color picker button was floating in the top-right corner of my production site.

I built it weeks earlier to test hero background colors during development. Deployed, forgot it existed. It sat there — `z-60`, fully visible to every visitor — until a friend pointed it out.

**TL;DR** — 3 Claude Code sessions, 5 minutes, 41 tool calls. Claude Opus fixed three UI bugs in uddental's homepage: heading hierarchy reversed across three sections, a dev tool leaking into production, and two CSS animations set to loop forever. The most interesting session used a completely vague prompt: "find weird stuff and fix it."

---

## The Headings Were Upside Down

Session 2 started with a specific observation but no proposed fix:

```
On pages, combinations like:
- small heading: "진료과목" (specialty category)
- larger subheading: "어떤 치료가 필요하세요?" (what treatment do you need?)
appear with the visual sizes reversed / hierarchy wrong.
```

Before touching any code, Claude ran `Read` five times. Homepage structure in `app/page.tsx`, then subpages, then the FAQ section — reading sequentially to establish what the *correct* pattern looked like before identifying where it broke.

The diagnostic approach: find a reference implementation first, then diff everything else against it.

FAQ and all subpages had it right: small eyebrow text for category labels, large `h2` for the description. That set the baseline.

Three homepage sections — treatment journey, specialties, facilities — had it backwards. Category names in `h2` (visually large), descriptions in `p` (visually small). Same component structure, opposite visual weight.

Fix: three `Edit` calls on a single file. No component refactoring, no shared utilities — direct corrections to `app/page.tsx`.

**Tool usage:** `Read(5)` `Edit(3)` `Bash(4)` `Agent(1)` — **13 calls total.**

---

## "Find Weird Stuff" — No Bug Report, No Bug Names

Session 3 was an experiment. Instead of describing what was broken, I wrote this:

```
Find and remove/fix all weird empty space at the top, broken-looking layout gaps,
and awkward UI artifacts. This includes unexpected blank areas, mispositioned overlays,
inconsistent spacing, and any obviously wrong mobile layout behavior.
```

No component names. No reproduction steps. No mention of what I suspected.

Claude ran `Read` 17 times. It went through `app/components/` file by file, then `globals.css`, then `app/page.tsx`, then each subpage. A full codebase sweep before writing a single line of output.

Three issues surfaced.

**The leaked dev tool.** `HeroBgPicker.tsx` — a floating color palette I built during development to test hero backgrounds — was still wired into the production layout. The button and color panel were rendering at `z-60` in the top-right corner of every page. Fully visible to every user. Classic dev tooling leak.

**The infinite animations.** `globals.css` had two keyframe animations: `floatingPop` and `floatingGlow`. Both attached to the bottom CTA button. Both using `animation-iteration-count: infinite`. Every page load, the button bounced and glowed indefinitely.

**The double blank lines.** `app/page.tsx` had duplicate empty lines between sections, creating uneven whitespace in the rendered layout.

The fixes were proportional to the problems.

`globals.css`: `infinite` → `1`. One word, one line. Double blank lines: removed. `HeroBgPicker.tsx`: replaced entirely with a minimal server component that just applies a fixed background color — all dev UI gone.

That last decision shows up in the tool log as `Write(1)`. Claude chose to rewrite the file rather than edit it. Since all the picker logic was going away anyway, a fresh server component was cleaner than editing around it.

```tsx
// Before: floating dev panel, z-60, color state, picker UI
// After:
export default function HeroBg() {
  return <div className="absolute inset-0 bg-[#f8f9fa]" />;
}
```

**Tool usage:** `Read(17)` `Edit(5)` `Bash(3)` `Agent(1)` `Write(1)` — **27 calls total.**

---

## Was Opus Overkill for UI Bugs?

All three sessions ran on `claude-opus-4-6`. That felt like overkill going in.

Session 3 changed my mind.

The vague prompt — "find weird stuff" — required building a mental model of what the codebase is *supposed* to look like before identifying what *deviates* from it. That's not mechanical file reading. It's inference. And some of those inferences aren't obvious:

**Is `HeroBgPicker.tsx` intentional production UI, or a dev tool that got left in?** You have to read the component to understand its purpose. A floating color picker with a panel that lets you swap background presets during development — that's clearly not a production feature. But that judgment requires reading enough context to make the call.

**Is `floatingPop infinite` a deliberate design choice?** It lives in `globals.css` right next to real production animation styles. Without reading the component that uses it, "bouncing forever" could look intentional.

If you've used Claude Code with Sonnet for debugging, you've probably noticed it makes fewer reads before forming conclusions. That's usually fine — fewer reads means faster results when you've given a clear target. But for an open-ended "find anything wrong" session, fewer reads means more assumptions. Wrong assumptions produce wrong fixes or missed bugs.

The model choice isn't about raw capability — it's about how much inference you're asking for under uncertainty.

For targeted bugs with specific reproduction steps → Sonnet.
For "I don't know what's broken, please find it" → Opus.

Full stats across all three sessions:

| Metric | Value |
|--------|-------|
| Sessions | 3 |
| Total tool calls | 41 |
| `Read` calls | 22 |
| `Edit` calls | 8 |
| `Bash` calls | 8 |
| `Write` calls | 1 |
| `Agent` calls | 2 |
| Files changed | 3 |
| Time elapsed | ~5 minutes |

The 22 reads aren't inefficiency — they're the work. Claude Code with Claude Opus reading your entire codebase before touching anything is exactly the behavior you want when the prompt is deliberately underspecified.

> You don't have to describe the bug. Read enough code and it finds itself.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
