---
title: "I Shipped a Friends Feature, Then Dropped It the Same Day"
published: false
description: "Live friend sharing went from a design call to a production database migration to a decision to drop it, all on September 27. What I built and left behind."
tags:
  - ai
  - privacy
  - postgres
  - webdev
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/06-cover.png"
---

On September 27 I applied a database migration to production so friends could watch each other's AI offices live. At 21:40 that same evening I decided friend sharing was not needed. I never had a second account on it, so as far as my notes show, I was the only person who ever used it.

Refmade is an app that draws your Claude Code and Codex sessions as an office, one team per session. It is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction, and I made the decisions and reviewed the results. The UI is Korean right now; that changes later in this series.

Two days earlier I had reset the design and chosen "friends only, live" as the way to look at other people's offices. This post is what happened when I built exactly that, and what it left behind.

## The design I built

The September 25 reset had cut the guestbook, gifts, the 266 cosmetics and the public village. Live viewing between friends was the one social idea I kept, with a hard rule attached: sharing is off by default, and nothing is public.

A friends feature here means one thing: a friend can open a page and see a read-only version of my office, a few seconds behind. My PC had to push something to a server, and the friend's browser had to pull it.

```
my PC                        server                     friend's browser
-----                        ------                     ----------------
refmade connect <code> ----> code (15 min, one use)
                      <----  device token (shown once, stored hashed)

watcher: every 60 s  ------> "sharing mode?"  (default: off)
if mode = friends:
  push summary, at most
  once per 5 s       ------> keep latest only  <---- poll every 5 s
                                                     (only if friend,
                                                      not blocked,
                                                      sharing on)
```

Turning sharing off deletes the stored summary right away. The default is "only me", and the page says so in plain words.

![A Korean settings card titled "My sharing scope" with three checkboxes: "Only me", selected, "Live to friends", and "Also show task names", greyed out.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/06-sharing-scope.png)

*The sharing card. Korean labels: "Only me: the office is visible only on my PC, nothing is sent", "Live to friends: friends follow my office a few seconds late", "Also show task names: used only when live to friends is on".*

## What leaves the PC, and what never does

The part I spent the most care on was the summary itself. A function builds a new record from an explicit list of fields. Nothing from the local snapshot is forwarded as it is, so a field added to the local model tomorrow cannot leak by accident.

```js
// cli/lib/office/friend-payload.mjs
export const FRIEND_WINDOW_MS = 2 * 3_600_000;   // last 2 hours only
export const FRIEND_MAX_BYTES = 64 * 1024;       // over this, oldest events go first
export const FRIEND_TEAM_STATUSES =
  Object.freeze(['work', 'mine', 'ask', 'idle', 'done']);
```

| Sent | Never sent |
|---|---|
| team status word, tool (Claude, Codex or a `refmade run`), finished-request count | the one-line "result" of a request |
| agent role, department, start and end times | an agent's label, note, type and lane |
| timestamps of actions, and which action category | request text, prompts, file paths |
| hand-offs between agents (who passed work to whom) | a team's folder name |
| team title, only if "show task names" is on | workflow names and descriptions |

If task names are off, the friend sees "Task 1" and "Task 2". A real summary came to about 29.5 KB, well under the 64 KB cap.

![A read-only office view in pixel art with columns of desks, status badges, and a side panel titled "Task 7" with "Marketing team: 20 people, 17 finished".](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/06-friend-view.png)

*The friend's view, rendered from a synthetic summary. Korean text: "Marketing team: 3 people working on step 1 of 1", "A task split among many, 20 people", "Waiting for the results of 3 marketing team members". Counters at the top: people working, finished requests, needs an answer. No real session data.*

## What I tested, and what I could not

On production I ran the whole path once. I generated a connection code, ran `refmade connect` with it, switched sharing on, and waited. About 30 seconds later the first summary arrived, 29.5 KB with task names hidden. The friend page showed it at 1440 and 390 pixels wide. When I switched sharing off, the stored summary was deleted immediately.

The test suites passed: 136 for the SQL, 143 for the API, 266 for the CLI. Those numbers say the code does what I wrote, and nothing about whether anyone wants it.

Three things I did not verify the way I wanted:

1. **Two accounts.** I had one production account. Friend requests, accepting, blocking, and "a stranger cannot read my office" were tested locally only.
2. **The live friend page in the automation browser.** The page stops polling when the tab is hidden, by design. The automated tab is always hidden, so it sat on "Loading" forever. I injected the same summary into a headless browser to see the page render.
3. **The privacy policy.** The site had no privacy policy page, and the address for it returned 404. The feature stored a summary of what someone's PC was doing. The report on this work listed the missing policy as the first of two open items, ahead of publishing the package.

There was a fourth problem, and it is the most ordinary one. The connect page told users to run `npx refmade@latest connect <code>`. The package was not on npm, and as of October 10 it still is not. The command would have failed on any other machine.

## The reversal

That evening I had a market research report in front of me (a later post covers it). At 21:40 I decided that the first release would be a dashboard plus a local way to give instructions, for people who find the terminal hard. I also decided that friend sharing was not needed.

So the feature I had chosen on September 25 and shipped on September 27 was dropped on September 27. The friends pages were taken down in the site deploy that went live at 00:35 on October 1, and they return 404 now. I kept the four files (two pages, two scripts) in a `retired-p2-friends` folder with a README on how to put them back: move them into the public folder and re-add the two routes.

What the removal did not clean up:

- The backend pieces stayed deployed with no screen in front of them. The README, dated September 30, says so, and my notes do not record removing them.
- The production database kept the new tables from that day, as far as the same README shows.
- A pile of docs, contracts and test results now describe something the app does not have.

## What I take from it

Agents made the feature cheap to build: one day from contract to production, including a database migration and a real end-to-end run. Taking it down took one site deploy. What a deploy does not remove is a backend with no screen in front of it, database tables with nothing reading them, and documents that point at nothing.

The check I would add is boring. Before touching production data for a new feature, write the one-sentence description of the first release and see whether the feature appears in it. On September 27 it would have said no, two days after I had said yes.

Next in the series: AI-generated sprites that came back with their white pixels turned transparent. The app link comes in the last post.

If you have shipped something to production and removed it within days, what did you leave behind that you wish you had scripted out in advance?
