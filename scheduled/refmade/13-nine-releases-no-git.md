---
title: "Refmade Shipped Without Git: 2,764 Files in One Snapshot"
published: false
description: "Every Refmade build up to 0.3.2 shipped with no Git history. What I lost, how a second Mac copied source out of an installer, and 17 gitleaks hits."
tags:
  - git
  - ai
  - webdev
  - buildinpublic
series: "Building Refmade"
cover_image: "https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/13-cover.png"
---

On October 7 I asked an agent why Refmade was not on GitHub. The answer was short: it had never been in Git. Seventeen days of work, from September 20 to October 7, and every installer I had published up to 0.3.2, existed only as a folder on a laptop.

This is part 13 of "Building Refmade", a series about a desktop app I am building mostly with Claude Code and Codex. I plan, decide and review. The agents write most of the code. Refmade draws the Claude Code and Codex sessions running on your computer as an office, so you can see which sessions are working and which are waiting for you. It is an independent app, not affiliated with Anthropic or OpenAI. The UI is Korean right now; that changes later in this series.

## How a project goes 17 days without `git init`

Nobody decided to skip Git. The folder started on September 20 as a personal structure for organizing agents, not as a product. Nothing in it said "repository", so nothing ever asked for one.

I do have a standing rule that code gets committed and pushed automatically after verification. That rule runs inside repositories. This folder was not one, so the rule never fired and never complained.

Deploys hid the gap too. The website went out with the Vercel CLI straight from a local folder. For rollback I noted the previous deployment each time, so "go back" meant "redeploy the older deployment", not "check out an older commit". On September 24 I told Codex to wrap up because I was moving the work to Claude Code. The handoff note it wrote said, in plain text, that the folder was not a Git repository. Nobody acted on that line, including me.

The only version control I had was a tarball. Before the big office rewrite on September 25, an agent packed `_backup/cli-before-office-p0-2026-09-25.tgz`. That is a snapshot, not a history.

| Date | What existed | Where the history lived |
|---|---|---|
| Sep 20 | Agent team folder | Nowhere |
| Sep 25 | Before the office rewrite | One tarball |
| Sep 28 | Desktop app 0.2.x installers | File timestamps |
| Oct 1 | 0.3.0 and 0.3.1 public | Deployment list |
| Oct 2 | 0.3.2 public | Same |
| Oct 7, 21:44 | First commit | Git, finally |

## A second Mac, and source inside an installer

The strangest part came between October 1 and October 6. I had a second Mac where Codex worked on a separate line of experiments: an easier first screen, a model-and-effort router and some automation ideas. The latest source was not on that machine. It only had what had been installed.

The agent found a workaround. A packaged Electron app carries its own JavaScript, so the installed 0.3.1 build contained the app source. The agent copied 1,034 files out of it, confirmed the originals' SHA-256 hashes did not change, and built the experiments on that copy.

It worked, and it meant reading my own product back out of an installer.

On October 6 an agent searched GitHub for the real source. An older public repository with the same name holds a gallery site last touched in July, a completely different product that I had stopped working on. The desktop app was not there. The status recorded that day was "source location pending". On October 8 the experiments from the second Mac were merged into the main tree as one commit: `integrate easy-start workspace into Refmade desktop`.

The underlying problem was that two machines each held part of the work. As far as I can reconstruct it, my main Mac had the latest source but not the experiments, and the second Mac had the experiments but not the latest source. A branch and a remote would have given both a single place to meet. "Source location pending" is a strange status to write about your own product.

## The first commit

On October 7 an agent created a private repository and pushed, at my request. The first commit has 2,764 files and about 105 MB. It is one snapshot commit that says "start Git here", with no history behind it. The commit is dated October 7 and does not pretend to be older.

What I kept out mattered as much as what went in:

| Excluded | Why |
|---|---|
| `runtime/` | Run logs and 33 copies of old deployments, about 5.4 GB |
| `_e2e/` | End-to-end output that included a browser's cookies |
| `_backup/` | Tarballs of earlier states |
| `dist/`, `node_modules/` | Rebuilt by the build |
| Screenshots, raw generated images | Large |

The `.gitignore` groups its rules by what they protect against. An excerpt, with the comments translated from Korean and other lines left out:

```gitignore
# 1. secrets: env files, keys, credentials, token caches, browser profiles
.env
.env.*
credentials*.json
Cookies
# 3. run records, state, caches, build output
runtime/
_e2e/
_backup/
```

The cookie patterns have a reason. The end-to-end folder held a browser's cookies, so the browser-profile patterns sit in the file and `_e2e/` is ignored whole.

## 17 gitleaks findings

Before the push, gitleaks ran over the tree and reported 17 findings. Each one was opened and compared against its source. All 17 were fake values inside tests: JWT-shaped strings, token-shaped strings and invented key names used as fixtures. None was a real credential.

A scanner cannot tell a fixture from a leak, so the comparison is the useful part. I keep that step on every first push, even for a private repository.

## What I lost, and what I changed

The cost is history. I cannot restore the September 21 dashboard from Git, because Git starts on October 7. What remains of that day is file modification times and screenshots. The same goes for every 0.2.x and 0.3.0 to 0.3.2 build: I have notes and deployment records, not the diffs.

After the snapshot, the rhythm changed fast. The Git log shows 15 commits dated October 8 alone, the day five releases went out (that day is the subject of part 14). I could not have done that safely without being able to look at yesterday's state of a file.

Refmade was not the only one. The same day, 13 folders on my machine, this one included, went into private repositories, each with its own ignore file covering secrets, operational data, run logs and build output.

The standing rule is now stricter: any folder with work in it gets `git init`, a gitleaks pass and a private remote before it ships anything. Today the working tree tracks 3,062 files across 38 commits.

![Refmade decision card in the pastel theme, with a recommended answer highlighted](https://raw.githubusercontent.com/jee599/dev_blog/main/images/refmade/13-decision-card.png)
*Refmade 0.3.9, Korean UI, public demo data. A decision card: "Tell me just this", then "What tone should I use to reply to the customer?", with a highlighted "AI recommended: Kind and short" option. This is the app that the tracked files build.*

## What I would check now

Git was optional for me only because every other step (build, deploy, rollback) had a substitute that felt like version control. Tarballs and deployment lists do not give you diffs. A quick test: can you answer "what changed between yesterday's build and today's" without the person who built it?

For 17 days I could not do that reliably. Part 14 covers the releases that came right after, and the checks that caught bugs in them. The app link comes in the last post of the series.

If you work with agents that create files for you, when do you make the first commit: before the first line of generated code, or once there is something worth keeping?
