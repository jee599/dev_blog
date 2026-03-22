---
title: "4 Sessions, 0 Tool Calls, 1 Config Fix: Debugging Claude Code When the Agent Won't Start"
published: true
description: "An expired API key silently killed 4 Claude Code sessions before a single tool call fired. Here's what zero tool calls means—and how to diagnose it fast."
tags: claudecode, ai, debugging, automation
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-03-22-saju_global-en
---

Four Claude Code sessions opened. Four sessions closed. Zero tool calls across all of them.

**TL;DR** An expired external API key blocked the `saju_global` automation pipeline entirely. Claude Code couldn't read a file, run a search, or write a single line — not because the agent was broken, but because the environment it needed was already down. The fix was one config value. Getting there took four wasted sessions and a hard look at my debugging instincts.

## A Workflow That Looked Like It Was Running

On 2026-03-22, I triggered the automated build-log generation workflow for `saju_global`. The job: analyze recent commits, produce Korean and English build logs in `build-logs/`, optionally draft a blog post. This workflow had run successfully before. Nothing in the code had changed.

Session 1 started. Session 1 ended. No files written.

I assumed it was a fluke — prompt didn't land right, maybe a transient issue. Session 2, same setup, same task. Same result: nothing. No output, no error message in any obvious place, no indication of what had gone wrong. The session just closed.

Sessions 3 and 4 were me repeating the same steps because I didn't know what else to do. All four sessions shared the same label in the logs: `Invalid API key · Fix external API key`. That label was both the symptom and the diagnosis, and I had glossed right over it.

## What `tool_calls: 0` Actually Means

This is the most important diagnostic signal in this incident.

When a Claude Code session ends with zero tool calls, it's not a vague failure — it's a specific one. The agent received the prompt, processed it, and stopped before taking any action. No file reads, no searches, no writes, no shell commands. The session opened and closed without leaving a mark on anything.

This is different from a session that fails partway through — where you'd see some tool calls, then an error, then termination. Zero tool calls means the agent never got started. Something blocked execution before the first action.

In `saju_global`, the agent's first meaningful action requires authenticating against an external API. The project routes saju (Korean four-pillar fortune analysis) data through an LLM API to produce interpretations. That API sits between Claude Code's intent and the actual execution path. When authentication fails at that layer, there's no graceful degradation — the session hits a wall and stops.

You can think of it as a locked door with no handle on the inside. The agent can see the task, can understand what needs to be done, but can't step through.

## The Retry Trap (And Why I Fell Into It)

There's a debugging habit that breaks down in automated pipelines: when something fails and you don't understand why, retry it.

In interactive debugging — running a test locally, calling an API from the terminal — retrying after a transient failure makes sense. Networks hiccup. Rate limits clear. Caches expire. Retrying costs little and sometimes resolves the issue without further investigation.

In an automated pipeline with Claude Code, this habit is expensive. Each session retry burns time, costs tokens, and produces no new information if the underlying environment issue hasn't changed. I ran four sessions before looking at the actual error. The pattern went:

1. Session fails → cause unknown → retry
2. Session fails → assume transient → retry
3. Session fails → check if prompt was wrong → retry
4. Session fails → actually look at logs

The error was visible in the logs from session 1. `Invalid API key` is not a subtle message. I just wasn't looking there first.

The corrected habit: **when a session ends with zero tool calls, open the session logs before touching the prompt**. The diagnostic information is already there. Retrying without diagnosing is not a debugging strategy — it's just expensive noise.

## The Fix Was One Line

Once I identified the root cause, the fix took about thirty seconds.

The external API key registered in the project's environment variables had either expired or was set to an incorrect value at some point. Updating it — in `.env` locally and in Cloudflare Pages environment variable settings for production — immediately restored normal operation.

Zero lines of code changed. One config value updated.

| Item | Before | After |
|------|--------|-------|
| External API key status | Expired / invalid value | Valid key restored |
| Tool calls per session | 0 | Normal execution |
| Automation workflow | Failed (4 sessions) | Recovered |

## What This Changes About How I Monitor AI Automation

The failure pattern here is easy to miss in a standard monitoring setup. There was no thrown exception, no HTTP error in a server log, no failed job with a non-zero exit code. Four Claude Code sessions ran and completed — *technically successfully*, from a process-monitoring perspective — while producing nothing.

This exposes a gap in how I was thinking about automation health: I was monitoring whether the *orchestration* ran, not whether the *agent* did anything.

Going forward, `tool_calls: 0` on a session that should have done work is an alert condition, not a normal result. Two monitoring changes this incident points to:

**1. Session output sanity checks.** After any automation session runs, verify that expected output was produced. For build-log generation, that means checking that new files exist in `build-logs/`. If they don't, something failed silently.

**2. Environment health checks before agent execution.** A lightweight API key validation at the start of each session — a single authenticated request that confirms the key is valid. If this check fails, surface the error immediately rather than letting the session proceed into a dead end.

Neither of these is technically complex. Both would have caught this incident at session 1 instead of session 4.

## Agent Failure vs. Environment Failure

There's a distinction worth internalizing if you're building automated AI pipelines.

**Agent failure** is when Claude Code has a working environment but produces wrong output — bad reasoning, incorrect file edits, misunderstood instructions. You debug this by examining prompts, context, and tool call results.

**Environment failure** is when the environment Claude Code depends on is broken before the agent gets to act — bad API keys, missing env vars, unreachable services. You debug this by checking dependencies, not prompts.

The diagnostic signal that separates them is `tool_calls: 0`. An agent that fails mid-execution leaves tool call traces. An agent that never got to execute leaves none.

When you see a session end at zero tool calls on a task that should have produced work, don't reach for the prompt editor. Reach for the logs and check your environment health first.

> Silent failures in automation can be worse than no automation at all. At least without it, you'd know the work wasn't done.

Four sessions. Zero tool calls. One config fix. The ratio of wasted effort to actual work was completely lopsided — and entirely avoidable with the right diagnostic instinct.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
