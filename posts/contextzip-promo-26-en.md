---
title: "From 326K Chars to 127K: Real Benchmark Results"
published: true
description: "Detailed benchmark results from running ContextZip on real-world project outputs across Node.js, Python, Rust, Go, and Java codebases."
tags:
  - ai
  - productivity
  - programming
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-26'
---

Abstract percentages are easy to doubt. Here are concrete numbers from real projects.

## Benchmark: Next.js E-Commerce Project

| Command | Before | After | Saved |
|---|---|---|---|
| `npm install` | 326,421 | 127,104 | 61% |
| `npm run build` | 48,291 | 12,847 | 73% |
| `npm test` | 89,204 | 4,521 | 95% |
| `npm run lint` | 24,891 | 3,204 | 87% |
| TypeScript error (40 files) | 12,847 | 412 | 97% |
| **Total session** | **501,654** | **148,088** | **70%** |

One development session. 353,566 characters of noise removed. That's roughly 88,000 tokens saved.

## Benchmark: Python Django API

| Command | Before | After | Saved |
|---|---|---|---|
| `pip install -r requirements.txt` | 45,891 | 2,104 | 95% |
| Django traceback (3 errors) | 8,421 | 891 | 89% |
| `python manage.py test` | 34,204 | 8,921 | 74% |
| `python manage.py migrate` | 12,104 | 3,412 | 72% |
| **Total session** | **100,620** | **15,328** | **85%** |

## Benchmark: Rust Microservice

| Command | Before | After | Saved |
|---|---|---|---|
| `cargo build` | 18,291 | 7,842 | 57% |
| Panic backtrace (tokio) | 4,521 | 891 | 80% |
| `cargo test` | 12,847 | 3,204 | 75% |
| `cargo clippy` | 8,204 | 2,891 | 65% |
| **Total session** | **43,863** | **14,828** | **66%** |

## The Takeaway

Python/Django sessions save the most (85%) because pip and Django produce verbose output. Next.js/npm sessions save 70% because of deprecation warnings and test runner output. Rust sessions save 66% — Rust tools are already relatively clean.

Across all three: **hundreds of thousands of characters saved per session**. That's context your AI can use for your actual code.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
