---
title: "Claude Code Channels: How Anthropic Built a Two-Way Bridge Between Telegram and Your Terminal"
published: true
description: "Anthropic shipped Claude Code Channels — MCP-based plugins that push Telegram and Discord messages into a running Claude Code session. Here's exactly how the architecture works and how to set it up in 5 minutes."
tags: claudecode, ai, mcp, programming
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-code-channels-hero.jpg
canonical_url: https://jidonglab.com/blog/claude-code-channels-ko
---

On March 20, 2026, Anthropic shipped Claude Code Channels as a research preview. Send a message from Telegram or Discord, and the Claude Code session running on your local machine picks it up, executes the work, and replies through the same chat app.

No terminal access required. No SSH tunnel. No VPN. You message a bot from the subway, and Claude fixes code on the machine sitting at your desk.

OpenClaw proved the demand — 200K GitHub stars for an open-source agent that let developers message their AI from WhatsApp, iMessage, and Telegram. Anthropic's response was to build the same capability into their first-party product, with tighter security and a five-minute setup.

**Source:** [Push events into a running session with channels](https://code.claude.com/docs/en/channels) – Anthropic Docs / [Anthropic Ships Claude Code Channels](https://www.implicator.ai/anthropic-ships-its-openclaw-rival-connecting-claude-code-to-telegram-and-discord/) – Implicator

## A Channel Is an MCP Server That Pushes, Not Pulls

This is the architectural distinction that matters. Regular MCP servers are passive — they sit idle until Claude calls them. "Use this tool" triggers an action. Without the call, nothing happens.

A Channel inverts this. It's an MCP server that declares the `claude/channel` capability and actively pushes events into a running Claude Code session. External systems fire messages the moment they arrive — a Telegram message from your phone, a CI failure webhook, a Datadog alert. Claude maintains session state across these events instead of rebuilding context every time someone opens a terminal.

Anthropic's documentation calls this "push, not pull." The distinction sounds minor. It isn't.

Traditional interaction: you sit at the terminal, type a prompt, Claude responds. You close the terminal, interaction ends.

Channels interaction: Claude Code runs in the background. Events arrive from the outside world. Claude processes each one with full project context. Your presence at the terminal is optional.

The two-way variant works like this:

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

Two modes exist. **One-way channels** forward events without expecting a reply — CI failure notifications, monitoring alerts pushed into Claude's context. **Two-way channels** let Claude read the message and respond through the same platform. Telegram and Discord both run as two-way channels.

## Nothing Is Exposed to the Internet

This is where Channels separates from OpenClaw at an architectural level.

The channel plugin runs locally on your machine and polls the Bot API. There is no inbound port opened on your machine. No webhook endpoint exposed to the public internet. No reverse proxy needed.

Webhook-based channels (for CI, monitoring, etc.) listen on a localhost HTTP port. External systems POST to `127.0.0.1:PORT` via an internal tunnel. The traffic never touches the public internet.

The security model layers on top of this: an allowlist-based plugin system (only Anthropic-approved plugins during the preview), pairing-code authentication (locks the bot to your specific user ID, ignoring messages from anyone else in the same Discord server), and prompt injection threat modeling documented in the official Channels reference.

OpenClaw, by contrast, gained traction with a more permissive security posture — which is exactly why multiple safety-focused forks emerged. The difference between "works for a hobbyist tinkering on personal projects" and "passes an enterprise security review" lives in these architectural choices.

## Telegram Setup: Five Minutes, Start to Finish

Requirements: Claude Code v2.1.80+, a claude.ai login (API keys are not supported), and the Bun JavaScript runtime.

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

Back in Claude Code, enter the pairing code. Connection complete. Every message you send from Telegram now lands directly in the Claude Code session.

A few things the Telegram channel supports that aren't immediately obvious. File attachments work — the reply tool sends files back, with images rendering inline and other types sent as documents (50MB per file limit). You can send images to Claude Code from Telegram, which is useful for sending debug screenshots of a mobile app you're testing. The bot shows a "typing..." indicator while Claude works, which is surprisingly useful for distinguishing between "Claude is still processing" and "Claude is stuck on a permission prompt."

One important constraint: Telegram's Bot API provides no message history. The bot only sees messages as they arrive in real-time. If the session was down when you sent a message, that message is gone.

## Discord Setup: Ten Minutes, a Few More Steps

Discord requires creating an application in the Developer Portal, which adds some overhead.

Go to the Discord Developer Portal, click New Application, name it. Navigate to Bot in the sidebar, create a username, then Reset Token and copy it. Scroll to Privileged Gateway Intents and enable **Message Content Intent** — without this, the bot cannot read message contents.

Under OAuth2 > URL Generator, select the `bot` scope and enable these permissions: View Channels, Send Messages, Send Messages in Threads, Read Message History, Attach Files, Add Reactions. Open the generated URL to invite the bot to your server.

```bash
# Install the Discord plugin
/plugin install discord@claude-plugins-official

# Configure with your bot token
/discord:configure <YOUR_BOT_TOKEN>

# Start with channels flag
claude --channels plugin:discord@claude-plugins-official
```

DM the bot on Discord. It sends a pairing code. Use `/discord:access pair <code>` to complete the link. The pairing system locks the bot to your Discord user ID — messages from anyone else in the same server are silently dropped.

## Fakechat: Test the Flow Without External Services

Before connecting to Telegram or Discord, you can validate the entire channel architecture locally using Fakechat — Anthropic's official localhost demo channel.

```bash
/plugin install fakechat@claude-plugins-official
claude --channels plugin:fakechat@claude-plugins-official
```

A chat UI opens on localhost in your browser. Type a message, it arrives in the Claude Code session. Claude responds, the reply appears in the browser. No authentication, no external service, no API keys.

Use it to understand the event flow before wiring up a real platform. Once the mechanics make sense, switch to Telegram or Discord.

## What MacStories Built on Launch Night

The most concrete validation of Channels came from MacStories, which tested the feature hours after launch. With `--dangerously-skip-permissions` enabled, they accomplished all of the following from an iPhone via Telegram, without touching the terminal once:

Built and ran an iOS project using xcodebuild, deployed it wirelessly to the iPhone they were using to chat with Claude Code. Compiled a list of 83 articles tagged "NPC" from Readwise Reader using its CLI tool. Kicked off a Claude Code skill that transcribes podcast audio, cleaned up the resulting text, and received TXT, SRT, and a Markdown report on the iPhone.

These aren't toy demos. Building an iOS project, deploying to a test device, running CLI tools, processing audio — this is real developer workflow executed entirely from a chat interface on a phone.

The `--dangerously-skip-permissions` flag was essential. Without it, every file write, command execution, and build step would have triggered a permission prompt that can only be answered at the terminal. That flag is the current tradeoff: full remote capability, or permission safety. Not both.

> Channels doesn't just add a chat interface to Claude Code. It inverts the relationship between developer and agent — from "I sit here and direct you" to "you run there and I check in when I want." That's a fundamentally different model for how software gets built.

---
- [Claude Code Channels docs](https://code.claude.com/docs/en/channels) – Anthropic
- [Hands-On with Telegram and Discord Integrations](https://www.macstories.net/stories/first-look-hands-on-with-claude-codes-new-telegram-and-discord-integrations/) – MacStories
- [Anthropic Ships Claude Code Channels](https://www.implicator.ai/anthropic-ships-its-openclaw-rival-connecting-claude-code-to-telegram-and-discord/) – Implicator
- [Claude Code Channels Setup Guide](https://claudefa.st/blog/guide/development/claude-code-channels) – Claude Fast
- [Claude Code CHANGELOG](https://docs.anthropic.com/en/release-notes/claude-code) – Anthropic
