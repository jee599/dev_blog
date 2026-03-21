---
title: "I Texted Claude From the Subway — Came Back to a Finished Slide Deck on My Mac"
published: true
description: "Scan a QR code, text from your phone, Claude works your desktop. 60-second setup, zero terminal commands."
tags: ai, productivity, webdev, beginners
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-dispatch-hero.jpg
canonical_url: https://jidonglab.com/blog/claude-dispatch-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-dispatch-cowork-setup'
id: 3379453
date: 'draft'
---

I was standing on a crowded subway platform when I pulled out my phone, typed "take yesterday's meeting notes and turn them into a slide deck," and put my phone back in my pocket. Twenty minutes later, I walked into my office, opened my MacBook, and the slides were done. Not a draft. Not an outline. **A finished deck**, built from my local files, sitting right there on my desktop.

This is Claude Dispatch.

## What Even Is Dispatch — And Why Should You Care?

Dispatch is the newest piece of Anthropic's Cowork framework, and understanding Cowork first makes the whole thing click. Cowork launched as a [research preview on January 13, 2026](https://www.anthropic.com/news/introducing-anthropic-labs), positioning itself as the desktop AI for knowledge workers — not developers, everyone. If Claude Code is the terminal agent for engineers, Cowork is the agent that operates your entire Mac. It opens files, drives your browser, connects to Gmail, Slack, Google Calendar, and Salesforce through plugins. Sessions persist across hours and days, so multi-step workflows don't lose context.

But Cowork had one frustrating limitation. You had to be **sitting at your computer**. Claude needed approvals mid-task, you had to initiate work from the desktop app, and the moment you closed the lid, the interaction model broke.

Dispatch removes that constraint entirely.

## What Happens When You Text Claude From the Subway?

The setup took me less than 60 seconds, and I timed it. I opened Claude Desktop on my Mac, which activated Cowork mode automatically. Then I opened the Claude mobile app on my iPhone and scanned the QR code displayed on my desktop screen. That was it — pairing complete, no API keys, no bot configuration, no terminal commands, no developer portal.

When I send a task from my phone, it routes through Anthropic's servers to my Mac, where Claude executes it locally in a sandboxed environment. My files never leave my machine. Anthropic's servers handle the relay and state synchronization, nothing more. The key architectural detail here is that all **actual work happens on your Mac** — Claude reads your files, edits your documents, uses your apps. The phone is just the remote control.

What makes this feel genuinely different from remote chat is the persistent conversation. It's a single continuous thread. I asked Claude to analyze a spreadsheet at 9 AM, then at 3 PM typed "pull out the outliers from that analysis," and Claude remembered exactly what I meant. No re-explaining, no re-uploading. The session carries state across the entire day.

## How Is This Different From Claude Code Channels?

Channels shipped three days after Dispatch, on March 20, and they share the same philosophy — AI agents should work even when you're not at the keyboard. But they serve completely different people with completely different tools.

Channels targets developers. The workspace is a terminal and codebase. You interact through Telegram or Discord bots, and it's MCP-based, so it can react to CI events, monitoring alerts, and webhooks. Setting it up means creating bots, installing plugins, and configuring tokens. Dispatch targets **everyone else**. The workspace is your entire desktop — local files, browsers, installed apps, connected plugins. You interact through the Claude mobile app directly. Setup is scanning a QR code.

The contrast in setup complexity maps directly to audience. Developers are comfortable with terminal commands and bot APIs. A marketing manager preparing a quarterly review needs QR-code-and-go simplicity.

## What Can You Actually Do With a Text Message?

The access scope surprised me. Dispatch inherits everything Cowork can do, triggered remotely. I tested local file operations first — "analyze the CSV in my Downloads folder and create a summary spreadsheet" — and Claude opened the file, parsed it, generated analysis, and created the output document without the file ever leaving my Mac.

Browser-based research works too. Telling Claude to "research competitor pricing for my proposal and add a comparison section" sends it to the web, where it searches, extracts relevant data, and inserts findings directly into your document. If you've connected plugins like Gmail or Slack through Cowork's marketplace, those are available remotely as well. "Summarize my unread emails from last week and flag the ones that need a response" is a perfectly valid instruction — Claude reads your email through the Gmail plugin, processes each message, and produces a prioritized list.

Document creation is where I spent most of my time. Presentations, reports, spreadsheets — Claude handles all of them using the local tools on your Mac. For data-heavy workflows, it can even write and execute scripts locally in a sandboxed environment, parsing logs, transforming datasets, and generating charts without requiring you to be a developer.

The persistent conversation means these tasks **chain naturally**. Analyze data in the morning, cross-reference it with last quarter in the afternoon, create a presentation from both analyses in the evening. One continuous thread, accumulating context.

## How Did Anthropic Build the Infrastructure for This?

Dispatch didn't appear in isolation. Anthropic laid the groundwork methodically throughout Q1 2026, and the timeline reveals a deliberate buildup.

It started with the Cowork research preview and Anthropic Labs expansion on January 13, when Instagram co-founder Mike Krieger moved to Labs to focus on experimental products and Ami Vora took over the Product organization. The signal was clear: repeat the Claude Code trajectory from research preview to billion-dollar product. A webinar on January 30 had Boris Cherny and Mikaela Grace demoing live workflows — research synthesis, document creation, data extraction — giving the first public look at what Cowork could actually do.

Then came the model upgrades. [Claude Opus 4.6 launched on February 5](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) with stronger coding, better planning, and a 1M token context window with a 14.5-hour task completion horizon. Sonnet 4.6 followed on February 17 with frontier coding and agent planning improvements. These weren't just incremental bumps — they were the **intelligence layer** Dispatch needed to handle complex multi-step tasks without supervision.

The enterprise infrastructure came next. A February 24 livestream called "The Briefing: Enterprise Agents" showcased Cowork in real enterprise deployments, with Finance, Legal, Sales, and Product leaders from Anthropic demoing their own team workflows. Early March brought recurring task scheduling and a new Customize section in Claude Desktop grouping skills, plugins, and connectors. Mid-March delivered the plugin marketplace with admin controls for Team and Enterprise plans, adding connectors for Gmail, Slack, Google Calendar, Salesforce, and more.

Dispatch shipped on March 17 for Max plan users, with Pro plan access the following day. Two days later, persistent agent threads arrived for Pro and Max users via Claude Desktop and mobile. Each layer — foundation, intelligence, integration, governance, remote access — was necessary before the next one made sense.

> Scanning a QR code and sending a text message doesn't feel like a technological shift, but a persistent AI agent with access to your local files, applications, and connected services, controllable from your pocket, is a fundamentally different model for how knowledge work gets done.

---

- [Anthropic Launches Claude Dispatch](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) – MLQ
- [Anthropic introduces 'Dispatch'](https://www.storyboard18.com/digital/anthropic-introduces-dispatch-feature-turning-claude-into-a-remote-ai-assistant-ws-l-92666.htm) – Storyboard18
- [Claude Cowork Dispatch Guide](https://www.geeky-gadgets.com/claude-cowork-dispatch-guide/) – Geeky Gadgets
- [Anthropic Dispatch: Always-On Creative Coworker](https://coey.com/resources/blog/2026/03/17/anthropic-dispatch-turns-claude-into-your-always-on-creative-coworker/) – COEY
- [Introducing Anthropic Labs](https://www.anthropic.com/news/introducing-anthropic-labs) – Anthropic
