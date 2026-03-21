---
title: "289 Tool Calls, 6 Sessions, and the Git Config Line That Blocked Vercel for 2 Hours"
published: true
description: "Built a 3-platform auto-publish pipeline with Claude Code. Then spent 2 hours debugging a Vercel block caused by a single git email mismatch."
tags: claudecode, automation, vercel, devto
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-22-portfolio-site-en
---

289 tool calls. 6 sessions. 5 projects running in parallel — designmaker, agentcrow, saju_global, spoonai, portfolio-site.

That's a normal day now. What wasn't normal: I spent 2 hours debugging a Vercel deployment block that came down to one line of git config.

**TL;DR**: The `auto-publish` skill I built takes one piece of content and fires it to three platforms simultaneously — spoonai.me (Korean), DEV.to (English), and Naver Blog (Korean HTML). The pipeline works. But before I could test it end-to-end, every push was being rejected by Vercel with a "Git author must have access" error. Root cause: global `git config user.email` set to the wrong account.

Session breakdown: Bash(127), Agent(38), Read(26), Edit(26) — 289 total.

## Publishing 4 Backlogged Posts in Under 5 Minutes

Four posts had been sitting in `src/content/build-logs/` — two on Claude Code channels architecture, two on dispatch and cowork patterns. Written. Never published.

I dropped the four file paths into Claude Code: "publish these to DEV.to."

Claude read each file, mapped them to the correct directory structure in my `dev_blog` repo, committed, and pushed. GitHub Actions picked it up and called the DEV.to API. All four went up as drafts.

Five minutes, start to finish.

Then I looked at the actual posts.

No SEO. No hooks. Titles were flat — no numbers, no outcomes. Descriptions explained the content instead of pulling the reader in. Bullet points everywhere (which my style rules ban). Tone was textbook, not personal.

Technically correct. Completely unremarkable.

I followed up: "Apply SEO, hooks, and all engagement techniques."

Claude's analysis: titles with no numbers → low click-through. Descriptions that explain instead of invite → no hook. Bullet points instead of prose → against the rules. No personal voice. Section headings that are neutral when they should create curiosity.

Then I dispatched 4 parallel agents — one per post — for simultaneous rewrites. The files don't share state, so there's no reason to run them sequentially. This is the multi-agent AI automation pattern at its most straightforward: independent tasks → parallel execution.

## Why Brainstorming Before Building Isn't Optional

The initial request was vague: "I want to drop one piece of content and have it go out to multiple platforms automatically."

Before writing a line of code, Claude ran the brainstorming skill. That step isn't optional when the requirements are fuzzy — it's what separates a pipeline that works from one that gets rebuilt halfway because the assumptions were wrong.

Brainstorming surfaced the questions that actually matter: What's the input interface — CLI, web, or Telegram? Which platforms, and how much of each is automatable? Where does image generation fit, and does it block the publish step?

The answers locked in the architecture before implementation started:

- Input: URL, keyword, or file (any of the three)
- Output: spoonai.me (Korean markdown) + DEV.to (English markdown) + Naver Blog (Korean HTML)
- Image generation: delegated to `dental-blog-image-pipeline`, which calls Gemini for illustrations and Playwright for capture — `auto-publish` calls this skill, doesn't duplicate it

Naver is the interesting constraint. No public API exists for Naver Blog. The automation goes through Cowork — a browser controller that watches `~/blog-factory/naver-queue/` and publishes one post per day using Chrome automation. Naver publishing isn't instant; it's a scheduled queue.

If I'd skipped brainstorming, this would have surfaced mid-implementation: "wait, there's no Naver API?" — and the whole structure would have needed rethinking with code already written. Instead, the Cowork approach was decided in the design phase, before a single file was touched.

Once the design locked, `writing-plans` decomposed it into tasks, then `subagent-driven-development` executed them. Each agent owned one file. Parallel, no conflicts.

## The Vercel Block That Was One Line Away

First real test: push to spoonai.me and watch it deploy.

spoonai.me showed 404. I opened the deployment logs:

```
Deployment Blocked
Git author jidongs45@gmail.com must have access to the team
jee599's projects on Vercel to create deployments.
```

My git commit author email was `jidongs45@gmail.com`. The Vercel project was owned by `jee599`. Vercel's deployment protection requires the git commit author to be a recognized team member — and that email wasn't one.

Here's the debugging path I actually took:

Push again → still blocked. Hit Redeploy in the Vercel dashboard → "This deployment can not be redeployed." Add team members through Vercel settings → still blocked. Push from a different GitHub account (`jidonggg`) → still blocked.

Every variation I tried targeted Vercel's team configuration. None of them worked, because the problem wasn't Vercel's configuration — it was my local git config.

```bash
git config --list | grep email
# user.email=jidongs45@gmail.com
```

Global `user.email` was set to `jidongs45@gmail.com` — an old account I'd never cleaned up. Every commit was being authored by an email Vercel had never seen.

The fix:

```bash
git config --global user.email "jee599-account-email@gmail.com"
```

One line. Two hours gone.

If you've ever wasted time debugging a Vercel deployment block, check this first. It's not in any error message; you have to know to look. I saved it to a Claude Code memory file (`feedback_vercel_deploy.md`): on any new repo connected to Vercel, verify `git config user.email` before the first push.

## What 38 Agent Calls in One Session Means

Bash at 127 calls is expected — git operations, terminal commands, file inspection. Agent at 38 is the more interesting number.

38 separate delegations to subagents: research tasks, parallel rewrites, isolated file edits. When tasks are genuinely independent, multi-agent dispatch is the right tool. Running them sequentially is just slower for no reason.

The session stretched to 22 hours 39 minutes because the Vercel debugging, the auto-publish skill design, and a pile of unplanned fixes all ran back to back. Long sessions create a specific problem in AI-assisted workflows: context compression. When a Claude Code session runs long enough, earlier decisions get summarized or dropped from context. You end up asking "why did we structure it this way?" and the reasoning isn't there.

The mitigation: write critical decisions to memory files during the session. That day produced three — `project_auto_publish.md`, `project_spoonai_admin.md`, `feedback_vercel_deploy.md`. The next session picks up with full context instead of reconstructing from git history.

The Vercel git email lesson is in memory. Next time I connect a new repo to Vercel, that's the first thing Claude will surface.

## The Pattern: Skills Before Code

What held everything together was a consistent sequence: use the skill stack before opening any file.

Brainstorming before auto-publish → Naver architecture decided before implementation, not during it. No mid-build redirects.

`writing-plans` before subagent dispatch → tasks decomposed into parallel-executable units with clear ownership and no shared state.

`subagent-driven-development` for execution → each agent owned exactly one file. No conflicts, no coordination overhead.

The skill stack functions as a forcing function. It makes you define what you're building — the constraints, the approach, the non-obvious decisions — before you start building it.

That's the opposite of what feels productive when you want to ship something. But skipping it means the "figuring out" happens during implementation, which costs more than figuring it out upfront.

> A finished pipeline means the next post isn't manual work anymore.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
