---
title: "One Telegram Message, One GitHub Repo: Claude Code as an Async Assistant (111 Tool Calls)"
published: true
description: "From a single Telegram message to a scaffolded GitHub repo in under 30 minutes. What 111 tool calls across a 47-hour session actually produced."
tags: claudecode, ai, automation, github
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-19-portfolio-site-en
---

I sent one Telegram message: "spin up another project for dental ads, English-focused." Under 30 minutes later, `~/dentalad/` existed on disk and a private GitHub repo was live. This is what Claude Code as an async assistant looks like in practice.

**TL;DR** Delegated a full day of async tasks through a Telegram → Claude Code pipeline. 111 tool calls — nearly half split between `Bash` (41) and `WebSearch` (20). 16 Telegram replies show how much back-and-forth async delegation actually generates.

## One Message to a Live GitHub Repo

The prompt was minimal:

> "Create another project connected to git, dental ads in English"

Claude proposed four name candidates. I replied "dentalad ok." Execution started:

1. Created `~/dentalad/` directory
2. Scaffolded `clinics/`, `ads-research/`, `site/`, `templates/`, `docs/`
3. Wrote `README.md`, `package.json`, `.gitignore`
4. Created `github.com/jee599/dentalad` as a private repo via `gh repo create`
5. Initial commit + `git push -u origin main`

A large chunk of the 41 Bash calls were consumed here, running in sequence: `gh repo create` → `git init` → `git remote add` → `git push`. My only input was confirming the name.

What makes this useful isn't the scaffolding itself — it's the absence of context-switching. The request happened whenever I thought of it. Execution happened on the machine while I was doing something else. The only synchronous moment was the name confirmation.

## When MCP Drops Mid-Session

Partway through, the Telegram MCP server disconnected. The session received only a "disconnected" signal — no root cause, nothing visible on the client side.

The usual suspects:

- Bot token expiry or rotation
- Temporary network interruption
- Plugin process crash
- Session loss after system sleep

Reconnection: ran `/telegram:configure` to check token state, reconnected. The dentalad completion notification went out after reconnection.

The important distinction here: **MCP disconnection doesn't kill the underlying work.** The notification channel failed; the task didn't. The repo was already on GitHub before the disconnect. Task execution and notification delivery are decoupled — which means a dropped connection is annoying, not destructive.

That said, long sessions will hit disconnects. Plan for the gap: any queued notifications need to be resent manually after reconnection.

## The Hard Limit of Scheduled Agents

"Search for Claude events in Pangyo on a schedule and notify me when something comes up." This hit a wall.

Remote scheduled agents (CCR) don't have access to local MCP plugins. The connectors available on claude.ai are Vercel and Gmail — the Telegram plugin is local-only. A remote agent has no path to push results to Telegram without an external mechanism.

Two options on the table:

1. **Direct Telegram Bot API** — embed the bot token in the trigger prompt, call `sendMessage` via `curl`. Works, but the token lives in plaintext in the trigger config.
2. **Gmail fallback** — route notifications through the Gmail connector already linked to claude.ai.

Scheduled agents are powerful, but they're isolated from the local plugin ecosystem. That's a real architectural boundary: anything that lives on `claude.ai` can't reach anything that runs only locally. The two worlds don't share a network boundary.

## Claude Design Blog → auto-publish

"Write and post a blog about the Claude design update." Used the `auto-publish` skill to generate two files in parallel:

- `~/dev_blog/posts/2026-04-18-anthropic-claude-design-launch-2026-en.md` (DEV.to)
- `~/spoonai-site/content/blog/2026-04-18-anthropic-claude-design-launch-2026-ko.md` (spoonai.me)

Most of the 20 WebSearch and 14 WebFetch calls were spent here — pulling official Anthropic docs, release notes, and technical blogs to fill the content. The flow: WebSearch finds URLs, WebFetch reads the actual body, Write produces platform-specific drafts.

One source topic, two language-specific outputs. The time-per-output ratio improves significantly once the pipeline is running — the research phase is the expensive part, and it's shared across both posts.

## Session Stats

| Metric | Value |
|--------|-------|
| Session duration | 47h 11min |
| Total tool calls | 111 |
| Bash | 41 |
| WebSearch | 20 |
| Telegram reply | 16 |
| WebFetch | 14 |
| Files created | 5 |
| Files modified | 0 |

Bash at the top was expected — most work was system operations: git commands, GitHub CLI, npm scripts. The number worth noting is **16 Telegram replies**. That's not just completion pings. It includes name proposals, progress updates at each stage, and result deliveries. Async delegation generates more communication overhead than it appears.

Edit count is zero. No existing code was modified in this session. Everything was net-new: a scaffolded repo and two blog posts.

## What This Actually Changes

The scaffolding and publishing are table stakes — Claude Code can do those from a terminal. What Telegram changes is the timing model.

Instructions don't require a terminal session anymore. A thought surfaces; a message goes out. Results come back to the phone. Work happens when it's relevant, not when a terminal happens to be open.

The 47-hour session length reflects that. It's not 47 hours of active work — it's 47 hours during which tasks could be initiated and received from anywhere. The actual execution time was a fraction of that.

## What's Next

- Investigate Telegram MCP auto-reconnect on disconnection
- Populate actual content in the dentalad project
- Decide between Bot API token approach and Gmail fallback for scheduled agent notifications

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
