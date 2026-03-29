---
title: "contextzip gain --graph: Watch Your Daily Savings Grow"
published: true
description: "ContextZip tracks every byte saved across all your sessions and shows cumulative impact over time. See how much cleaner your AI context has become."
tags:
  - ai
  - productivity
  - opensource
  - claudecode
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-29'
---

After a week of using ContextZip, run:

```bash
$ contextzip gain --graph

ContextZip Savings Report
═══════════════════════════

Daily:
Mon ████████████░░░░░░░░  31,204 chars (87 commands)
Tue ██████████████████░░  52,891 chars (142 commands)
Wed ████████████████░░░░  44,123 chars (118 commands)
Thu █████████████░░░░░░░  38,902 chars (104 commands)
Fri ██████████████████████ 61,203 chars (167 commands)
Sat ████░░░░░░░░░░░░░░░░  12,891 chars (34 commands)
Sun ██░░░░░░░░░░░░░░░░░░   8,204 chars (21 commands)

Week total: 249,418 chars saved (673 commands)
Avg per command: 370 chars saved
Top category: npm (42% of savings)
```

Concrete numbers. Daily breakdown. Which category of commands saves the most.

## What the Graph Tells You

**Spike days** are build-heavy days. Friday at 61K saved means lots of builds and test runs. Saturday at 12K means light coding.

**Top category** shows where your noise comes from. If npm is 42% of your savings, your JavaScript projects are the noisiest. If Docker is the top, you're doing lots of container work.

**Average per command** helps you understand the baseline. 370 chars per command means most commands have moderate noise. If it's 1,000+, you're running very noisy commands regularly.

## Monthly Rollup

```bash
$ contextzip gain --month

March 2026: 1,247,891 chars saved
             3,421 commands filtered
             Avg: 365 chars/command
             Peak day: Mar 14 (89,204 chars)
```

Over a month, the savings add up to millions of characters — hundreds of thousands of tokens. At current AI pricing, that's measurable cost savings.

## Try It

```bash
cargo install contextzip
eval "$(contextzip init)"
```

Use it for a week. Then run `contextzip gain --graph` and see your own numbers.

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
