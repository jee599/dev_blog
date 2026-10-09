---
title: "I Built an Agent Team, Then Couldn't See What It Did"
published: false
description: "A solo developer's first days with a Codex agent team: a dashboard that went empty when agents skipped status reports, and a dead project's name reused."
tags:
  - ai
  - claudecode
  - codex
  - buildinpublic
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/01-cover.png"
---

The first files of my agent team were written at 22:47 on September 20, 2026. By the next day I had a web dashboard to watch it. The dashboard was only as full as the agents were diligent: when one skipped its status report, that part of the office was empty.

This is the first of 16 posts about building Refmade, one every two days. Refmade is a desktop app that reads the session logs Claude Code and Codex already write on your machine and draws them as a small pixel-art office, so you can see which agent is doing what. It's an independent app, not affiliated with Anthropic or OpenAI. I'm a solo developer based in Korea, and I should say up front how the work is split: Claude Code and Codex agents wrote most of the code at my direction. I planned, decided and reviewed. The posts are about the decisions, the reversals and the bugs.

The series follows the real order of events. The next few posts cover a product plan that grew out of control, the switch to reading logs, and a map of how Claude Code and Codex write those logs. Later ones cover shipping a Mac app without notarization, a first Git commit that arrived far too late, and a gate that stopped a broken release. Failures get as much space as launches.

The app's UI is Korean right now. That changes later in this series, so every screenshot has an English caption.

## The name belonged to a dead project

"Refmade" is older than the app. From March 20 to July 2, 2026, Refmade was a different product: a web design reference catalog with a gallery front end. It was a Next.js app with about 83 references, 131 commits and a payment integration wired in. One April 1 commit fixed a mobile out-of-memory crash in the gallery.

Then I stopped working on it. On August 7 I cleaned up my hosting account and cut 29 projects down to 12. The old Refmade project survived for one reason: a custom domain was attached to it, so I left it out of the deletion. About six weeks later, on September 21, that domain was pointed at the new office dashboard.

None of the gallery's code carried over. The new app started fresh on September 20. What carried over was a name and a domain that had been spared by accident.

## The team I couldn't see

The September 20 files were not a product. They were a personal operating setup for Codex: eleven subagent definitions (PM, product, business, marketing, design, Figma, engineering, implementation, research, data analysis and review, with the team lead being the main conversation) plus a short README that says it was made at my request as a personal operating setup. I had a team. I could not tell what it was doing.

With several agents running in separate terminals, the question "who is working on what, and who is waiting for me?" had no good answer. So on September 21 I asked Codex for an "office": a web dashboard with one floor per task, each person's current job, the next step, what they're waiting for, meetings and records. Codex built it, and I reviewed the screens and sent back changes.

| | v1 office (Sept 21) |
|---|---|
| Runs at | `127.0.0.1:4318` on my Mac |
| Remote view | password-protected page through a quick tunnel; works only while the Mac and the bridge are running |
| Refresh | every 5 seconds, paused in hidden tabs |
| Art | pixel-art floors, shelves and 12 seated characters, drawn with GPT Image |
| Checks passed | 25 Python tests and 16 Node auth/deploy tests |

The remote view was not a hosted service. A quick tunnel exposed my Mac's state read-only, so with the Mac off the office was unreachable. That was fine for a tool only I used. It also meant the first version of "see my agents from anywhere" was really "see my agents while my laptop is on".

The pixel art worked as intended. The data model is where it failed.

## Where it broke

The first version asked each agent to record its own state. A small recorder script wrote those reports to files and the dashboard drew them. A separate observer could tell that a session window was open, but it listed those on their own layer, with no role, next step or meeting attached.

```text
agent -> writes status report -> file -> dashboard -> "office"
              |
              +-- skips the report -> nothing to draw -> empty floor
```

An agent in the middle of a long task has no particular reason to stop and write a status note. When it didn't, that agent had nothing on the floor, and a floor with nobody on it looks like an idle team. The dashboard could not tell "nobody is working" from "nobody reported".

On September 21 the dashboard looked right, the tests passed and the screens matched the design. By September 25 I had decided the approach itself was wrong. How I replaced self-reports with log reading is the subject of post 3.

The lesson I took was narrow. A dashboard that depends on the observed system describing itself will be wrong in exactly the moments you most want it right. Anything I could read without the agent's cooperation was more trustworthy than anything the agent chose to tell me.

There was a smaller problem in the same dashboard: the logo's white background stuck out of the sign. I kept the original logo file untouched and fixed its position and blend mode inside the sign.

![Isometric pixel-art office with five characters, desks, a whiteboard with sticky notes and plants](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/01-office-illustration.png)

*An illustration generated with Codex (gpt-image-2) for an earlier version of the product site: five characters, desks and a whiteboard with sticky notes. It is AI-generated art, not an app screenshot.*

## What the office looks like today

The current app draws a team per session from local logs instead of from reports. Here is a crop of version 0.3.9 with three teams.

![Three team cards from the Refmade office view, each with pixel-art characters at desks](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/01-team-cards.png)

*Refmade 0.3.9, public demo data, UI in Korean. Left: area "Neighborhood workshop" (Claude, 1 team), task "Improve homepage booking screen", working with 2 art-team members. Middle and right: the two teams of area "Spring-light cafe" (Codex). Middle: task "Prepare new-menu promotion", working with 3 marketing-team members. Right: task "Sort customer-inquiry replies", marked "I need your answer". The workshop and cafe names are invented sample data.*

## Where it stands today

Refmade today runs on Mac (Apple Silicon) and Windows, it is free, and it needs Claude Code or Codex installed and logged in on your machine. Version 0.3.9 is the current Mac build. The later posts cover how each of those pieces got there, including the parts that went wrong.

The app link comes in the last post of the series.

Next up is the product plan my agent team wrote on September 21, and the days in which it grew guestbooks and a gacha.

If your agents run in separate terminals or sessions, how do you currently know which one is stuck waiting for you?
