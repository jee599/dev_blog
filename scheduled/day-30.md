---
title: "Open Source, MIT License, Fork of RTK — The Full Story"
published: false
description: "ContextZip's origin story: a fork of RTK that grew into a language-aware CLI output optimizer for AI agents."
tags:
  - opensource
  - rust
  - ai
  - programming
---

ContextZip exists because I kept running out of context window in Claude Code. Not because my code was too long, but because `npm install` output was eating 40% of it.

## The Origin

I was using RTK (Reduce Toolkit) — a Rust CLI that strips ANSI codes and deduplicates output. It helped. A 30-50% reduction in CLI noise. But I was still hitting context limits during build-heavy sessions.

The problem: RTK treats all output as plain text. It doesn't know that a Python traceback has "framework frames" and "application frames." It doesn't know that 40 TypeScript errors with the same message but different files are semantically identical. It can't distinguish deprecated warnings from security warnings.

## The Fork

I forked RTK and started adding what was missing:

**Week 1:** Language-aware stack trace filtering. Teach the tool to recognize Node.js, Python, Rust, Go, Java, and C# stack traces and strip framework frames. 412 tests.

**Week 2:** Semantic duplicate grouping. Instead of exact-match deduplication, pattern-based grouping that recognizes "same error, different location." 247 tests.

**Week 3:** Command-specific noise patterns. 102 CLI commands benchmarked. Progress bars, layer hashes, wheel-building logs, download indicators — each pattern tested individually. 397 tests.

Total: 1,056 tests. Three weeks of building. One goal: make AI context windows contain signal, not noise.

## The MIT License

ContextZip is MIT-licensed. Same as RTK. Fork it, modify it, use it commercially, contribute back. The only requirement is the license notice.

## The Numbers Today

- 1,056 tests
- 102 command patterns
- 6 language-specific stack trace filters
- 60-90% average noise reduction
- <1ms processing latency
- Zero runtime dependencies
- Single binary install

## What's Next

More language support (Ruby, Elixir, PHP). Smarter web content extraction. IDE plugin for non-terminal AI agents. Community-contributed patterns.

The core mission stays the same: your AI should read your code, not your npm warnings.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*This is part 30 of 30 in the ContextZip Daily series. Thanks for reading.*
