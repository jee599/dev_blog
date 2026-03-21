---
title: "3 Plugins vs 200K Stars: Why I Still Pick Claude Code Channels Over OpenClaw"
published: true
description: "I tested both. 3 plugins beat 200K GitHub stars — here's why security won."
tags: ai, productivity, opensource, webdev
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-channels-vs-openclaw.jpg
canonical_url: https://jidonglab.com/blog/claude-code-channels-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-code-channels-vs-openclaw'
id: 3379445
date: 'draft'
---

OpenClaw has 200,000 GitHub stars, supports every messaging platform you can name, and costs nothing. Claude Code Channels has three plugins, requires a paid subscription, and can't even handle permission prompts remotely. I still chose Channels for my production workflow.

That sounds irrational. It's not — and the reason comes down to a single word that solo devs underestimate until it bites them: **security**.

In my [previous post](https://dev.to/jee599/claude-code-channels-architecture-setup), I covered how Claude Code Channels works — the push-not-pull architecture, the local MCP plugin bridge, and the five-minute Telegram/Discord setup. Now the harder questions. What can't it do? How does it stack up against the open-source project that pioneered this interaction model?

## Why Does a Single Permission Prompt Break Everything?

When Claude Code needs to perform a risky action — deleting a file, executing a shell command, writing to a protected directory — it shows a permission prompt in the terminal. You approve or deny. Standard safety mechanism. The problem is there's **no way** to respond to these prompts from Telegram or Discord. Claude hits a permission gate, it stops, and you have to physically walk to the terminal.

This breaks the core value proposition. You're supposed to be away from your machine, sending work to Claude from your phone. But the moment Claude tries to actually write code or run a build, it stalls on a permission prompt.

The pragmatic workaround is `--dangerously-skip-permissions`:

```bash
claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions
```

The flag name is intentionally alarming. With it enabled, Claude reads, writes, deletes files, and executes commands without asking. On a personal project where you're the only operator, the risk is manageable. On a machine connected to production infrastructure, think carefully. MacStories' launch-night testing — building iOS apps, running CLI tools, processing audio from an iPhone — was only possible because they ran with this flag. The current reality: full remote capability, or permission safety. Pick one.

## What Does "Research Preview" Actually Mean for Your Workflow?

Channels is explicitly labeled "research preview," and that label carries real constraints. The `--channels` flag only accepts plugins from Anthropic's curated allowlist — right now that's Telegram, Discord, and Fakechat (the localhost demo). Pass anything else and Claude Code starts normally, but the channel silently doesn't register.

If you build your own channel, testing requires `--dangerously-load-development-channels`, and channels built this way can't be distributed to other users. Anthropic must review and list them in the official marketplace first. Authentication is another wall: a claude.ai login is required, and API key authentication doesn't work. This blocks developers who access Claude Code through organizational API keys rather than personal subscriptions.

Organization admins must explicitly enable channels in managed settings — if they don't, the `--channels` flag is silently ignored. Sessions must stay open because events only arrive while the session is active. Close Claude Code, the channel dies. Always-on setups require tmux, screen, or a background process wrapper with no built-in daemon mode. And the platform gaps are obvious: no Slack, no WhatsApp, no iMessage, no Microsoft Teams. Anthropic has said the `--channels` flag syntax and notification protocol may change based on feedback, so plan for API changes in Q2-Q3 2026 if you're building production workflows around this.

## How Did One Austrian Developer Build a 200K-Star Rival in an Hour?

Context matters. Peter Steinberger created OpenClaw in November 2025 by hooking WhatsApp to Claude Code. The first version took about an hour to build. By February 2026, it had grown to roughly 300,000 lines of code and supported most major messaging platforms.

The Anthropic-OpenClaw relationship has layers. Steinberger originally named the project "Clawd" — a direct reference to Anthropic's Claude. Anthropic sent a cease-and-desist for potential trademark infringement, the name changed to OpenClaw, Steinberger later joined OpenAI, and then Anthropic built the same feature into its own product. His now-famous anecdote: on a trip to Morocco, he sent a photo of a tweet to WhatsApp, and his agent checked out the repository, committed a fix, and replied to the original poster on Twitter. All from a phone.

## Why Would Anyone Choose a 200K-Star Open-Source Tool?

OpenClaw's platform coverage is overwhelming. WhatsApp, iMessage, Slack, Signal, Telegram, Discord, Microsoft Teams — nearly every messaging platform people actually use, compared to Channels' two. The cost gap is equally stark: OpenClaw is free and open-source under MIT license, where you can connect to cloud APIs for roughly $5-20/month depending on usage, or run local models via Ollama for zero API cost. Channels requires a Claude subscription at $20/month for Pro, up to $100/month for Max.

OpenClaw runs on macOS, Windows, and Linux with integration into platform-specific messaging apps like iMessage on Mac, giving it an edge in daily workflow integration. It's also **model-agnostic** — you can wire it to Claude, GPT-4, local models, or any mix. Channels is locked to Claude through Anthropic's infrastructure.

## So Why Would I Still Pick 3 Plugins Over All of That?

Security. This is the decisive gap, and it's not close.

OpenClaw ships with permissive defaults, and its security posture has been a recurring concern — multiple safety-focused forks exist. Channels has allowlist-based plugin verification, pairing-code authentication that locks bots to specific user IDs, no inbound ports exposed, and prompt injection threat modeling in the official documentation. The difference between "passes a personal risk tolerance check" and "passes an enterprise security review" lives here.

Setup complexity tells its own story. OpenClaw users were buying dedicated Mac Minis to run the agent 24/7. Channels adds one flag to an existing Claude Code session — no dedicated hardware, no complex configuration, no self-hosting maintenance. And because Channels works inside the same environment as Claude Code's tools, skills, memory, worktrees, and MCP servers, your channel messages arrive with **full project context** already loaded. OpenClaw operates as a separate layer that calls APIs without sharing Claude Code's file system awareness or session continuity.

For team environments, Channels offers governance controls that OpenClaw simply doesn't have: admin-level enable/disable, permission rules, and audit trails out of the box.

The short version: personal projects with maximum platform flexibility point toward OpenClaw. Team environments with security requirements point toward Channels.

## Where Does This Fit in Claude Code's Growing Surface Area?

Anthropic has been building out Claude Code's reach throughout early 2026. The product started as a terminal tool, then expanded to IDE integration (VSCode, Cursor), a desktop app, a web interface, the Agent SDK for programmatic agent layers, GitHub Actions for CI/CD, Slack integration for team chat, and Remote Control for cross-device session continuity. What was missing: the ability to **react to external events**. Channels fills that gap.

Anthropic's own documentation draws the comparison explicitly. Web sessions are stateless conversations on claude.ai, Slack integration is Claude in team chat, MCP servers are tools Claude invokes, Remote Control is accessing the same session from different devices, and Channels is "pushing events from non-Claude sources into your already-running local session." The keyword is "non-Claude sources" — not just human messages, but system events like CI failure webhooks, monitoring alerts, and GitHub events flowing directly into a Claude Code session with full project context.

## What Does This Actually Look Like in Practice?

The baseline use case is mobile coding. Leave a tmux session running at home with `claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions`. From anywhere, send "fix the JWT validation bug in auth.py" via Telegram. Claude reads the code, patches it, commits. Result arrives in Telegram.

Push it further with CI pipeline auto-response: forward build failures into the channel, and Claude reads the logs with full project context, diagnosing issues like "this type mismatch was introduced when you refactored the auth module yesterday." It can auto-fix and open a PR. For solo developers running multiple projects, consolidating monitoring alerts into one Claude Code session turns it into a multi-project triage hub — Sentry errors, Cloudflare Workers logs, database alerts all flowing to Claude, which handles urgent ones immediately and sends a Telegram digest of the rest.

Discord becomes a lightweight code review interface when you connect a Claude bot to a team server. A developer types "review this PR" in Discord, Claude reads the diff and posts comments. No context switching to a separate tool.

## Can You Build Your Own Channel Right Now?

Yes, with caveats. Anthropic published a Channels reference documenting how to build custom channels. The core requirement is an MCP server that declares the `claude/channel` capability and implements the channel protocol. During the research preview, custom channels need the `--dangerously-load-development-channels` flag and can't be distributed — Anthropic review and marketplace listing is required for general distribution.

The architecture is plugin-based by design, and the Telegram and Discord plugin source code is public in the `claude-plugins-official` GitHub repository. Community-built Slack, WhatsApp, and Teams channels are technically possible since the protocol is documented and the reference implementations are open. The plugin system itself bundles MCP servers and automatically provides tools when enabled, declared in settings.json, with CLI tool usage detection triggering plugin tips alongside existing file pattern matching.

## Does This Replace Your Tailscale + SSH Setup?

If you already run a Tailscale + SSH + tmux remote development setup, Channels can simplify a meaningful chunk of that pipeline. The old flow goes from phone to Tailscale VPN to SSH to remote machine to tmux attach to typing a prompt in Claude Code to checking output to tmux detach. The Channels flow: phone to Telegram message. Done. Result arrives in Telegram.

SSH direct access is still needed for complex debugging, real-time terminal output, and permission prompts if you don't run with `--dangerously-skip-permissions`. But for quick bug fixes, build triggers, and code questions, Telegram is enough. The practical pattern: keep one tmux session permanently running with Claude Code in `--channels` mode, maintain your Tailscale + SSH pipeline for heavy lifting, and use Telegram for lightweight tasks. Two paths to the same machine, optimized for different interaction weights.

> The shift Channels represents isn't about intelligence — it's about availability. An AI agent that requires you to sit at a terminal is constrained by your physical presence. An AI agent that accepts work from your pocket is constrained only by your imagination.

---
- [Claude Code Channels docs](https://code.claude.com/docs/en/channels) – Anthropic
- [Hands-On with Telegram and Discord Integrations](https://www.macstories.net/stories/first-look-hands-on-with-claude-codes-new-telegram-and-discord-integrations/) – MacStories
- [Anthropic Ships Claude Code Channels](https://www.implicator.ai/anthropic-ships-its-openclaw-rival-connecting-claude-code-to-telegram-and-discord/) – Implicator
- [Claude Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy
- [Claude Code Channels Setup Guide](https://claudefa.st/blog/guide/development/claude-code-channels) – Claude Fast
