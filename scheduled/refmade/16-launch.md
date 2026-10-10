---
title: "Refmade 0.4.0 Is Out: A Free Mac App in Eight Languages"
published: false
description: "Refmade 0.4.0 for Mac shipped October 10 at 20:17 KST: free, eight languages, ad-hoc signed. What it sends, who it's for, and where I want feedback."
tags:
  - macos
  - electron
  - ai
  - showdev
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/16-cover.png"
---

Refmade 0.4.0 went live on October 10, 2026 at 20:17 KST. It is a free Mac app, now in eight languages, and this is the post where I finally link to it: [refmade.com](https://refmade.com). The translations were checked by AI agents only. No native speaker has checked them, so I'd like you to tell me where they sound wrong.

This is post 16, the last of "Building Refmade". I'm a solo developer based in Korea. Claude Code and Codex agents (Claude Sonnet and Opus for most of this work) wrote most of the code at my direction. I planned, decided and reviewed.

## What Refmade is

Refmade is an independent desktop app. It is not made, sponsored or endorsed by Anthropic or OpenAI. It does two things.

First, it lets you hand work to Claude Code or Codex on your own computer without typing commands: you describe the job in plain words, answer questions with buttons, and read the result. Second, it reads the session logs those two tools already write and draws your running jobs as a small pixel-art office. When an agent needs your answer, a question mark appears on its monitor.

You need Claude Code or Codex installed and signed in. Refmade doesn't replace them. The app is free. The AI usage is billed separately, on your own Claude or ChatGPT plan or pay-as-you-go, not by me.

![The English landing page of refmade.com: headline "Using AI is not hard", a "Get it free" button and a banner announcing Mac 0.4.0 in eight languages](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/16-site-en.png)
*The top of refmade.com/en/, captured with Playwright at 1280 px wide on the day of release. I cropped it to the top 620 px.*

## What 0.4.0 is

| | |
|---|---|
| Platform | Mac, Apple silicon, macOS 13 or later |
| Languages | Korean, English, Japanese, Simplified Chinese, Spanish, Brazilian Portuguese, German, French |
| Price | Free |
| Installer | DMG, 186,077,466 bytes (the site says about 190 MB) |
| Signing | Ad-hoc, not notarized |
| Windows | Public build stays 0.3.2, Korean screens only |

Because it isn't notarized, macOS blocks the first launch. Open System Settings, go to Privacy & Security and press "Open Anyway". You do this once per version. Post 12 explains why I chose this over paying for notarization. Traditional Chinese and Hong Kong users get the English screens, and European Portuguese gets Brazilian.

Windows is behind. A 0.3.8 Windows installer exists, but it was only cross-built and never run on a real Windows machine, so it isn't published. 0.3.1 is the only Windows build that has passed a check on a real PC, and 0.3.2 is public without that check.

If you already have 0.3.9 or 0.3.8, the app tells you a new version exists. It does not install it for you.

## What the app sends

The app itself talks to my server for two things: it checks for a new version, and on Mac it fetches a list of ads for the billboard in the office view. The ads are banners for my other services. There is no switch to turn them off. The new-version check can be switched off from the menu. The app has no usage statistics.

It does not send your work to me. When you give a job to Claude Code or Codex, that tool, running on your computer under your account, sends it to the model company. The only socket measurement I made was in post 10, on a 0.2.x build on September 29: all 94 of the app's own sockets pointed at 127.0.0.1, and the outside connections came from the tools it launches. I have not repeated that capture on 0.3.x or 0.4.0, so what I say about the version check and the ad feed comes from reading the code. I never read packet contents.

![Chinese approval card in the pastel theme asking which tone to use for replying to a customer](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/16-chinese-decision.png)
*Refmade 0.4.0 in Simplified Chinese, public demo data. The card asks "What tone should we use to reply to the customer?" and marks "Friendly and concise" as the AI's recommendation. The names are invented sample data.*

## Who it's for

It is for people who want to use Claude Code or Codex and find the terminal a barrier: someone who wants help answering customer emails or fixing a page on a small business site, and wants to see what the AI is doing before agreeing to anything. It is also for developers who run several agents and lose track of which one is waiting.

It is not a substitute for judgment. The "AI decides" mode answers light choices such as tone, title and color with the AI's recommendation, and it is off by default. It is a convenience switch and not a permission system. The wording rules that decide what counts as "light" are word lists, and I described in the previous post how they leaked and where I stopped. Installing Claude Code still means pasting one line into a terminal once, and Codex needs Node.js first.

I haven't tested the app with non-developers. I don't have user numbers to show you.

## How to try it

Go to [refmade.com](https://refmade.com) for the Korean default page, or [refmade.com/en/](https://refmade.com/en/) for English. The other languages have their own paths, for example [refmade.com/ja/](https://refmade.com/ja/) for Japanese. Each of the eight languages has a home page and a download page, 16 pages in total, and 30 screenshots of the real app in that language, taken with demo data.

![The Japanese landing page of refmade.com with the headline AIを使うのは、難しくありません](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/16-site-ja.png)
*refmade.com/ja/ on release day, same crop. The headline reads "Using AI is not hard."*

## What I'd like feedback on

The translations, mainly. They went through a glossary, two translation passes, a back-translation review and a second review of the safety wording, all by AI agents. The site and the 0.4.0 update note both say this. Nobody who speaks these languages natively has read them. If a button label sounds strange, a safety question is ambiguous, or a sentence reads like a machine, I want to know which language and which screen.

The easiest way is the "Send feedback" button at the bottom right of the app. It opens a mail draft to a fixed address, which reaches me, with a fixed subject line. In a window that isn't Korean, the draft body also names the app's language, so I know which translation you saw. Nothing is sent until you press send yourself, and nothing is attached.

![Spanish activity rows and the "Enviar comentarios" feedback button at the bottom right of the window](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/16-spanish-feedback.png)
*The "Send feedback" button in Spanish ("Enviar comentarios"), public demo data. The rows above it read "A new request arrived" with sample task names.*

## Looking back at the series

The 16 posts cover the work from September 20 to October 10, and they are published from October 12 to November 11.

The first posts were about the start: "I Built an Agent Team, Then Couldn't See What It Did", then "A Local-First Plan, Then 4 Days of Scope Creep" and "Stop Trusting Agent Self-Reports: Read the Logs Instead". The middle was craft and reversals: "Reading Claude Code and Codex Session Logs: Four Traps", "Five Parallel AI Builders, One Contract, 25 Review Fixes", "I Shipped a Friends Feature, Then Dropped It the Same Day", "Codex Image Gen Saved My White Pixels as Transparent" and "13 Research Agents Told Me My Feature Was Already Free".

Then came the app: "Wrapping Claude Code and Codex in Electron: A Stop Bug", "Measuring What My Electron App Sends: 94 Sockets, 0 Out", "My Claude Code Sign-in Fix Needed Two Fixes of Its Own", "Shipping a Mac Electron App Without Apple Notarization" and "Refmade Shipped Without Git: 2,764 Files in One Snapshot". The last two before this were "5 Releases in One Day: Release Gates for a Solo App" and "Eight Languages in One Day: Localizing a Korean-Only App".

The pattern I'd pull out is boring. Each time something went wrong, it was a claim I hadn't checked against the code or the running app: an agent's status report, a safety sentence, a Korean string that I thought was only text. The checks that paid off were comparisons against the real thing.

Thanks for reading. The app is at [refmade.com](https://refmade.com).

Which of your own tools stores a human-readable sentence somewhere that code later depends on?
