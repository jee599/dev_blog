---
title: "A Local-First Plan, Then 4 Days of Scope Creep"
published: false
description: "My agents wrote a local-first plan for an agent-office app. Days later it had guestbooks, gifts and a 266-item gacha, plus a PostgreSQL race I reproduced."
tags:
  - ai
  - claudecode
  - postgres
  - productivity
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/02-cover.png"
---

The product plan my agent team wrote on September 21, 2026 had a rule in it: never tell users their data stays on their PC. By September 25 the same project had guestbooks, gifts and a cosmetics gacha with 266 items.

This is post 2 of "Building Refmade". Refmade is an independent desktop app (not affiliated with Anthropic or OpenAI) that draws your Claude Code and Codex sessions as a pixel-art office. Post 1 covered the agent team I couldn't see and the dashboard that went empty whenever an agent skipped its status report. Claude Code and Codex agents wrote most of the code and documents here at my direction; I made the calls and reviewed the results.

## The plan was good

On September 21 I asked for a plan for a customer-facing version: other people install it locally, watch their agents on the web, and maybe send work to their own CLI from the web. My agents produced a plan, an architecture note, a user guide, a logic review, a source list, a verification list and two PDFs.

Two sentences in it still look right to me.

The first says the product must not tell users that their data never leaves the PC. A local CLI sends prompts and file contents to a model provider, so that promise would be false the first time someone ran a task. The second says the service must not pool customers' subscription tokens to run other people's work. The customer's PC opens an outbound connection to the server, and the server never exposes anything on the local machine.

I also decided early that the office is private by default, and that letting others visit it and showing task content are two separate switches. Price and launch date were left open, and the plan says in plain words that it grants no permission to sell.

The first-run screen still follows the first rule. Here is the preview-mode screen from the September 29 build.

![Refmade first-run screen with two cards, Claude Code ready and Codex needing login, and a list of notes about what is sent where](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/02-first-screen-notes.png)

*Refmade first-run screen, preview mode, a late-September 0.2.x build, UI in Korean. Title: "I'll get the AI ready first". Cards: "Claude Code: ready" and "Codex: login needed". Notes below: the app itself sends nothing to the internet; when you hand over a job, the Claude Code or Codex on this computer sends the request and needed file contents to Anthropic, OpenAI or a provider you connected, and Claude Code may also contact Anthropic when the app checks readiness; login is managed by each AI tool; the work counts against your own plan; AI answers can be wrong.*

That caption has an expiry date. This build said the app sends nothing itself. Later builds added a version check against my server and an ad-board request, and the current first-run screen says so in its first note. The note about what Claude Code and Codex send is still there. I measure what actually leaves the machine in a later post.

I also had a naming guide written for the Claude and Codex references the app needs. Product names and domains don't contain them, and there are no logos or look-alike mascots. The guide cites the official brand and usage pages and I designed around it. That's my reading, not legal advice.

## Then the plan grew

What nobody wrote was a list of things the product would not do. Between September 22 and 25 the following got added, each one a reasonable step from the one before.

| Added Sept 22 to 25 | Detail |
|---|---|
| Standalone dashboard mode | PC pairing; only an anonymous ID, state and timestamps are sent; three sharing settings default to off |
| Web requests to a local CLI | natural-language request that can edit up to 8 tracked documents or code files |
| Social layer | mini home pages, guestbooks, gifts, decorating |
| Cosmetics gacha | 266 items; rarity D/C/B/A/S at 50/30/15/4/1 percent |
| Two "world" layouts | a token pyramid and a construction-site village |
| Languages | Korean, Japanese, Chinese and English UI, with automatic post translation |

The plan itself recommended visits, gifts and decorating for the first beta, so the drift was partly written into the document I had asked for. The gacha plan file lists its rarity odds as approved on September 21, the day of the plan. As of the September 24 report none of it was deployed. It ran locally and lived in review screenshots.

The September 24 report counted 62 confirmed defects dropping to 0, 104 final screens (13 screens, 4 languages, 2 widths), and passing test suites in the hundreds. Those numbers show how far agents can polish a feature that nobody has decided to keep. On September 25 I stopped and asked for a redesign from scratch. That's post 3.

## The race I reproduced on a real database

One piece of that week is worth keeping on its own. The remote-execution feature had a setting to turn execution off. I wanted proof that "off" meant off, and unit tests against a mock couldn't show that.

On September 24 I had my agents start a throwaway PostgreSQL 17.10 cluster on a random loopback port, apply the three SQL files, and use only synthetic users and devices. Production was never touched. Seven checks ran on independent connections. Four passed, two reproduced a race, and one couldn't be judged.

```text
A: BEGIN; lock device row; set execution = off      (not committed yet)
B: queue a task -> wrapper reads execution = on     (no lock taken)
B: waits for A's row lock (pg_stat_activity: Lock / transactionid)
A: COMMIT
B: resumes -> inserts a queued task                 <- should be refused
```

*Simplified timeline of the two failing checks, from the September 24 test report.*

The wrapper functions read the setting without locking, then called an original function that took the row lock. "Off" was committed first, and a new task (or a new lease, in the claim variant) appeared anyway. The report doesn't call this a strict ordering violation, because B started while A's change was still in flight. It does say what happened: after the off-switch was committed, new work was still created. The fix was to take [`FOR UPDATE`](https://www.postgresql.org/docs/17/explicit-locking.html) on the device row first and read the setting afterward, inside one transaction. I had the two wrappers changed and reran the same seven checks on a fresh throwaway database: 7 of 7 passed. The unfixed SQL under the same harness still reproduced both races. Nothing was applied to production.

The seventh check taught me about my own tooling. The harness updated a table directly as a service role, which the schema rightly forbids, and got "permission denied". That was a test bug, so the report left the check as "not determined" instead of counting it either way. In the rerun it calls the product's own revoke function instead. An earlier failure was also a harness bug: it skipped the "started" state and sent "completed" straight away. And the real Claude delegation test stopped after four calls on a token budget, which I recorded as `stopped`, not as a pass.

## What I'd change

The plan was the right document. It had no section called "not in scope". An agent will happily build the next adjacent thing, and a 266-item gacha is adjacent to a guestbook, which is adjacent to a profile page. The September 25 redesign came with exactly that: a written list of what to remove.

Most of the week is gone now. Today's app has no social layer, no gacha, no worlds and no web-to-PC execution; the code sits in an archive folder. What survived is the first rule and an office that is local-only.

Do you keep a written "not in scope" list for agent-built projects, and who is allowed to overrule it?
