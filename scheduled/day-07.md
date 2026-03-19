---
title: "The Hidden Cost of ANSI Color Codes in AI Context"
published: false
description: "ANSI escape codes are invisible to you but consume real tokens in your AI's context window."
tags:
  - ai
  - programming
  - productivity
  - claudecode
---

Open your terminal. Run `ls --color`. The filenames look normal to you — colored by type.

Now look at what your AI actually receives:

```
\x1b[0m\x1b[01;34mnode_modules\x1b[0m  \x1b[01;34mpublic\x1b[0m  \x1b[01;34msrc\x1b[0m
\x1b[00mpackage.json\x1b[0m  \x1b[00mtsconfig.json\x1b[0m  \x1b[01;32mstart.sh\x1b[0m
```

Every color is an escape sequence: `\x1b[01;34m` for blue, `\x1b[0m` for reset. These sequences are 7-12 bytes each. In a colorful terminal output, they can add 20-40% overhead.

Your AI can't see colors. But it reads every escape byte.

## It Gets Worse

ANSI codes aren't just colors. They include:
- **Cursor movement** — spinners and progress bars use these
- **Line clearing** — `\x1b[2K` erases the current line
- **Bold, underline, blink** — decorations your AI can't render

A single `npm install` progress bar animation generates hundreds of cursor movement codes. Each one is invisible in your terminal but visible (and costly) in the AI's context.

## Before vs After

**Before** (raw colored output):
```
\x1b[1m\x1b[32m✓\x1b[39m\x1b[22m Compiled successfully in 2.3s
\x1b[2m\x1b[90m  File sizes after gzip:\x1b[22m\x1b[39m
\x1b[2m\x1b[90m  \x1b[22m\x1b[39m\x1b[1m48.2 kB\x1b[22m  \x1b[36mbuild/static/js/main.abc123.js\x1b[39m
```

**After** (through ContextZip):
```
✓ Compiled successfully in 2.3s
  File sizes after gzip:
  48.2 kB  build/static/js/main.abc123.js
💾 contextzip: 312 → 142 chars (54% saved)
```

Same information. No invisible escape codes. 54% smaller.

```bash
cargo install contextzip
eval "$(contextzip init)"
```

**GitHub:** [github.com/contextzip/contextzip](https://github.com/contextzip/contextzip)
