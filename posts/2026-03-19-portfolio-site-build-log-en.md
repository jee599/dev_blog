---
title: "Claude Code Logs Everything. I Built a Pipeline to Read Them."
published: true
description: "73 hours, 423 tool calls. How I parsed Claude Code's .jsonl session logs to auto-generate build logs and rebuilt jidonglab.com as a project portfolio hub."
tags: claudecode, ai, webdev, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-19-portfolio-site-en
---

73 hours. 423 tool calls. One Claude Code session.

I didn't plan to leave it running that long. I just kept working — kept adding features, fixing bugs, following threads. When I finally checked the session timer, it read 73 hours 53 minutes. Claude Code accumulates session time continuously unless you explicitly close the session. There's no idle timeout.

That number is also why this build log exists at all. I found it in a `.jsonl` file.

**TL;DR**: Claude Code logs every session to `~/.claude/projects/` as `.jsonl` files — user prompts, tool calls, file changes, everything. I built a pipeline (`scripts/parse-sessions.py` + `scripts/generate-build-log.sh`) to parse those logs and auto-generate build logs. In the same session, I rebuilt jidonglab.com from an AI news site into a project portfolio hub, connected 28 GitHub repos through the API, and added an admin interface for managing project visibility without touching code.

---

## The .jsonl Files You Didn't Know Were There

I stumbled on this by accident. Mid-session, I opened `~/.claude/projects/` for an unrelated reason.

It was full of `.jsonl` files. Every project, every session, every conversation — all recorded. User prompts, tool invocations, file diffs, assistant responses. A complete timestamped history of everything I'd asked Claude to do and everything it had actually done.

The build log use case hit me immediately.

I'd been writing build logs manually — sitting down after a long session and trying to reconstruct what happened. That workflow has two problems. It's tedious: you spend 20-30 minutes writing about work you just spent hours doing. And it's lossy: the interesting decisions compress into vague summaries. "Refactored the admin panel" isn't useful. The specific reason you chose one approach over another — that's what's worth recording.

The `.jsonl` files don't compress anything. They keep everything.

I asked Claude directly:

> "How can I use these .jsonl files to automatically generate per-project logs — prompts, file changes, tool usage?"

The output was `scripts/parse-sessions.py`. It reads the `.jsonl` for a given project, extracts all user-authored prompts, collects the list of files modified by Edit/Write tools, and counts tool usage by type. Piped through `scripts/generate-build-log.sh`, the parsed output becomes a structured Markdown build log — headings, tool usage table, prompt excerpts, and a timeline of what changed.

The pipeline doesn't replace editorial judgment. You still decide what context matters and what story to tell. But the raw material is already there. You're curating, not reconstructing.

No more manual archaeology. The session remembers. The script reads it. The log writes itself.

---

## "Why Can I Only See 7 of My 11 Projects?"

jidonglab.com started as an AI news aggregator with a blog attached. I added a portfolio section later, but it was duct-taped together — 11 active projects, only 7 showing in the portfolio, no way to manage visibility without editing Astro content files directly. Adding or hiding a project meant touching `src/content/projects/`, rebuilding, and deploying.

This was the core task for the session: turn jidonglab.com into a proper portfolio hub.

Three pieces: a project registry, GitHub API integration, and a rebuilt admin panel.

The registry lives in `scripts/project-registry.yaml`. Each entry maps a project to its local git path, slug, and branch — enough information for CLI scripts to locate the right repo and pull commit history. This file is intentionally CLI-only. It has no relationship to the Astro build process. Keeping it separate means scripts can use it freely without worrying about Astro's content pipeline expectations.

On the Astro side, I added a `visible` field to the projects collection schema in `src/content/config.ts`. Toggling a project's portfolio visibility is now a content operation — flip the field, the project appears or disappears. No code changes, no manual rebuild required beyond the content update.

The GitHub API connection was the ugly part. First attempt returned a 403.

> "github api error 403"

Obvious in hindsight: listing private repos requires a Personal Access Token with explicit `repo` scope. The token I'd configured didn't have it. I updated the permissions, retried, and got access to all 28 repos.

Seeing "9 registered, 28 on GitHub" in the admin panel was the moment the whole thing clicked. Nine projects deliberately added to the portfolio. Nineteen more repos — experiments, abandoned ideas, private tools — visible to me as context, invisible to visitors by default.

That gap between "on GitHub" and "in portfolio" is exactly the kind of thing that should be admin-controlled, not hardcoded.

---

## Working Inside a 58KB File

The admin panel is a single Astro file. At the start of this session it was already 58KB — months of accumulated feature work in one component. Tabs, modals, fetch calls, inline JavaScript for client-side interactivity.

I added two new tabs: Projects and Build Logs.

The Projects tab shows the registered/GitHub split, surfaces each project's metadata from the content collection, and lets me toggle visibility with a button that writes back to the YAML frontmatter. The Build Logs tab surfaces parsed session data — recent prompts, tool usage stats, modified file lists — directly in the browser without leaving the admin interface.

Tool usage for this section: Bash 248 times, Edit 72, Read 63.

The Read count tells the story. With a 58KB file, you can't drop it in context as a whole and expect consistent results. The workflow becomes: read a section, understand it, edit a specific part, read again to verify. That pattern repeated dozens of times across the session. Slow by absolute standards, but accurate — each edit had full context for the surrounding code.

Midway through, I hit a YAML parsing error when toggling project status from the admin panel. The bug was in the serialization logic — it was reconstructing YAML frontmatter incorrectly when the source contained nested objects, which caused the write to corrupt the file. Found the specific line, patched the reconstruction logic, confirmed the fix by toggling a test project back and forth a few times in the UI.

A good reminder: admin panel complexity scales nonlinearly with feature count.

---

## Korean Posts on DEV.to, and the Case for Context Isolation

While the portfolio work was running, I noticed something in the content audit:

> "Take down any Korean-language posts on DEV.to and check whether existing posts are properly set up for search visibility."

The auto-publish script that pushes build logs to DEV.to had been running without a language filter. Korean build logs were going to DEV.to alongside English ones. DEV.to is an English-first platform — Korean posts don't index well for the target audience, and they create a confusing experience for readers who land on them from search.

I pulled the Korean posts, then went through the existing English build logs and updated titles and tag sets for better search alignment. Specific technology names and concrete outcomes in the title consistently outperform generic descriptions.

The translation backlog was six Korean build logs that needed English counterparts. Sending that work to the same session would have been a mistake. Mixing translation and active implementation work in one context degrades quality in both directions — the translation gets less focused, and the coding work gets interrupted by the cognitive overhead of switching registers.

Instead, I used the `Agent` tool to spin up a dedicated translation agent:

> "Agent 'Translate 6 build logs to English' completed. All 12 files created successfully."

One agent, six source posts, twelve outputs — a DEV.to version and a Medium version for each post. The isolated context paid off. Translation quality was consistent across all six posts in a way it usually isn't when translation happens as a side task during a development session.

This is the clearest argument for multi-agent approaches in Claude Code: not just parallelism for speed, but **context hygiene**. A task that deserves its own focused context should get its own agent and its own context window. Mixing unrelated concerns in a single long session is a quality tax that compounds over time.

---

## CronCreate: Scheduling Inside the Session

After building the pipeline, I wanted it to run automatically:

> "Set up Claude Code scheduling to update build logs per-project every 6 hours, then post to jidonglab."

This was my first time using `CronCreate`. The difference from a local cron matters in practice.

`CronCreate` schedules run inside the Claude Code session context. That means they can execute prompts, use tools, and interact with files through the same interface as interactive work. A local cron can only run shell commands — it can trigger a script, but it can't continue a conversation or invoke Claude tools directly.

For the build log pipeline, the practical implication: a `CronCreate` job can run the parse script, review the output, make editorial decisions about what makes it into the final log, and push the result — all as part of the same scheduled task. A shell-based cron can only run the raw pipeline. It can't do the judgment layer.

A fallback `~/Library/LaunchAgents/com.jidong.build-log.plist` was also generated as a launchd-based local schedule for when the Claude Code session isn't active. The shell-based launchd job handles the raw data pipeline; the `CronCreate` job handles the full editorial pass when the session is live.

---

## Session Stats

Full tool breakdown:

| Tool | Count | Primary use |
|------|-------|-------------|
| Bash | 248 | git status, npm builds, API testing, curl |
| Edit | 72 | admin.astro, schema changes, components |
| Read | 63 | chunked reads of the 58KB admin file |
| Write | 19 | new files: scripts, YAML registry, build logs |
| Grep | 10 | pattern search across the codebase |

Total session time: 73 hours 53 minutes. Actual active work was spread across roughly a day and a half. The timer is wall time, not compute time — Claude Code keeps sessions open until you close them explicitly.

That 73-hour number is why I found this project entry so easily in the `.jsonl` files. It stood out in the session list. Which led to the pipeline. Which generated this build log.

The recursion is not lost on me.

> The logs are already there. All you need is a script to read them.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
