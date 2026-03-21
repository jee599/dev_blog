---
title: "Claude Dispatch: Send a Text, Come Back to Finished Work on Your Desktop"
published: true
description: "Anthropic shipped Dispatch inside Claude Cowork — pair your phone with your Mac via QR code, send tasks remotely, and Claude executes them on your desktop. Here's how the Cowork ecosystem works and what Dispatch can actually do."
tags: ai, productivity, cowork, programming
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-dispatch-hero.jpg
canonical_url: https://jidonglab.com/blog/claude-dispatch-ko
---

On March 17, 2026, Anthropic's Felix Rieseberg posted a tweet:

"We're shipping a new feature in Claude Cowork as a research preview that I'm excited about: Dispatch! One persistent conversation with Claude that runs on your computer. Message it from your phone. Come back to finished work."

Message it from your phone. Come back to finished work. That's the entire product thesis in two sentences.

**Source:** [Anthropic Launches Claude Dispatch](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) – MLQ / [Anthropic introduces 'Dispatch'](https://www.storyboard18.com/digital/anthropic-introduces-dispatch-feature-turning-claude-into-a-remote-ai-assistant-ws-l-92666.htm) – Storyboard18

## You Need to Understand Cowork Before Dispatch Makes Sense

Dispatch isn't a standalone feature. It's a piece of a larger framework called Cowork, and the positioning only clicks if you see the full picture.

Cowork launched as a research preview on January 13, 2026. If Claude Code is the terminal AI for developers, Cowork is the desktop AI for every knowledge worker. Anthropic's Head of Product for Enterprise, Scott White, used the phrase "vibe working" — if "vibe coding" let non-programmers ship software by describing what they wanted, "vibe working" lets anyone delegate complex multi-step work to an AI agent.

Cowork runs inside the Claude Desktop app. The difference from regular Claude chat: Cowork Claude can operate your computer. It opens files, uses your browser, accesses external services through plugins — Gmail, Slack, Google Calendar, Salesforce. Sessions persist, so multi-step workflows retain context across hours or days of interaction.

But Cowork had one critical constraint. You had to be at your computer. Claude needed approvals mid-task, you had to initiate work from the desktop app, and the moment you closed the lid, the interaction model broke.

Dispatch removes that constraint.

## How Dispatch Actually Works

The mechanics are straightforward. Pair your phone with your Mac. Send instructions from anywhere. Claude executes them on your desktop. Come back to completed work.

```
1. Install Claude Desktop on Mac (Cowork enabled)
2. Open Claude mobile app (iOS/Android), scan QR code to pair
3. Pairing complete (~60 seconds)
4. Send task from phone → routed through Anthropic servers → arrives at Mac
5. Claude on Mac executes locally (files, browser, plugins)
6. Check results from phone or later at your desk
```

One architectural detail worth noting: instructions route through Anthropic's servers. This is different from Claude Code Channels, which uses local MCP plugins polling Bot APIs directly. Dispatch uses Anthropic's mobile app and server infrastructure as the relay layer.

But all actual work execution is local. Claude runs in a sandboxed environment on your Mac — reading files, editing documents, using apps. Files don't leave your machine. Anthropic's servers handle instruction relay and state synchronization, nothing more.

The "persistent conversation" property is what makes Dispatch feel different from just "remote chat." It's a single continuous thread. Ask Claude to analyze a spreadsheet at 9 AM, then ask "pull out the outliers from that analysis" at 3 PM, and Claude remembers the context. No re-explaining what "that analysis" refers to. The session carries state.

## This Is Not Claude Code With a Phone Interface

Dispatch and Claude Code Channels shipped in the same week (Channels on March 20, three days after Dispatch). They share a philosophy — "AI agents should work even when you're not at the keyboard" — but they target different audiences with different tools.

Channels is for developers. The workspace is a terminal and codebase. You interact through Telegram or Discord bots. It's MCP-based, so it can react to CI events, monitoring alerts, and webhooks. Setup involves creating bots, installing plugins, configuring tokens.

Dispatch is for everyone. The workspace is the entire desktop — local files, browsers, installed apps, connected plugins. You interact through the Claude mobile app directly. Setup is scanning a QR code. No bot creation, no plugin installation, no terminal commands.

Anthropic positioned Cowork as "Claude that doesn't just answer questions, but actually executes work and produces results." Dispatch adds the ability to trigger that execution remotely.

## Setup Is Actually 60 Seconds

Dispatch setup is almost suspiciously simple compared to Channels.

Install Claude Desktop on your Mac if you haven't already. Open the app — Cowork mode activates. On your phone, open the Claude mobile app (available on iOS and Android). Scan the QR code displayed in Claude Desktop. Done.

No API keys. No bot configuration. No terminal commands. No BotFather. No Developer Portal. Two apps open, one QR code scan, and you're paired. First task can be dispatched within a minute.

The contrast with Channels is stark. Channels requires Bun installation, plugin marketplace registration, plugin installation, bot creation on Telegram/Discord, token configuration, and session startup with specific flags. Dispatch requires opening two apps.

This gap in setup complexity maps directly to the target audience. Developers are comfortable with terminal commands and bot APIs. Non-technical professionals need QR-code-and-go simplicity.

## What Dispatch Can Actually Do

The access scope is broad. Dispatch inherits everything Cowork can do, executed remotely:

**Local file operations.** "Analyze the CSV in my Downloads folder and create a summary spreadsheet." Claude opens the file, parses it, generates analysis, creates the output document. The file stays on your Mac.

**Browser-based research.** "Research competitor pricing for my proposal and add a comparison section." Claude opens a browser, searches, extracts relevant data, and inserts it into your document. Web search capability built into the Cowork sandbox.

**Plugin integrations.** If you've connected Gmail, Slack, Google Calendar, or other services through Cowork's plugin marketplace, Dispatch can access them. "Summarize my unread emails from last week and flag the ones that need a response" is a valid instruction — Claude reads your email through the Gmail plugin, processes each one, and produces a prioritized list.

**Document creation.** Presentations, reports, spreadsheets. "Take these meeting notes and turn them into a slide deck" is the kind of task Dispatch handles. Claude uses the local tools and files available on your Mac.

**Sandboxed code execution.** For data-heavy workflows, Claude can write and execute scripts locally. Parsing logs, transforming datasets, generating charts — the sandbox supports code execution without requiring you to be a developer.

The persistent conversation means these tasks can chain. "Analyze this data" in the morning, "now cross-reference it with last quarter" in the afternoon, "create a presentation from both analyses" in the evening. One continuous thread, accumulating context.

## The Cowork Ecosystem That Makes Dispatch Possible

Dispatch didn't appear in isolation. Anthropic built the infrastructure throughout Q1 2026.

**January 13 — Cowork research preview + Anthropic Labs expansion.** Instagram co-founder Mike Krieger moved to Labs to focus on experimental products. Ami Vora took over the Product organization. The signal: repeat the Claude Code trajectory (research preview to billion-dollar product in six months).

**January 30 — Cowork webinar.** Boris Cherny (Head of Claude Code) and Mikaela Grace (Applied AI) demoed live workflows: research synthesis, document creation, data extraction.

**February 5 — Claude Opus 4.6 launch.** The model powering Cowork got smarter. Stronger coding, better planning/debugging, 1M token context window, 14.5-hour task completion horizon.

**February 17 — Claude Sonnet 4.6 launch.** Frontier coding, agent planning, and long-context reasoning improvements. 1M token context in beta.

**February 24 — The Briefing: Enterprise Agents livestream.** Deep dive into Cowork and plugins in enterprise deployments. Finance, Legal, Sales, and Product leaders from Anthropic demoed their own team workflows.

**Early March — Recurring task scheduling.** Cowork gained the ability to schedule recurring and on-demand tasks. A new Customize section in Claude Desktop grouped skills, plugins, and connectors.

**Mid-March — Plugin marketplace + admin controls.** Team and Enterprise plans got a plugin marketplace with connectors for Gmail, Slack, Google Calendar, Salesforce, and more.

**March 17 — Dispatch ships.** Max plan first, Pro plan the following day.

**March 19 — Persistent agent thread.** Pro and Max users can access a persistent agent thread via Claude Desktop or mobile to manage Cowork tasks.

The timeline shows Dispatch as the capstone of a deliberate buildup: foundation (Cowork), intelligence (model upgrades), integration (plugins, marketplace), governance (admin controls), and finally remote access (Dispatch). Each layer was necessary before the next made sense.

> Dispatch's simplicity is deceptive. Scanning a QR code and sending a text message doesn't feel like a technological shift. But the underlying architecture — a persistent AI agent with access to your local files, applications, and connected services, controllable from your pocket — is a fundamentally different model for how knowledge work gets done.

---
- [Anthropic Launches Claude Dispatch](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) – MLQ
- [Anthropic introduces 'Dispatch'](https://www.storyboard18.com/digital/anthropic-introduces-dispatch-feature-turning-claude-into-a-remote-ai-assistant-ws-l-92666.htm) – Storyboard18
- [Claude Cowork Dispatch Guide](https://www.geeky-gadgets.com/claude-cowork-dispatch-guide/) – Geeky Gadgets
- [Anthropic Dispatch: Always-On Creative Coworker](https://coey.com/resources/blog/2026/03/17/anthropic-dispatch-turns-claude-into-your-always-on-creative-coworker/) – COEY
- [Introducing Anthropic Labs](https://www.anthropic.com/news/introducing-anthropic-labs) – Anthropic
