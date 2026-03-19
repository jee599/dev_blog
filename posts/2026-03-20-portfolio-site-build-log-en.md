---
title: "584 Tool Calls to Rebuild a Portfolio Site with Claude Code and Parallel Agents"
published: true
description: "584 tool calls, 98 hours. How I rebuilt jidonglab.com from an AI news site into a project portfolio hub — and what three GitHub API errors taught me about spec-first development."
tags: claudecode, webdev, ai, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-20-portfolio-site-en
---

584 tool calls. 98 hours and 38 minutes. Bash 352 times, Edit 92, Read 86.

This wasn't a redesign. It was an identity change. My personal site went from "AI news blog" to "solo dev project portfolio hub" — and the process surfaced three lessons I didn't expect.

**TL;DR** — In a single Claude Code session, I handled GitHub API integration, build log automation, a full site redesign, and plugin ecosystem expansion using parallel agents. There were plenty of mistakes. The mistakes were the most educational part.

## The Problem With an Invisible Portfolio

I had 11 git projects running locally. Only 7 were on the portfolio. Build logs were written by hand. The site was running on autopilot — auto-generating AI news every few hours — while the actual work I was doing stayed invisible.

The prompt I used:

```
Convert jidonglab.com from an AI news/blog site to a project portfolio hub.
I have 11 git projects locally but only 7 are registered in the portfolio.
Build logs are generated manually.

Desired workflow:
1. Generate build logs via CLI
2. Manage projects + publish build logs from an Admin panel
```

Claude broke it into 6 implementation steps: create `project-registry.yaml`, update schemas, write CLI scripts, build API endpoints, add Admin tabs, wire up DEV.to sync. It ran through 350+ Bash calls, one step at a time.

## Three GitHub API Errors, Back to Back

The most painful stretch was GitHub API integration. The goal: when a project's settings change in the Admin panel, write the updated YAML directly to GitHub. Simple concept. Three consecutive errors.

**Error 1: 403.** The Personal Access Token was missing the `repo` scope. Regenerated the token.

**Error 2: 409.**

```
src/content/projects/news4ai.yaml does not match 7cc02a8819f7f2704cbcdf17f10e0035c78abb6e
```

Updating a file via the GitHub API requires sending the current file's SHA. We were sending a stale one.

**Error 3: 422.**

```
"sha" wasn't supplied.
```

Creating a *new* file means you must not send a SHA. The code was sending one anyway. The create/update branching logic was missing entirely.

Claude fixed the code after each error. And watching the errors change in sequence made something clear: this was a predictable cascade. If we'd read the GitHub API docs first and implemented to spec, it would have worked on the first try. Asking Claude to "fix it and keep iterating until it works" got there eventually — but spec-first would have been twice as fast.

The lesson isn't "don't use Claude for API integration." It's "give Claude the spec, not just the error." When you're debugging an API, paste the relevant docs section into the conversation before asking for a fix. The error → fix → new error loop is avoidable.

## The Bug That Kept Coming Back

There was a separate, unexpected bug. Korean build logs kept appearing on DEV.to — a platform where I only publish English content.

I said "take down all the Korean posts from DEV.to." They came down. Next day, they were back. I said "I told you to remove that logic — why is it uploading again?" Fixed again. Back again.

The root cause: the filtering logic was split across two files. `publish-to-devto.yml` in GitHub Actions had a language filter that wasn't working correctly. And `sync-devto.ts` in the API layer had its own separate logic. Fix one, the other still fires.

It only resolved after I explicitly said "build logs are jidonglab-only — confirm this is never going to DEV.to" and both files were updated simultaneously.

Claude Code tends to focus on the file it just edited. It doesn't proactively scan for duplicate logic elsewhere in the codebase. For hard constraints — "never publish X to platform Y" — name the specific files, or repeat the constraint until every path is closed. Don't assume that fixing the most obvious file fixed the problem.

## Four Parallel Agents, One Redesign

"Redesign the whole site. Trendy and techy. Projects should be the main focus."

My site uses AgentCrow — an orchestration layer that dispatches specialized agents in parallel from a single prompt. It dispatched four agents:

```
🐦 AgentCrow — dispatching 4 agents:
1. @frontend_developer → "Redesign homepage layout — project-first structure"
2. @ui_designer       → "Redesign nav + footer in Base layout"
3. @ux_architect      → "Improve projects/index.astro"
4. @critique          → "UX critique of current design"
```

`index.astro`, `Base.astro`, and `projects/index.astro` were each assigned to a separate agent. The main thread received completion signals and coordinated next steps.

The homepage ended up with project cards as the primary content. Status-based sorting: live → beta → in development → discontinued. That ordering got a one-line adjustment afterward: "beta means it's already running, so it should be second."

The advantage of parallel agents is speed. The risk is context isolation — if one agent changes a Tailwind class and another agent doesn't know about it, conflicts happen. Dividing work at the file level prevents collisions. That's the single most important thing to get right before dispatching.

If you've ever tried multi-agent work and hit merge conflicts, this is usually why: work was divided by feature instead of by file. Feature-level parallelism sounds clean in planning. File-level parallelism actually works.

## Automating Build Logs from JSONL

This post itself is an example of the pipeline I built during this session.

Claude Code writes session data to `~/.claude/projects/` as JSONL files — one per session. I built a two-part pipeline: `parse-sessions.py` reads the JSONL and extracts session summaries, `generate-build-log.sh` calls the Claude API and produces a markdown build log from those summaries.

Registered in GitHub Actions to run every 6 hours. New session detected → build log auto-generated → committed to the repo.

The alternative was local cron. Local cron only runs while the machine is on. GitHub Actions runs on schedule in the cloud regardless. For anything that needs to be reliable, cloud scheduling wins.

## The Three Patterns Worth Keeping

By the end of 98 hours and 584 tool calls, three things consistently made work faster or slower:

**Name constraints at the file level.** "Don't publish Korean to DEV.to" said once wasn't enough. When a constraint applies to multiple files, name the files explicitly. Repeat the constraint until all paths are confirmed closed.

**Read the spec before iterating on errors.** The GitHub API 403 → 409 → 422 cascade was avoidable. Giving Claude an error and asking it to fix-and-retry works. Giving it the relevant API docs section and asking for a spec-compliant implementation is faster and produces cleaner code.

**Split parallel agent work by file, not by feature.** File-level task assignment prevents merge conflicts. Before dispatching multiple agents, map out which files each agent will touch. Overlap is a conflict waiting to happen.

These aren't Claude Code-specific lessons. They apply to any collaborative development — with humans or agents. The higher the parallelism, the more important the coordination discipline.

> A portfolio isn't built — it's shown. Automation was the work of making the showing happen automatically.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
