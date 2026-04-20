---
title: "I Built an AI Newsletter for Myself. 11 Subscribers, 49 Posts, Zero Regrets."
published: true
description: "A solo-operated AI news platform with a daily 8am cron, Resend-powered individual email sends, and a 49-post bilingual pipeline. Built in a weekend, still running a year later."
tags:
  - ai
  - automation
  - nextjs
  - indiehackers
series: "Solo AI Products"
canonical_url: https://jidonglab.com/posts/2026-04-19-spoonai-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-19-spoonai-ai-newsletter'
id: 3527817
date: '2026-04-20T15:43:31Z'
---

Eleven subscribers. Forty-nine bilingual posts. One person pushing the commits. That's the entire accounting sheet of [spoonai.me](https://spoonai.me), and I'm telling you those numbers up front because I think they're the most interesting part of the project.

**TL;DR** — I wake up at 8:01 KST and three bilingual AI news posts are already live on my site. A cron job on a [Claude Code](https://dev.to/jee599/66-5-of-my-claude-code-tokens-were-wasted-a-200-line-wrapper-got-them-back) scheduled task triggers the `spoonai-daily-briefing` skill, which crawls sources via Firecrawl, writes Korean and English posts in parallel, commits to Next.js, Vercel auto-deploys, and Resend sends individual emails to eleven people. Mon–Fri daily, Sat weekly digest, Sun article-only. I built it for myself first. Ten others decided to ride along.

## Why 11 Subscribers Is a Feature, Not a Bug

Most content advice is built for scale. Grow the list, grow the CTR, grow the open rate. That's fine if you're running a media company. I'm not.

I built spoonai.me because I got tired of doom-scrolling Twitter and X for AI news. You know the feeling. Thirty tabs open, four "must-read" threads bookmarked, and at the end of the night you couldn't tell me what actually shipped that day.

The bottleneck in AI news isn't information. It's curation. There's too much signal, too many people shouting over each other, and the stuff that matters usually arrives in broken English on a repo README that nobody retweets.

So I built the newsletter I wanted to read. Eleven people signed up. Ten Korean readers, one English reader. That split tells you something specific about my audience: they're Korean developers who want English-source AI news translated and triaged, plus one non-Korean reader who just likes the curation. That's a real audience. You can't fake that split with growth hacks.

Eleven subscribers is not failure. It's focus. If ten thousand people subscribed tomorrow, the product wouldn't change — the product is the loop, not the list.

And here's the part nobody writing growth threads will tell you: a list of eleven engaged readers is a better product than a list of eleven thousand who never open. I know all eleven of mine. Two of them have replied. One of them caught a typo on day three. That's a signal loop you literally cannot buy with paid acquisition.

## The 8am Cron That Does My Reading For You (And Me)

Here's what happens while you're brushing your teeth and I'm still asleep.

At exactly `0 8 * * *` KST, a scheduled task inside Claude Code fires. It triggers a custom skill called `spoonai-daily-briefing`. The skill opens a fresh session, reads yesterday's published posts to avoid duplicates, and queries Firecrawl MCP to crawl a curated list of AI sources.

[Firecrawl](https://www.firecrawl.dev) does the dirty work of turning ugly HTML and PDF preprints into clean markdown. I don't touch it. I don't babysit it. It just returns text.

The skill then picks the three highest-signal stories, writes two versions of each post in parallel — Korean and English, not translated, actually written in both languages with different rhetorical beats — and commits them to my Next.js repo. Vercel picks up the push and deploys. A Vercel MCP check verifies the deploy went green.

Then Resend fires. Eleven individual sends, one personalized email each, Korean template for ten of them, English template for one. I wake up around 8:30. Three new bilingual pairs are already live. My own inbox has the email. I read it with coffee. That's the whole loop.

The 6-hour window I didn't know I needed is the gap between "AI news happens overnight in the US" and "I want to start my Korean workday with context." That gap is exactly what the 08:00 KST cron fills. By the time I'm awake, the AI news you missed yesterday has already been summarized, filed, and emailed to the eleven people who asked for it.

## Why I Don't BCC

Most newsletter tutorials will tell you to BCC your list. Don't.

BCC looks spammy to email providers. Gmail's own spam classifier treats large BCC batches as a signal. If you're sending to eleven people, you're fine either way — but the habit matters. The moment you grow to a hundred, BCC will start landing in Promotions, and from there it's a slow death.

I use [Resend](https://resend.com) and fire individual sends. Each subscriber gets their own personalized email with their own greeting, their own unsubscribe link tied to their identity, their own language preference. Resend's pricing at this scale is basically free, and the per-send architecture means I can personalize anything I want — the top story, the reading order, the subject line.

You might think this is overkill for eleven subscribers. It is. But the architecture that works at eleven will also work at eleven thousand. And when a subscriber replies to one of my emails — which happens more than you'd expect — they're replying to a message that looks like I sent it to them specifically, because I did.

## 49 Posts, One Weekend, One Person

I launched the first version of spoonai.me in a weekend. The full stack is Next.js on Vercel with a single author seat. There's no CMS. Posts are markdown files in the repo. Deploys happen on push. That's it.

The scheduled task skill does the real work. Its job description, in plain terms, is: wake up, read the world, write three things worth reading, ship them, tell eleven people. The cron expression is `0 8 * * *`. The skill name is `spoonai-daily-briefing`. The MCP integrations it uses are Firecrawl for crawling and Vercel for deploy verification.

The rhythm is Mon–Fri daily posts plus emails, Sat weekly digest email, Sun article-only with no email send. Sunday is the rest day. I decided early that if I wouldn't want an email on Sunday morning, neither would my readers. The rhythm holds.

On 2026-04-16 alone, the pipeline published three bilingual post pairs. Six posts in one day. Topics: Opus 4.7 adaptive thinking, OpenAI's duct-tape GPT-Image-2 release, Opus 4.7 system card findings. I wrote zero of those posts manually. I read all of them over breakfast.

Forty-nine bilingual posts at the time of writing. That's ninety-eight actual files, because Korean and English are separate canonical URLs. The pipeline has been running for months without manual intervention. When it breaks, it usually breaks loudly — a Firecrawl timeout, a Resend API blip, a Vercel deploy that hangs on a dependency update. I fix it in the evening. The next morning the cron fires again. The loop keeps closing.

This is the same pattern as [my Hermes 4 405B experiment](https://dev.to/jee599/i-ran-hermes-4-405b-for-72-hours-heres-what-broke) — small surface area, ruthless instrumentation, let the scheduled task carry the weight. The fewer moving parts, the longer it runs unattended. A cron job, a skill, an API key, and a repo. Everything else is noise.

spoonai.me succeeds a project I previously called news4ai. That earlier attempt died because I tried to do the curation manually. Twenty minutes a day became forty became an hour became "I'll do it tomorrow" became silence. The moment I moved the curation onto a cron and a skill, the project became sustainable. The hard part wasn't the code. It was admitting that my own willpower was the bottleneck.

## Build Your Own Brief

I'm not pitching you spoonai.me. Ten of my eleven subscribers speak Korean, and if you're reading this in English, odds are the specific posts I publish aren't matched to your exact feed anyway.

What I'm pitching you is the shape. Pick the topic you keep doom-scrolling about. Set a cron. Pick two or three sources that actually matter. Crawl them, write a brief, email it to yourself. Do it for thirty days. See what survives.

If your brief is useful to you, it will be useful to somebody else. My ten Korean readers and my one English reader exist because I didn't water down my curation to chase a broader audience. I wrote for me. They found it. You don't need permission and you don't need a list. You need a loop.

spoonai.me is just the example running this pattern out in the open. If you want to see what the output of the loop looks like before you build your own, [the site is here](https://spoonai.me). The English subscribe link is in the footer. If you sign up, you'll be subscriber number twelve, and I will personally notice, because I am one person reading my own analytics in the morning.

Doom-scrolling feels like staying informed. It's not. It's renting your attention to whoever optimizes engagement hardest that week. You can opt out. You can build a five-minute brief that actually covers what you care about, and you can automate it until you forget you built it.

That's what spoonai.me is. Eleven subscribers. Forty-nine posts. One cron. Zero regrets.

> Doom-scrolling is outsourcing your attention to someone else's algorithm. Build your own brief.
