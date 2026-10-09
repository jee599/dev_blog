---
title: "Five Parallel AI Builders, One Contract, 25 Review Fixes"
published: false
description: "How I split a local app across five builder agents and one integrator with a file-ownership contract, then fixed 25 review findings and picked a game UI."
tags:
  - ai
  - claudecode
  - node
  - webdev
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/05-cover.png"
---

On September 26 I had five builder agents work from one markdown contract that said which files were theirs. When P0, the first local version, was done, it ran at 127.0.0.1 with 224 passing tests and no requests leaving the machine. Before that, a review pass ended in 25 fixes, and I think that number says more about parallel agent work than the test count does.

This is part of a series about building Refmade, a desktop app that draws your Claude Code and Codex sessions as an office: one team per session, with the main agent as team lead and each subagent as a teammate. Refmade is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code, at my direction. I planned the work, made the calls, and reviewed what came back. The UI is Korean right now; that changes later in this series.

The previous posts covered why the office reads local logs instead of trusting agents to report. This one is about the first version that actually ran, the "P0".

## A contract is a file-ownership table

A build contract, in my usage, is a document that fixes the interfaces between parallel workers and says which worker may edit which file. Without one, five agents writing one app produce five slightly different ideas of what a "team" object looks like.

The contract lives in the repo as `office-v2/P0-CONTRACT.md`. The file is dated September 25 and is about 40 KB today, because sections were added during the build; one of them, for the workflow view, comes up below. The part that mattered most was a table of who owns what:

| Builder | Owns | Edits existing files |
|---|---|---|
| A | log classification, Claude log reader | none |
| B | Codex log reader | none |
| C | office model, collector | none |
| D | HTTP server, the `open` command | the CLI entry file and its translation keys, only to add the command |
| E | the browser page and its scene code | none |
| Integrator | nothing new | everything, but only for defects found at integration |

Every builder got its own tests next to its own code. The 125 existing tests were frozen. No new dependencies, Node 18 or later, ES modules only. The logs under `~/.claude` and `~/.codex` are read-only for the whole app.

The rule I cared about most was the shortest one: "Other people's files are read-only." To change an interface, a builder had to edit the contract first and tell the integrator, not patch someone else's file. It is the same rule a team of humans uses, and it needed to be written down for agents for the same reason.

## One loopback port is reachable by everyone on the machine

The server binds to 127.0.0.1 only. That is the easy part. The less obvious part is that a loopback port is open to every other program and every other user account on the same computer, so "local" is not the same as "private".

Builder D's contract section answers that with a per-run key. `refmade open`, a developer command that was never published, generates a random key and opens the page at `http://127.0.0.1:<port>/#k=<key>`. The key sits after the `#`, which browsers never send over the network. The page reads it and attaches it to every API call. This is the check as it exists in `cli/lib/office/server.mjs` today:

```js
const keyOk = (req, params) => {
  if (!key) return true;
  const given = req.headers['x-refmade-key'] ?? params.get('k');
  if (typeof given !== 'string' || given.length !== token.length) return false;
  return timingSafeEqual(Buffer.from(given), key);
};
```

The `?k=` fallback exists because `EventSource`, the browser API behind the live stream, cannot set custom headers. A request whose `Host` header is not the server's own address gets a 421, which blocks DNS rebinding. Static files need no key. The API returns nothing without it.

This protects the office view from other local programs. It does not make the agents' own work safe, and I do not claim it does. It only keeps the view private on a shared machine.

## What the review pass found

After the five builders finished and the integrator joined their work, I ran a review with four different angles, then a second round that tried to refute each finding. Findings that survived the refutation round became fixes. The total was 25.

I only have the count for the 25, not a list of what each one was. The log-reading traps from that day, such as a fork's copied transcript showing every teammate twice and one-shot runs looking like a resting team, are the subject of the previous post. One limit is still on my known-limits list: the one-line "result" under a finished request is the first sentence of the agent's last answer, and agents sometimes write short internal codes there that then show up on screen.

Two things went wrong in the process, not in the code. The workflow's own critique and fix steps failed because I hit a weekly usage limit, so I checked those parts by hand. And a few timing tests in the executor and file-watcher suites wobbled under load, though they passed when run alone. They are on the same known-limits list.

## I asked for a game and got three

I wanted the office to feel more like a game. I also asked to drop the phrase "my turn" for a request waiting on the user, because it read oddly. That became the brief for three skins on the same data contract. Only the screen code could change.

![Top status bars of three game UI variants: a cozy brown wooden frame, a navy management-sim bar with six counters, and a retro navy RPG bar with a double border.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/05-three-skins.png)

*Top bars of variants A (cozy sim), B (management sim) and C (retro RPG). Labels in Korean: "agents working", "finished requests", "hand-offs", "waiting for answer", "waiting for orders". Counts come from my own machine's logs, taken minutes apart, with team names cropped out.*

The brief also listed what to leave out: particle rain, rainbows, level-ups, rewards, token bragging, anything decorative that was not tied to a real event. Effects were allowed only when something actually happened, such as a "+1 done" floating over the lead when a request ended. The font is Galmuri, a pixel font under the OFL license, bundled with the app so nothing loads from a CDN.

I picked B, the management sim. The test count was 245 once it was in place, up from 224.

## Status words in plain sentences

The skin brief fixed the status vocabulary at five states: working, waiting for orders, needs your answer, not started, run ended. The words have drifted since. Today's game theme says "people working", "finished requests" and "waiting for confirmation" in its counters, and puts plainer sentences on top.

![Two Korean counters on a pixel-art bar showing 9 people working, 0 finished requests, 1 waiting for confirmation.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/05-counters.png)

*Counters in today's game theme: "people working 9", "finished requests 0", "waiting for confirmation 1". Public demo data.*

![A panel titled "Missions in progress" with the sentence "2 teams are working. 1 needs my answer", and a task row "Organize customer inquiry replies: needs my answer to continue".](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/05-status-sentence.png)

*A status sentence in the app: "2 teams are working. 1 needs my answer." The task name is sample data.*

One caution carried over from this version. A finished request card means the request ended. It does not mean the work succeeded. The app reads turn boundaries from logs, and a turn that ended badly still ends.

## A word I had to remove that evening

I had told the agents that workflow runs were not showing up properly on screen. They took it to mean that the structure and the roles were invisible, and answered with an assembly-line view (stages across, branches down) and nine role badges, added to the contract as a new section. Around 22:00 I told them the Korean word they had picked for the branches read strangely, and they removed that word from the code and the page.

I kept the view and the word had to go. Terminology on a screen is part of the product, and an agent will happily ship a word that only makes sense inside the contract.

## Results, with their limits

When P0 was done: 224 tests passing (245 after I picked the skin), a first load of about 2 seconds, and no request to anything outside 127.0.0.1 in the browser checks. The numbers are from my notes of that day's test and render runs.

They do not show that anyone can use the thing. My notes record no usability test with a non-developer, and 245 green tests say nothing about that.

Next up is a friends feature that I shipped to production and decided to drop on the same day. The app link will be in the last post of the series.

If you split one codebase across parallel agents, who owns the shared file, and do you use an integrator the way I did or let the agents merge each other's work?
