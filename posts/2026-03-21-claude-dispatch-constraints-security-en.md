---
title: "Claude Dispatch Has a 50% Success Rate — Here's Why I'm Still Using It"
published: true
description: "Half my Dispatch tasks fail. The security model is solid, but 5 constraints make it a gamble. Honest breakdown."
tags: ai, productivity, webdev, beginners
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-dispatch-limits.jpg
canonical_url: https://jidonglab.com/blog/claude-dispatch-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-dispatch-constraints-security'
id: 3379450
date: 'draft'
---

Half the tasks I send to Dispatch fail. I'm still using it every day. Here's why — and more importantly, here's everything that goes wrong.

In the [previous post](https://dev.to/jidonglab/claude-dispatch-cowork-setup), I covered what Dispatch is, how Cowork works, and the Q1 2026 ecosystem that made it possible. This time I'm going through the parts nobody wants to talk about: the constraints, the security tradeoffs, and whether OpenClaw is actually a better choice.

## Why Does Half of What I Send It Fail?

Dispatch is a research preview, and that label is doing **heavy lifting**. The roughly 50% success rate on non-trivial tasks is the number you need to internalize before anything else. Simple file operations work reliably. Complex multi-step workflows — "analyze this CSV, find trends, build a presentation" — hit bugs. Claude stalls mid-task, produces incomplete results, or misinterprets what I meant. I've learned to verify every output before trusting it.

The platform constraint is equally blunt: macOS only. Windows and Linux users are locked out entirely because Claude Desktop's Cowork sandbox only runs on macOS. Given that a meaningful chunk of developers work on Windows, Anthropic is cutting its addressable audience in half before the product even launches.

Your Mac also needs to stay awake, powered on, and connected to the internet the entire time Dispatch runs. Lid closed? Sleep mode? Network hiccup? Everything stops. If you want always-on availability, you're leaving a laptop open on your desk while you're on a train — dealing with power consumption, battery wear, and the general awkwardness of that setup.

Execution is **single-threaded**. One task at a time. Send a second instruction before the first finishes and it queues. For workflows that naturally involve parallel subtasks, this bottleneck is painful. There's also no scheduled execution yet — "summarize my email every morning at 9 AM" doesn't work through Dispatch alone, even though Cowork itself recently added recurring task scheduling. And Claude can't initiate contact. No proactive notifications, no "hey, something needs your attention." You have to check in. The agent waits.

## Is the "Everything Local" Security Model Actually Secure?

Dispatch's security thesis is straightforward: all execution happens on your machine. Files never leave your Mac. Code runs in a local sandbox. Anthropic's servers relay instructions and sync state but don't touch your data. For professionals handling sensitive documents — legal, medical, financial — this is a genuine advantage over cloud-based alternatives.

But "local execution" cuts both ways. Anthropic warns explicitly that instructions sent remotely trigger **real actions** on your computer. File modification, deletion, email sending — these happen. "Clean up the old rows in that spreadsheet" could delete data you need, and there's no undo button for remote AI actions. Damage can happen fast between when you send an instruction and when you realize the outcome wasn't what you expected.

The permission system exists, and it's your responsibility to configure it well. You define what Claude can and can't access — restrict to specific folders, limit browser usage, control plugin access. The tradeoff is direct: narrow permissions reduce risk but also reduce usefulness. Wide permissions increase capability but increase exposure. Finding the right boundary is a manual process that takes trial and error.

There's also the external content problem. When Claude browses the web as part of a task, it can encounter pages designed for prompt injection. Anthropic's sandboxing mitigates this, but edge cases in a research preview aren't fully resolved. The kill switch — close the mobile app, quit Claude Desktop, or power off the Mac — means total loss of control isn't possible. But "not total loss" is a low bar.

My practical advice: start with tight permissions on non-critical tasks. Build confidence in how Claude interprets your instructions before expanding access to anything important.

## Should You Use Dispatch or OpenClaw?

The comparison gets made constantly, but these two products solve fundamentally different problems for fundamentally different people.

OpenClaw is a developer tool for talking to an AI agent from **any** messaging platform — WhatsApp, iMessage, Slack, Signal, Telegram, Discord, Teams. It's open-source under MIT, free to use, and model-agnostic. You can connect Claude, GPT-4, local models, or any mix. Run it entirely offline with local models and API costs drop to zero. The tradeoff: security is your responsibility, initial setup requires terminal commands and API key configuration, and you're maintaining your own infrastructure.

Dispatch is for non-developers who want to control a desktop AI from their phone with zero setup. Two apps, one QR code, done. But you're locked into the Claude mobile app as the only interface — no Discord, no Telegram, no Slack. You're paying $20/month for Pro or $100/month for Max. OpenClaw's core insight of meeting users in the apps they already live in is something Dispatch doesn't even attempt.

On cost, the gap narrows at heavy usage. OpenClaw is free but cloud API calls add up — roughly $5/month for light use, $15-20 for heavy daily use. At that point, Dispatch's flat fee looks comparable. But OpenClaw has an escape valve: switch to local models and costs drop to zero.

Where Dispatch clearly wins is **security for organizations**. Allowlist-based plugins, sandboxed local execution, admin controls for Team/Enterprise, no data leaving the machine. OpenClaw's permissive defaults have spawned safety forks — the community recognized the risk before the project addressed it.

They're not competing for the same users. OpenClaw gives developers maximum flexibility at the cost of self-managed security. Dispatch gives everyone else instant access at the cost of platform lock-in and a subscription fee.

## What Does a Dispatch Workflow Actually Look Like?

I send "summarize today's AI news focused on agent developments" while commuting. Claude on my Mac opens a browser, crawls recent articles, extracts key points, creates a document. The finished briefing waits when I arrive. Research synthesis without touching a keyboard.

Remote document production works the same way. "Take the Q1 revenue CSV in Downloads, analyze trends, and build a presentation with charts." Claude parses the file, runs analysis, generates slides — all saved locally on my Mac. Email triage with the Gmail plugin connected is equally hands-off: "Pull my unread emails from last week, flag anything that needs a response, and draft replies for the top three."

The non-code use cases surprised me most. I threw a draft business plan at Claude and said "research competitor pricing from the web and strengthen the competitive analysis section." It browsed, extracted data, and edited the document. Useful for government grant applications, investor decks, or project proposals where the work is **research-heavy** but not code-heavy.

## Where Is This Actually Heading?

The single-threaded constraint is the most obvious improvement target, and multi-threading is almost certainly coming. Parallel task execution — "analyze these three files simultaneously and cross-reference the results" — would transform Dispatch from a sequential assistant into something closer to a team. I'd expect this within the next few quarterly updates.

Proactive notifications would change the product's entire dynamic. Right now Dispatch is "I tell Claude what to do." With notifications, it becomes "Claude tells me what it found." A monitoring alert triggers analysis, Claude determines it's urgent, pushes a notification to my phone. That's a different product category entirely.

Windows support is a matter of time, not strategy. The macOS dependency comes from Cowork's sandbox implementation in Electron-based Claude Desktop. Porting that sandbox to Windows is an engineering challenge, and when it ships, the addressable market doubles overnight. Scheduled execution integration — connecting Cowork's existing recurring task scheduling to Dispatch — means "every morning at 9 AM, summarize my email and send me a digest." Automation without code.

The bigger picture matters here. Anthropic's Labs team, led by Instagram co-founder Mike Krieger since January 2026, has an explicit mission to incubate experimental products at the frontier of Claude's capabilities. Claude Code went from research preview to billion-dollar product in **6 months**. Anthropic is betting Cowork follows the same curve. And the 1M token context window going GA for Opus 4.6 and Sonnet 4.6 at standard pricing means Dispatch tasks involving large documents, entire codebases, or multi-day conversations get better automatically. The model improvements and the product features are co-evolving.

> The chatbot era is ending. "You ask, I answer" was the first model. "You instruct, I execute" is the second — and Dispatch, with all its 50% failure rate and single-platform constraints, is the clearest signal of where Anthropic is building next.

---
- [Anthropic Launches Claude Dispatch](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) – MLQ
- [Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy
- [Dispatch Security & Permissions](https://www.geeky-gadgets.com/claude-dispatch-security-permissions/) – Geeky Gadgets
- [What is Claude Dispatch](https://www.glbgpt.com/hub/claude-dispatch-remote-ai-guide/) – GlobalGPT
- [Introducing Anthropic Labs](https://www.anthropic.com/news/introducing-anthropic-labs) – Anthropic
