---
title: "Docker Build Failed? ContextZip Keeps the Context That Matters"
published: false
description: "When Docker builds fail, the error is buried in 100+ lines of cached layer output. ContextZip surfaces the actual failure line automatically."
tags:
  - ai
  - devops
  - productivity
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
---

Docker build failed. The error is on line 47 of 120. Lines 1-46 are cached layer confirmations. Lines 48-120 are cleanup output. Your AI reads all 120 lines to find the one error.

## Before: Failed Docker Build

```
[+] Building 52.1s (8/12)
 => [internal] load build definition from Dockerfile                    0.0s
 => [internal] load metadata for docker.io/library/node:20-alpine      1.1s
 => CACHED [build 1/6] FROM docker.io/library/node:20-alpine@sha256... 0.0s
 => CACHED [build 2/6] WORKDIR /app                                    0.0s
 => CACHED [build 3/6] COPY package*.json ./                           0.0s
 => [build 4/6] RUN npm ci --production                               38.2s
 => [build 5/6] COPY . .                                               0.3s
 => ERROR [build 6/6] RUN npm run build                                12.5s
------
 > [build 6/6] RUN npm run build:
#12 2.341 > myapp@1.0.0 build
#12 2.341 > tsc && next build
#12 4.892
#12 4.892 src/pages/index.tsx(15,3): error TS2322: Type 'string' is not assignable to type 'number'.
#12 4.892
------
Dockerfile:14
--------------------
  13 |     COPY . .
  14 | >>> RUN npm run build
  15 |
--------------------
ERROR: failed to solve: process "/bin/sh -c npm run build" did not complete successfully: exit code: 1
```

23 lines. The error is `TS2322: Type 'string' is not assignable to type 'number'` in `src/pages/index.tsx:15`.

## After: Through ContextZip

```
ERROR [build 6/6] RUN npm run build
src/pages/index.tsx(15,3): error TS2322: Type 'string' is not assignable to type 'number'.
ERROR: failed to solve: exit code: 1
💾 contextzip: 1,847 → 198 chars (89% saved)
```

Cached layers stripped. Build step numbers stripped. The error, its source location, and the final failure status preserved. 89% reduction.

ContextZip recognizes Docker-specific patterns: `CACHED` lines are noise, `ERROR` lines are signal, layer hashes are noise, Dockerfile references with `>>>` are signal.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
