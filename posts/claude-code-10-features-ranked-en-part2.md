---
title: "Claude Code Has Too Many Features. Here Are the 10 That Matter, Ranked. (2/2)"
published: false
description: "Ralph Loop to Agent Teams. Scaling, parallelism, and quality gates."
tags:
  - ai
  - claudecode
  - productivity
  - webdev
---

Part 1 covered the foundation: CLAUDE.md, Skills, Hooks, GitHub Actions, and Subagents. Those 5 make Claude Code smart. These next 5 make it scale.

Part 1 was “how to make one Claude session effective.” Part 2 is “how to run multiple Claudes in parallel.” Large refactors, external integrations, automated quality gates, and experimental multi-agent collaboration.

## Ralph Loop

The game changer for large-scale tasks. Give Claude a job and tell it “keep going until it’s done.”

Mechanism:
1) Claude works
2) Claude tries to stop
3) Stop hook intercepts and re-injects the same prompt
4) Claude reads modified files/git history and continues
5) Loop ends on `<promise>DONE</promise>`

```bash
/ralph-loop "Add error handling to all API endpoints. Output <promise>DONE</promise> when complete" --max-iterations 20
```

Use `--max-iterations` as a hard safety guard.

For large migrations, pair with `PROGRESS.md` checklist so each loop can resume deterministically.

## MCP

Model Context Protocol is the standard bridge from Claude Code to external systems.

```bash
claude mcp add github -s user -- npx @modelcontextprotocol/server-github
```

One command and Claude can query GitHub APIs.

High-impact use case: ticket orchestration.

```text
Read JIRA-1234 and implement the requirements.
When done, change the ticket status to In Review and leave a comment.
```

Scope options:
- `-s user`: global across projects
- `-s local`: local only, not committed
- `-s project`: project-level, committed/shared

Watch-outs:
- each MCP server consumes context
- MCP servers expose their own tools; they don’t inherit Read/Write/Bash

## Git Worktrees

Worktrees are the infra for true parallel coding.

```bash
claude --worktree feature-social-login
claude --worktree bugfix-login-crash
```

Each session gets an isolated working directory + branch, so file conflicts are minimized.

Add `--tmux` to run in background sessions for overnight parallel batches.

```bash
claude --worktree feature-auth --tmux
claude --worktree feature-dashboard --tmux
claude --worktree refactor-api --tmux
```

Subagent integration:

```md
---
name: parallel-builder
description: Parallel build agent
isolation: worktree
---
```

## Code Review Plugins

Official multi-agent PR review plugins.

- `/code-review`: general parallel review
- `/pr-review-toolkit:review-pr`: specialized review lanes

```bash
/code-review
/code-review --comment
/pr-review-toolkit:review-pr tests
/pr-review-toolkit:review-pr errors
/pr-review-toolkit:review-pr types
/pr-review-toolkit:review-pr all
```

Use local `/code-review` as pre-flight, then CI review as second pass for a strong double safety net.

## Agent Teams

Experimental multi-session teamwork mode.

Subagents are one-way reporting. Agent Teams are two-way coordination between teammates.

Enable:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Usage:

```text
Create 3 teammates to refactor the payment module.
API lead, DB lead, Test lead.
Share schema changes and API interface updates as you go.
```

Current caveats (experimental):
- unstable session resumption
- occasional premature “done” by team lead
- high token burn (multiple active model instances)

Use Agent Teams when cross-layer coordination is truly needed.
For most daily workflows, Subagents + Worktrees are enough.

-----

Hierarchy recap:
- CLAUDE.md / Skills / Hooks = foundation
- GitHub Actions / Subagents = execution layer
- Ralph Loop / Worktrees = scaling layer
- Code Review / MCP / Agent Teams = situational tools

You don’t need all 10 at once. Start with one strong CLAUDE.md, then expand incrementally.

> “Having 10 tools doesn’t mean using 10 tools. But you’d better know what all 10 do.”
