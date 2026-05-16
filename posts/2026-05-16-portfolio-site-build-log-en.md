---
title: "14 Tool Calls, Zero File Edits: Using Claude Opus 4.7 as a Pure SERP Analyst"
published: true
description: "2 sessions, 14 tool calls, 0 file modifications — how explicit prompt constraints turn Claude Opus 4.7 into a focused SERP analyst."
tags: claudecode, claudeai, promptengineering, aiautomation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-16-portfolio-site-en
---

The session ended with 14 tool calls, 0 file modifications, and genuinely useful output. No code was written. No files were touched. Just analysis — and it worked.

This is a record of two Claude Code sessions where the goal wasn't to build anything. It was to analyze a pile of SERP JSON and produce a tight synthesis. What made it work wasn't clever prompting — it was two explicit constraints most people skip over.

**TL;DR** Deploy Claude Opus 4.7 as a read-only analyst with a hard word limit and it will compress complex SERP JSON into a focused, actionable summary. The two constraints that actually matter: `Do not edit files` and a specific number like `Keep under 700 words`.

## The Problem: SERP Data That Piles Up Fast

I run a project that monitors Korean medical and dental advertising keywords daily. Every day, SERP data for around 10 keywords lands at `sources/serp-YYYY-MM-DD/summary.json` — structured JSON covering ad counts, positions, organic result counts, place ad presence, official Naver Ads notice tracking, and more.

A quick note on context: medical and dental advertising in Korea operates under strict regulations, and Naver — Korea's dominant search engine — is the primary battleground. Changes to ad formats, auction dynamics, or official Naver Ads policies can materially affect campaign performance for clinics running these ads. Tracking daily SERP snapshots across 10 representative keywords lets you catch pattern shifts early, before they affect campaign spend.

The challenge is purely operational. Each day's JSON is readable in isolation. Spotting meaningful patterns across days requires reading multiple files, holding context, and filtering out the noise. That's a task humans do poorly at scale and inconsistently at speed.

Passing it to Claude for synthesis was the obvious solution. The less obvious part was figuring out how to prompt it so the output was actually useful — not just comprehensive.

## Why Claude Tends to Over-Produce

Before getting into the sessions, it's worth being explicit about the failure mode this workflow is trying to avoid.

Claude's default behavior when given rich, structured data is to be thorough. It will surface everything it finds. It will cross-reference related files. It will produce a synthesis that's accurate and complete. And it will do all of this while trying to be helpful — which often means it also tries to improve what it reads.

If you ask Claude to "review" a knowledge base and "synthesize" what's there, it will often also reorganize an entry, update a stale hypothesis, or add a missing section. These are good instincts for a general assistant. They're disruptive instincts for a pure analysis session.

Two explicit constraints solve both problems: over-production and over-editing.

## Session 1: Cast a Wide Net

The first prompt was deliberately broad. I wanted to see what Claude would surface with minimal constraints:

```
You are reviewing today's Korean medical/dental ads daily research data.
Read sources/serp-2026-05-16/summary.json and the existing rolling
KB/source-index/SERP/hypotheses files. Give a concise Korean synthesis:
(1) new official changes, (2) SERP repeated patterns,
(3) what files should be updated,
(4) whether an HTML report is justified.
Do not edit files.
```

`Do not edit files` was the only hard constraint. Everything else was open-ended.

Claude ran 9 Bash commands: it parsed the SERP JSON, listed directory contents to find the KB files, read through the existing knowledge base and hypotheses, cross-referenced the running patterns, and assembled a structured synthesis. No human intervention. No guided steps. Just: here's what to read, here's the format, don't touch anything.

Output: a thorough multi-point synthesis. Accurate. Useful. Long.

The problem was "concise" — my word, my vague instruction. What "concise" means when you've read a dense JSON file and cross-referenced five KB files is not the same as what it means to someone reading the output on a phone. Claude honored the spirit of the word but set the threshold at "comprehensive synthesis" rather than "quick briefing."

That's on the prompt, not on Claude. Session 2 fixed it.

## Session 2: Narrow the Scope, Define the Output

Before running session 2, I made two targeted changes:

1. Added `only` to scope the input to just `summary.json` — no KB cross-referencing
2. Replaced `concise` with `Keep under 700 words` — a number, not an adjective

The prompt:

```
Read sources/serp-2026-05-16/summary.json only.
Output Korean bullet synthesis with:
new official Naver Ads notices, medical/dental relevance,
SERP pattern across 10 keywords, HTML-report yes/no.
Keep under 700 words.
```

The behavioral change was immediate and measurable.

`only` eliminated the exploratory phase. Claude didn't scan the KB directory, didn't cross-reference the hypotheses, didn't look for related files. It opened `summary.json`, read it, and synthesized it. One input, one output.

`Keep under 700 words` forced prioritization. Claude had to distinguish between what was *significant* and what was merely *present* in the data. That distinction — significant vs. present — is exactly what makes an analysis useful. Most of what's in any given day's JSON is stable, expected, unremarkable. The useful synthesis surfaces the 20% that changed.

Tool call count: 4 Bash + 1 Read = 5 total. Session 1 needed 9 Bash calls alone. The reduction came from two sources: narrower scope (no KB reading) and Claude already knowing the JSON structure from session 1. That structural context carried over even though the sessions were independent prompts.

## What Claude Found on May 16

Three findings from the synthesis:

### Naver Place Ad Inventory Expansion Test

Official Naver Ads notice: testing expanded place ad display inventory, with restaurant-category businesses as the initial rollout. Direct impact on dental/medical: none yet. Restaurants are the test case.

But the signal matters beyond the immediate category exclusion. Naver has been gradually expanding place ad real estate for months. If the restaurant test succeeds, the expansion will likely reach other local business categories. Dental clinics, which rely heavily on local search traffic, are an obvious subsequent target. Filing this as a directional signal worth tracking — not an immediate action item.

### No Significant SERP Pattern Changes Across 10 Keywords

Ad counts were stable. Position distribution was consistent with prior weeks. No anomalies in organic result composition. No new SERP features appearing or disappearing. A stable day in a volatile landscape is itself a data point worth recording.

### Self-Determined: HTML Report Not Needed

This was the most interesting output from the session, and it deserves more than a line in a table.

The prompt explicitly asked Claude to make a binary judgment: is an HTML report justified today, yes or no? Claude said no. One official notice with no immediate medical advertising impact, no pattern changes, no anomalies. The threshold for "report-worthy" wasn't met.

Here's why that matters: a daily analysis workflow that generates a report every day trains you to ignore the reports. If every session produces an artifact, the artifact stops carrying information. Its presence tells you nothing about whether something important happened. Claude's judgment here — that the threshold wasn't met, so nothing should be produced — is the correct behavior for a system that's supposed to flag significant changes, not just acknowledge that today happened.

Teaching a model to not produce output when output isn't warranted is one of the harder calibration problems in LLM workflows. This prompt got it right.

## Tool Call Stats

| Tool | Session 1 | Session 2 | Total |
|------|-----------|-----------|-------|
| Bash | 9 | 4 | **13** |
| Read | 0 | 1 | **1** |
| Edit | 0 | 0 | 0 |
| Write | 0 | 0 | 0 |

**Files modified: 0. Files created: 0.**

The Bash-heavy distribution is expected. JSON parsing, directory listing, content searching across the KB — all of that runs through Bash in Claude Code. The single Read call happened in session 2 when Claude needed to open a specific file directly after Bash exploration had already identified it.

The zero Edit/Write count is the whole point of this build log. A pure analysis session should not produce file artifacts unless there's a justified reason to. In this case there wasn't. The workflow maintains a clean separation between "data in" and "analysis out." Everything that happened is fully reversible — because nothing happened to the files.

## Three Rules That Changed the Output

### 1. Numbers beat adjectives for output constraints

`concise` is a preference. It's context-dependent and model-dependent and varies with every run. `Keep under 700 words` is a mechanical constraint. Claude can count. It will enforce the limit.

This generalizes: whenever you need bounded output — a specific number of bullet points, a maximum section length, a word limit — express it as a number. Adjectives describe what you want. Numbers define the boundary the model can't cross.

### 2. `Do not edit files` is a required line for read-only sessions

Without this constraint, Claude will improve things it notices. It'll update a stale KB entry. It'll add a missing hypothesis. It'll reorganize a section that's getting long. These might be correct improvements, but they're side effects you didn't ask for. They make the session harder to audit and the state harder to reason about.

One line eliminates the entire category. If you're running a read-only session, say so. The absence of edit instructions does not imply read-only behavior — Claude's default is to be helpful, and helpful often means making changes.

### 3. Session 1 explores; session 2 extracts

Don't try to write the perfect prompt on the first attempt. Use session 1 to explore broadly: let Claude read widely, understand the data structure, and surface what's actually there. Then look at that output, identify what was useful, and write a narrower session 2 that asks for exactly that.

Session 2's Bash count dropped from 9 to 4 because session 1 had already established the JSON schema and directory structure. That structural knowledge carried over into a faster, more targeted run. The improvement wasn't from a better prompt in isolation — it was from two sessions building on each other.

This is a composable pattern. A broad exploration session followed by a narrow extraction session beats a single over-engineered prompt most of the time.

## The Pattern Beyond SERP Data

The workflow here — Claude as read-only analyst, constrained from editing, with a hard output limit — is portable.

Any situation where you have structured data that needs synthesis benefits from it. Logs from a distributed system. Monitoring output from a production service. API response archives you're trying to make sense of. Database query results you need summarized. The specific domain doesn't matter. The pattern does.

The constraints don't limit Claude's analytical capability. They shape the output format so it's actually usable rather than merely thorough. There's a meaningful difference between a tool that produces accurate output and a tool that produces actionable output. Word limits and read-only constraints close most of that gap.

One session. Two constraints. Zero files modified. Useful output. That's the entire method.

## What I'd Do Differently

One thing I'd change: session 1's prompt asked Claude to identify "what files should be updated." That question primed it to think in terms of producing changes, which is the opposite of what I wanted. Even with `Do not edit files` present, the question introduced a frame that wasn't useful.

A cleaner version of that prompt would ask "what observations are worth tracking" instead of "what files should be updated." The former is analyst thinking; the latter is editor thinking. When you want pure analysis, every part of the prompt should reinforce that frame — not just the explicit constraint at the end.

The other change: I'd run the narrow session (session 2) first next time. Starting broad produces useful exploration, but for a daily workflow where the data structure is already known, the wide sweep is often unnecessary. The 9 Bash calls in session 1 were doing structural discovery that could have been skipped on day two of running this workflow. On day one, explore. After that, go straight to the narrow prompt.

---

*tool calls: 14 (Bash×13, Read×1) · sessions: 2 · files modified: 0 · model: claude-opus-4-7*

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
