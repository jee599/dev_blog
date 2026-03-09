---
title: "exit 0 Means Pass, exit 2 Means Block — Taming AI with Claude Code Hooks"
published: true
description: "CLAUDE.md instructions can be forgotten. Hooks execute every time, deterministically"
tags:
  - ai
  - llm
  - productivity
  - webdev
id: 3328608
date: '2026-03-09T02:48:01Z'
---

CLAUDE.md guidance is strong, but long sessions can dilute adherence. Hooks enforce behavior at execution time.

## Semantics

- exit 0: allow
- exit 2: block
- stderr: feedback to Claude
- stdout: inject context

## Common production patterns

1. **PreToolUse dangerous command block** (`rm -rf`, destructive SQL)
2. **SessionStart re-injection after compaction**
3. **PreCompact async backups**
4. **StatusLine token visibility**
5. **PostToolUse auto-format/lint**

Use CLAUDE.md for “what to do.”
Use hooks for “what must never happen.”

> One `exit 2` is often more reliable than 100 lines of “please don’t.”

---
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide)
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks-reference)
- [Trail of Bits Claude Code Config](https://github.com/trailofbits/claude-code-config)
