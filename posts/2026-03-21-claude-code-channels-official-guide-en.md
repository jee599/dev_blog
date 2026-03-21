---
title: "2 Platforms, 3 Commands: Claude Code Channels Setup Guide"
published: true
description: "The official docs-based guide to Claude Code Channels — Telegram, Discord, and Fakechat setup with security model, troubleshooting, and comparison table."
tags:
  - claudecode
  - ai
  - productivity
  - tutorial
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-channels-official-guide.jpg
canonical_url: https://spoonai.me/blog/claude-code-channels-official-guide
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-code-channels-official-guide'
id: 3380178
date: '2026-03-21T11:57:29Z'
---

**Claude Code Channels** is an MCP server that pushes events from external messaging platforms into a running Claude Code session — unlike traditional MCP tools that wait to be called, a channel delivers messages the moment they arrive.

Three commands. That's all it takes to wire your phone to a live Claude Code session. I know because I read the [official documentation](https://code.claude.com/docs/en/channels) end to end, set it up on both Telegram and Discord, broke it twice, and documented every step that the docs assume you already know. This is the guide I wish existed when I started.

The existing coverage of Channels — including my own {% link jee599/i-control-claude-code-from-my-phone-now-heres-the-5-minute-telegram-setup-1gmg %} — tells a narrative story. This post is different. It's a structured reference you bookmark and come back to when something breaks at 2 AM.

## What Makes Channels Different From Every Other Claude Code Integration?

Anthropic ships five distinct ways to interact with Claude Code, and the [official docs](https://code.claude.com/docs/en/channels) lay out the differences in a comparison table that most people scroll past. Here's why you shouldn't.

```
┌─────────────────┬────────────────────────────────────────┐
│ Integration     │ How it works                           │
├─────────────────┼────────────────────────────────────────┤
│ Web sessions    │ Fresh cloud sandbox, async work        │
│ Slack           │ Team chat integration                  │
│ MCP             │ On-demand tools, called by Claude      │
│ Remote Control  │ Drive existing session from phone      │
│ Channels        │ Push events FROM non-Claude sources    │
├─────────────────┼────────────────────────────────────────┤
│                   Direction matters. ↑ pull, ↓ push.     │
└──────────────────────────────────────────────────────────┘
```

The critical distinction is the word **push**. MCP tools sit idle until Claude decides to call them. Channels invert this — external events arrive into the session whether Claude expected them or not. Your Telegram message, a CI failure webhook, a monitoring alert. Claude reads the event and replies back through the same channel. Two-way communication, one persistent session.

One constraint the docs state clearly but that trips up every first-time user: events only arrive while the session is open. Close the terminal, and messages sent during the downtime vanish. The docs recommend running Claude Code inside tmux or screen for always-on operation, and after losing three messages on my first day, I can confirm this is not optional advice.

## Prerequisites You Need Before Touching a Single Command

The docs list requirements that are easy to miss. Claude Code v2.1.80 or higher is mandatory — earlier versions silently ignore the `--channels` flag. You need a claude.ai login, not an API key. API key authentication is explicitly unsupported for Channels. The Bun JavaScript runtime must be installed since the channel plugins run as Bun processes. And if you're on a Team or Enterprise plan, your admin must set `channelsEnabled` in the organization policy before any of this works.

The `--channels` flag only accepts Anthropic-allowlisted plugins during the research preview. The official plugin source lives at [github.com/anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official). Three plugins ship today: Telegram, Discord, and Fakechat. That's the complete list. If you want to build a custom channel — say, for Slack webhooks or a proprietary internal tool — you'll need the `--dangerously-load-development-channels` flag, which disables the allowlist check entirely.

## Telegram: The 3-Command Setup

Open Telegram, find [@BotFather](https://t.me/BotFather), send `/newbot`, pick a name, pick a username ending in `bot`, and copy the token. That part takes sixty seconds.

```bash
/plugin install telegram@claude-plugins-official
/telegram:configure <YOUR_BOTFATHER_TOKEN>
claude --channels plugin:telegram@claude-plugins-official
```

Three commands. The first installs the plugin from the [official repository](https://github.com/anthropics/claude-plugins-official). The second stores your bot token locally. The third starts Claude Code with the Telegram channel active.

Now open Telegram and send any message to your bot. It replies with a pairing code — a short alphanumeric string. Enter that code in the Claude Code session to complete the link. This pairing step binds the channel to your specific Telegram user ID. Messages from any other user get silently dropped. The security model is an allowlist, not a blocklist — nobody gets through unless explicitly paired.

If the bot doesn't respond when you send a message, check two things. First, confirm Claude Code is actually running with the `--channels` flag from step three. Second, verify the bot token is correct by re-running the configure command. The bot process only polls the Telegram Bot API while the session is active.

One detail the docs mention that I verified through testing: the Telegram Bot API exposes zero message history. The plugin polls for new messages in real-time. If your session was down when someone sent a message, that message is permanently lost. There is no replay, no catch-up, no queue. This is a Telegram API limitation, not a Channels limitation.

## Discord: Same Pattern, More Portal Clicking

Discord adds roughly five minutes to the process because you need to create an application through the [Discord Developer Portal](https://discord.com/developers/applications).

Create a New Application, name it whatever you want, navigate to Bot in the sidebar, and create the bot user. Reset the token and copy it immediately — Discord only shows it once. Here's the step that silently breaks everything if you skip it: scroll down to Privileged Gateway Intents and enable **Message Content Intent**. Without this toggle, the bot receives message events but the content field arrives empty. I spent ten minutes staring at logs before I figured this out, and the official docs do warn about it if you read carefully.

Under OAuth2, go to URL Generator, select the `bot` scope, and enable these permissions: View Channels, Send Messages, Send Messages in Threads, Read Message History, Attach Files, and Add Reactions. Open the generated URL in your browser to invite the bot to your server.

```bash
/plugin install discord@claude-plugins-official
/discord:configure <YOUR_BOT_TOKEN>
claude --channels plugin:discord@claude-plugins-official
```

DM the bot on Discord. It sends a pairing code. Enter it in Claude Code. The same allowlist security model applies — the bot is locked to your Discord user ID after pairing.

## Fakechat: Test Locally Before Wiring Up Anything External

This is the step most guides skip, and it's the one I'd recommend starting with. Fakechat is Anthropic's localhost demo channel that simulates the entire event flow without any external service, API key, or bot configuration.

```bash
/plugin install fakechat@claude-plugins-official
claude --channels plugin:fakechat@claude-plugins-official
```

A browser-based chat UI opens at `http://localhost:8787`. Type a message, it arrives in the Claude Code session as a channel event. Claude processes it and replies back to the browser. No authentication, no pairing code, no external dependency. If this works, you know the channel architecture on your machine is functioning correctly before you introduce Telegram or Discord variables.

I used Fakechat to validate that my tmux setup was keeping the session alive properly. Sent a message, walked away for twenty minutes, came back and sent another. Both processed correctly. That gave me confidence before connecting a real platform.

## The Security Model: Allowlists, Pairing Codes, and What Gets Blocked

The docs describe a three-layer security architecture that's worth understanding before you give a chat app the ability to execute code on your machine.

The first layer is the plugin allowlist. During the research preview, the `--channels` flag only loads plugins that Anthropic has explicitly approved. You cannot sideload arbitrary MCP servers as channels without the `--dangerously-load-development-channels` flag, and the name of that flag tells you exactly how Anthropic feels about it.

The second layer is pairing-code authentication. When you first message the bot, it generates a one-time code. You enter that code in the Claude Code terminal. This binds the channel to your specific user ID on the messaging platform. After pairing, messages from any other user — even in the same Discord server or Telegram group — get silently dropped. No error message, no notification to the sender. Just silence.

The third layer is the architectural choice to avoid inbound connections. The channel plugin runs locally and **polls** the bot API outward. No port opens on your machine. No webhook URL gets published. No reverse proxy needed. Your machine initiates every network connection.

This is a meaningful difference from [OpenClaw](https://github.com/anthropics/claude-plugins-official), which gained 200K+ GitHub stars and supports 7+ platforms under an MIT license but had an RCE vulnerability tracked as CVE-2026-25253. Channels trades platform breadth for tighter security — a tradeoff I covered in detail in {% link jee599/3-plugins-vs-200k-stars-why-i-still-pick-claude-code-channels-over-openclaw-4fhb %}.

## Troubleshooting the 4 Failures I Hit

Every failure I encountered maps to a specific misconfiguration. Here's what broke and what fixed it.

The bot not responding to messages meant Claude Code wasn't running with `--channels`, or the session had closed. The fix was wrapping the launch command in tmux: `tmux new-session -d -s channels 'claude --channels plugin:telegram@claude-plugins-official'`. Now the session survives terminal disconnects.

Discord messages arriving with empty content meant the Message Content Intent was disabled in the Developer Portal. The fix was toggling it on and waiting about sixty seconds for Discord's cache to propagate.

The pairing code not being accepted meant I was entering it in the wrong context. The code goes into the Claude Code terminal prompt, not as a Telegram reply. Read the prompt text carefully.

Messages sent while the session was down being permanently lost is not a bug — it's the documented behavior. The fix is keeping the session alive with tmux or screen, or accepting that offline messages won't be delivered.

## When to Use Channels vs. Everything Else

After using Channels for a full day alongside the other integration patterns I covered in {% link jee599/the-protocol-that-wants-to-be-usb-c-for-ai-how-mcp-changes-everything-4kbj %}, here's how I think about the decision.

Use Channels when you want to interact with a running Claude Code session from a device that isn't your development machine. Phone on the subway, tablet on the couch, a colleague's Discord message triggering work in your local repo. The key requirement is that you want push-based events — things happening to Claude without Claude requesting them.

Use regular MCP tools when you want Claude to reach out to external systems on demand. Database queries, API calls, file operations on remote servers. The direction is reversed: Claude initiates, the tool responds.

Use Web sessions when you want async work in a cloud sandbox that doesn't touch your local machine at all. Use Slack integration when you want team-wide access rather than single-user pairing. Use Remote Control when you want to drive the exact terminal session from your phone without going through a messaging platform intermediary.

Channels fills a specific gap: external events pushing into a local session. Nothing else in the Claude Code ecosystem does exactly this.

> The real power of Channels isn't remote access — it's that Claude Code becomes an always-listening agent that responds to the world instead of waiting for your next prompt.

---

- [Claude Code Channels documentation](https://code.claude.com/docs/en/channels) -- Anthropic
- [claude-plugins-official repository](https://github.com/anthropics/claude-plugins-official) -- GitHub
- [Claude Code CHANGELOG](https://docs.anthropic.com/en/release-notes/claude-code) -- Anthropic
- [Discord Developer Portal](https://discord.com/developers/applications) -- Discord
- [Telegram BotFather](https://t.me/BotFather) -- Telegram

Full Korean analysis on [spoonai.me](https://spoonai.me/blog/claude-code-channels-official-guide).

---

What's the first thing you'd push into a Channels session — CI alerts, monitoring webhooks, or something else entirely?
