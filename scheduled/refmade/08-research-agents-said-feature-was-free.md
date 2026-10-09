---
title: "13 Research Agents Told Me My Feature Was Already Free"
published: false
description: "I had 13 research agents size my app idea and a second pass try to refute them. Both vendors ship the feature, so Refmade became a two-vendor dashboard."
tags:
  - ai
  - claudecode
  - startup
  - productivity
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/08-cover.png"
---

On the evening of 27 September, 13 research agents and a second pass that tried to refute them agreed on one thing. The feature I was about to build, a window where you tell Claude Code or Codex what to do instead of using a terminal, is already included in the apps people pay for.

Refmade is a desktop app I'm building that reads your Claude Code and Codex session logs and draws them as a pixel office. It is an independent project, not affiliated with Anthropic or OpenAI. Claude Code and Codex agents wrote most of the code at my direction; I planned, decided and reviewed. This is part 8 of the series. The UI is Korean right now; that changes later in this series.

## What I asked for

On 25 September I had cut the mini-homepages, guestbook, gifts and gacha draws and gone back to my original plan. On the evening of 27 September I wrote down what I wanted next: a desktop app with no work content sent to a server, the dashboard as the main thing and orchestration as an option. People who find the terminal hard should be able to type a request into the app and watch the work happen. Then I asked for market size, viability and targets.

The agents produced a memo with about 60 sources. Numbers in it carried one of six labels: measured, announced, reported, estimated, assumed or proposed. I recommend the labels more than any other part of the process. They made it obvious that the last steps of my market-size funnel were assumptions nobody had measured, so the high and low ends of the estimate differed by a factor of tens.

## What was already free

I rechecked the claims that matter most against the vendors' own pages while writing this post.

| Tool | What it covers | What it leaves out |
|---|---|---|
| [Claude Desktop, Code tab](https://code.claude.com/docs/en/desktop) | Sessions with their own history and folder, several in parallel in a sidebar | Claude only |
| [`claude agents`](https://code.claude.com/docs/en/agent-view) | Background sessions grouped by state (Needs input, Working, Completed and a few others); you can send new tasks | Terminal sessions appear only after you move them to the background; subagents are not listed as separate rows |
| [ChatGPT desktop app](https://learn.chatgpt.com/docs/whats-new) | Codex merged into the app on 9 July 2026, available on every plan with some feature limits | Codex only |
| [Pixel Agents](https://github.com/pixel-agents-hq/pixel-agents) | Pixel-art office for agents, MIT license, VS Code extension or `npx` | Claude Code is the only implemented integration; Codex is listed as roadmap |
| [Munder Difflin](https://github.com/chaitanyagiri/munder-difflin) | Electron app, MIT, runs a dozen CLIs including both of ours | The page does not say whether sessions started outside the app show up |

Pixel Agents had 9,419 GitHub stars when the agents counted on 27 September (GitHub API) and about 9.6k when I looked again for this post.

The business side was worse than the feature side. [Vibe Kanban announced its shutdown on 10 April 2026](https://www.vibekanban.com/blog/shutdown): "the vast majority are free users and we couldn't find a business model that we could get excited about." Tools in this area that individuals run locally were almost all free. The paid plans I found were mostly attached to cloud, team or remote features.

## The slot that was left

The memo's finding was that every first-party tool shows its own company's sessions. Reduced to a grid:

```
                    shows Claude sessions   shows Codex sessions
Anthropic apps              yes                     no
OpenAI apps                 no                      yes
Pixel Agents                yes                     not yet
Refmade (goal)              yes                     yes
```

The empty cell is one screen for both vendors, reading the logs both CLIs already write, wherever you started the session. The memo added a limit I should repeat: it found no tool in its search range that does this, and that is different from proof that none exists. Two free open-source session monitors already cover parts of the same ground, so the slot is narrower than the grid suggests.

The memo narrowed the gap to a combination of four things it could not find together in anything widely used. The tool works from logs alone, with no hooks installed, so it sees a session wherever it was started. It shows subagents and workflow steps as teammates. It is a native app on Mac and Windows. And it is in Korean. The memo also warned that the first point matters less than it sounds: from logs alone you can guess that an approval is pending, but you cannot answer it.

The pain was also thin evidence. The people complaining about losing track of tabs were individual developers, in posts with a handful of comments, and each of them had already solved it with a free tool. Nobody had measured how common the problem is. On the Hacker News thread for Munder Difflin, comments ranged from praise for being cute and useful to calling it cringe. I read all of that as a reason to keep the first version small.

## What I did with it

The memo recommended a first version that is only a free read-only dashboard, with the "do the work for you" part decided later, after a price test and a look at the terms. I did not follow all of that. I decided the first version is the dashboard plus a local way to send work, aimed at people who are uncomfortable in a terminal. That was why I wanted the app in the first place. The memo itself rated that part as mostly overlapping with the official apps, so I went in knowing it would not set Refmade apart. The app is free.

![A first-run screen in a pink and white pixel style. The title says to get an AI ready first. Two cards sit side by side: Claude Code with a green 'Ready' badge, and Codex with a yellow 'Login needed' badge and a login button.](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/08-setup-cards.png)

*The first screen of a late-September build, cropped; no user data is on it. Visible Korean text: "Let's get an AI ready first." / "Refmade is a window for handing work to the AI helper on this computer. Prepare just one of the two below." Claude Code: "Ready", "Works with a Claude account (Pro or higher plan) or pay-as-you-go. Ready to use. Logged in with a Claude account." Codex: "Login needed", "Works with a ChatGPT Plus or higher plan or pay-as-you-go. The amount you can use differs by plan. A login screen opens in your web browser. Log in, press Allow, and come back to this window; it confirms automatically." Button: "Log in". "You can do this later."*

The same evening I decided friend sharing was not needed, which is the reversal in post 6. Whether "send work" was technically possible through each vendor's supported interfaces was the next thing I checked, and post 9 covers that.

The memo listed risks. Two of them shaped the app.

- **Log formats.** Both CLIs write internal formats, and either can change between versions. The office depends on reading them.
- **Measurement.** The app has no telemetry and reports no usage. It only asks my server for the newest version number and, in the Mac build, for the settings of the ad boards that show my other services in the office view. So I have no usage numbers. Downloads and whatever people tell me are what I will have.

## What I would repeat

Label every number with its source type. Write down which recommendation you are overriding and why, so the override is on paper when the result comes in. Open the primary sources again before you publish a table.

The app link comes in the last post of the series.

If you run Claude Code and Codex side by side, how do you keep track of which session is waiting on you?
