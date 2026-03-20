---
title: "605 Tool Calls: How I Rebuilt My Portfolio Into a Project Hub with Claude Code"
published: true
description: "605 tool calls, 355 Bash commands, one session. How I turned jidonglab.com from an AI news blog into a project portfolio hub — and three bugs that made it messy."
tags: claudecode, webdev, ai, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-20-portfolio-site-en
---

605 tool calls. 355 Bash. 99 Edit. 91 Read.

That's not a success metric. That's a record of what it looks like when a session doesn't run clean. I fixed the same bug three times. Hit a build timeout I didn't see coming. Spent three iterations on GitHub API errors that were all predictable from the docs. The number just reflects that honestly.

**TL;DR** — I converted jidonglab.com from an AI news aggregator into a project portfolio hub. One session: JSONL-based build log automation, a GitHub API-connected admin panel, a parallel-agent site redesign, and a build timeout caused by a component doing data fetching it had no business doing.

## The Problem: 11 Projects, 7 Visible

I had 11 git repos running locally. The portfolio showed 7. Build logs were written by hand, one at a time. The site was publishing AI news automatically every few hours — while everything I was actually building stayed invisible.

A visitor couldn't tell what I was working on. That was the problem.

I opened with a structured prompt:

```
Convert jidonglab.com from an AI news/blog site into a project portfolio hub.
I have 11 git projects locally, but only 7 are in the portfolio.
Build logs are generated manually.

Target flow:
1. Generate build logs via CLI
2. Manage projects + publish build logs from Admin
```

The site's `admin.astro` was a 58KB file. Claude read it and laid out a 6-step plan: create `project-registry.yaml`, update Content Collection schemas, write CLI scripts, add API endpoints, extend the Admin panel, wire up DEV.to sync. Then it ran 355 Bash commands to implement each step.

## The JSONL Pipeline That Writes Blog Posts From Code

It started with one line: "It'd be nice to generate build logs from JSONL sessions."

Claude Code stores every conversation locally at `~/.claude/projects/` as JSONL files — user prompts, tool calls, and results, all of it. Parse those files and you can reconstruct what happened in any session.

`parse-sessions.py` reads the JSONL, filters by project directory, and produces a structured summary. `generate-build-log.sh` sends that summary to the Claude API and gets back a markdown draft. Hook it into GitHub Actions and every `git push` can trigger an auto-generated build log.

This post is sourced from the same session data that pipeline processes.

One question came up during setup: what's the difference between a local cron job and GitHub Actions? Local cron only runs when your machine is on. For anything that needs to run reliably on a schedule, GitHub Actions wins.

## GitHub API Fails — Three Times in a Row

The Admin panel needed to commit project YAML directly to GitHub when settings changed. The GitHub Contents API handles this. The errors came in sequence, each predictable from the previous.

**403 first.** The Personal Access Token was missing the `repo` scope. Generated a new token.

**Then 409.**

```
src/content/projects/news4ai.yaml does not match 7cc02a8819f7f2704cbcdf17f10e0035c78abb6e
```

Updating a file through the GitHub Contents API requires sending the current file's SHA alongside the update. The code was using a stale SHA. Fix: `GET /contents/{path}` to fetch the current SHA first, then include it in the `PUT` request.

**Then 422.**

```
"sha" wasn't supplied.
```

Creating a new file means no SHA field at all — but the code was sending an empty string. Added a branch: check whether the file exists, and if not, omit the SHA field entirely.

I used a "keep fixing until it works" prompt and Claude iterated through each error. Looking back, all three failure modes were visible in the GitHub API docs. Reading the spec upfront and implementing to it would have cut the tool calls in half.

If you're ever doing GitHub Contents API work: new files → no SHA field, existing files → fetch current SHA first, always. The 422 and 409 cascades are both caused by getting that one thing wrong.

## The Same Bug Fixed Three Times

DEV.to is for English content. Korean build logs kept appearing there anyway.

First time: asked to remove them. Done. Next day they were back. Asked why. Got a fix. They appeared again.

The filtering logic was split across two places. The `publish-to-devto.yml` GitHub Actions workflow had a `lang` filter that wasn't working. The `sync-devto.ts` API layer had its own separate publish logic. Fix one, the other fires independently.

It only stopped after I explicitly said: "Build logs are jidonglab-only — confirm this is never going to DEV.to again." Both files were updated together, and it stayed fixed.

Claude Code focuses on the file it just changed. It won't proactively scan for duplicate logic elsewhere in the codebase. For constraints that actually matter, name the specific files involved. Repeat the constraint until all paths are confirmed closed. Don't assume that fixing the most obvious place fixed the problem.

## The Build Timeout I Didn't See Coming

After deploying, Cloudflare Pages killed the build mid-way:

```
Failed: build exceeded the time limit and was terminated
```

The culprit was `ProjectCard.astro`. The component was calling `getCollection('build-logs')` directly inside itself. Run the math:

- 9 project cards on the homepage
- Each calls `getCollection` at build time
- 24 build log entries in the collection
- 9 × 24 = **216 file reads** happening inside component renders

The fix: remove `getCollection` from `ProjectCard`, pass the build log data down from the parent component as props.

```
fix: remove getCollection from ProjectCard → build timeout resolved
```

It's a basic rule — components shouldn't fetch their own data. Data flows down. But this one passed all local builds just fine and only blew up in the Cloudflare Pages environment.

If you're using Astro with Content Collections, this is a real gotcha: calling `getCollection` inside a component is perfectly valid in development. It silently becomes a performance problem at build time when that component renders multiple times.

## Two Agents, Zero Conflicts

"Redesign the whole site. Projects should be front and center."

My workflow uses AgentCrow — an orchestration layer that dispatches multiple specialized Claude Code agents in parallel from a single prompt. It dispatched two agents:

```
🐦 AgentCrow — dispatching 2 agents:
1. @frontend_developer → "Homepage redesign — project-first layout"
2. @frontend_developer → "Base layout nav + footer improvements"
```

`index.astro` and `Base.astro` were edited simultaneously by separate agents. No merge conflicts — because they were working in different files.

One adjustment after the redesign shipped: "beta means it's already running, so it should probably be second." Final sort order: live → beta → in development → discontinued.

The rule for parallel agents is file-level separation. Two agents editing the same file concurrently will conflict. Before dispatching, split the scope at the file boundary first. If you've hit conflicts with multi-agent workflows before, this is almost certainly why — work was divided by feature instead of by file.

## What 605 Actually Measures

36 files changed. 18 new files created. 9 projects updated.

A large portion of the 355 Bash calls were `npm run build` and `tsc --noEmit` — verifying each code change before moving on. The build-verify loop is tedious. It also catches problems before they compound into something harder to untangle.

The GitHub API triple-fail was the opposite pattern: iterating against runtime errors instead of reading the spec. Give Claude an error message and ask it to fix-and-retry — it works. Give it the relevant section of the API docs and ask for a spec-compliant implementation — it works faster and produces cleaner code.

> Automation is the process of turning "how I built things" into a record that writes itself. While you're shipping, the blog catches up.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
