---
title: "Track Every Token You Save With contextzip gain"
published: true
description: "ContextZip tracks cumulative token savings across sessions. See exactly how much AI context window space you've reclaimed over days and weeks."
tags:
  - ai
  - productivity
  - claudecode
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-14'
id: 3496060
date: 'draft'
---

How much context are you actually saving? ContextZip tracks it.

```bash
$ contextzip gain
Today:     42,891 chars saved (23 commands)
This week: 287,432 chars saved (156 commands)
All time:  1,247,891 chars saved (892 commands)
```

Every command that runs through ContextZip records its before/after size. `contextzip gain` shows you the cumulative numbers.

## Why This Matters

"60-90% savings" sounds abstract until you see the concrete numbers from your own workflow. After one day of normal development:

- 23 commands ran through the proxy
- 42,891 characters of noise were stripped
- That's roughly 10,000 tokens saved
- At Claude's pricing, that's real money over time

After a week, the numbers compound. A typical development week generates 150-200 CLI commands. At 60-80% noise per command, you're looking at 200K-300K characters saved per week.

## Per-Command Visibility

Every command shows its savings inline:

```
$ npm test
PASS src/utils.test.ts
PASS src/api.test.ts
Tests: 24 passed, 24 total
💾 contextzip: 8,421 → 312 chars (96% saved)
```

You see the savings in real-time, for every command.

## The Graph

```bash
$ contextzip gain --graph
Mon ████████████░░░░░░░░ 31,204
Tue ██████████████████░░ 52,891
Wed ████████████████░░░░ 44,123
Thu █████████████░░░░░░░ 38,902
Fri ██████████████████████ 61,203
```

A daily bar chart of characters saved. Useful for understanding which days generate the most CLI noise (build days, deployment days).

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
