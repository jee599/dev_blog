---
title: "Measuring What My Electron App Sends: 94 Sockets, 0 Out"
published: false
description: "I sampled sockets every 0.25 s, ran nettop and read DNS logs on my Electron app. The 0 was true until my own update check and ad feed arrived."
tags:
  - privacy
  - networking
  - electron
  - macos
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/10-cover.png"
---

On September 29, my Electron app opened 94 sockets across four runs, and every one of them pointed at 127.0.0.1. The same runs also caused 20 connections to the outside world from a single one-line task. Both numbers are true.

This is part 10 of a series about Refmade, a desktop app I'm building alone. It lets people who don't use a terminal hand work to the Claude Code or Codex they already have installed, and shows the agents as an office you can watch. It is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction; I planned, decided and reviewed. The UI is Korean right now; that changes later in this series.

## The sentence I refused to write

From the first product plan on September 21, I had a rule for the copy: never say "your data never leaves your PC." Refmade starts a CLI on your machine, and that CLI sends your prompt and the file contents it needs to a model provider. A claim that sounds like "nothing leaves" would be false on the first task.

What I could say was narrower. The app itself should send nothing, and the gap between that and the CLI's traffic is what I measured. Whatever the CLI sends is the CLI's business, and the app should say so. That is a claim you can measure, so on September 29 I measured it, against the 0.2.x Mac build.

## How I measured

Four runs: two plain smoke launches, one Claude task, one Codex task. During each run I took a snapshot of the socket table every 0.25 seconds, ran `nettop` next to it, and collected the DNS records. A snapshot only sees sockets that are open at that instant, so a short connection can fall between two samples. The short interval, `nettop` and the DNS records are three views of the same run, and each covers a gap in the others.

| What I looked at | Result |
|---|---|
| Sockets opened by the app's own processes | 94, all on 127.0.0.1 |
| DNS lookups from the app's own processes | 0 |
| Connections during a one-line Claude task | 20, all from the CLI the app started |
| Packet contents | not inspected (needs admin rights) |
| Login flow, long-running tasks | not measured |

I take the 94 local sockets to be the app's own pieces talking to each other, such as the window and its office server. I didn't trace each one. The 20 outside connections come from Claude Code. My own Claude setup had MCP servers enabled, and Claude Code also sends usage statistics. A person without those servers would probably see fewer connections, but I didn't measure that.

I'd skip "0 external sends" as a headline. The accurate version is "0 from the app's processes, 20 from the tool it launched, content not inspected."

## The guard in the window

The renderer has its own rule. Every request a page in the app's window makes goes through one function, and only four kinds get through: the app's own files, DevTools, inline data, and the office server on `127.0.0.1` at its one port.

```js
case `${APP_SCHEME}:`: return isAppUrl(parsed) ? {allow: true, reason: 'app'} : {allow: false, reason: 'app-host'};
case 'devtools:':
case 'chrome-devtools:': return {allow: true, reason: 'devtools'};
case 'data:':
case 'blob:': return {allow: true, reason: 'inline'};
case 'http:': return isOfficeUrl(parsed, officePort) ? {allow: true, reason: 'office'} : {allow: false, reason: 'network'};
default: return {allow: false, reason: 'network'};
```

A Content-Security-Policy with `connect-src 'self'` sits behind it. A page script that tries to reach another host is cancelled by the filter and refused again by the policy.

## What the first screen says

I wrote the measurement into the first screen of the app, in plain Korean.

![First-screen setup card with privacy notes](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/10-first-screen-notes.png)

*The first screen as I prepared 0.2.3, captured at 01:20 on Sept 30 in preview mode (Korean UI, nothing from real work). Heading: "Let's get an AI ready first". Two cards: Claude Code "Ready", Codex "Login needed". The first note under them reads: "The Refmade app itself sends nothing over the internet. When you hand it work, the Claude Code or Codex on this computer sends the request and the file contents it needs, under your account, to Anthropic, OpenAI, or wherever you connected the AI. Even when checking that the AI is ready, Claude Code sometimes connects to Anthropic." Below the crop, two more notes say that logins are managed by each AI and that usage counts against your plan.*

A reader who sees only "the app sends nothing" might assume a one-line task is silent. It isn't: the capture showed 20 connections from the CLI, which is why the note names the CLI's own traffic in its second and third sentences.

## Then the 0 stopped being true

The first note in that screenshot stopped being accurate less than 24 hours after I captured it. I built 0.3.0 the next night, and it went live at 00:35 on October 1, with a new-version notice. About ten seconds after launch, and once a day after that, the app makes a GET request for a small version file on my own site. A menu switch turns it off.

On October 8, the Mac build 0.3.3 added billboards in the office view. The app fetches banners for my other services from my site about every 60 seconds, up to six at a time, each image capped at 350 KB. There is no switch to turn this off. The request carries no work data or identifiers, and I don't count impressions or clicks. A request to a web server still shows your IP address to that server, and I haven't checked how long my hosting provider keeps request logs.

Here is the whole history in one table.

| Version | Requests the app makes to Refmade's site | Basis |
|---|---|---|
| 0.2.x, Sept 29 | none | measured, 4 runs |
| 0.3.0, Oct 1 (built Sept 30) | version file, 10 s after launch then daily | code reading |
| 0.3.3, Oct 8 (Mac) | the same, plus the billboard feed every 60 s | code reading |

Both calls run in the main process through Node's `https` module, which the window's request filter above never sees. A comment at the top of that filter said "the app sends nothing to any server." That stopped being true when 0.3.0 went out, which is a good reminder that comments don't get tested.

The first note on the screen changed. This is the current Korean text, translated (the original names the site's domain, which I left out here): "The Refmade app fetches the new version number and the office ad banners from Refmade's site. These requests don't send your work or files. You can turn off update notices from the menu."

I haven't repeated the socket capture on 0.3.x. What I say about those two requests comes from reading the code, not from a new measurement.

## What I'd keep

A measurement belongs to a build number and a date. "0" was the right answer for one version and the wrong one for the next, and nothing in the app failed when that happened. The only thing that went stale was the sentence next to the number.

If you ship a desktop app that talks to your own server, the part to automate is the comparison between what the screen promises and what the code requests.

How do you verify what an Electron app sends: a proxy and packet capture, OS tools like `nettop`, or reading the code? And does anything fail in your CI when the privacy copy and the network calls drift apart?

The app link comes in the last post of the series.
