---
title: "Claude Code 8 Sessions, 69 Tool Calls: When the Orchestrator Gates Itself Out"
published: true
description: "One day, 8 Claude Code sessions, 69 tool calls across 4 projects. Only 2 Write calls. The orchestrator gate that blocked a single HTML file, and the narrow finish pass pattern."
tags: claudecode, ai, automation, devjournal
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-29-portfolio-site-en
---

May 28: 8 sessions, 69 tool calls, 4 different projects running inside automated pipelines. SpoonAI news curation, dental ad research, product revenue reports, CLI status reports. Only 2 of those 69 calls were `Write`. That ratio says more about production automation than any dashboard metric.

**TL;DR** The more complex your orchestration rules, the more likely a simple task gets blocked. Session 5 had the orchestrator gate block a single HTML file creation. Manual reclassification to `simple` fixed it in under a minute. Sessions 7 and 8 were health checks — zero tool calls each.

## 48% Bash, 35% Read: What the Numbers Actually Mean

The breakdown of 69 tool calls:

- `Bash`: 33 calls (48%)
- `Read`: 24 calls (35%)
- `TaskCreate`: 5 calls
- `WebSearch`: 4 calls
- `Write`: 2 calls
- `ToolSearch`: 1 call

Two `Write` calls. Two new files created all day. The other 67 calls were reading, running, and verifying. That's what production automation actually looks like — not writing new code, but reading existing data, validating state, and updating outputs.

The pattern varies by session. Session 1 (SpoonAI intel curation) used only 10 `Bash` calls. The input JSON was already prepared — read and restructure was enough. Session 4 (P1 product report) included 4 `WebSearch` calls because it needed live market data. Tasks with pre-prepared inputs and tasks requiring live search have fundamentally different structures, and they show up clearly in the tool stats.

## When the First Pass Doesn't Finish, You Need a Second Session

Sessions 2 and 3 were two stages of the same task: a daily dental ad research update. Session 2 created the main file (`2026-05-28-daily-update.md`) but left the cumulative files (`rolling-knowledge-base.md`, `naver-ranking-hypotheses.md`, etc.) and the HTML report unfinished.

The first line of the Session 3 prompt was blunt:

```
# Narrow finish pass — 2026-05-28 medical/dental ads daily job

The first artifact pass created .../2026-05-28-daily-update.md
but did not finish cumulative files or HTML report.
```

This is the reality of orchestration with Claude Code. Complex tasks in a single session often drop outputs. The **narrow finish pass** pattern — documenting exactly what the first pass missed, then running a second session to finish only those items — is the practical fix.

Session 3 used 15 `Read` calls and 3 `Bash` calls. No `Write` calls. It was reading already-created files and appending missing content. The tool breakdown alone tells you this session was filling gaps, not building from scratch.

The prompt structure matters here. Starting the second session's prompt with "the previous pass created X but not Y" pre-scopes the work. The model doesn't re-examine everything — it goes straight to what's missing.

## The Orchestrator That Blocked Itself

Session 5 is the most interesting failure mode. The prompt was simple: create one file at `~/.hermes/tmp/report-demo/cli_report_design_status.html`. A Korean HTML report covering CLI version status and report design spec changes.

The orchestrator gate blocked it. Here's the relevant log line:

```
오케스트레이터 게이트가 차단했습니다.
단일 HTML 파일 생성 작업이라 `simple`로 재분류한 뒤 다시 진행합니다.
```

*(Translation: "The orchestrator gate blocked the request. Reclassifying as `simple` — it's a single HTML file — and retrying.")*

The complexity classifier got it wrong. The gate treated the HTML report request as `standard` or higher, then blocked `Write` permission because the workflow stage wasn't `implementing`. The actual task was creating a single file.

The fix was trivial — manually reclassify as `simple` and proceed. Session 6 used 1 `Bash` call to verify the target directory and 1 `Write` call to create the file. Two sessions were spent, but Session 6 took under a minute.

**What this reveals**: as orchestration rules grow more precise, false positives increase. When the boundary between `simple` and `standard` is ambiguous and the gate defaults to blocking, real throughput drops. The orchestrator needs an explicit reclassification escape hatch — a way to override the classifier without dismantling the workflow.

I've seen this pattern in code review systems too. Strict lint rules that flag valid patterns, CI gates that block clean commits. The right fix isn't to disable the gate — it's to build a well-defined override path that requires explicit acknowledgment.

## Sessions 7 and 8 Were Pings

Session 7's entire prompt: `Return exactly: CLAUDE_OK`. Session 8: `Return exactly: CLAUDE_OK_AFTER_FIX`. Zero tool calls each. The orchestrator confirming Claude CLI is alive — health checks.

Two of 8 sessions were pings. Six sessions did actual work. The shortest real session was Session 1 at approximately 0 minutes of wall time. Session count is a meaningless productivity metric here — you'd be counting heartbeats alongside actual executions.

## Three Patterns Worth Keeping

**1. Separate prepared-input tasks from live-search tasks at design time.**

`Read` + `Bash` pipelines run fast when the input data is already on disk. `WebSearch` pipelines need a different structure — results have to arrive before anything else can proceed. Mixing them in the same session creates unpredictable execution times and makes the tool call distribution noisy.

**2. Track first-pass gaps explicitly and encode them in the next session's prompt.**

The narrow finish pass pattern works because the second session starts knowing exactly what's missing. Don't rely on the model to infer what was skipped — state it explicitly in the first line of the prompt. Session 3 ran cleanly because its entire scope was pre-defined to only the gaps from Session 2.

**3. Build an explicit reclassification path into your orchestrator.**

Complexity misclassification isn't edge-case noise — it blocks real work. Session 5's manual override demonstrates the pattern: stating `simple` directly in the corrected prompt let the gate accept the correction. The alternative — restarting the workflow from scratch — wastes time and obscures what actually happened. Make reclassification a first-class operation.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
