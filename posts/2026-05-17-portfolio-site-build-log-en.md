---
title: "14 Tool Calls, Zero Code Written: Claude Opus for Daily Medical Ad SERP Analysis"
published: true
description: "Read-only Claude Code sessions: 13 Bash, 1 Read, 0 file edits. How I use Claude Opus to synthesize Korean medical ad SERP data in under a minute."
tags: claudecode, ai, promptengineering, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-17-portfolio-site-en
---

Yesterday's two Claude Code sessions generated 14 tool calls. Not a single file was modified.

That's the whole story — except for the part about what those 14 calls actually accomplished and why this read-only pattern is one of the more underrated ways to use Claude Code.

**TL;DR**: A read-only research pipeline using Claude Opus 4-7 to analyze Korean medical/dental advertising SERP data. No code written — just fast synthesis of accumulated JSON files. 13 Bash calls, 1 Read, 0 edits.

## The Problem Nobody Wants to Solve Manually

The `dental-ad-ops` project runs a daily SERP crawler against Naver — Korea's dominant search engine, where medical advertising operates under strict legal and platform constraints. Think of it as a stricter version of Google Ads' medical advertising policies, layered on top of Korean healthcare advertising law (의료법 제56조).

Every day, files accumulate in `sources/serp-YYYY-MM-DD/summary.json`: ad placements by keyword, official Naver Ads policy notices, industry-specific patterns across 10 tracked keywords. A typical file contains:

- Top 3 ad positions for each of 10 dental keywords
- Whether Naver's official advertising team has issued any new medical/dental notices
- Changes in ad format types (text ads vs. Place Ads vs. Smart Store integrations)
- Competitive positioning signals

Reading through all of this manually every morning takes 20–30 minutes — *if* you know what to look for. The tricky part is that significance often requires context. A "Place Ad inventory expansion test in the restaurant category" sounds completely irrelevant to a dental clinic. Until you know that Naver historically rolls out new ad formats vertically-first before broadening, at which point it becomes a leading indicator worth tracking.

That cross-referencing context lives across multiple KB files that have been building over weeks: `KB/serp-patterns.md`, `KB/hypotheses.md`, `KB/source-index/`.

The solution isn't more automation scripts. It's handing the reading and cross-referencing to Claude.

## Why Claude Code Instead of the API?

The obvious question: why use Claude Code for this rather than a proper API pipeline?

A few practical reasons:

**File access is built-in.** Claude Code reads `sources/serp-2026-05-16/summary.json` directly with a Bash command. No auth setup, no file-serving layer, no API wrapper. For analysis sessions, this zero-friction access is faster than building an API pipeline.

**Iterative prompt refinement.** I can see the output, adjust the prompt, and rerun in the same session. API-based pipelines require code changes to adjust behavior. During the prompt design phase, that iteration speed matters.

**Local KB context.** The rolling knowledge base files live in the project directory. Claude Code reads them natively — no data pipeline needed to get KB context into the prompt.

The tradeoff: Claude Code sessions aren't easily schedulable. For daily automation, a script calling the Anthropic API directly is the right end state. These sessions are useful during setup, validation, and days when I want to actively interrogate the data rather than passively receive a briefing.

## Session 1: Wide-Context KB Synthesis

Here's the exact prompt from the first session:

```
You are reviewing today's Korean medical/dental ads daily research data.
Read sources/serp-2026-05-16/summary.json and the existing rolling KB/source-index/SERP/hypotheses files.
Give a concise Korean synthesis:
(1) new official changes,
(2) SERP repeated patterns,
(3) what files should be updated,
(4) whether an HTML report is justified.
Do not edit files.
```

Four things are doing work here.

**Role framing before file access.** Telling Claude it's reviewing Korean medical ad data gives it the domain lens before it reads anything. Without it, Claude approaches `summary.json` as generic JSON. With it, a restaurant-category ad test gets correctly interpreted as a dental-relevant signal.

**Explicit file scope.** Named files and categories, not open-ended "look around the project." Claude is thorough by default — explicit scope prevents useful-but-unnecessary exploration.

**Structured four-point output.** Predictable structure makes the response scannable. Free-form analysis requires more cognitive load to process.

**`Do not edit files.`** — the most important line.

Claude Code's default orientation is action. Left unconstrained, it will write output to files, create summary documents, generate structured reports. This is the right behavior when you're building something. When you want analysis piped to your terminal, it's overhead you didn't ask for. The explicit constraint keeps the session clean.

This session used 9 Bash calls:
- `cat sources/serp-2026-05-16/summary.json` — read the day's data
- `ls KB/` — enumerate KB files
- Multiple `cat` calls on KB files (serp-patterns.md, hypotheses.md, source-index entries)
- `jq` to extract specific fields from the JSON

Completed in under a minute.

### What Wide Context Catches

Reading the full KB alongside fresh SERP data lets Claude catch multi-file patterns that single-file analysis misses.

The Naver Place Ad restaurant expansion is the concrete example from this session. Isolated, it's a restaurant story. Cross-referenced against the KB hypothesis that Naver is systematically expanding Place Ad formats across verticals, it becomes a dental-relevant signal to monitor. That connection requires context that doesn't exist in any single file.

## Session 2: Fast Daily Check Under 700 Words

The second session tightened the scope considerably:

```
Read sources/serp-2026-05-16/summary.json only.
Output Korean bullet synthesis with:
new official Naver Ads notices, medical/dental relevance, SERP pattern across 10 keywords, HTML-report yes/no.
Keep under 700 words.
```

Three deliberate changes from Session 1:

**`summary.json only`** — no KB files. When I already have rolling context in my head from earlier in the week, I don't need Claude to re-derive it. I need today's delta summarized fast.

**`HTML-report yes/no`** — binary decision at the end of the prompt. The pipeline has a downstream step: generate an HTML stakeholder report when SERP patterns shift significantly. Asking for a binary decision makes that call explicit and actionable, rather than leaving it implicit in the analysis.

**`Keep under 700 words`** — without this, Claude produces thorough output. Thorough is generally correct but wrong here. A word cap forces prioritization and cuts hedging.

Key findings from this session:

- **Naver Place Ad inventory expansion test** in restaurant verticals. Not immediately actionable for dental, but consistent with the broader Place Ad expansion pattern — worth a flag in the KB.
- **Brand Search PC schedule change** effective 2026-05-11. Dental clinics running brand keyword campaigns should verify their campaign schedules haven't been silently affected.
- None of the 10 tracked dental SERP keywords show direct medical/dental targeting changes from Naver's side.
- **HTML report decision: No.** No significant pattern changes. Daily briefing is sufficient.

4 Bash calls, 1 Read. 5 tool calls total. About 1 minute.

## The Read-Only Claude Code Pattern

Combined: 13 Bash, 1 Read, 14 total tool calls. Zero files modified or created.

This is a specific usage pattern worth naming explicitly: **read-only analysis sessions**.

The typical Claude Code mental model is "AI assistant that writes code." That's accurate for most use cases. But Claude Code can also function as a fast synthesis engine for structured data — reading JSON, markdown, and text files, cross-referencing context, producing distilled output.

The constraints that make this pattern actually work:

**1. Explicit read-only instruction in the prompt.** `Do not edit files.` Without this, Claude acts. That's usually good. Here it isn't.

**2. Output format specification.** Numbered bullets, word caps, binary decisions. Predictable structure makes output faster to act on and prevents unstructured free-form responses.

**3. File scope definition.** Name the files to read. "Look at the project" triggers thorough exploration. Thorough isn't always useful.

**4. Binary decisions at the end.** "HTML-report yes/no" is faster to act on than "what do you recommend about reporting." Force the decision in the prompt.

## Prompt Design as the Control Surface

Same source data. Two prompts. Two qualitatively different outputs.

**Session 1 — wide context, KB synthesis:**
- Use when: first run of the week, high-change days, strategic review needed
- Output: deep cross-referenced synthesis, catches multi-file patterns
- Tool calls: 9 Bash
- Time: ~1 minute

**Session 2 — narrow scope, output cap:**
- Use when: routine daily check, low-change days, quick scan
- Output: concise daily briefing, explicit decisions
- Tool calls: 5 (4 Bash + 1 Read)
- Time: ~1 minute

Both sessions take roughly the same wall-clock time. The difference is depth and context token consumption. Session 1 burns more context window but surfaces cross-file patterns. Session 2 is lean, focused, and lower cost.

The logical next step is a routing layer: a short script that checks yesterday's KB delta, decides which session type is appropriate, and runs accordingly.

```
if significant_change_detected(delta):
    run_wide_context_synthesis()
else:
    run_narrow_daily_check()
```

That decision layer turns the current manual two-prompt workflow into a single automated pipeline that adapts to the data.

## Where This Fits in the Larger Automation Stack

The dental ad SERP analysis is one component in a broader daily briefing pipeline:

1. **Crawler** (Python script) → writes `sources/serp-YYYY-MM-DD/summary.json`
2. **Claude Code analysis sessions** (this post) → reads data, synthesizes findings
3. **KB update** (manual or semi-automated) → updates rolling hypotheses and patterns
4. **Telegram briefing** → sends key findings to the dental clinic team

Steps 1 and 4 are already automated. Step 3 is semi-manual. The Claude Code sessions in step 2 are currently manual — I run them when I have time to actively engage with the data.

The end state is step 2 becoming a scheduled API call: a Python script that reads `summary.json`, sends it to the Anthropic API with the appropriate prompt, and writes structured output to the KB automatically. The Claude Code sessions are the prototyping environment for validating prompt designs before committing them to that automation.

This is a useful pattern in general: Claude Code for prompt iteration and validation, the API for scheduled production runs.

## The Numbers

| Metric | Value |
|--------|-------|
| Total sessions | 2 |
| Total tool calls | 14 |
| Bash calls | 13 |
| Read calls | 1 |
| Files modified | 0 |
| Files created | 0 |
| Elapsed time | ~1 minute |
| Model | claude-opus-4-7 |

## When Read-Only Is the Right Call

Not every Claude Code session should produce artifacts. Sometimes the output *is* the value — a daily briefing that replaces 30 minutes of manual reading with 1 minute of AI synthesis.

The read-only pattern fits when:
- Data is already collected and structured (JSON, CSV, markdown)
- The goal is synthesis, not transformation
- Output is for human consumption, not downstream automation
- Speed and iteration matter more than reproducibility

It doesn't fit when you need version-controlled output, when analysis feeds into another automated step that needs a file to read, or when the session needs to run unattended on a schedule.

The mental shift is simple: Claude Code isn't only a coding tool. It's a general-purpose tool that happens to have excellent file access and can execute arbitrary shell commands. For structured data analysis, those properties make it a powerful read-only synthesis engine.

> Not every Claude Code session writes code. Sometimes the most efficient session is the one that writes nothing.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
