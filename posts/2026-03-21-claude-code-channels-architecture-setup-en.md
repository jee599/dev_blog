---
title: "I Control Claude Code From My Phone Now — Here's the 5-Minute Telegram Setup"
published: true
description: "200K GitHub stars proved devs want phone-to-terminal AI. Anthropic just shipped their answer."
tags: ai, claudecode, productivity, programming
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-channels-hero.jpg
canonical_url: https://jidonglab.com/blog/claude-code-channels-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-code-channels-architecture-setup'
id: 3379440
date: 'draft'
---

I was on the subway when I pushed a commit to production. Not from a laptop. Not through SSH. I sent a Telegram message from my phone, and Claude Code — running on the machine sitting at my desk — picked it up, fixed the bug, and replied with the diff. No terminal access required.

That moment rewired how I think about coding.

On March 20, 2026, Anthropic shipped Claude Code Channels as a research preview, and within hours I had it running. The concept is deceptively simple: send a message from Telegram or Discord, and a live Claude Code session on your local machine executes the work and replies through the same chat app.

OpenClaw proved the demand with **200K GitHub stars** for an open-source agent that connected WhatsApp, iMessage, and Telegram to a developer's AI. Anthropic's response was to build the same capability into their first-party product, with tighter security and a setup I timed at under five minutes.

## Why Does "Push, Not Pull" Change Everything?

This is the architectural distinction that actually matters. Regular MCP servers are passive — they sit idle until Claude calls them. "Use this tool" triggers an action. Without the call, nothing happens.

A Channel inverts this entirely. It's an MCP server that declares the `claude/channel` capability and actively **pushes** events into a running Claude Code session. External systems fire messages the moment they arrive — a Telegram message from your phone, a CI failure webhook, a Datadog alert. Claude maintains session state across these events instead of rebuilding context every time someone opens a terminal.

Anthropic's documentation calls this "push, not pull." The distinction sounds minor. It isn't.

Think about the traditional interaction: you sit at the terminal, type a prompt, Claude responds. You close the terminal, interaction ends. With Channels, Claude Code runs in the background. Events arrive from the outside world. Claude processes each one with full project context. Your presence at the terminal is **optional**.

Here's the two-way data flow:

```
Phone (Telegram/Discord)
  ↓ message sent
Bot API (Telegram/Discord servers)
  ↑ polled by
Local MCP plugin (Bun process, runs on your machine)
  ↓ wraps message as <channel> event
Claude Code session (local terminal)
  ↓ executes work (reads/edits code, runs commands)
  ↓ calls reply tool
Local MCP plugin → Bot API → result appears on phone
```

Two modes serve different needs. One-way channels forward events without expecting a reply — CI failure notifications, monitoring alerts pushed into Claude's context. Two-way channels let Claude read the message and respond through the same platform, which is how both Telegram and Discord operate.

## How Does Anthropic Keep Your Machine Off the Public Internet?

This is where Channels separates from OpenClaw at an architectural level.

The channel plugin runs locally on your machine and **polls** the Bot API. No inbound port opens on your machine. No webhook endpoint gets exposed to the public internet. No reverse proxy needed. When I first read the architecture docs, I expected some kind of tunnel or relay server. There isn't one. Your machine initiates every connection outward.

Webhook-based channels for CI and monitoring do listen on a localhost HTTP port, but external systems POST to `127.0.0.1:PORT` via an internal tunnel. The traffic never touches the public internet.

The security model layers three protections on top of this: an allowlist-based plugin system that only permits Anthropic-approved plugins during the preview, pairing-code authentication that locks the bot to your specific user ID so messages from anyone else in the same Discord server get silently dropped, and prompt injection threat modeling documented in the official Channels reference.

OpenClaw gained traction with a more permissive security posture — which is exactly why multiple safety-focused forks emerged. The gap between "works for a hobbyist tinkering on personal projects" and "passes an enterprise security review" lives in these architectural choices.

## Can You Really Set This Up in Five Minutes?

I timed myself. Four minutes and thirty seconds, including the BotFather conversation.

You need Claude Code v2.1.80+, a claude.ai login (API keys are not supported), and the Bun JavaScript runtime. That's it.

Start by creating a Telegram bot. Open BotFather in Telegram, send `/newbot`, pick a display name and a unique username ending in `bot`. Copy the token BotFather returns.

```bash
# Register the official plugin marketplace (first time only)
/plugin marketplace add anthropics/claude-plugins-official

# Install the Telegram plugin
/plugin install telegram@claude-plugins-official

# Configure with your BotFather token
/telegram:configure <YOUR_BOT_TOKEN>

# Start Claude Code with the channels flag
claude --channels plugin:telegram@claude-plugins-official
```

Open Telegram and send any message to your bot. It replies with a pairing code. If the bot doesn't respond, confirm Claude Code is running with `--channels` from the previous step — the bot can only reply while the channel is active.

Back in Claude Code, enter the pairing code. Connection complete.

Here's what surprised me. File attachments work — the reply tool sends files back, with images rendering inline and other types sent as documents up to 50MB per file. You can send screenshots of a mobile app you're testing directly to Claude Code from Telegram, which turned out to be my most-used workflow within the first hour. The bot also shows a "typing..." indicator while Claude works, which is surprisingly useful for distinguishing between "Claude is still processing" and "Claude is stuck on a permission prompt."

One constraint worth knowing: Telegram's Bot API provides no message history. The bot only sees messages as they arrive in real-time. If the session was down when you sent a message, that message is gone forever.

## What About Discord — Is It Worth the Extra Steps?

Discord requires creating an application in the Developer Portal, which adds roughly five more minutes to the setup.

Go to the Discord Developer Portal, click New Application, and name it. Navigate to Bot in the sidebar, create a username, then Reset Token and copy it. The critical step most people miss: scroll to Privileged Gateway Intents and enable **Message Content Intent**. Without this, the bot receives messages but cannot read their contents — a silent failure that cost me ten minutes of debugging.

Under OAuth2 > URL Generator, select the `bot` scope and enable these permissions: View Channels, Send Messages, Send Messages in Threads, Read Message History, Attach Files, and Add Reactions. Open the generated URL to invite the bot to your server.

```bash
# Install the Discord plugin
/plugin install discord@claude-plugins-official

# Configure with your bot token
/discord:configure <YOUR_BOT_TOKEN>

# Start with channels flag
claude --channels plugin:discord@claude-plugins-official
```

DM the bot on Discord. It sends a pairing code. Use `/discord:access pair <code>` to complete the link. The pairing system locks the bot to your Discord user ID — messages from anyone else in the same server are silently dropped.

## What If You Want to Test Without Any External Service?

Before connecting to Telegram or Discord, you can validate the entire channel architecture locally using Fakechat — Anthropic's official localhost demo channel.

```bash
/plugin install fakechat@claude-plugins-official
claude --channels plugin:fakechat@claude-plugins-official
```

A chat UI opens on localhost in your browser. Type a message, it arrives in the Claude Code session. Claude responds, the reply appears in the browser. No authentication, no external service, no API keys. I'd recommend starting here to understand the event flow before wiring up a real platform.

## What Did MacStories Build on Launch Night?

The most concrete validation came from MacStories, who tested the feature hours after launch. With `--dangerously-skip-permissions` enabled, they accomplished everything from an iPhone via Telegram without touching the terminal once.

They built and ran an iOS project using xcodebuild, then deployed it wirelessly to the very iPhone they were using to chat with Claude Code. They compiled a list of 83 articles tagged "NPC" from Readwise Reader using its CLI tool. They kicked off a Claude Code skill that transcribes podcast audio, cleaned up the resulting text, and received TXT, SRT, and a Markdown report — all on the iPhone.

These aren't toy demos. Building an iOS project, deploying to a test device, running CLI tools, processing audio — this is real developer workflow executed entirely from a chat interface on a phone.

The `--dangerously-skip-permissions` flag was essential. Without it, every file write, command execution, and build step would have triggered a permission prompt that can only be answered at the terminal. That flag is the current tradeoff: **full remote capability, or permission safety**. Not both. I expect Anthropic to solve this gap soon, but for now, you choose.

> Channels inverts the relationship between developer and agent — from "I sit here and direct you" to "you run there and I check in when I want."

---
- [Claude Code Channels docs](https://code.claude.com/docs/en/channels) – Anthropic
- [Hands-On with Telegram and Discord Integrations](https://www.macstories.net/stories/first-look-hands-on-with-claude-codes-new-telegram-and-discord-integrations/) – MacStories
- [Anthropic Ships Claude Code Channels](https://www.implicator.ai/anthropic-ships-its-openclaw-rival-connecting-claude-code-to-telegram-and-discord/) – Implicator
- [Claude Code Channels Setup Guide](https://claudefa.st/blog/guide/development/claude-code-channels) – Claude Fast
- [Claude Code CHANGELOG](https://docs.anthropic.com/en/release-notes/claude-code) – Anthropic
