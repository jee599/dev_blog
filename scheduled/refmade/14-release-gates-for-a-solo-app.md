---
title: "5 Releases in One Day: Release Gates for a Solo App"
published: false
description: "Five Refmade releases on October 8. The packaged smoke test, injected regressions, a screenshot freshness check and a fact sheet that caught a false claim."
tags:
  - testing
  - electron
  - ai
  - webdev
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/14-cover.png"
---

On October 8 I shipped five releases of a desktop app, 0.3.3 through 0.3.7, from a first commit at 17:43 to a last deploy at 22:16. Twice in three days the packaged build was broken while the regular tests were green. This post is about the checks that caught those bugs, and the one that caught a false sentence in my own draft of the website copy.

Part 14 of "Building Refmade". Refmade is a Korean-language desktop app (the UI is Korean right now; that changes later in this series) that draws your local Claude Code and Codex sessions as an office. It is an independent app, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction. I planned, decided and reviewed. Part 13 covered the day I found the project had no Git history, which is why this day has a commit log at all.

## The day

The Git log has 15 commits dated October 8. Five of them ended in a release:

| Version | Commit time | Change |
|---|---|---|
| 0.3.3 | 17:43 | Office banners for my other services (no off switch) |
| 0.3.4 | 20:18 | Tools shown inside the conversation |
| 0.3.5 | 21:21 | Refreshed game-style office, decision modes |
| 0.3.6 | 21:44 | Simpler wording for automatic mode |
| 0.3.7 | 22:15 | Icons and numbers readable inside their cards |

The last two came out of a feedback loop. I asked for simpler automatic-mode wording, and that became 0.3.6. Then I looked at the app at its real size. At 21:46 I wrote that the automatic-mode artwork looked crowded and that the pastel office's numbers crossed their card borders. The fix went out as 0.3.7 at 22:16. Each fix went out as a new version. A published installer is never overwritten.

![Pastel office status bar in 0.3.6 (top) and 0.3.7 (bottom): the numbers 9, 0 and 1 sit on the card border in 0.3.6 and inside the cards in 0.3.7](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/14-counters-before-after.png)
*The pastel office's top bar in 0.3.6 (top) and 0.3.7 (bottom). Korean UI, public demo data. Left to right: "My office / tap an area to see that task big", then counters "9 people working", "0 finished requests", "1 answer needed from me", and a clock. In 0.3.6 the digits ride the card edge. In 0.3.7 they sit inside.*

For 0.3.7 the agent measured the glyph ink instead of eyeballing it: at least 8.14 px of clearance above the digits and 7.8 px below, in both themes at three window widths. App tests were 446/446.

## Gate 1: the packaged app, not the test runner

The most useful check I have is boring. After building the installer, a smoke test launches the packaged app and clicks through the first screens.

In 0.3.5 it found that the legacy "easy workspace" screen requested a shared module the local server would not serve. The server only answers an allowlist of routes, and one needed file was not on it. The regular tests had not caught it. The fix was to allow the module, CSS and image routes, plus a regression test that walks the whole module graph over HTTP and still rejects unlisted paths.

On October 10, preparing 0.3.9, the same smoke test found the same class of bug. A new file, `signals.mjs`, was not served to the workspace, and the screen stayed on "Opening the workspace..." with no way forward. `npm test` had not run the workspace suite at all. The fix was one line in `app/workspace/server.mjs`, then `test:workspace` passed 80/80.

Two misses in two days, both caught by the packaged build. I take that as evidence that the check pays for itself, and as evidence that my unit suite has a blind spot.

## Gate 2: tests that fail on purpose

An all-green suite can be all-green because it checks nothing. For 0.3.9 an adversarial review found one P1 and nine P2 issues, all fixed. Then the agents injected regressions deliberately: break the behavior, run the suite, confirm a test goes red. The suite caught all 23 injected regressions.

This is a mutation check, and it is why I treat "464 of 464" as a statement about the code and not just a number. It still says nothing about whether a person can use the app. I have not run a study with non-developers, and the release notes say so.

## Gate 3: screenshots go stale, so the build fails

Each release page on the site shows real app screenshots. They are taken by a script in a hidden Electron window with public demo data, so nobody's real sessions are on them. The risk is old screenshots next to a new version.

So the release check hashes the app's visual source and compares it with the hash recorded when the screenshots were taken:

```js
// dashboard/deploy/release-presentation.mjs (abridged)
for (const folder of ['main', 'renderer', '../cli/office-app']) {
  // ...read every file under the folder, sorted by path...
  for (const file of files) digest.update(`${folder}/${file}\0${sha(await fs.readFile(path.join(base, file)))}\n`);
}
// ...
if (manifest.visualSourceSha256 !== await visualSourceDigest(appDir))
  throw new Error('Release presentation: app source changed; recapture the actual app before shipping');
```

If I change the renderer and forget to recapture, the deploy build fails. The capture scripts also assert the digest did not change while they were running. One small bug turned up on the way: the release date `2026.10.10` matched the existing `x.y.z` version regex, so dates now use Korean date formatting.

![A release-notes card for Mac 0.3.9 dated October 10, 2026, listing three changes about animated text](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/14-release-notes.png)
*The release-notes card on the site. Korean text. Headline: "When I need your answer, the letters hop." Items: "Added: my turn gets color and two hops", "Added: a wave while working", "Changed: news pops once". Below: "This update is for Mac. The public Windows version is 0.3.2." The right panel shows a demo decision card.*

## Gate 4: a fact sheet that found a false sentence

On October 10 I had the agents rewrite the site copy for non-developers. Before shipping it, an agent built a fact sheet: every claim in the draft next to the line of code or doc that backs it.

Two claims failed. "You never open a terminal" was false, because installing Claude Code means pasting one line, and Codex needs Node.js first. The bigger one was the automatic-mode safety wording, which was broader than reality:

- Codex runs in a mode that edits files inside the chosen folder, usually without showing an approval card. One doc says automatic approval of file work. Another says the app never auto-approves anything on its own. The code is closer to the second.
- The "let the AI handle it" setting is a switch that answers light multiple-choice questions with the AI's recommended option, using word rules, up to 20 times. It has nothing to do with permissions. In a test, the question "Post this wording on the homepage?" with an option "Post it (recommended)" went straight through.
- The app tells the AI to stay in the folder and not deploy, send mail, charge money or edit databases. That is an instruction in a prompt. It does not block anything.

The draft was rewritten before it shipped. Automatic mode is a convenience switch and I describe it that way now. A test count cannot show this kind of mistake. A sentence cannot be tested; it has to be traced to code.

## What I did not fix

Four things from those days stayed open, and the release notes say so. A report of a stray Claude sign-in window in 0.3.6 could not be reproduced from the exact screen I saw, so the notes do not claim a fix. One CLI timing test failed once under load (38 ms against a 50 ms limit), passed 9/9 on its own, and is recorded as timing-sensitive. Two workspace browser tests (a timeout and a missing local server) were already failing before the 0.3.9 change and are listed as known failures, which is why I quote the 464 and not "everything". A Windows 0.3.8 installer was cross-built but never run on a Windows machine, so the public Windows build is still 0.3.2.

Also on October 10, 0.3.9 added text signals so that the app tells you when it needs you: words hop when an answer is waiting, letters wave while the AI works, and news pops once. Both the app window and the embedded office start their loop from the wall clock, so the two beats land within 16 ms of each other, and reduced-motion settings turn the movement into a color change.

The app link comes in the last post of the series.

If you ship alone, which check has caught the most bugs for you: the packaged-build smoke test, deliberate regressions, or a review of what the page claims?
