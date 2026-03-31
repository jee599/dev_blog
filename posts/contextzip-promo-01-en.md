---
title: "One Command to Save 90% of Your Claude Code Tokens"
published: true
description: "CLI output floods your AI context window with noise — deprecation warnings, ANSI codes, progress bars. One command strips it all automatically."
tags:
  - ai
  - claudecode
  - productivity
  - opensource
series: "ContextZip Daily"
canonical_url: "https://github.com/jee599/contextzip"
---

You just ran `npm install` inside Claude Code. 847 lines of output. Deprecation warnings, progress bars, ANSI color codes, duplicate messages.

Claude read every single one of them. And now your context window is 30% smaller.

## The Problem

Every CLI command you run inside an AI coding agent dumps its raw output into the context window. Most of that output is noise — framework frames in stack traces, repeated warnings, spinner animations, color escape codes.

Your AI doesn't need any of it. But it pays for all of it.

## Before / After

**Before** (raw `npm install`):
```
npm warn deprecated inflight@1.0.6: This module is not supported...
npm warn deprecated glob@7.2.3: Glob versions prior to v9...
npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4...
added 847 packages in 12s
```
326,000 characters fed into context.

**After** (through ContextZip):
```
added 847 packages in 12s
💾 contextzip: 326,421 → 127,104 chars (61% saved)
```
127,000 characters. Same useful information. 61% less noise.

## One Command

```bash
cargo install contextzip
eval "$(contextzip init)"
```

That's it. ContextZip wraps your shell as a transparent proxy. Every command you run gets its output cleaned automatically — no config files, no per-command setup.

It strips ANSI codes, collapses duplicate warnings, removes framework stack frames, and groups identical errors. The original command behavior is completely unchanged.

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)

5 seconds to install. Works with Claude Code, Cursor, Windsurf, or any AI agent that runs CLI commands.

---

*Part of the [ContextZip Daily](https://dev.to/ji_ai/series/contextzip-daily) series. Follow for daily tips on optimizing your AI coding workflow.*

**Install:** `npx contextzip` | **GitHub:** [jee599/contextzip](https://github.com/jee599/contextzip)
