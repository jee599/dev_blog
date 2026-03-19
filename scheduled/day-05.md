---
title: "I Benchmarked 102 CLI Commands — Here's How Much Context They Waste"
published: false
description: "Real benchmark data from 102 common CLI commands showing how much output is noise vs. signal for AI agents."
tags:
  - ai
  - productivity
  - programming
  - opensource
---

I ran 102 common CLI commands through ContextZip and measured the before/after output size. The results were worse than I expected.

## The Numbers

| Command Category | Avg. Reduction | Worst Case |
|---|---|---|
| `npm install` | 61-91% | 94% (large monorepo) |
| Node.js stack traces | 70-85% | 92% (nested async) |
| `pip install` | 55-75% | 88% (building wheels) |
| Python tracebacks | 60-80% | 95% (Django stack) |
| `cargo build` | 40-60% | 78% (many warnings) |
| Rust panics | 72-80% | 89% (tokio runtime) |
| `docker build` | 75-86% | 91% (multi-stage) |
| Go panics | 85-97% | 97% (goroutine dump) |
| `git` operations | 5-15% | 30% (large diff) |
| Java/Spring traces | 80-90% | 95% (Spring Boot) |

The pattern is clear: the more "framework" a command involves, the more noise it produces. Package managers and framework stack traces are the biggest offenders. Simple commands like `git status` or `ls` have minimal waste.

## The Worst Offender

Go goroutine panics. When a Go program crashes with multiple goroutines, the runtime dumps every goroutine's stack. A crash with 50 goroutines can produce 2,000+ lines. Your bug is usually in the first 5 lines. 97% reduction.

## The Surprising One

`pip install` with `--verbose`. 88% of the output is wheel-building progress that means nothing to an AI debugging your import error.

## What This Means

If you're using Claude Code, Cursor, or any AI coding agent, roughly 60-80% of your CLI output context is wasted on noise. That's context that could hold your actual code.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

Every command shows its savings inline: `💾 contextzip: 200 → 40 chars`. You see exactly what you're saving.

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
