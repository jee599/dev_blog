---
title: "Stop Trusting Agent Self-Reports: Read the Logs Instead"
published: false
description: "My first dashboard for AI agents went blank whenever an agent forgot to report. On September 25 I redesigned it to read local session logs. Here is why."
tags:
  - ai
  - claudecode
  - architecture
  - buildinpublic
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/03-cover.png"
---

My first agent dashboard depended on the agents reporting their own work. If an agent worked and said nothing, the office looked empty. That was the September 21 design. Four days and a pile of extra features later, I asked for a redesign from scratch.

A status board that depends on the thing it monitors goes blank when that thing goes quiet. The fix was to stop asking the agents anything.

## Where this fits

Refmade is a desktop app I'm building alone that shows what your Claude Code and Codex sessions are doing, drawn as a small office. It is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction, and I planned, decided and reviewed. The UI is Korean right now; that changes later in this series.

Earlier in the series: the first office was a dashboard for an agent team I had built on September 20 (post 1), and over the next few days the scope grew into guestbooks, gifts and a 266-item cosmetics gacha (post 2). This post is about the day I stopped that.

## The day I asked for a redesign from scratch

On September 25 I compared what existed with the first plan and told the agents the product had drifted. What I wanted was simple: see how orchestration and local CLIs actually run, feel work getting finished, peek at other people's offices, and see each agent's work and hand-offs. I asked for a redesign from scratch, not a patch.

The design document opens with a diagnosis. Between September 21 and 25 the product had picked up mini home pages, gifts, a reward-box gacha, a token pyramid, a public village, post translation, and running tasks on your PC from the web. Each had pulled it further from one question: what is my AI team doing right now?

I answered four design questions that day. One office floor as the central picture. Other people's offices visible to friends only. Orchestration from the terminal only, with the web view read-only. Scope limited to a design document and a moving prototype, with no existing code touched. The friends-only idea survived until September 27, which is post 6.

## The design change: observe, don't ask

The first design looked like this.

```
BEFORE (Sep 21)                      AFTER (Sep 25)
agent --writes report--> board       CLI --writes session log--> disk
no report = empty office             office reads the log (read-only)
                                     no report needed, nothing to forget
```

Claude Code and Codex already write every session to local files. Those files show when a session started, which tool each step called, which sub-agent was spawned by whom, and, with some inference, when a request ended. So the new rules were these. One session is one team. The main session is the team lead. Each sub-agent is a team member, linked to its parent by `parentAgentId` in its metadata file, with `workflowPhase` saying which workflow stage it belongs to. A monitor on each desk changes color by what that agent is doing, decided only from the tool's name.

The privacy side mattered as much as the reliability side. The design said the office would run on timestamps, tool names, parent links and request boundaries, and would not read prompts, code or file paths. I wrote that boundary into the document before the live reader existed, because a dashboard that needs your prompts is a different product. The reader that shipped later is a little less pure: it looks at some text in memory to apply its rules, and it keeps a session title, a folder name and a one-sentence result for the local page. Post 4 lists what it looks at and what it keeps.

## What the prototype replayed

I did not build the live reader that day. The September 25 prototype replayed 90 minutes of my own real Claude Code logs, 02:00 to 03:30 Korea time on September 24, through the new rules. The extractor leaves out message text, paths and tool arguments.

| What the replay showed | Count |
|---|---|
| Teams (sessions) | 10 |
| Agents | 79 (10 leads, 56 workflow agents, 11 sub-agents, 2 forks) |
| Actions | 4,699 |
| Hand-offs | 157 (59 delegations, 66 reports, 32 passes) |
| Finished requests | 45 |

The 32 "passes" were inferred from workflow labels (the extractor hands work from one agent to the next when their labels match and the times line up), so treat that one as a guess, not a measurement. The other counts come from the extractor script, and they match the replay file the prototype plays.

I can't show the prototype screenshots, because the team names in them are real session titles from my machine. The two captures below are from the current app instead, with the public demo data I use for release notes. They show the same idea after it grew up: the office counts working people, finished requests and requests waiting on me.

![Top strip of the Refmade office view showing 9 working people, 0 finished requests, and 1 request that needs my answer](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/03-office-counters.png)

*Refmade's office header, demo data. The Korean reads "1 task is waiting for your answer" (banner), "My office", "9 people working", "0 finished requests", "1 needs my answer".*

![Panel titled In-progress missions with the sentence: 2 teams are working, 1 needs my answer](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/03-team-panel.png)

*The team panel in the game theme, demo data: "In-progress missions. 2 teams are working. 1 needs my answer." The task name, "Sort customer inquiry replies", is fake.*

## What I deleted

Redesigning from scratch meant a removal list, and the removal list was longer than the feature list.

| Removed from the new app | Added |
|---|---|
| Mini home pages, guestbook, gifts | Sep 21 to 22 |
| Reward-box gacha, 266 cosmetics | Sep 21 to 25 |
| Token pyramid, construction-site village, A/B worlds | Sep 24 |
| Public village, post translation (4 languages) | Sep 24 |
| Running tasks on my PC from the web | Sep 22 to 23 |

The design document says the removed code moves to an archive folder when implementation starts, instead of being deleted.

## Two limits

First, observation cannot know the plan. A session log doesn't say how many steps remain, so an observed team never gets a progress percentage. Only a team started through my own `refmade run` command knows its plan ("3 of 5 done"), and only that team carries a progress count. I preferred a missing number to an invented one.

Second, the board says "finished requests", never "succeeded". A request is finished when Claude Code ends its turn; post 4 covers the other cases. Whether the work was good is a separate question that no log answers. The wording on the board keeps that distinction.

One more risk sits outside my code. The logs are each vendor's internal format, and a version update can change them. Reading them is a bet that the shape stays close enough for me to keep up.

## Review and what was still rough

An independent design review scored the prototype 6 out of 10 and listed eight problems. I fixed all eight: focus jumping away when a panel re-rendered, the finished board getting clipped on mobile, an 11px minimum for text, the colors for "my turn" and "waiting on a question" being too close, and keyboard control of the timeline. The checks reported zero design-lint failures and no horizontal scroll from 360 to 1920 px. Still rough, in the brief's own list: characters walked in straight lines with no walking frames, the art was a temporary cut-up of the September 21 assets, and the three friends in the prototype were made-up examples.

The next post is about how the reader tells a request from a tool result, a fork from a real sub-agent, and when a request actually ends. The app link comes in the last post of the series.

Which would you rather trust for a status board on your own agents: what they say they did, or what the files on disk say they did, even if the file format can change under you?
