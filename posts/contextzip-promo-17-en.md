---
title: "How I Built a 1,056-Test Rust CLI in 3 Weeks"
published: true
description: "Building ContextZip in Rust: 1,056 tests, pattern-based output filtering, zero runtime dependencies, and sub-millisecond processing latency."
tags:
  - rust
  - opensource
  - programming
  - ai
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-17'
id: 3511297
date: '2026-04-17T01:15:53.802Z'
---

ContextZip started as a fork of RTK (Reduce Toolkit). Three weeks later, it was a different tool with 1,056 tests and coverage for 102 CLI command patterns.

Here's what building it looked like.

## Week 1: The Core Filters

The first week was ANSI stripping and duplicate detection. ANSI codes seem simple until you hit edge cases — partial sequences, nested attributes, malformed escapes from buggy tools. 247 tests just for ANSI handling.

Duplicate detection was harder. "Duplicate" doesn't mean "identical." These lines are duplicates in meaning:

```
npm warn deprecated inflight@1.0.6: This module is not supported...
npm warn deprecated glob@7.2.3: Glob versions prior to v9...
```

Both are "npm deprecated" warnings. The package names differ but the pattern is the same. ContextZip groups by pattern, not exact match.

## Week 2: Stack Trace Intelligence

Each language has different stack trace formats. Node.js uses `at Function (file:line:col)`. Python uses `File "path", line N, in function`. Rust uses numbered frames with `at path:line`. Go dumps entire goroutine stacks.

For each language, ContextZip needs to know which frames are "framework" and which are "yours." The heuristic: paths containing `node_modules`, standard library paths, runtime internals → framework. Everything else → application code.

412 tests for stack trace filtering across 6 languages.

## Week 3: Command-Specific Patterns

Package managers, build tools, Docker, git — each has its own noise patterns. Progress bars in pip, layer hashes in Docker, tree-shaking stats in webpack. 102 command patterns tested individually.

## The Result

1,056 tests. Zero false positives in the benchmark suite (no useful information stripped). 60-90% average noise reduction across all tested commands. Written in Rust for zero overhead.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
