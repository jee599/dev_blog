---
title: "The Architecture of a Transparent CLI Proxy"
published: false
description: "How ContextZip intercepts command output without changing command behavior. A look at the proxy architecture."
tags:
  - rust
  - programming
  - opensource
  - ai
---

ContextZip wraps your shell commands without changing their behavior. No modified binaries. No PATH manipulation. No LD_PRELOAD tricks. Here's how.

## The Shell Function Approach

`contextzip init` outputs a shell function. For zsh:

```bash
contextzip_exec() {
  local output
  output=$("$@" 2>&1)
  local exit_code=$?
  echo "$output" | contextzip filter
  return $exit_code
}
```

This simplified version shows the core idea. The real implementation handles:
- Separate stdout/stderr capture
- Signal forwarding (Ctrl+C propagation)
- TTY detection (interactive vs. pipe mode)
- Streaming for long-running commands

## The Filter Pipeline

When output enters `contextzip filter`, it passes through a pipeline of processors:

```
Raw Output
  → ANSI Stripper (remove escape codes)
  → Pattern Detector (identify output type)
  → Stack Trace Filter (language-specific)
  → Duplicate Grouper (semantic matching)
  → Noise Remover (progress bars, spinners)
  → Stats Reporter (savings calculation)
Clean Output
```

Each stage is independent. If the pattern detector identifies a Python traceback, the stack trace filter uses Python-specific rules. If it detects npm output, the noise remover applies npm-specific patterns.

## Why Rust

The proxy adds a processing step to every command. That step needs to be fast enough to be invisible. Rust gives us:

- **Zero-copy parsing** where possible
- **No garbage collection pauses**
- **Stream processing** — output is filtered as it arrives, not buffered
- **Single binary** — no runtime dependencies

In benchmarks, ContextZip adds <1ms of latency to command execution. The compile time savings from reduced context far outweigh this.

## The Transparency Contract

ContextZip guarantees:
1. Exit codes pass through unchanged
2. Stderr and stdout remain separate
3. No output is added except the savings line
4. Signals propagate to the child process

Your CI/CD scripts, test runners, and build tools work exactly as before.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
