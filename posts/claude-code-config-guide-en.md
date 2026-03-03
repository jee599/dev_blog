---
title: "If You Installed Claude Code and Only Chat With It — You’re Missing the Point"
published: true
description: "Claude Code’s real power isn’t in the chat. It’s in 3 config files."
tags:
  - ai
  - webdev
  - claude
  - productivity
id: 3303801
date: 'draft'
---

You installed Claude Code. You type `claude`. A chat opens. You ask it to fix bugs and write tests.

If that’s where you stopped, you’re using maybe 20% of it.

Claude Code’s real power lives in three config files: **CLAUDE.md**, **Hooks settings**, and **MCP server connections**.

Set these up and the experience completely changes.

## CLAUDE.md — Memory That Survives Sessions

Claude Code forgets everything when a session ends.

You taught it “always use the -v flag with pytest” yesterday? Gone.

`CLAUDE.md` fixes this.

Drop a `CLAUDE.md` file in your project root. Claude Code reads it automatically when a session starts.

```md
# Project Guide

## Dev Rules
- Always run tests with `pytest tests/ -v`
- Create backups before any DB operations
- Commit messages use feat/fix/docs prefixes

## Tech Stack
- Python 3.11, FastAPI, PostgreSQL
- Frontend: Next.js 14 App Router
```

## Hooks — Automation That Never Forgets

Hooks force shell commands to run at specific lifecycle points.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read f; if echo \"$f\" | grep -qE '\\.(ts|tsx)$'; then npx prettier --write \"$f\" 2>/dev/null; fi; }"
          }
        ]
      }
    ]
  }
}
```

Blocking example:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json,sys; d=json.load(sys.stdin); p=d.get('tool_input',{}).get('file_path',''); sys.exit(2 if '.env' in p else 0)\""
          }
        ]
      }
    ]
  }
}
```

## MCP — Plug New Abilities Into Claude Code

```bash
# GitHub
claude mcp add github -s user \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=your-token \
  -- npx -y @modelcontextprotocol/server-github

# Context7
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest

# Playwright
claude mcp add playwright -s project -- npx -y @playwright/mcp@latest

# PostgreSQL
claude mcp add postgres -s project \
  -e DATABASE_URL="postgresql://user:pass@localhost:5432/mydb" \
  -- npx -y @modelcontextprotocol/server-postgres
```

Use `-s user` for global tools, and `-s project` for project-specific tools.

## Put All Three Together

- `CLAUDE.md` teaches rules
- Hooks enforce quality
- MCP extends capabilities

Thirty minutes of setup saves you time every single day after that.

> Claude Code’s real power isn’t in the conversation. It’s in the configuration.
