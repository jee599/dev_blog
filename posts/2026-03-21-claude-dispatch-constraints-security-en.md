---
title: "Claude Dispatch: The Constraints, the Security Model, and What Comes Next"
published: true
description: "Dispatch is macOS-only, single-threaded, and has a ~50% task success rate. But the security model is solid, the OpenClaw tradeoffs are real, and the roadmap is clear. Here's the honest assessment."
tags: ai, productivity, security, cowork
cover_image: https://r2.jidonglab.com/blog/2026/03/claude-dispatch-limits.jpg
canonical_url: https://jidonglab.com/blog/claude-dispatch-ko
hashnode_url: 'https://plzai.hashnode.dev/2026-03-21-claude-dispatch-constraints-security'
---

In the [previous post](https://dev.to/jidonglab/claude-dispatch-cowork-setup), I covered what Dispatch is, how Cowork works, and the Q1 2026 ecosystem buildup that made it possible.

Now for the parts that matter more: what it can't do, how the security model works, how it compares to OpenClaw, and where this is heading.

**Source:** [Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy / [Dispatch Security & Permissions](https://www.geeky-gadgets.com/claude-dispatch-security-permissions/) – Geeky Gadgets / [What is Claude Dispatch](https://www.glbgpt.com/hub/claude-dispatch-remote-ai-guide/) – GlobalGPT

## The Constraints Are Real

Dispatch is a research preview, and the label is honest. Here's what that means in practice.

**macOS only.** The biggest constraint right now. Windows and Linux users cannot use Dispatch. Claude Desktop's full Cowork sandbox only works on macOS. Given that a meaningful percentage of developers and knowledge workers use Windows, this limits the addressable audience significantly.

**Desktop must stay awake.** Your Mac needs to be powered on, awake, and connected to the internet for Dispatch to work. Lid closed? Sleep mode? Network drop? Dispatch stops. If you want always-on availability, you need your Mac running 24/7 — which means power consumption, battery wear, and the general awkwardness of leaving a laptop open on your desk while you're on a train.

**Single-threaded execution.** One task at a time. Send "analyze this file" and then "organize that folder" before the first finishes — the second queues until the first completes. For complex workflows that naturally involve parallel subtasks, this is a meaningful bottleneck.

**No scheduled execution.** "Summarize my email every morning at 9 AM" doesn't work through Dispatch alone. Cowork itself recently added recurring task scheduling, but configuring scheduled tasks remotely through Dispatch isn't there yet.

**No proactive notifications.** Claude can't initiate contact. It responds to your messages but won't independently say "hey, something needs your attention." You have to check in. The agent waits for instructions.

**Task success rate.** This needs to be said directly — early reports suggest a roughly 50% success rate on non-trivial tasks. Simple file operations work reliably. Complex multi-step workflows hit bugs: Claude stalls mid-task, produces incomplete results, or misinterprets instructions. The research preview label exists for this reason. Expect to verify outputs.

## The Security Model: Everything Local, With Caveats

Dispatch's security thesis is "all execution is local." Your files never leave your machine. Code runs in a local sandbox on your Mac. Anthropic's servers relay instructions and sync state — they don't touch your data.

For professionals handling sensitive documents — legal, medical, financial — this is a genuine advantage over cloud-based alternatives. Your client files stay on your hardware.

But "local execution" is a double-edged design choice.

**Irreversible actions are possible.** Anthropic warns explicitly: instructions sent remotely trigger real actions on your computer. File modification, deletion, email sending — these can happen. "Clean up the old rows in that spreadsheet" could delete data you need. There's no undo button for remote AI actions.

**Permission management is your responsibility.** Dispatch has a permission system — you define what Claude can and can't access. Restrict to specific folders, limit browser usage, control plugin access. But the tradeoff is direct: narrow permissions reduce risk but also reduce usefulness. Wide permissions increase capability but increase exposure. Finding the right boundary is a manual process.

**External content exposure.** When Claude browses the web as part of a task, it can encounter malicious pages designed for prompt injection. Anthropic's sandboxing mitigates this, but in a research preview, edge cases aren't fully resolved.

**Kill switch exists.** You can stop everything instantly — close the mobile app, quit Claude Desktop, or power off the Mac. Total loss of control isn't possible. But damage can happen fast between when you send an instruction and when you realize the outcome wasn't what you expected.

The practical advice: start with tight permissions on non-critical tasks. Build confidence in how Claude interprets your instructions before expanding access to important files or connected services.

## Dispatch vs OpenClaw: Different Problems, Different Tools

The comparison gets made constantly, but the two products are solving fundamentally different problems.

**OpenClaw** is a developer tool for talking to an AI agent from any messaging platform. WhatsApp, iMessage, Slack, Signal, Telegram, Discord, Teams — nearly complete coverage. It's open-source (MIT license), free to use, and model-agnostic (connect to Claude, GPT-4, local models, or any mix). It can run entirely offline with local models, eliminating API costs. The tradeoff: security is your responsibility, initial setup is complex, and you're maintaining your own infrastructure.

**Dispatch** is a consumer-friendly tool for non-developers to control a desktop AI from their phone. The Claude mobile app is the only interface — no third-party messaging integration. It's macOS-only and requires a Claude subscription ($20/month Pro, $100/month Max). The tradeoff: limited platform coverage and a paid subscription, but zero setup complexity and enterprise-grade security.

### Platform Coverage

OpenClaw dominates. Nearly every messaging platform people use daily. Dispatch has one: the Claude mobile app. No Discord, no Telegram, no Slack, no WhatsApp. The core OpenClaw insight — "meet users in the apps they already live in" — is something Dispatch doesn't address.

### Setup Complexity

Dispatch wins by a wide margin. Two apps, one QR code. OpenClaw requires terminal commands, API key configuration, bot setup, and ongoing maintenance of a self-hosted system. The gap maps directly to target audience: developers are comfortable with terminal-based setup; non-technical professionals need instant onboarding.

### Cost Structure

Dispatch charges flat monthly fees: $20 (Pro) or $100 (Max). OpenClaw is free, but cloud API calls add up — roughly $5/month for light use, $15-20 for heavy daily use. At heavy usage, the costs converge. But OpenClaw has an escape valve: switch to local models via Ollama or LM Studio and API costs drop to zero.

### Security Model

Dispatch wins for organizations. Allowlist-based plugins, sandboxed local execution, admin controls for Team/Enterprise, no data leaving the machine. OpenClaw's permissive defaults have spawned safety forks — the community recognized the risk before the project addressed it comprehensively.

### The Core Difference

OpenClaw gives developers maximum flexibility and platform coverage at the cost of self-managed security. Dispatch gives non-developers instant access to a remote desktop AI at the cost of platform lock-in and a subscription fee.

They're not competing for the same users in the same scenarios.

## What Dispatch Workflows Look Like in Practice

**Research synthesis on the go.** Send "summarize today's AI news focused on agent developments" while commuting. Claude on your Mac opens a browser, crawls recent articles, extracts key points, creates a document. The finished briefing waits when you arrive.

**Remote document production.** "Take the Q1 revenue CSV in Downloads, analyze trends, and build a presentation with charts." Claude parses the CSV, runs analysis, generates slides. Results saved locally on your Mac.

**Email triage.** With the Gmail plugin connected: "Pull my unread emails from last week, flag anything that needs a response, and draft replies for the top three." Claude reads through your inbox, categorizes messages, and prepares draft responses you can review later.

**Non-code project management.** Throw a draft business plan at Claude and say "research competitor pricing from the web and strengthen the competitive analysis section." Claude browses, extracts data, and edits the document. Useful for government grant applications, investor decks, or project proposals where the work is research-heavy but not code-heavy.

## Where This Is Heading

Reading Anthropic's announcements and the research preview constraints together, the roadmap is visible.

**Multi-threading is coming.** The single-threaded constraint is an obvious improvement target. Parallel task execution — "analyze these three files simultaneously and cross-reference the results" — is likely in the next few quarterly updates.

**Proactive notifications will arrive.** Claude initiating contact when something needs attention. A monitoring alert triggers analysis, Claude determines it's urgent, and pushes a notification to your phone. This transforms Dispatch from "I tell Claude what to do" to "Claude tells me what it found."

**Windows support is a matter of time.** The macOS dependency comes from Cowork's sandbox implementation in the Electron-based Claude Desktop. Porting that sandbox to Windows is an engineering challenge, not a strategic one. The addressable market doubles overnight.

**Scheduled execution integration.** Cowork already has recurring task scheduling. Connecting it to Dispatch means "every morning at 9 AM, summarize my email and send me a digest on my phone." Automation without code.

**The bigger picture.** Anthropic's Labs team (led by Instagram co-founder Mike Krieger since January 2026) has an explicit mission: incubate experimental products at the frontier of Claude's capabilities. Cowork and Dispatch are the first results. Claude Code went from research preview to billion-dollar product in six months. Anthropic is betting Cowork follows the same curve.

The 1M token context window going GA for Opus 4.6 and Sonnet 4.6 at standard pricing (announced in March) matters here too. Dispatch tasks that involve large documents, entire codebases, or multi-day conversation threads benefit directly from bigger context. The model improvements and the product features are co-evolving.

> The chatbot era is ending. "You ask, I answer" was the first interaction model for AI. "You instruct, I execute" is the second. Dispatch — with all its current limitations — is the clearest signal that Anthropic is building for the second model. The success rate is 50%. The platform coverage is one. The constraint list is long. But the direction is unmistakable: an AI that sits at your computer and does work on your behalf, whether you're in the room or not.

---
- [Anthropic Launches Claude Dispatch](https://mlq.ai/news/anthropic-launches-claude-dispatch-for-remote-desktop-ai-control/) – MLQ
- [Dispatch vs OpenClaw](https://www.techloy.com/claude-dispatch-vs-openclaw-which-ai-agent-tool-should-you-use/) – Techloy
- [Dispatch Security & Permissions](https://www.geeky-gadgets.com/claude-dispatch-security-permissions/) – Geeky Gadgets
- [What is Claude Dispatch](https://www.glbgpt.com/hub/claude-dispatch-remote-ai-guide/) – GlobalGPT
- [Anthropic Dispatch: Always-On Creative Coworker](https://coey.com/resources/blog/2026/03/17/anthropic-dispatch-turns-claude-into-your-always-on-creative-coworker/) – COEY
- [Introducing Anthropic Labs](https://www.anthropic.com/news/introducing-anthropic-labs) – Anthropic
