---
title: "Building a 1,056-Test Rust CLI Without Writing Rust — Claude Code Did It"
published: true
description: "I shipped a 40-module Rust CLI with 1,056 tests and 102 benchmarks. I don't write Rust. Claude Code does."
tags:
  - ai
  - rust
  - devops
  - programming
---

I don't write Rust. I can read it well enough to catch obvious bugs, but I've never typed `impl` or `fn main()` from scratch. Yet I shipped a 40-module Rust CLI with 1,056 tests in 3 weeks.

Claude Code wrote every line of Rust. I wrote prompts, reviewed diffs, and made architecture decisions. The tool — ContextZip — compresses Claude Code's own context window. So the AI built a tool to make itself work better. That irony wasn't lost on me.

Here's exactly how the process worked, including the parts that went wrong.


## The Subagent Pattern

I never gave Claude Code a vague instruction like "build a context compressor." Every task was a subagent dispatch — a scoped prompt with clear inputs, expected outputs, and test requirements.

A typical dispatch:

> "Implement an error stacktrace filter for Node.js. Input: raw stderr with Express middleware frames. Output: error message + user code frames only. Write 20+ test cases covering nested errors, empty traces, and mixed stdout/stderr. Put the filter in `src/filters/error_stacktrace.rs`."

The subagent implements, writes tests, runs them. Then I dispatch a second subagent to review:

> "Review the error_stacktrace filter. Check edge cases: what happens with zero frames? Frames with no file path? Stack traces inside JSON output?"

This two-agent cycle — implement, then review — caught 80% of bugs before I even looked at the code.


## Week 1: Fork and Rename

The foundation was RTK (Rust Token Killer), an open-source CLI with 34 command modules, 60+ TOML filters, and 950 tests. I forked it and dispatched a subagent to rename every reference from "rtk" to "contextzip" across 70 files.

1,544 insertions, 1,182 deletions. All 950 tests still passing. Then three agents worked in parallel: one on the install script, one on GitHub Actions CI/CD for 5 platforms, one extending the SQLite tracking system.

By Friday: `curl | bash` installs the binary on Linux or macOS, and `contextzip gain --by-feature` shows per-filter savings.


## Week 2: The 6 New Filters

This is where ContextZip stops being a rename and starts being a product. Six new compression filters, each built by a subagent cycle:

1. **Error stacktraces** — strips framework frames from Node.js, Python, Rust, Go, Java
2. **ANSI preprocessor** — removes escape codes, spinners, progress bars
3. **Web page extraction** — strips nav, footer, ads, keeps article content
4. **Build error grouping** — collapses 40 identical TypeScript errors into one group
5. **Package install compression** — removes deprecated warnings, keeps security alerts
6. **Docker build compression** — success = 1 line, failure = full context

Each filter got 15-20 dedicated test cases. The error stacktrace filter alone has 20 tests covering 5 languages.


## Week 3: Benchmarks and Honest Failures

I ran 102 benchmark tests with production-scale inputs. The results were not uniformly impressive.

| Category | Cases | Avg Savings | Best | Worst |
|:---------|------:|------------:|-----:|------:|
| Docker build | 10 | 88.2% | 97% | 77% |
| ANSI/spinners | 15 | 82.5% | 98% | 41% |
| Error stacktraces | 20 | 58.7% | 97% | 2% |
| Build errors | 15 | 55.6% | 90% | -10% |

Rust panic compression started at 2%. The subagent's first implementation only stripped the backtrace header line. I rewrote the prompt with explicit examples of Rust panic output and dispatched again. It landed at 80%.

Java stacktrace compression went negative (-12%) on short traces. The formatted output was longer than the raw input. I added a threshold: if compression ratio is below 10%, pass through the original output unchanged. Final result: 20% savings on Java, no negative cases.

Build error grouping hit -10% on single-error inputs. Same fix — threshold passthrough.

Lying about benchmarks is worse than imperfect numbers. The README shows every result, including the weak spots.


## What I Actually Did vs. What Claude Did

**Me:** Architecture decisions, prompt design, review, quality gates, benchmark analysis, bug triage.

**Claude Code:** All Rust implementation, test writing, CI/CD configuration, README generation, install script.

The split was roughly 20% me (thinking, reviewing, deciding) and 80% Claude (typing, testing, building). But that 20% was the difference between shipping and not shipping. Without review cycles, the Rust panic filter would still be at 2%.


## Final Stats

- 1,056 tests, 0 failures
- 102 benchmark cases
- 40+ command modules (34 inherited + 6 new)
- 5-platform CI/CD (Linux x86/musl, macOS arm64/x86, Windows)
- 3 install methods (curl, Homebrew, cargo)
- README in 4 languages

The tool works. I use it daily. My Claude Code sessions last 40-60% longer before hitting context limits. The AI built a tool to extend its own memory, and the humans reviewing it are the reason it actually works.

---

- [GitHub: jee599/contextzip](https://github.com/jee599/contextzip)
- [102-test benchmark results](https://github.com/jee599/contextzip/blob/main/docs/benchmark-results.md)
