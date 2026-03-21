---
title: "Claude Code Agent Teams Can Spawn Agents. It Just Doesn't Know Which Ones to Use."
published: true
description: "I gave Claude Code 144 pre-built agents and auto-dispatch. One npm command. Zero config."
tags:
  - ai
  - claude
  - productivity
  - opensource
id: 3372582
date: '2026-03-19T14:43:35.082Z'
---

Claude Code's Agent Teams feature is genuinely impressive. You type a complex prompt, it spawns subagents, they work in parallel, each with its own context window. The architecture is there.

But there's a gap nobody talks about.

Agent Teams doesn't know *which* agents to use. It doesn't know that a game project needs a game designer, a physics engineer, and a QA specialist. It doesn't know that a SaaS dashboard needs a frontend dev, a backend architect, and someone who understands Stripe webhooks. It spawns blank subagents with no identity, no rules, no specialization.

You're supposed to define them yourself. Every time. With `--agents` JSON. For every project.

I built the missing piece.

![AgentCrow Demo](https://raw.githubusercontent.com/jee599/agentcrow/main/assets/demo.gif)

---

## 144 Agents, One Command

```bash
npx agentcrow init
```

That's it. This installs 144 specialized agent definitions into your project — 9 hand-crafted builtin agents with strict MUST/MUST NOT rules, plus 135 community agents from [agency-agents](https://github.com/msitarzewski/agency-agents) covering 15 divisions: engineering, game dev, design, marketing, testing, DevOps, and more.

When you run `claude` after init, it reads the agent roster from `.claude/CLAUDE.md` and automatically decomposes your prompt into tasks, matches the right agents, and dispatches them.

No API key needed. No separate server. No configuration. Just Claude Code doing what it already does — but now it knows *who* to call.

---

## What Actually Happens

I typed this:

```
Build a SaaS dashboard with Stripe billing, user auth, and API docs
```

Claude decomposed it into 5 tasks and dispatched 5 specialized agents:

```
━━━ 🐦 AgentCrow ━━━━━━━━━━━━━━━━━━━━━
Dispatching 5 agents:

🖥️ @ui_designer       → dashboard layout, component hierarchy
🖥️ @frontend_developer → React components, charts, responsive UI
🏗️ @backend_architect  → Auth system, REST API, Stripe webhooks
🧪 @qa_engineer        → billing flow E2E tests, auth edge cases
📝 @technical_writer   → API reference, onboarding guide

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Each agent has a defined personality, communication style, and critical rules. The QA engineer, for example, has rules like "MUST cover happy path, edge cases, and error paths" and "MUST NOT skip error handling tests." These aren't suggestions — they're baked into the agent's identity.

The key difference: without AgentCrow, Claude spawns generic subagents. With AgentCrow, each subagent *knows its job*.

---

## The Comparison Nobody Asked For (But Everyone Needs)

| | Agent Teams alone | + AgentCrow |
|:---|:---:|:---:|
| Spawn subagents | ✅ | ✅ |
| Know which agents to use | ❌ | ✅ |
| 144 pre-built agent roles | ❌ | ✅ |
| Auto-decompose prompts | ❌ | ✅ |
| Agent identity & rules | ❌ | ✅ |
| Zero config | ❌ | ✅ |

Agent Teams is the engine. AgentCrow is the brain.

---

## Under the Hood

The architecture is deliberately simple. When you run `npx agentcrow init`, here's what happens:

```
  🐦 AgentCrow v3.3.2

  ▸ Builtin agents ··· 9 installed ✓
  ▸ External agents ··· downloaded ✓
  ▸ Agent definitions ··· 144 generated ✓
  ▸ Agent symlink ··· 144 agents linked ✓
  ▸ Dispatch rules ··· CLAUDE.md created ✓
  ▸ SessionStart hook ··· installed ✓

  ✓ AgentCrow ready — 144 agents, max 5 per dispatch
```

9 builtin agents are YAML files I wrote by hand. Each one defines a role, personality, MUST rules, MUST NOT rules, deliverables, and success metrics. The QA engineer agent has 5 MUST rules and 5 MUST NOT rules covering everything from test independence to mock usage.

135 external agents come from [agency-agents](https://github.com/msitarzewski/agency-agents), covering game development (Unreal, Unity, Godot specialists), marketing, sales, spatial computing — domains I wouldn't have thought to include.

Agents are stored globally at `~/.agentcrow/` and symlinked into each project. Second project onward = instant, no download.

A `.claude/CLAUDE.md` file gets generated with dispatch rules and a SessionStart hook ensures Claude sees `🐦 AgentCrow active` every session. Each agent gets a role emoji (🖥️ frontend, 🏗️ backend, 🧪 qa, 🛡️ security, 📝 writer...) so you can visually track what's happening.

The entire system is a CLAUDE.md file and some YAML. No runtime dependencies, no background processes, no API keys. Turn it off with `agentcrow off`, turn it back on with `agentcrow on`.

---

## What I Learned Building This

The hardest part wasn't the agent matching or the decomposition logic. It was figuring out what *shouldn't* be automated.

My first attempt tried to intercept every prompt, decompose it with an LLM call, and auto-dispatch. The decomposition alone took 15 seconds. For a simple "fix this typo" prompt, that's absurd.

The current design is smarter: CLAUDE.md tells Claude to only decompose multi-task requests. "Fix this bug" runs normally. "Build a dashboard with auth, billing, tests, and docs" triggers the agent system. Claude makes that judgment call — and it's surprisingly good at it.

I also learned that agent identity matters more than I expected. A generic "write tests" subagent produces generic tests. A QA engineer agent with "MUST cover edge cases" and "MUST NOT use sleep for async waits" produces *professional* tests. The rules constrain the model in the right direction.

---

## Try It

```bash
npx agentcrow init
claude
```

Then type something complex. Watch it decompose and dispatch.

The source is on [GitHub](https://github.com/jee599/agentcrow). The npm package is [agentcrow](https://www.npmjs.com/package/agentcrow).

> Agent Teams is powerful. It just needed someone to tell it who to call.

---

- [AgentCrow GitHub](https://github.com/jee599/agentcrow)
- [agency-agents](https://github.com/msitarzewski/agency-agents) — the 135 community agents
- [Claude Code Agent Teams docs](https://docs.anthropic.com/en/docs/claude-code)
