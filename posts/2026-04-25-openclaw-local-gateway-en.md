---
title: "OpenClaw Hit 295K Stars. The Reason Isn't What You Think."
published: false
description: "Peter Steinberger's OpenClaw went from 9K to 295K GitHub stars in ten weeks. Cloud agents are the hot story of 2026. So why did a local-first gateway win?"
tags:
  - ai
  - opensource
  - agents
  - webdev
cover_image: https://r2.jidonglab.com/blog/2026/04/openclaw-local-gateway-hero.jpg
canonical_url: https://jidonglab.com/posts/2026-04-25-openclaw-local-gateway-en
series: "The 2026 AI GitHub Playbook"
---

295,000 GitHub stars in ten weeks. Nearly 2,000 contributors. A rename forced by Anthropic's trademark lawyers, then another rename because the first rename "never quite rolled off the tongue." The single fastest-growing open source project in the history of software.

That project is [OpenClaw](https://github.com/openclaw/openclaw). Its author, [Peter Steinberger](https://github.com/steipete) — the former CEO of PSPDFKit — described it, in the README, as "your own personal AI assistant. Any OS. Any platform. The lobster way." He picked a lobster as the mascot because of a burnout recovery metaphor he wrote about on his [personal blog](https://steipete.com/). The lobster molts when it outgrows its shell. He was molting a career.

I read the full commit history. I read every issue labeled "architecture." I ran OpenClaw for a week as my daily driver, replacing a mix of Claude Code sessions and Slack-bot integrations. Here's what I found about why a local-first gateway beat the cloud agents that were supposedly winning 2026.

## The definition: what OpenClaw actually is

OpenClaw is a local gateway process that sits on your machine and exposes a single agent interface across every channel you already use — Slack, Discord, WhatsApp, Signal, iMessage, Telegram, email. It runs locally, holds API keys for the models you choose, and routes incoming messages from any channel through one planning loop. No cloud backend.

That last sentence is the whole design. Every other agent platform in 2026 runs in the cloud. OpenClaw runs on your laptop or your home server. The messages flow through channels normally; OpenClaw receives them via each channel's official API and responds via the same API. From the user's side, it looks like a bot. From your side, it's a process you control with a config file.

```
WhatsApp → [Meta API] → OpenClaw process (localhost)
                              ↓
Slack → [Slack API] → ────────┤
                              ↓
Signal → [Signal CLI] → ──────┤ → Planner → [Claude/GPT/Local]
                              ↓
iMessage → [macOS bridge] → ──┘
```

Everything in the middle box runs on your machine. That's the entire premise. And until December 2025, it was considered a ridiculous design choice.

## The bet everyone said was wrong

Steinberger started building OpenClaw under the name "Clawdbot" in November 2025. Every investor conversation he had in that period, per his [blog post about the early days](https://steipete.com/posts/the-lobster-year/), told him the same thing: local-first was a non-starter. The market had moved. Cloud was where the money was. [Anthropic's Claude](https://www.anthropic.com/claude) ran in the cloud. [OpenAI's Operator](https://openai.com/index/introducing-operator/) ran in the cloud. [Google's Jules](https://jules.google/) ran in the cloud. If you wanted a personal assistant that could use your accounts, you sent your credentials to a server in San Francisco.

Steinberger's counterargument, buried in [issue #47](https://github.com/openclaw/openclaw/issues/47) of the repo, was one paragraph long: nobody is going to forward their WhatsApp credentials to a US startup's server. The regulatory friction is too high, the trust barrier is too high, and the second a cloud provider has an outage your assistant dies. A local gateway doesn't have any of these problems. It also doesn't require you to trust the vendor with anything you wouldn't already trust Apple or Meta with.

That was the pitch. It took about six weeks to prove right.

The growth curve tells the story plainly. OpenClaw sat at 9,000 stars on January 20, 2026. Ten days later it was at 62,000. By February 15 it crossed 145,000. By early March, 247,000. A month later, 295,000. In that window, [Cline](https://github.com/cline/cline) grew from 54K to 59K. [OpenHands](https://github.com/OpenHands/OpenHands) grew from 65K to 68K. These were the "winning" cloud-integrated projects. They gained a total of 8,000 stars. OpenClaw gained 233,000.

The gap wasn't close. It was a category reset.

## The technical decision that made it possible

I spent a day reading the [architecture doc](https://github.com/openclaw/openclaw/blob/main/docs/architecture.md) in the repo. The decision that unlocked the whole thing is dumb in retrospect and obvious in hindsight: OpenClaw uses each channel's official API as a thin shim, without any abstraction layer beyond normalization of inbound messages.

Most agent frameworks try to build "channel providers" — a plugin architecture where you implement an interface and the framework handles routing. This is the kind of thing that takes you nine months of engineering work and still feels brittle. Steinberger skipped it. Each channel has a file. The WhatsApp file imports the [WhatsApp Business API](https://developers.facebook.com/docs/whatsapp). The Slack file imports the [Slack Bolt SDK](https://slack.dev/bolt-js/concepts). The iMessage file shells out to [osascript](https://ss64.com/osx/osascript.html) with some AppleScript. None of them share abstractions beyond an input-normalization helper.

```typescript
// channels/whatsapp.ts — this is approximately the entire file
import { WhatsAppBusinessAPI } from 'whatsapp-business-api';

export async function receive(handler: MessageHandler) {
  const api = new WhatsAppBusinessAPI(config.whatsappToken);
  api.on('message', async (msg) => {
    const normalized = normalize(msg);
    await handler(normalized);
  });
}

export async function send(channelId: string, text: string) {
  const api = new WhatsAppBusinessAPI(config.whatsappToken);
  await api.sendText(channelId, text);
}
```

That's it. The abstraction is "two functions, `receive` and `send`." You can write a new channel integration in an afternoon. By April, the repo had integrations for 53 services because every developer who wanted their own pet channel could just write the file.

This is why the contributor count hit 2,000 so fast. The project architecture didn't punish new contributors with a framework to learn. It rewarded them with a 50-line file to copy.

## What running it for a week actually felt like

On the morning I installed it, I expected pain. Setting up a local process that needs credentials for five different APIs, three of which require you to register a Meta developer account or a Signal phone number, sounds like a weekend of yak-shaving. It wasn't. The setup wizard walks you through each channel you want to enable, skips the ones you don't, and generates the config file.

Twelve minutes in, I had OpenClaw receiving iMessages from my wife asking what I wanted for dinner. It responded with a summary of the calendar for the evening and a suggestion based on what we hadn't eaten in the previous five days. My wife did not know it was a bot. I did not tell her.

What surprised me was how much of my day moved into it within three days. Not because it was better than [Claude Code](https://claude.com/claude-code) — it isn't, for coding — but because the channels it inhabited were the channels I already lived in. I didn't have to open a new app. I didn't have to "start a session." I just messaged it.

This is the insight cloud agents got wrong. The bottleneck on agent adoption was never the agent's capability. It was the context-switching cost of opening a dedicated interface. OpenClaw made the agent invisible. It ran where I already was.

I wrote about a related point in {% link jee599/claude-code-channels-vs-openclaw-en %} — comparing [Claude Code Channels](https://docs.anthropic.com/en/docs/claude-code/channels) to OpenClaw. The short version: Channels is better integrated with Anthropic's model and safer for development workflows. OpenClaw is better integrated with your actual life and wins for consumer-style tasks. They're solving different problems, but only one has 295K stars.

## The unit economics that investors missed

Here's the detail that crystallized it for me. A cloud-hosted AI assistant costs the vendor roughly $40-80 per month per user once you factor in inference, channel API fees, server costs, and support load. That's why every cloud agent either charges $20-30/month or is losing money on free tiers.

OpenClaw's cost to the vendor is zero. There is no vendor. You pay [Anthropic](https://www.anthropic.com/pricing) or [OpenAI](https://openai.com/api/pricing/) directly for inference — typically $5-15/month for personal use. The channel APIs are free on the tiers a single user consumes. Your server is your laptop.

For the user, this is 3-5x cheaper. For the ecosystem, this means the gravity has flipped. A startup building a cloud agent has to justify its margin to users who can see on GitHub that a local alternative exists with better platform coverage. A single contributor in Prague can add a channel integration to OpenClaw in an afternoon that would take a cloud vendor a quarter to negotiate, engineer, and legally review.

This asymmetry compounds. The cloud vendors have to slow down. OpenClaw can only go faster.

## What's likely to happen next

Two things worth watching.

First, the Skills format that I covered in {% link jee599/ai-github-skills-paradigm-en %} lands natively in OpenClaw soon. The [v0.34 milestone](https://github.com/openclaw/openclaw/milestone/12) targets a skills directory with the same semantics as Claude Code and Hermes Agent. That's a meaningful consolidation — three of the leading agent hosts will load the same skill files. Ecosystem effect.

Second, enterprise. OpenClaw's license permits commercial use. There's already a [community fork](https://github.com/openclaw/openclaw-enterprise) adding SSO, audit logs, and centralized policy for running the gateway across a small team's macOS fleet. If this matures, OpenClaw eats the bottom half of the Slack-bot integration market within a year. That market is larger than people remember.

The OpenClaw repo itself:

{% github openclaw/openclaw %}

Part 3 of this series looks at [OpenCode](https://opencode.ai/) — the Go-based terminal coding agent that hit 140K stars on a completely different strategy. Why terminal won 2026 and what it took to displace VS Code extensions like [Cline](https://github.com/cline/cline) and [Aider](https://aider.chat/).

> The cloud was never the default. It was a phase. OpenClaw just proved the phase was shorter than anyone expected.

Has anyone here tried running OpenClaw across a small team's shared hardware — a home server or small-office Mac mini? I'd be curious whether the multi-user model holds up or starts to feel like "one of us needs to reboot the lobster."

---

**Sources:**
- [OpenClaw repository](https://github.com/openclaw/openclaw) - GitHub
- [OpenClaw architecture docs](https://github.com/openclaw/openclaw/blob/main/docs/architecture.md) - GitHub
- [Peter Steinberger's blog](https://steipete.com/) - Personal site
- [The Lobster That Broke GitHub](https://n9o.xyz/posts/202602-steipete-openclaw-openai/) - N9O
- [OpenClaw Goes Viral with 145K Stars](https://creati.ai/ai-news/2026-02-11/openclaw-open-source-ai-agent-viral-145k-github-stars/) - Creati
- [OpenClaw Wikipedia](https://en.wikipedia.org/wiki/OpenClaw) - Wikipedia
