---
title: "How I Automated My Entire Claude Code Workflow with Hooks"
published: true
description: "Claude Code Hooks run shell commands at 22+ lifecycle events. Here's how I use PreToolUse, PostToolUse, and Notification hooks to automate formatting, block .env edits, and get desktop alerts."
tags: [ai, webdev, productivity, tutorial]
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-hooks-automation-guide-hero.jpg
canonical_url: https://spoonai.me/posts/claude-code-hooks
series: "Claude Code Power User Guide"
hashnode_url: 'https://plzai.hashnode.dev/2026-03-25-claude-code-hooks-automation-guide'
id: 3385070
date: '2026-03-22T16:14:52.925Z'
---

I added one PostToolUse hook to my Claude Code configuration last Tuesday. It auto-runs Prettier every time Claude edits a file. The setup took 3 minutes. I haven't manually formatted a single file since — that's roughly 20 manual `npx prettier --write` runs per day that just disappeared.

Claude Code Hooks are user-defined shell commands that execute at specific lifecycle points of the AI coding agent. If you've used Git Hooks, the mental model is identical: define a trigger point, attach a script, and let it fire automatically. The critical difference is the target. Git Hooks react to version control events. Claude Code Hooks react to the AI agent's behavior itself — when it's about to edit a file, run a tool, or finish responding. And because hooks are deterministic, they don't depend on the LLM remembering your instruction. They fire every single time.

This is Part 2 of the "Claude Code Power User Guide" series. Part 1 covered how MCP extends Claude Code's capabilities by connecting it to external services and data sources. Hooks solve the other side of the equation: controlling what Claude Code does, and ensuring certain actions always happen or never happen regardless of how the conversation goes.

{% link jee599/claude-code-config-guide %}

## 22 Lifecycle Events, and Why Only 3 Matter Day-to-Day

The [Hooks Guide](https://code.claude.com/docs/en/hooks-guide) lists 22+ events you can hook into. SessionStart fires when a session begins or resumes. UserPromptSubmit triggers before Claude processes your prompt — you could use it to inject context or validate input. PreToolUse and PostToolUse bracket every tool execution. PermissionRequest catches the moment a permission dialog would appear. Notification fires when Claude sends an alert. Stop fires when Claude finishes responding.

Then there are the specialized events: SubagentStart and SubagentStop for managing subagent lifecycle, PreCompact and PostCompact for context compaction, ConfigChange for settings file changes, TaskCompleted, InstructionsLoaded, WorktreeCreate and WorktreeRemove, SessionEnd, and more.

In practice, three events cover 90% of what I need. PostToolUse handles all my post-processing — auto-formatting after edits, running lint checks after file creation. PreToolUse acts as a security gate — I block edits to .env files, credentials, and other sensitive paths before they happen. Notification pipes Claude's alerts to macOS desktop notifications so I can work in another app without constantly checking the terminal.

The rest of the events become relevant as your setup grows more sophisticated. PreCompact and PostCompact matter when you're running long sessions and need to preserve specific context through compaction. Stop with a prompt-type hook can verify that Claude actually completed the task before ending the turn. But start with those three. They deliver the most value with the least configuration.

## The Four Hook Types

Every hook has a type field that determines how it executes. The command type runs a shell command — this is the one you'll use 95% of the time. The http type sends a POST request to a URL endpoint, which is useful for triggering webhooks or external service integrations. The prompt type runs a single-turn LLM evaluation that returns a yes/no decision. The agent type spins up a multi-turn subagent with full tool access for complex verification tasks.

Here's the auto-formatting hook I mentioned at the top, using the command type.

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
      }]
    }]
  }
}
```

The matcher field takes a regex pattern. `Edit|Write` means this hook only fires when the Edit or Write tool is used. Claude running Bash, Read, or any other tool won't trigger it. The command itself uses [jq](https://jqlang.github.io/jq/) to extract the file path from the tool input JSON, then pipes it to [Prettier](https://prettier.io/). Every file Claude touches gets formatted automatically.

Exit codes are how hooks communicate decisions back to Claude Code. Exit 0 means "proceed normally" — for some events, stdout from the hook becomes additional context. Exit 2 means "block this action" — stderr becomes feedback that Claude receives, explaining why the action was blocked. Any other exit code means "proceed but log stderr" — useful for non-critical warnings.

That exit 2 behavior is where hooks get genuinely powerful. It's not just logging. It's a hard gate. Claude receives the stderr message and adapts its approach accordingly.

{% link jee599/claude-hooks-exit2 %}

## Protecting .env Files — A PreToolUse Hook

The hook I'm most grateful for is the simplest one. A PreToolUse script that blocks any edit to files containing `.env` in the path.

```bash
#!/bin/bash
FILE=$(jq -r '.tool_input.file_path // empty')
if [[ "$FILE" == *".env"* ]]; then
  echo "BLOCKED: .env file editing is prohibited" >&2
  exit 2
fi
exit 0
```

Before this hook existed, I relied on Claude "knowing" not to touch .env files. It usually didn't — but "usually" isn't good enough when the downside is committing secrets to a public repository. Now the protection is deterministic. Claude can't edit .env files no matter what the conversation says, no matter how the prompt is structured. The exit 2 response tells Claude the action was blocked, and Claude adjusts — it might ask me to make the change manually, or suggest an alternative approach.

I saved this script as `~/.claude/scripts/protect-files.sh` and referenced it in my global settings. The global placement means every project gets this protection automatically, even new ones I haven't configured yet.

## Desktop Notifications — Reclaiming Your Attention

Before the Notification hook, my workflow with Claude Code looked like this: start a task, switch to another app, remember 5 minutes later to check if Claude finished, switch back to the terminal, see Claude has been waiting for input for 3 minutes. Repeat.

The fix is a command hook on the Notification event that calls macOS `osascript` to display a native notification. When Claude needs input, finishes a task, or hits an error, I see a notification banner immediately. The context-switching cost dropped dramatically.

This is the kind of automation that sounds trivial but changes how you work. I spend less time monitoring the terminal and more time on actual development. Claude Code becomes something that runs in the background and taps me on the shoulder when it needs attention.

## Context Re-injection After Compaction

Long Claude Code sessions have a known pain point: context compaction. When the context window fills up, Claude compresses older conversation history to make room. Important details can get lost in the process — project-specific conventions, architectural decisions, the current state of a multi-step task.

A SessionStart hook with a compact matcher solves this. When a session resumes after compaction, the hook automatically re-injects a file containing critical project context. The file might include the current task description, key architectural constraints, or a summary of decisions made earlier in the session. Claude picks up where it left off without the "wait, what were we doing?" moment.

## Where Configuration Lives

Hook configurations go in one of three places. `~/.claude/settings.json` is global — applies to every project on your machine. `.claude/settings.json` is project-level and should be version-controlled, so your team shares the same hooks. `.claude/settings.local.json` is project-level but gitignored, for personal preferences that shouldn't affect teammates.

The decision framework is simple. Security hooks like .env protection go in global settings — you want them everywhere, always. Project-specific hooks like a custom linter or test runner go in `.claude/settings.json` so every contributor benefits. Personal convenience hooks like desktop notifications or specific formatting preferences go in `.claude/settings.local.json`.

I keep my settings minimal. Global: .env protection and desktop notifications. Per-project: auto-formatting with the project's specific Prettier config. Local: nothing yet, but this is where I'd put experimental hooks I'm testing.

## The Difference from Git Hooks

Git Hooks and Claude Code Hooks occupy different layers of the same workflow. Git Hooks guard code quality at the version control boundary — pre-commit linting, pre-push tests, commit message formatting. Claude Code Hooks guard agent behavior at the AI interaction boundary — what the agent is allowed to edit, what happens after it edits something, whether its output meets quality standards.

They complement each other perfectly. My pre-commit hook runs ESLint to catch syntax errors. My PreToolUse hook blocks .env file edits to prevent secret exposure. My PostToolUse hook runs Prettier so the code is already formatted before it reaches the pre-commit hook. The layers work together, each catching different categories of issues.

The prompt and agent hook types add a dimension Git Hooks don't have. A Stop hook with type "prompt" can ask an LLM to evaluate whether Claude's response actually answered the original question. A Stop hook with type "agent" can spin up a verification agent that checks the modified files, runs tests, and confirms the task is complete. This is quality assurance built directly into the AI agent's lifecycle.

The next part of this series covers Claude Code's Agent system — how to dispatch subagents for parallel task execution. Once you combine Hooks for behavior control with Agents for work distribution, Claude Code transforms from a coding assistant into a reliable automation engine.

> The best automation is the kind you set up once and forget exists.

What hooks have you set up for your Claude Code workflow? I'm particularly curious about creative uses of the Stop hook with prompt or agent types — the verification possibilities seem deeper than what I've explored so far.

---

Full Korean analysis on [spoonai.me](https://spoonai.me/posts/claude-code-hooks).

**Sources:**
- [Claude Code Hooks Guide](https://code.claude.com/docs/en/hooks-guide) - Anthropic
- [Claude Code Hooks Reference](https://code.claude.com/docs/en/hooks) - Anthropic
- [Prettier](https://prettier.io/) - Prettier
- [jq](https://jqlang.github.io/jq/) - jqlang
