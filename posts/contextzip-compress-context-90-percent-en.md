---
title: "I Compressed Claude Code's Context by 90% — Here's How"
published: true
description: "Claude Code wastes tokens on npm warnings, Docker hashes, and stacktrace noise. ContextZip strips 90% of it before it reaches the context window."
tags:
  - ai
  - claudecode
  - productivity
  - opensource
hashnode_url: 'https://plzai.hashnode.dev/contextzip-compress-context-90-percent'
---

My Claude Code session died mid-debug. Not because the problem was hard — because `npm install` dumped 150 lines of deprecated warnings into the context window.

That's the real cost of context waste. It's not about money (though tokens aren't free). It's about Claude forgetting the code you showed it 5 minutes ago because the window is stuffed with noise.

I measured it. A typical Node.js debugging session generates 3,000-5,000 tokens of command output. Over 60% is framework frames, ANSI escape codes, progress spinners, and package manager chatter. Claude reads all of it. Claude learns nothing from it.

So I built ContextZip. It sits between your shell and Claude Code, compressing every command output before it reaches the context window. Here are real before/after results.


## Node.js Error Stacktrace: 93% Saved

```diff
- TypeError: Cannot read properties of undefined (reading 'id')
-     at getUserProfile (/app/src/api/users.ts:47:23)
-     at processAuth (/app/src/middleware/auth.ts:12:5)
-     at Layer.handle (/app/node_modules/express/lib/router/layer.js:95:5)
-     at next (/app/node_modules/express/lib/router/route.js:149:13)
-     at Route.dispatch (/app/node_modules/express/lib/router/route.js:119:3)
-     ... 22 more node_modules frames

+ TypeError: Cannot read properties of undefined (reading 'id')
+   → src/api/users.ts:47         getUserProfile()
+   → src/middleware/auth.ts:12   processAuth()
+   (+ 27 framework frames hidden)
```

30 lines become 3. Claude sees the error message and your code. Not Express internals.


## npm install: 95% Saved

```diff
- npm warn deprecated inflight@1.0.6: This module is not supported...
- npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4...
- npm warn deprecated glob@7.2.3: Glob versions prior to v9...
- npm warn deprecated @humanwhocodes/object-schema@2.0.3...
- npm warn deprecated @humanwhocodes/config-array@0.13.0...
- npm warn deprecated eslint@8.57.1: This version is no longer...
- ... 40 more deprecation warnings
- added 847 packages in 12s

+ added 847 packages in 12s
+ (46 deprecation warnings removed — 0 security issues)
```

The install summary and security warnings stay. The 46 identical "deprecated" lines vanish.


## Docker Build: 96% Saved

```diff
- #1 [internal] load build definition from Dockerfile
- #1 sha256:a3b4c5d6e7f8... 0.0s done
- #2 [internal] load metadata for docker.io/library/node:20-alpine
- #2 sha256:b4c5d6e7f8a9... 1.2s done
- #3 [1/8] FROM docker.io/library/node:20-alpine@sha256:c5d6e7f8...
- #3 sha256:c5d6e7f8a9b0... 0.0s done
- ... 45 more layer lines with sha256 hashes

+ ✓ Docker build completed (8 stages, 12.4s)
+ Image: myapp:latest (145MB)
```

On success, you get one line. On failure, the error context is preserved in full.


## 5-Second Install

```bash
curl -fsSL https://raw.githubusercontent.com/jee599/contextzip/main/install.sh | bash
```

Restart Claude Code. That's it. Every command output is now compressed automatically through Claude Code's hook system.


## See Your Savings

Run `contextzip gain` anytime to check cumulative savings:

```
ContextZip Token Savings Report
═══════════════════════════════
Total commands processed:  247
Total input tokens:        48,291
Total output tokens:       14,487
Total saved:               33,804 (70.0%)

By feature:
  error_stacktrace    8,412 saved (93.2%)
  docker_build        6,891 saved (96.1%)
  ansi_cleanup        5,244 saved (82.5%)
  npm_install         4,102 saved (95.3%)
  build_errors        3,891 saved (55.6%)
```

Every filter tracks its own savings independently. You know exactly where the compression comes from.


## What It Doesn't Touch

ContextZip never removes error messages, security warnings, or test failure details. The filters are aggressive on noise but conservative on signal. If `npm audit` finds a critical vulnerability, you'll see it. If a test assertion fails, you'll see the expected vs actual values.

The compression is lossy by design — but it only loses the parts Claude was going to ignore anyway.

---

- [GitHub: jee599/contextzip](https://github.com/jee599/contextzip)
- [102-test benchmark results](https://github.com/jee599/contextzip/blob/main/docs/benchmark-results.md)
