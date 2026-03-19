---
title: "ANSI Spinners, Progress Bars, Decorations — All Gone"
published: false
description: "Terminal animations look great for humans but consume real tokens in AI context. ContextZip strips them all."
tags:
  - ai
  - productivity
  - programming
  - claudecode
---

Watch your terminal during `npm install`. See that spinning dot? That progress bar crawling across the screen? Those are ANSI animations — cursor movements that redraw the same line hundreds of times.

You see one line updating smoothly. Your AI sees hundreds of cursor movement commands stacked on top of each other.

## How Terminal Animations Work

A spinner works by:
1. Print `⠋ Loading...`
2. Move cursor to start of line (`\x1b[G`)
3. Print `⠙ Loading...`
4. Move cursor to start of line
5. Repeat 200 times

Your terminal shows one smooth animation. The raw output is 200 lines of text with cursor movement codes. Your AI ingests all 200.

A progress bar is worse:
```
\x1b[2K\x1b[1A\x1b[2K\x1b[G⸨░░░░░░░░░░░░░░░░░░░░⸩ 5%
\x1b[2K\x1b[1A\x1b[2K\x1b[G⸨█░░░░░░░░░░░░░░░░░░░⸩ 10%
\x1b[2K\x1b[1A\x1b[2K\x1b[G⸨██░░░░░░░░░░░░░░░░░░⸩ 15%
... (17 more updates)
\x1b[2K\x1b[1A\x1b[2K\x1b[G⸨████████████████████⸩ 100%
```

20 versions of the same progress bar. Each with 30+ bytes of escape codes. Your AI reads them all.

## After ContextZip

```
added 847 packages in 12s
💾 contextzip: 12,847 → 142 chars (99% saved)
```

All spinner frames → gone. All progress bar updates → gone. All cursor movement codes → gone. The final result preserved.

99% savings on animation-heavy output. This is where ANSI stripping alone (which RTK does) falls short — you need to understand that cursor movement codes mean "this line replaces the previous one" and collapse them.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
