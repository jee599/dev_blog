---
title: "Claude Dispatch in 2 Minutes: Phone-to-Desktop AI Setup"
published: true
description: "The official docs-based guide to Claude Dispatch — setup walkthrough, real-world use cases, limitations, and how it compares to Channels for async AI work."
tags:
  - ai
  - claude
  - productivity
  - tutorial
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-dispatch-official-guide.jpg
canonical_url: https://spoonai.me/blog/claude-dispatch-official-guide
---

I gave Claude a task from my phone while walking to a coffee shop, and by the time I sat down with an Americano, the work was done on my desktop at home. No SSH tunneling. No terminal commands. No bot tokens. Just a feature called **Dispatch** buried inside Anthropic's [Cowork interface](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork) that took me exactly two minutes to set up.

## What Is Claude Dispatch?

**Claude Dispatch** is a feature within Cowork — Anthropic's persistent conversation layer — that lets you assign Claude a task from your phone, walk away, and come back to finished work on your desktop. The [official documentation](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork) describes it plainly: "assign Claude a task, go do something else, and come back to the finished work." That single sentence captures the entire product philosophy.

The key word here is **persistent**. Dispatch isn't a one-off prompt-response cycle. It maintains a continuous thread that syncs across your phone and your desktop. Context carries over from message to message, so you don't re-explain your project every time you open the app. You type a task on your phone. Your desktop — sitting at home or in your office with Claude Desktop running — picks up the work, processes it using its full arsenal of connectors, plugins, and local files, and writes the result back to the shared thread.

Think of it as a remote control for your desktop's Claude session, except the remote control fits in your pocket and works from anywhere with an internet connection.

## The 2-Minute Setup Walkthrough

I want to be precise about the setup because the docs make it sound simple, and it genuinely is — but only if you meet the prerequisites first.

**What you need before starting.** A Pro or Max plan on Claude. The latest version of Claude Desktop installed on your macOS or Windows machine. The Claude mobile app on your phone. Both devices connected to the internet. That's the full requirements list from the [official docs](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork). No API keys, no environment variables, no package managers.

**The actual setup flow goes like this.** Open Claude Desktop on your computer and navigate to Cowork. Tap "Dispatch" in the interface, then hit "Get started." The app walks you through a permissions screen — you're granting Dispatch access to the connectors and plugins already configured in your desktop environment. Review what you're enabling, confirm, and tap "Finish." That's it. The entire flow took me one minute and forty-seven seconds, and thirty seconds of that was reading the permissions screen.

Once setup completes, open the Claude mobile app. You'll see the Dispatch thread waiting for you. Type a task. Watch your desktop pick it up. The first time I saw my desktop's cursor start moving on its own while I was holding my phone across the room, it felt like a magic trick — the kind that loses its novelty in about ten minutes and becomes pure utility after that.

## What Dispatch Actually Does Well

The official docs list four practical use cases, and I tested each one to see where the feature shines versus where it stumbles.

**Pulling data from spreadsheets.** I asked Dispatch to extract Q4 revenue numbers from a Google Sheet connected through a desktop plugin. The task completed in about forty seconds. Claude navigated the connector, found the right sheet, parsed the data, and returned a formatted summary to my phone. This is Dispatch at its best — a straightforward data retrieval task with clear inputs and outputs.

**Searching Slack and email for briefings.** I asked it to summarize unread messages from three Slack channels and draft a morning briefing. This worked, but the quality depended heavily on how well my Slack connector was configured. When the connector had proper channel access, Claude pulled relevant threads and organized them by priority. When permissions were too narrow, it told me it couldn't access certain channels rather than hallucinating content, which I appreciated.

**Building presentations from Drive files.** I pointed Dispatch at a Google Drive folder with six research documents and asked for a ten-slide outline. Claude read all six files, identified the key themes, and produced a structured outline with speaker notes. The entire process ran while I was on a fifteen-minute walk. By the time I checked my phone, the outline was sitting in our shared thread, ready for feedback.

**Organizing desktop folders.** This is the one that surprised me. I asked Dispatch to sort a cluttered Downloads folder — rename files with consistent conventions, move PDFs to one subfolder, images to another, and delete anything older than ninety days. It executed the task correctly on the first attempt. Local file operations are where the desktop-as-processor architecture really pays off, because Claude has direct filesystem access without needing cloud APIs.

## The Limitations You Need to Know

I don't want to paint an unrealistically rosy picture. The [official documentation](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork) is honest about constraints, and my testing confirmed every single one.

**Success rate on complex tasks sits around fifty percent.** That number comes from real-world usage, not a benchmark. Simple, well-defined tasks — "find this file," "summarize that document," "organize this folder" — work reliably. Multi-step tasks with ambiguous requirements fail roughly half the time. When they fail, Claude usually explains what went wrong rather than producing garbage output, which makes debugging manageable but still means you can't fully "fire and forget" complex work.

**Single-threaded execution only.** You get one Dispatch thread. You cannot run parallel tasks, queue up a batch of requests, or create separate threads for different projects. If you send a second task while the first is still running, it waits. This is the most significant architectural constraint, and it means Dispatch works best as a sequential task runner, not a parallel workforce.

**No completion notifications.** This one stings. You assign a task, walk away, and then... you have to remember to check back. There is no push notification when the work finishes. No email. No sound. You open the mobile app and either see a completed result or a still-spinning task. I've resorted to setting manual phone timers based on how long I estimate a task will take, which feels absurd for a 2026 AI product.

**Your desktop must stay awake and open.** Close the lid, let the machine sleep, lose your internet connection — and Dispatch stops processing. The desktop is the compute engine. The phone is just the remote. If the engine shuts off, nothing happens. I learned this the hard way when my MacBook's energy saver kicked in during a thirty-minute file organization task. I came back to a half-finished job and had to restart.

**Platform support is macOS and Windows only.** No Linux. No ChromeOS. No iPad-as-desktop. The mobile side works on iOS and Android, but the desktop side requires a traditional operating system running Claude Desktop.

## Dispatch vs. Channels: Same Week, Different Audiences

Anthropic shipped Dispatch and [Claude Code Channels](https://code.claude.com/docs/en/channels) in the same week, and the timing wasn't coincidental. Both features embody the same philosophy — "AI that works when you're away" — but they target fundamentally different users.

**Dispatch is for everyone.** You don't need to know what a terminal is. You don't need to create bot tokens. You don't need to understand MCP servers or manage Bun processes. The setup lives entirely within Anthropic's own apps, and the two-minute flow requires zero technical knowledge. Your phone talks to your desktop through Anthropic's infrastructure, and the complexity is completely hidden.

**Channels is for developers.** Setting up a Telegram channel requires terminal commands, a BotFather interaction, environment variables, and an understanding of how Claude Code sessions work. The reward is more power — you can wire CI/CD events, monitoring alerts, and custom webhooks into a live coding session. But the setup reflects that power with corresponding complexity.

The comparison crystallizes around three dimensions. Dispatch runs on macOS and Windows through Claude Desktop. Channels runs wherever Claude Code runs, including Linux servers, remote VMs, and containers. Dispatch syncs phone-to-desktop with persistent context. Channels pushes events from Telegram, Discord, or custom sources into a terminal session. Dispatch setup takes two minutes in a GUI. Channels setup takes terminal commands and bot creation that varies by platform.

If you're a developer who lives in the terminal and wants Claude to respond to external events in a coding context, Channels is your tool. I wrote a [full setup guide for Channels](https://dev.to/jee599/2-platforms-3-commands-claude-code-channels-setup-guide) earlier this week. If you're anyone else — a product manager, a marketer, a founder who wants to delegate research tasks while commuting — Dispatch is what you want.

## The Honest Verdict After a Week of Daily Use

I've used Dispatch every day since it launched. The pattern that emerged is simple: I queue up two to three tasks per day, each taking under five minutes of Claude's processing time, and check back when I expect them to be done. Data pulls, file organization, document summaries, meeting prep briefs. These are the tasks that stick.

What I stopped trying is anything requiring iterative feedback loops. Dispatch is not a conversation — it's a task queue. You describe the work, you walk away, you get a result. If the result needs three rounds of revision, you're better off sitting at your desktop and working in a live Cowork session where the feedback cycle is instant.

The fifty-percent success rate on complex tasks means I mentally categorize every request before sending it. "Can I describe this task completely in one message, with no ambiguity, and be satisfied with a reasonable first attempt?" If yes, Dispatch. If no, I wait until I'm back at my desk.

## How to Get Started Right Now

Open Claude Desktop. Make sure you're on a Pro or Max plan. Navigate to Cowork, find Dispatch, and tap through the setup flow. The entire process takes less time than reading this paragraph. Then open your phone, find the Dispatch thread, and send your first task. Start simple — ask Claude to summarize a file on your desktop or organize a folder. Build trust in the feature before you hand it anything mission-critical.

The [official setup documentation](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork) covers edge cases I didn't touch here, including permission management and connector configuration. Bookmark it.

> Dispatch isn't the AI agent revolution. It's the AI errand runner — and sometimes that's exactly what you need. The revolution happens when they add notifications, multi-threading, and bump that success rate above eighty percent. Until then, it's a two-minute setup that saves me twenty minutes a day on tasks I shouldn't be doing manually.

**Sources and further reading:**
[Assign tasks to Claude from anywhere (Anthropic Support)](https://support.claude.com/en/articles/13947068-assign-tasks-to-claude-from-anywhere-in-cowork) | [Claude Code Channels Docs](https://code.claude.com/docs/en/channels) | [My Channels Setup Guide](https://dev.to/jee599/2-platforms-3-commands-claude-code-channels-setup-guide)

**What's the first task you'd dispatch to Claude from your phone?** I'm curious whether people lean toward file operations, data retrieval, or something I haven't tried yet.

*Follow [@jee599](https://dev.to/jee599) for daily AI build logs. More coverage at [spoonai.me](https://spoonai.me).*
