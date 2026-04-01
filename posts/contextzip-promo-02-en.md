---
title: "Stop Wasting Tokens on npm Install Noise"
published: true
description: "npm install dumps hundreds of deprecation warnings into your AI coding agent's context window. Here's how to filter them out automatically with one tool."
tags:
  - ai
  - productivity
  - webdev
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
hashnode_url: 'https://plzai.hashnode.dev/contextzip-promo-02'
id: 3442025
date: 'draft'
---

Run `npm install` in a medium-sized project. Count the deprecation warnings.

I counted 47 in one project. Each one says something like "This module is not supported and is kept for compatibility." Claude Code reads all 47. They're identical in meaning. They cost tokens. They push your actual code out of the context window.

## What npm Install Actually Outputs

```
npm warn deprecated inflight@1.0.6: This module is not supported...
npm warn deprecated @humanwhocodes/config-array@0.11.14: Use @eslint/config-array
npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
npm warn deprecated @humanwhocodes/object-schema@2.0.3: Use @eslint/object-schema
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated eslint@8.57.1: This version is no longer supported...
⸨████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░⸩ ⠏ reify:core-js-compat: timing reifyNode...
added 1247 packages in 18s
```

Your AI needs exactly one line from this: `added 1247 packages in 18s`. Everything else is noise.

## After ContextZip

```
added 1247 packages in 18s
💾 contextzip: 89,241 → 8,102 chars (91% saved)
```

91% reduction. 47 deprecation warnings → gone. Progress bars → gone. ANSI escape codes → gone. The install result is preserved.

## Install

```bash
cargo install contextzip
eval "$(contextzip init)"
```

No config. No per-project setup. It just works as a transparent shell proxy.

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
