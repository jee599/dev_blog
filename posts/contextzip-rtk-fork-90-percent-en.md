---
title: "RTK Saves 60% of Tokens. I Made It Save 90%."
published: true
description: "I forked RTK (Rust Token Killer) and added 6 filters for error stacktraces, Docker builds, and package install noise. Here's what changed."
tags:
  - rust
  - cli
  - opensource
  - ai
---

RTK is one of the best tools in the Claude Code ecosystem. 28k GitHub stars, 60-90% token savings on git, test, and ls output, 34 command modules with TOML-based filters. If you use Claude Code and don't have RTK installed, go install it now.

But RTK has blind spots. It doesn't compress error stacktraces. It doesn't touch npm install warnings. It passes Docker build logs through unchanged. And ANSI escape codes — spinners, progress bars, color codes — all of that noise flows straight into your context window.

I forked RTK and built ContextZip to fill those gaps. Here's a direct comparison.


## What RTK Does vs. What ContextZip Adds

| Category | RTK | ContextZip |
|:---------|:---:|:----------:|
| git diff/log/status | Yes | Yes (inherited) |
| ls/find/tree | Yes | Yes (inherited) |
| test output (Jest, pytest) | Yes | Yes (inherited) |
| cargo/rustc output | Yes | Yes (inherited) |
| Error stacktraces | No | Yes — 5 languages |
| ANSI/spinner cleanup | No | Yes — preprocessor |
| npm/pip install noise | No | Yes — keeps security |
| Docker build logs | No | Yes — 88% avg savings |
| Build error grouping | No | Yes — deduplicates |
| Web page extraction | No | Yes — article only |

ContextZip inherits all 34 of RTK's command modules and 60+ TOML filters unchanged. Everything RTK compresses, ContextZip compresses identically. The 6 new filters run on output that RTK passes through untouched.


## The 6 New Filters

**Error stacktrace compression.** Node.js, Python, Rust, Go, Java. Strips framework and library frames, keeps your code frames and the error message. A 30-line Express stacktrace becomes 3 lines. 93% savings on Node.js, 80% on Rust, 58.7% average across all languages.

**ANSI preprocessor.** Runs before all other filters. Strips escape codes, cursor movement sequences, spinner characters (⠋⠙⠹⠸), progress bars, and decoration lines. Preserves error markers, timestamps, and warning prefixes. 82.5% average savings.

**Package install compression.** Removes `npm warn deprecated` spam (often 40+ identical lines), pip download progress, yarn resolution noise. Keeps the install summary, security audit results, and any vulnerability warnings. 95% savings on npm, with zero security information lost.

**Docker build compression.** On success: collapses all layer hashes and pull progress into a single summary line with stage count and duration. On failure: preserves the failing step, error output, and surrounding context. 88.2% average, up to 97% on large multi-stage builds.

**Build error grouping.** 40 identical `TS2322: Type 'string' is not assignable to type 'number'` errors become one group with all file:line references listed. The error message appears once, the locations appear as a compact list. 55.6% average savings.

**Web page extraction.** `contextzip web <url>` fetches a page and strips navigation, footer, sidebar, cookie banners, ads, and script tags. Returns the main content with code blocks and tables preserved. Useful for pulling documentation into context without the chrome.


## 102-Test Benchmark: The Honest Numbers

| Category | Cases | Avg Savings | Best | Worst |
|:---------|------:|------------:|-----:|------:|
| Docker build | 10 | 88.2% | 97% | 77% |
| ANSI/spinners | 15 | 82.5% | 98% | 41% |
| Error stacktraces | 20 | 58.7% | 97% | 2% |
| Build errors | 15 | 55.6% | 90% | -10% |
| Package install | 12 | 72.3% | 95% | 15% |
| Web extraction | 10 | 68.4% | 89% | 34% |
| **Weighted total** | **102** | **61.1%** | | |

The worst cases are real. Rust panics with short traces: 2% savings. Single build errors: -10% (formatting overhead exceeds noise removed). These edge cases use threshold passthrough — if compression ratio drops below 10%, the original output passes through unchanged.

Combined with RTK's inherited filters, total savings on a typical debugging session run 70-90%.


## Safety Guarantees

ContextZip is aggressive on noise but conservative on signal. Three rules are never broken:

1. **Error messages are never removed.** The actual error text — `TypeError`, `ENOENT`, `panic!`, segfault — always passes through.
2. **Security warnings are never removed.** `npm audit` vulnerabilities, CVE references, and authentication failures are preserved.
3. **Test failure details are never removed.** Expected vs actual values, assertion messages, and failing test names all pass through.

If a filter can't confidently classify something as noise, it passes it through unchanged.


## Migrating from RTK

```bash
# Uninstall RTK (optional — they don't conflict)
# Install ContextZip
curl -fsSL https://raw.githubusercontent.com/jee599/contextzip/main/install.sh | bash
```

The install script sets up the Claude Code hook automatically. Restart Claude Code and you're done. If you had RTK's hook configured, ContextZip replaces it — same hook mechanism, same binary location pattern.

Your existing workflow doesn't change. Every command you run in Claude Code is compressed automatically. The only visible difference: the savings line now says `contextzip` instead of `rtk`, and the numbers are higher on error-heavy sessions.

---

- [GitHub: jee599/contextzip](https://github.com/jee599/contextzip)
- [102-test benchmark results](https://github.com/jee599/contextzip/blob/main/docs/benchmark-results.md)
