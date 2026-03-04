---
title: "Claude Code Has Too Many Features. Here Are the 10 That Matter, Ranked. (1/2)"
published: false
description: "CLAUDE.md to Subagents. These 5 are the foundation. Get them wrong and everything else breaks."
tags:
  - ai
  - claudecode
  - productivity
  - webdev
---

Claude Code has a feature overload problem. CLAUDE.md, Skills, Hooks, MCP, Ralph Loop, Agent Teams, Worktrees, Subagents, Plugins… Every blog post mentions different things. Half of them describe features that don’t exist yet or confuse community tools with official ones.

So I went through everything. Anthropic’s GitHub repos, code.claude.com docs, the plugin marketplace.json. I pulled out only the features that are real, verified, and documented. Then I ranked them by importance.

Part 1 covers the foundation: the 5 features that everything else depends on. If these are weak, the other 5 won’t deliver.

## CLAUDE.md

The foundation. Without this, the other 9 are half as useful.

It’s a project context file that Claude Code automatically reads at session start. You put your coding conventions, architecture rules, and forbidden patterns here. Then you never have to repeat “we use TypeScript, functional components only, conventional commits” every session.

Every other feature references this file:
- `/code-review` checks against CLAUDE.md
- GitHub Actions review uses CLAUDE.md rules
- Subagents read CLAUDE.md before they start

If this is weak, everything else loses accuracy.

Location strategy matters:
- Root CLAUDE.md for project-wide rules
- Subdirectory CLAUDE.md (e.g., `src/UI/`) for module-specific rules
- `~/.claude/CLAUDE.md` for global rules

A practical Next.js example:

```md
# FateSaju - AI Fortune Analysis

## Stack
Next.js 14 (App Router), TypeScript, Tailwind CSS
Supabase (Auth + DB + Edge Functions)
Claude API (fortune interpretation)
Vercel deployment

## Rules
- Functional components + hooks only
- Always try-catch on API calls
- Korean UI text managed in constants/
- Commits: conventional commits (feat:, fix:, docs:)

## Forbidden
- No `any` types
- No console.log in commits
- No hardcoded API URLs (use env vars)
```

Tip: keep CLAUDE.md short and explicit. “Do X” beats “it would be nice if…” every time.

## Skills

If CLAUDE.md is your always-on memo, Skills are on-demand manuals.

Define SKILL.md files under `.claude/skills/`. Claude loads relevant skills based on context. Ask about widgets, UI skill loads. Ask about deployment, deploy skill loads.

Why not put everything in CLAUDE.md? Token economics.

- CLAUDE.md loads every session
- Skills load only when relevant

So CLAUDE.md should contain global rules. Skills should contain domain-specific workflows.

Example: UE5 CommonUI skill.

```md
---
name: ue5-ui-system
description: UE5 CommonUI UI system guide.Responds to "widget", "UI", "CommonUI", "popup" keywords.
---

# UE5 UI System Rules

## Widget Lifecycle
CreateWidget<T>() → AddToViewport() or AddChild()
Always initialize in NativeConstruct()
Remove with RemoveFromParent() (GC handles the rest)

## CommonUI Patterns
All UI widgets inherit UCommonActivatableWidget
Input routing via UCommonUIActionRouterBase
Popups via PushContentToLayer_ForPlayer()
ESC key via OnHandleBackAction() override

## Common Bugs
Widget crash: CreateWidget with nullptr Outer
Input dead: InputComponent Priority conflicts
Focus lost: Missing ActivateWidget() call
```

Skills can also run in forked context:

```md
---
name: deep-research
description: Deep codebase investigation
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files with Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

## Hooks

Hooks are Claude Code’s automation core.

- `PostToolUse`: after tool runs
- `PreToolUse`: before tool runs
- `Stop`: when Claude tries to stop
- `SessionStart`, `Notification`, etc.

Auto-format example:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/scripts/format-check.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Blocking dangerous Bash commands is the same pattern via `PreToolUse`.

For long tasks, Notification hooks can trigger desktop alerts.

Hook types:
- `command`
- `http`
- `prompt` (Stop/SubagentStop only)

## GitHub Actions PR Automation

Tag `@claude` in issues/PR comments to trigger implementation/review workflows.

Quick setup: `/install-github-app` in Claude Code terminal.

Manual setup:
1) Install app: <https://github.com/apps/claude>
2) Add `ANTHROPIC_API_KEY` to repo secrets
3) Add workflow yaml

Example prompt in issue:

```text
@claude Implement this issue.
Add social login (Kakao, Google) to the login page.
Modify LoginForm and create SocialLoginButton.
```

Claude can implement and open PR automatically.

During review:

```text
@claude Missing try-catch here. Add error handling and show toast on failure.
```

Claude patches and pushes commits to the same PR.

You can also automate review in CI with `anthropics/claude-code-action@v1`.

## Custom Subagents

Subagents are specialized worker agents with isolated context windows.

Why this matters: long main sessions get context-clogged. Subagents offload heavy tasks and return concise summaries.

Two ways to create:
- interactive `/agents`
- markdown file under `.claude/agents/`

Example reviewer agent:

```md
---
name: code-reviewer
description: Code review agent
tools:
  - Read
  - Glob
  - Grep
  - Bash(git diff *)
skills:
  - ue5-ui-system
permissionMode: bypassPermissions
---

# Code Review Agent
Analyze changed code and check for:
- Bugs
- Performance issues
- CLAUDE.md convention violations

Include file path, line number, severity, and fix suggestion.
```

Use Subagents for delegated isolated work.
Use Skills for in-context domain guidance.

-----

That’s the foundation 5.

CLAUDE.md defines rules.
Skills separate domain knowledge.
Hooks automate repetitive checks.
GitHub Actions automates PR workflows.
Subagents delegate specialized tasks.

Get these right first. Part 2 covers scaling tools: Ralph Loop, MCP, Git Worktrees, Code Review plugins, and Agent Teams.

> “Having 10 tools doesn’t mean using 10 tools. But the foundation better be solid.”
