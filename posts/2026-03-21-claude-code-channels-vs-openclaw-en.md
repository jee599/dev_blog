---
title: "Claude Code Channels vs OpenClaw: The Tradeoffs Nobody's Talking About"
published: true
description: "Channels can't approve permissions remotely, only supports 3 plugins, and requires a paid subscription. OpenClaw is free and covers every messaging platform. Here's when each one wins — plus real-world scenarios and custom channel development."
tags: claudecode, ai, opensource, devops
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-channels-vs-openclaw.jpg
canonical_url: https://jidonglab.com/blog/claude-code-channels-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-code-channels-vs-openclaw'
---

In the [previous post](https://dev.to/jidonglab/claude-code-channels-architecture-setup), I covered how Claude Code Channels works — the push-not-pull architecture, the local MCP plugin bridge, and the five-minute Telegram/Discord setup.

Now the harder questions. What can't it do? How does it compare to OpenClaw, the open-source project that pioneered this interaction model? And what does it actually look like in production workflows?

**Source:** [Push events into a running session with channels](https://code.claude.com/docs/en/channels) – Anthropic Docs / [Claude Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy / [First Look](https://www.macstories.net/stories/first-look-hands-on-with-claude-codes-new-telegram-and-discord-integrations/) – MacStories

## The Permission Problem Is the Single Biggest Friction Point

When Claude Code needs to perform a risky action — deleting a file, executing a shell command, writing to a protected directory — it shows a permission prompt in the terminal. You approve or deny. Standard safety mechanism.

The problem: there is no way to respond to permission prompts from Telegram or Discord. If Claude hits a permission gate, it stops. You have to physically go to the terminal to approve.

This breaks the core value proposition. You're supposed to be away from your machine, sending work to Claude from your phone. But the moment Claude tries to actually write code or run a build, it's likely to hit a permission prompt and stall.

The pragmatic workaround is `--dangerously-skip-permissions`:

```bash
claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions
```

The flag name is intentionally alarming. With it enabled, Claude Code reads, writes, deletes files, and executes commands without asking. On a personal project where you're the only operator, the risk is manageable. On a machine connected to production infrastructure, think carefully.

MacStories' launch-night testing — building iOS apps, running CLI tools, processing audio from an iPhone — was only possible because they ran with this flag. Without it, every build step would have stalled on a permission prompt. The current reality: full remote capability, or permission safety. Pick one.

## Research Preview Constraints You Need to Know

Channels is explicitly labeled "research preview." Here's what that means in practice.

**Allowlist restriction.** The `--channels` flag only accepts plugins from Anthropic's curated allowlist. Right now that's three: Telegram, Discord, and Fakechat (the localhost demo). Pass anything else and Claude Code starts normally, but the channel doesn't register. The startup message tells you why.

**Custom channels need a "dangerously" flag.** If you build your own channel, testing requires `--dangerously-load-development-channels`. Channels built this way can't be distributed to other users. Anthropic must review and list them in the official marketplace before general use.

**Authentication limitation.** A claude.ai login is required. API key authentication doesn't work. This is a significant barrier for developers who access Claude Code through organizational API keys rather than personal subscriptions.

**Team/Enterprise gating.** Organization admins must explicitly enable channels in managed settings. If they don't, the `--channels` flag is silently ignored.

**Session must stay open.** Events only arrive while the session is active. Close Claude Code, the channel dies. Always-on setups require tmux, screen, or a background process wrapper. There's no built-in daemon mode.

**Platform gaps.** No Slack. No WhatsApp. No iMessage. No Microsoft Teams. The plugin architecture is designed to be extensible — Telegram and Discord plugin source code is public in the `claude-plugins-official` GitHub repo — but during the preview, only allowlisted plugins actually work with `--channels`.

Anthropic has said the `--channels` flag syntax and notification protocol may change based on feedback. Plan for API changes in Q2-Q3 2026 if you're building production workflows around this.

## OpenClaw: The Open-Source Project That Started This

Context matters. OpenClaw was created by Austrian developer Peter Steinberger in November 2025. He hooked WhatsApp to Claude Code and the first version took about an hour to build. By February 2026, it had grown to roughly 300,000 lines of code and supported most major messaging platforms.

The project crossed 200,000 GitHub stars. Steinberger's now-famous anecdote: on a trip to Morocco, he sent a photo of a tweet to WhatsApp, and his agent checked out the repository, committed a fix, and replied to the original poster on Twitter. All from a phone.

The Anthropic-OpenClaw relationship has layers. Steinberger originally named the project "Clawd" — a direct reference to Anthropic's Claude. Anthropic sent a cease-and-desist for potential trademark infringement. The name changed to OpenClaw. Steinberger later joined Anthropic's rival, OpenAI. And then Anthropic built the same feature into its own product.

## Where OpenClaw Wins

**Platform coverage.** WhatsApp, iMessage, Slack, Signal, Telegram, Discord, Microsoft Teams. OpenClaw covers nearly every messaging platform people actually use. Channels supports Telegram and Discord. That's it.

**Cost.** OpenClaw is free and open-source under MIT license. You can connect to cloud APIs (paying per call — roughly $5/month for light use, $15-20 for heavy), or run local models via Ollama or LM Studio for zero API cost. Channels requires a Claude subscription: $20/month for Pro, up to $100/month for Max.

**Platform support.** OpenClaw runs on macOS, Windows, and Linux. Channels runs wherever Claude Code runs (any OS with a terminal), so this is roughly a tie — but OpenClaw's ability to integrate with platform-specific messaging apps (iMessage on Mac, for example) gives it an edge in daily workflow integration.

**Flexibility.** OpenClaw is model-agnostic. You can wire it to Claude, GPT-4, local models, or any mix. Channels is locked to Claude through Anthropic's infrastructure.

## Where Channels Wins

**Security.** This is the decisive gap. OpenClaw ships with permissive defaults, and its security posture has been a recurring concern — multiple safety-focused forks exist. Channels has allowlist-based plugin verification, pairing-code authentication that locks bots to specific user IDs, no inbound ports exposed, and prompt injection threat modeling in the official documentation. The difference between "passes a personal risk tolerance check" and "passes an enterprise security review" lives here.

**Setup complexity.** OpenClaw users were buying dedicated Mac Minis to run the agent 24/7. Channels adds one flag to an existing Claude Code session. No dedicated hardware, no complex configuration, no self-hosting maintenance.

**Anthropic ecosystem integration.** Channels works inside the same environment as Claude Code's tools, skills, memory, worktrees, and MCP servers. Your channel messages arrive with full project context already loaded. OpenClaw operates as a separate layer that calls APIs — it doesn't share Claude Code's file system awareness or session continuity.

**Enterprise governance.** Team and Enterprise admins can control whether channels are enabled. Permission rules apply. Audit trails exist. OpenClaw offers none of this out of the box.

The short version: personal projects with maximum platform flexibility → OpenClaw. Team environments with security requirements → Channels.

## Where Channels Fits in Claude Code's Surface Area

Anthropic has been building out Claude Code's reach throughout early 2026. The product started as a terminal tool. Then came IDE integration (VSCode, Cursor), desktop app, web interface, Agent SDK for programmatic agent layers, GitHub Actions for CI/CD, Slack integration for team chat, and Remote Control for cross-device session continuity.

What was missing: the ability to react to external events. Channels fills that gap.

Anthropic's own documentation draws the comparison explicitly. Web sessions are stateless conversations on claude.ai. Slack integration is Claude in team chat. MCP servers are tools Claude invokes. Remote Control is accessing the same session from different devices. Channels is "pushing events from non-Claude sources into your already-running local session."

The keyword is "non-Claude sources." Not just human messages — system events. CI failure webhooks, monitoring alerts, GitHub events. These can now flow directly into a Claude Code session with full project context.

## Real-World Scenarios That Make Sense Today

**Mobile coding.** The baseline use case. Leave a tmux session running at home with `claude --channels plugin:telegram@claude-plugins-official --dangerously-skip-permissions`. From anywhere, send "fix the JWT validation bug in auth.py" via Telegram. Claude reads the code, patches it, commits. Result arrives in Telegram.

**CI pipeline auto-response.** Forward build failures into the channel. Claude reads the logs with full project context and can diagnose issues like "this type mismatch was introduced when you refactored the auth module yesterday." Push it further and Claude can auto-fix and open a PR.

**Multi-project alert hub.** For solo developers running multiple projects, consolidate monitoring alerts into one Claude Code session. Sentry errors, Cloudflare Workers logs, database alerts — Claude triages, handles urgent ones immediately, summarizes the rest and sends a Telegram digest.

**Discord code review bridge.** Connect a Claude bot to a team Discord server. A developer types "review this PR" in Discord, Claude reads the diff and posts comments. Discord becomes a lightweight code review interface.

## Building Custom Channels

Anthropic published a Channels reference documenting how to build custom channels. The core requirement: an MCP server that declares the `claude/channel` capability and implements the channel protocol.

During the research preview, custom channels need the `--dangerously-load-development-channels` flag and can't be distributed to others. Anthropic review and marketplace listing is required for general distribution.

But the architecture is plugin-based by design. The Telegram and Discord plugin source code is public in the `claude-plugins-official` GitHub repository. Community-built Slack, WhatsApp, and Teams channels are technically possible — the protocol is documented, the reference implementations are open.

The plugin system itself is worth noting. Plugins bundle MCP servers and automatically provide tools when enabled. They're declared in settings.json (a `source: 'settings'` marketplace source was added in the same release), and CLI tool usage detection triggers plugin tips alongside the existing file pattern matching.

## Replacing Parts of an Existing Remote Dev Pipeline

If you already run a Tailscale + SSH + tmux remote development setup, Channels can simplify a meaningful chunk of that pipeline.

The old flow: phone → Tailscale VPN → SSH to remote machine → tmux attach → type prompt in Claude Code → check output → tmux detach.

The Channels flow: phone → Telegram message → done. Result arrives in Telegram.

SSH direct access is still needed for complex debugging, real-time terminal output, and permission prompts (if you don't run with `--dangerously-skip-permissions`). But for quick bug fixes, build triggers, and code questions, Telegram is enough.

The practical pattern: keep one tmux session permanently running with Claude Code in `--channels` mode. Maintain your Tailscale + SSH pipeline for heavy lifting. Use Telegram for lightweight tasks. Two paths to the same machine, optimized for different interaction weights.

> The shift Channels represents isn't about intelligence — Claude's reasoning didn't get better this week. It's about availability. An AI agent that requires you to sit at a terminal is constrained by your physical presence. An AI agent that accepts work from your pocket is constrained by your imagination.

---
- [Claude Code Channels docs](https://code.claude.com/docs/en/channels) – Anthropic
- [Hands-On with Telegram and Discord Integrations](https://www.macstories.net/stories/first-look-hands-on-with-claude-codes-new-telegram-and-discord-integrations/) – MacStories
- [Anthropic Ships Claude Code Channels](https://www.implicator.ai/anthropic-ships-its-openclaw-rival-connecting-claude-code-to-telegram-and-discord/) – Implicator
- [Claude Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy
- [Claude Code Channels Setup Guide](https://claudefa.st/blog/guide/development/claude-code-channels) – Claude Fast
