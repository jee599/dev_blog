---
title: "9 Tool Calls to Compliance: Automating Dental Ad Review with Claude Opus 4.7"
published: true
description: "Claude Opus 4.7 reviewed dental ad compliance in 2 sessions, 9 tool calls — checking for contradictions, hospital name leaks, and guarantee claims. Result: OK."
tags: claudecode, ai, automation, compliance
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-17-portfolio-site-en
---

2 sessions. 9 tool calls. The verdict: **OK**.

That's the entire compliance audit for a daily dental advertising report, handled by Claude Opus 4.7. No manual file-diffing, no checklist scanning, no second-guessing whether "premium service" crosses a legal line. The model read both files, applied the criteria, and returned a clean pass.

**TL;DR** — 5 Bash calls + 4 Read calls to cross-check a daily update `.md` against an HTML intelligence report. No blocking issues: no contradictory facts, no hospital names in user-facing copy, no guarantee language, no missing source labels.

## Why Compliance Automation for Dental Ads

Dental advertising in South Korea is governed by Article 56 of the Medical Act. The rules are specific: phrases like "guaranteed booking," "best procedure," or "proven results" are violations. So is any direct mention of a hospital's name or address in user-facing content. Every report that gets published is exposure to regulatory risk.

Doing this manually means opening two files, comparing them line by line, and running a mental checklist against legal criteria. For a daily report cadence, that's unsustainable.

The automation opportunity is clear: read the files, apply fixed criteria, surface blocking issues. Nothing more.

## Session 1: Open Criteria, First Pass

The first prompt was intentionally broad:

```
Read the daily update and HTML report for 2026-05-17 under
/Users/jidong/dentalad/research/daily-medical-dental-ads.
Check for contradictions, unsupported claims, accidental
hospital names/addresses, or missing required labels.
Return concise blocking issues only, or OK if none.
```

Claude used Bash 5 times and Read 2 times — navigating the directory structure, loading both files, then running through the criteria. Elapsed time felt under 30 seconds.

The session established the baseline. Both files were readable, no obvious violations surfaced.

## Session 2: Enumerating Every Blocking Condition

After confirming the first pass, the second session named the violations explicitly:

```
Blocking review only. Read these two files:
research/daily-medical-dental-ads/2026-05-17-daily-update.md
research/daily-medical-dental-ads/reports/2026-05-17-info-keyword-ai-and-local-serp-patterns.html.

Answer exactly OK if no blocking issue. Blocking issues:
contradictory facts between the two files,
named hospitals/addresses in user-facing summary/report,
missing source/label caveats,
or claims of guaranteed rankings/reservations/revenue.
```

Two Read calls to load both files. Verdict: **OK**.

## Tool Call Breakdown

| Tool | Count |
|------|-------|
| Bash | 5 |
| Read | 4 |
| **Total** | **9** |

Files modified: 0. Files created: 0. Pure review pass.

## The Prompt Design Lesson

The difference between the two sessions was specificity. Session 1 gave Claude categories. Session 2 gave it exact violations to match against.

"Guarantee language" requires inference. `guaranteed rankings/reservations/revenue` removes it. The model pattern-matches against a concrete list instead of interpreting an abstract concept. At daily cadence, that predictability matters more than flexibility.

The `Answer exactly OK if no blocking issue` constraint was just as important. Fixed output format means the downstream pipeline can parse the result without ambiguity. Any response other than "OK" routes to human review — no regex required.

## What's Left to Build

The prompt runs manually today. Next step: GitHub Actions. When the daily report generates, trigger the compliance session automatically. If the result isn't "OK," push a Slack alert before anything publishes.

There's also a cost question. Claude Opus 4.7 is the highest-capability model, but this task — read two files, match against a list — might not need it. Running the same review with Haiku and Sonnet will show whether a cheaper tier holds the same pass/fail accuracy. At daily cadence, the difference is real money.

If Haiku holds up, this becomes a nearly-free automated safeguard on every report that goes out.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
