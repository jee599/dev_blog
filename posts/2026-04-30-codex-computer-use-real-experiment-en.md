---
title: "I Gave Codex My Mouse for a Day. Here's What Broke."
published: true
description: "Codex now sees, clicks, and types with its own cursor. I ran it on real workflows for 24 hours. Some worked. Some broke in unexpected ways."
tags: [ai, productivity, webdev, automation]
cover_image: https://r2.jidonglab.com/blog/2026/04/codex-computer-use-real-experiment-hero.jpg
canonical_url: https://jidonglab.com/blog/codex-computer-use-real-experiment
series: "Codex April 2026 Deep Dive"
hashnode_url: 'https://plzai.hashnode.dev/2026-04-30-codex-computer-use-real-experiment'
id: 3592349
date: '2026-04-30T14:58:51.456Z'
---

At 9:14 a.m. on a Tuesday I watched my cursor drift across the menu bar without me touching the trackpad. It hovered over the Numbers icon, paused, then double-clicked. A spreadsheet I had not opened in three weeks slid into focus, and a new column appeared cell by cell while my hands sat in my lap.

Codex Computer Use is the [April 2026 update](https://developers.openai.com/codex/changelog) that lets [OpenAI Codex](https://openai.com/index/codex-for-almost-everything/) see your screen, move its own cursor, and type into any app — not just files in your editor. It runs in the background and stays inside a sandbox you define. The macOS build shipped earlier this spring; the April release added native Windows support on top of [PowerShell and the Windows native sandbox](https://openai.com/index/introducing-the-codex-app/). Same idea on both platforms: a cursor that is not yours, doing work that used to be yours.

I gave it permission for one workday. Three real tasks. Honest log.

## Why I wanted this badly

The boring truth is a Tuesday ritual I hate. A vendor sends a CSV of charges, and I reconcile it line by line against a dashboard with no export button — just a search bar and a table that paginates twenty rows at a time. Numbers usually match. When they do not, I write a Slack message that starts, "Hey, quick one." Forty minutes, bad mood for the rest of the morning.

I have tried to automate it twice — a Playwright script that broke the day the vendor changed their CSS, a Zapier flow that could not handle the dashboard's auth. Both times the maintenance cost ate the savings. What I wanted was something that behaved the way I behave: squint at the screen, click around, copy a number, and only call me when something looked off. Codex Computer Use is the first thing that promises that without a brittle selector for every button.

## Turning it on (and the sandbox you actually want)

Enabling computer use was less ceremonial than I expected. Install the latest Codex desktop app, open Settings, toggle on "Computer use" under Agents. On macOS it asks for Accessibility permissions the first time the cursor moves; on Windows the native sandbox handler asks for a scoped grant per application. The piece worth paying attention to is the permission file. Mine looks roughly like this:

```toml
# ~/.codex/computer-use.toml
allowed_apps   = ["Numbers", "Safari", "Slack", "Linear"]
denied_apps    = ["1Password", "Mail", "Messages", "System Settings"]
network        = "deny-by-default"
require_human  = ["send_message", "submit_form", "purchase"]
session_log    = "~/codex-logs/2026-04-30.jsonl"
```

That last block matters most. `require_human` forces Codex to pause before any irreversible action — sending a message, submitting a form, anything that costs money. The first time it stops on a Slack send and waits for you to press Approve, you understand why it is the only sane default.

I also turned on stable [hooks](https://developers.openai.com/codex/changelog) and `codex exec --json`, which now reports reasoning-token usage per step. If you let an agent click around your machine, you want a transcript you can read afterward. The TUI's new `/side` command — spawning a side conversation without losing main-task state — was useful for asking "wait, why did you do that?"

## How it stacks up against the obvious alternatives

Three other tools were in my head before I tried this. [Anthropic's Claude computer use](https://www.anthropic.com/news/3-5-models-and-computer-use), GA since late 2024, is the closest cousin — same screen-reading, same cursor — but it shines brightest scripted through the API, not as an always-on background agent. Microsoft Copilot Vision, baked into Edge, is strong inside a browser tab and much weaker the moment you cross into a native app it cannot annotate. OpenAI Operator runs in a remote cloud-browser sandbox; safer, but cut off from logged-in desktop apps or local files.

Codex Computer Use sits somewhere else. It runs on your hardware, sees what you see, and is the same Codex you were already using for code. The continuity matters more than I expected: after the CSV reconciliation, the diff was already in the Codex session that had my repo open, so I could ask it to write a Python script that did the comparison in pure code next time. None of the other three give you that handoff for free.

## Three tasks, one full day

Task one: reconcile the Tuesday CSV against the vendor dashboard. Win. I dragged the file in and said "match this against the dashboard, flag any row off by more than two cents, put discrepancies in a new sheet." It opened Numbers and Safari, paged through the table, produced a discrepancy sheet with seven rows. Manual: ~40 minutes. Codex: 11 minutes, of which I spent maybe 90 seconds approving two pause-points. The discrepancies matched what I would have flagged.

| Task                             | Manual time | Codex time | My time at keyboard |
| -------------------------------- | ----------- | ---------- | ------------------- |
| Reconcile vendor CSV vs dashboard | ~40 min     | 11 min     | ~90 sec             |
| Sync Linear export to GitHub Project | ~25 min | 18 min     | ~6 min              |
| Clear Figma comment screenshots   | ~15 min     | failed     | the full 15 min     |

Task two: update a [GitHub Project](https://github.com/features/projects) board from a Linear export so columns matched the new sprint. Partial. Codex parsed the CSV, opened the board in the new in-app browser — April Codex ships with an embedded browser you can comment directly on rendered pages, which I only appreciated when I watched it leave a pull-request-style note on a card — and moved cards mostly correctly. It got confused on one column recently renamed from "In review" to "Awaiting QA" and put four cards in the wrong place. It noticed itself, asked "please confirm these," and waited. I fixed them by hand. The lesson: the agent is good at executing the rule you stated, not at noticing that your rule is out of date.

Task three: clear forty-plus stale screenshot comments in a [Figma](https://www.figma.com/) file. Outright failure. Figma's comment UI uses a custom canvas, not DOM elements, and Codex's screen reader could see the comments but could not reliably target the small "resolve" button on each one. It clicked next to the button maybe thirty percent of the time and once accidentally placed a new comment by clicking the canvas itself. I stopped it after eight minutes — three resolved, two created. I did the rest manually. The honest takeaway: when an app's controls are non-standard or visually crowded, vision-driven control still has a hit rate that is not good enough for unattended work.

If you want a more general primer on how I usually wire tools into agents, I wrote up the MCP-based version of this story here:

{% link jee599/how-i-connected-20-tools-to-claude-code-in-5-minutes %}

## What 90+ new plugins changed in practice

The other shoe was a wave of more than ninety new plugins — [Atlassian Rovo](https://www.atlassian.com/software/rovo), [CircleCI](https://circleci.com/), [CodeRabbit](https://www.coderabbit.ai/), GitLab Issues, the Microsoft Suite, [Render](https://render.com/), and a long tail of niche ones. They compose with computer use: when a plugin exists Codex prefers the API call; when no plugin covers a surface, it falls back to clicking. Mid-task on the GitHub job I watched it switch modes — using the plugin to read the project schema, then driving the cursor to drag cards because the plugin did not yet expose column reorder. That hybrid is what makes the whole thing feel like one tool instead of two.

## Would I leave it on tomorrow

For the CSV reconciliation, yes, immediately. I already moved the Tuesday ritual to a scheduled Codex run with the same permission file and a Slack ping if any discrepancy is over a dollar. For project-board work, yes but supervised — I would not let it run while I sleep. For visually messy apps like Figma comments, not yet. The cursor-on-canvas era is real but uneven, and pretending otherwise is how you end up with two new comments on a screenshot you were trying to delete.

What is your reconciliation-equivalent — the boring forty-minute task you would hand to a cursor that is not yours, if you trusted the sandbox?

> An agent that can click is only as good as the line you draw around what it is allowed to click.

---

Sources:
- [OpenAI — Codex for almost everything](https://openai.com/index/codex-for-almost-everything/)
- [OpenAI Developers — Codex changelog](https://developers.openai.com/codex/changelog)
- [OpenAI — Introducing the Codex app](https://openai.com/index/introducing-the-codex-app/)
- [Smartscope — Codex Desktop major update, April 2026](https://smartscope.blog/en/generative-ai/chatgpt/codex-desktop-major-update-april-2026/)
- [BuildFastWithAI — OpenAI Codex for almost everything (2026)](https://www.buildfastwithai.com/blogs/openai-codex-for-almost-everything-2026)
