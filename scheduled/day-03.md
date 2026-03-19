---
title: "Your Node.js Stack Traces Are Eating Your Context Window"
published: false
description: "Node.js errors include dozens of internal framework frames. Your AI reads all of them. It doesn't need to."
tags:
  - ai
  - claudecode
  - programming
  - productivity
---

A typical Node.js error stack trace is 30-50 lines. Your code caused maybe 3 of those lines. The other 27-47 are `node:internal/modules/cjs/loader`, `node:internal/modules/run_main`, and friends.

Claude Code reads them all. Every `at Module._compile` frame. Every `at node:internal/main/run_main_module` frame. They add nothing to debugging but cost real tokens.

## Before: Raw Stack Trace

```
Error: Cannot find module './config'
    at Module._resolveFilename (node:internal/modules/cjs/loader:1075:15)
    at Module._load (node:internal/modules/cjs/loader:920:27)
    at Module.require (node:internal/modules/cjs/loader:1141:19)
    at require (node:internal/modules/cjs/helpers:110:18)
    at Object.<anonymous> (/app/src/server.ts:4:18)
    at Module._compile (node:internal/modules/cjs/loader:1254:14)
    at Module._extensions..js (node:internal/modules/cjs/loader:1308:10)
    at Module.load (node:internal/modules/cjs/loader:1117:32)
    at Module._load (node:internal/modules/cjs/loader:958:12)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:81:12)
    at node:internal/main/run_main_module:23:47
```

11 lines. Your AI needs 2: the error message and `/app/src/server.ts:4:18`.

## After: Through ContextZip

```
Error: Cannot find module './config'
    at Object.<anonymous> (/app/src/server.ts:4:18)
💾 contextzip: 612 → 89 chars (85% saved)
```

The internal Node.js frames are stripped. The error and your code's frame remain. 85% less context consumed.

## How It Works

ContextZip recognizes framework stack frame patterns — `node:internal/*`, `node_modules/*`, and runtime internals. It keeps the error message and your application frames. The filter runs automatically on every command output.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

Zero config. Your debugging context stays clean.

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
