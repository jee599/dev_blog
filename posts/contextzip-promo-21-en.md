---
title: "Why RTK Wasn't Enough (And What I Added)"
published: true
description: "ContextZip started as a fork of RTK (Reduce Toolkit) for basic output cleaning. Here's what was missing and what I built to make it AI-aware."
tags:
  - rust
  - opensource
  - ai
  - productivity
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-21'
id: 3380632
date: '2026-03-21T14:51:52.330Z'
---

RTK (Reduce Toolkit) is a solid Rust CLI for reducing AI context size. I used it daily. Then I hit its limits.

RTK handles ANSI stripping and basic deduplication well. But real-world CLI output has patterns RTK doesn't catch. I forked it and built ContextZip.

## What RTK Does Well

- ANSI escape code removal
- Basic line deduplication
- Character count reporting
- Clean Rust codebase

## What Was Missing

**1. Language-aware stack trace filtering.** RTK treats stack traces as plain text. It doesn't know that `node:internal/modules/cjs/loader` is a framework frame and `/app/src/server.ts` is your code. ContextZip recognizes stack trace formats for Node.js, Python, Rust, Go, Java, and C# — and strips framework frames while keeping application frames.

**2. Semantic duplicate grouping.** RTK deduplicates exact matches. But 40 TypeScript errors with the same message but different file paths aren't exact duplicates. ContextZip groups by error pattern, not exact string match.

**3. Command-specific patterns.** `npm install` progress bars use ANSI cursor movement, not just color codes. Docker layer IDs are unique strings that RTK won't deduplicate. ContextZip has 102 command-specific patterns.

**4. Savings tracking.** `contextzip gain` tracks your cumulative savings over time. RTK only reports per-command stats.

**5. Web content extraction.** When AI agents fetch web pages, the HTML structure is noise. ContextZip extracts content from HTML.

## The Numbers

RTK on a typical session: 30-50% reduction.
ContextZip on the same session: 60-90% reduction.

The difference is language-aware filtering and semantic grouping. Generic text processing gets you halfway. Understanding the *meaning* of the output gets you the rest.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
