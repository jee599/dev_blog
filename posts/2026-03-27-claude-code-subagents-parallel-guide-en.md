---
title: "How I Run 10 AI Agents in Parallel with Claude Code"
published: true
description: "A practical guide to Claude Code subagents and agent teams. Solo developer workflows for parallel codebase analysis, review, and testing."
tags: [ai, webdev, productivity, programming]
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-subagents-parallel-guide-hero.jpg
canonical_url: https://spoonai.me/posts/claude-code-agent
series: "Claude Code Power User Guide"
---

Three research agents running in parallel. Codebase analysis dropped from 10 minutes to 3. I'm a solo developer, but for the first time it felt like I had a team.

Claude Code subagents are specialized AI assistants that run in their own context windows inside your main Claude session. Each one has its own system prompt, its own tool access, its own model configuration. You can run up to 10 of them simultaneously. The main session delegates tasks to them, and they report back when done.

I've been using subagents for about two months now. This is what I've learned about making them actually useful, not just a novelty.

## The Built-in Agents You Didn't Know About

Claude Code ships with six agents out of the box. The one I use most is Explore, which runs on Haiku for fast, read-only codebase search. It fires automatically when Claude needs to understand your project structure. No risk of accidental modifications because it literally can't write files.

The Plan agent handles research in plan mode. The General-purpose agent gets full tool access for complex, multi-step tasks. There's also a Bash agent, a statusline-setup agent, and a Claude Code Guide agent for onboarding questions.

For small projects, these built-ins are all you need. I spent my first month never creating a custom agent. Explore would auto-fire for code analysis, General-purpose would handle refactoring. It worked.

Then my codebase hit 500+ files across three services. I needed a code-reviewer that runs after every change. I needed tests and documentation updated in parallel, not sequentially. The built-ins couldn't do that. So I started building my own.

## Creating Custom Agents: Three Approaches

The fastest way is the `/agents` command inside Claude Code. You describe what you want, Claude generates a markdown file, and it drops into `.claude/agents/`. Done in 30 seconds.

If you want full control, write the markdown file yourself. The YAML frontmatter takes a dozen configuration fields. Here's my code reviewer:

```yaml
---
name: code-reviewer
description: "Reviews code for bugs, performance, and security issues"
tools: [Read, Grep, Glob, Bash]
model: sonnet
permissionMode: plan
---

You are a code reviewer. Analyze the given code for:
1. Logic bugs and edge cases
2. Performance bottlenecks
3. Security vulnerabilities
4. Naming and readability issues

Be specific. Reference line numbers. Suggest fixes, not just problems.
```

The key decisions here: `tools` is set to Read, Grep, Glob, and Bash only. This agent can read everything but can't modify anything. `model: sonnet` because reviews need speed, not maximum reasoning depth. `permissionMode: plan` keeps it in read-only mode.

For one-off agents, there's the CLI approach: `claude --agents '{"reviewer": {"description": "...", "prompt": "..."}}'`. I use this when testing new agent configurations before committing them to a file.

Four invocation methods exist. If you write a good description, Claude auto-delegates matching tasks to your agent without you asking. You can request it in natural language: "use the code-reviewer subagent." You can directly mention it with `@"code-reviewer (agent)"`. Or you can lock an entire session to one agent with `claude --agent code-reviewer`.

The auto-delegation is the one that surprised me. I created an agent with the description "Reviews code for bugs and security issues" and Claude started routing code review requests to it without me ever mentioning the agent by name. The description is effectively a routing rule.

{% link jee599/building-mentoring-platform-10-agents %}

## Foreground vs Background: Where It Gets Interesting

Subagents default to foreground mode. They block. Permission prompts pass through the parent session. You watch them work, approve actions, and wait for results.

Background mode changes everything. Set `background: true` in the frontmatter or hit Ctrl+B while an agent is running, and it detaches. Multiple agents run concurrently. Permissions are pre-approved. You get notified when they finish.

Here's my actual workflow when refactoring a module. I spin up three background research agents simultaneously. One explores all files that import from the target module. One analyzes the dependency graph. One checks test coverage for every function I'm about to touch. Three agents, three context windows, running in parallel.

Before agents: this analysis took about 10 minutes of sequential Claude queries. After: 3 minutes, with more thorough results because each agent focuses on one thing.

The trade-off is real, though. Background agents can't ask for permission mid-task. If they hit a file that needs elevated access, they skip it silently. I've had agents return incomplete results because they couldn't read a file behind a permission gate. The fix is setting `permissionMode: dontAsk` or `bypassPermissions` for trusted agents, but that's a conscious security trade-off you need to make.

## Agent Teams: Agents That Talk to Each Other

Regular subagents report to their parent and that's it. They can't communicate with each other. [Agent Teams](https://code.claude.com/docs/en/agent-teams), introduced in February 2026 with Opus 4.6, change this model entirely.

Agent Teams are multiple independent sessions that coordinate. TeamCreate builds the team. SendMessage enables direct inter-agent communication. A shared TaskList tracks progress across all team members. One agent can tell another "I found a bug in auth.ts, fix it" without going through the parent.

I haven't used Agent Teams as heavily as subagents yet, but the use case I'm exploring is a full development cycle agent team: one agent writes code, one reviews it, one writes tests, one updates documentation. They communicate directly: the reviewer tells the coder about issues, the coder fixes them, the tester verifies the fix. No human in the loop for routine changes.

The configuration fields that make this work are `memory: project` for persistent cross-session learning, `isolation: worktree` for running agents in isolated git worktrees so they don't conflict, and `maxTurns` to prevent runaway agents from burning through your token budget.

{% link jee599/agentcrow-launch %}

## Configuration Fields That Actually Matter

Most tutorials show you name, description, and tools. Those are the minimum. The fields that changed my workflow are the less obvious ones.

`memory: project` lets agents remember patterns across sessions. My code-reviewer agent learned our project's naming conventions, architecture decisions, and recurring issues. In week one, it gave generic feedback. By week three, it was catching project-specific anti-patterns that a fresh agent would miss.

`effort` controls reasoning depth: low, medium, high, max. I set Explore-type agents to low for speed and debugging agents to max for thoroughness. The difference is real. A max-effort debugger agent spent 8 minutes tracing a race condition through four files. A low-effort agent would have given up after the second file.

`isolation: worktree` creates a fresh git worktree for the agent. The main branch is untouched. The agent experiments freely. When it's done, you review the diff and merge what works. This is the setting that made me trust agents with code modifications.

PreToolUse hooks add validation before any tool execution. I built a DB query validator that checks every SQL command for read-only compliance before the agent can run it. The agent writes `SELECT * FROM users`, the hook approves it. The agent writes `DROP TABLE`, the hook blocks it. Safety rails that let you grant more tool access without losing control.

```
User Request
    ↓
Main Claude Session
    ├── @code-reviewer (background, sonnet, read-only)
    ├── @test-writer (background, sonnet, edit access)
    ├── @doc-updater (background, haiku, write access)
    └── @architect (foreground, opus, full access)
              ↓
    Results aggregated → Human review → Commit
```

## The Solo Developer Multiplier

Here's the honest assessment. Subagents don't replace a team. They don't have the judgment of an experienced engineer who knows your business context. They miss subtle bugs. They sometimes generate tests that pass but don't actually test anything meaningful.

What they do replace is the sequential bottleneck of being one person. Writing code, then reviewing it, then writing tests, then updating docs. Four tasks, one after another. With agents, all four happen in parallel. The total wall-clock time for a feature drops by 60-70%, even accounting for the time you spend reviewing agent output.

I keep four agents configured on every project: writer, reviewer, tester, architect. Before starting work, I dispatch them in parallel. The architect analyzes the task, the writer starts coding, the reviewer watches the writer's output, the tester prepares test scaffolding. By the time I'm ready to commit, I have code, review comments, tests, and documentation all waiting.

The configuration that makes this sustainable is `memory: project`. Without it, every session starts from zero. With it, agents build institutional knowledge. My code-reviewer remembers that we use a specific error handling pattern. My test-writer remembers that we mock the database layer a certain way. The agents get better over time, which is the whole point.

> You develop alone, but you don't have to work alone. The agents become the team you couldn't afford to hire.

What's your agent setup? I'm curious whether people are going deep on a few agents or wide with many specialized ones.

---

Full Korean analysis on [spoonai.me](https://spoonai.me/posts/claude-code-agent).

**Sources:**
- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents) - Anthropic
- [Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams) - Anthropic
- [Claude Code](https://code.claude.com) - Anthropic
