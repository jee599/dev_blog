---
title: "7 Sessions, 489 Tool Calls: Running Two Products Simultaneously with Claude Code"
published: true
description: "7 sessions, 489 tool calls, 35 files changed. i18n raw key bug fixed, 22-file mobile patch, 12-agent business plan in 34 min — one day of Claude Code across two products."
tags: claudecode, ai, nextjs, multiagent
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-21-portfolio-site-en
---

`window.innerWidth` returned **2240px**. The browser window was 784px wide. Content was overflowing at 2.8x — and that number only appears when you actually run the app and measure it in a live browser context.

That was one of seven sessions today. 489 tool calls total. 35 files changed. Claude Code ran two products simultaneously — preterview (an AI mock interview app) and a dental clinic marketing automation system — across a full working day.

**TL;DR** — The next-intl `scopeClientMessages` function silently drops the `interview` and `portfolio` namespaces when the `x-cc-pathname` header is absent, causing raw key output like `interview.room.endInterview`. Fixed in 113 tool calls. Separately: a 12-agent workflow generated a 7,747-word business plan in 34 minutes using 1.27M tokens.

## The 9-Minute Benchmark: What a Good Delegation Looks Like

First task of the morning was the dental clinic's weekly SERP measurement. Six keywords, six rank checks, digest file, `sync.sh`, commit to production.

I didn't touch it directly. The request went to the `dental-clinic` subagent. **2 tool calls, 9 minutes.**

The agent restored context from `clinic.json` and `history.json`, ran live measurements across all six keywords, wrote the digest file, and pushed the commit. One keyword slipped from rank 8 to 9. The agent logged it as rotation noise — the prompt had explicitly said "do not re-score, only record measurements" — and didn't touch the numbers.

This is what the delegation pattern is for. Context restore → measure → record → sync is a self-contained pipeline running entirely inside the subagent. The main session holds no dental state. It receives a commit hash.

When a task has its own context, its own data files, and a clear output format, handing it off keeps the main session clean for everything else that day.

## `innerWidth: 2240px` — Why Runtime Measurement Beats Static Analysis

Session 3 was the largest by volume. It started with:

```
preterview is broken on mobile — buttons misaligned, English text showing
on Korean settings, layout weirdness everywhere. Check everything, find
whitespace and line break overflow issues, fix all of it.
```

The dev server went up in the background. Using browser automation with `browser_batch`, the session loaded the actual mobile viewport. Device set to iPhone at 390px. The render came back at 1568px. Then JavaScript ran `window.innerWidth` directly in the live browser context: **2240px**.

Window: 784px. Content: 2240px. Root cause identifiable before touching a single file.

This is why live measurement reverses the debugging direction. Finding viewport overflow through source files means guessing which component is the culprit, then working inward. Measuring the rendered output gives you a number, and the number points you to the file.

The second issue — English buttons appearing on Korean locale settings — was an i18n routing problem. The app was detecting `Accept-Language: en` from the browser and redirecting to `/en`, overriding the explicit user language preference. Fix: `i18n/routing.ts`.

Then came missing translation keys. Several components had no Korean translations at all, falling through to English strings. Each missing key required locating the component, finding the correct namespace, and filling in the JSON files.

**22 files modified across 4 hours:**

- `app/[locale]/layout.tsx`, `globals.css` — root overflow causing the 2240px bleed
- `i18n/routing.ts` — browser language detection logic
- `components/interview/InterviewRoom.tsx`, `RadarChart.tsx` — mobile layout
- `components/resume/steps/ItemHeader.tsx` — line-break overflow
- 6 JSON message files for `ko/` and `en/` — missing keys filled
- 5 admin pages — no mobile handling at all

Loop: edit → build → browser screenshot at real viewport → find next issue → repeat.

**Bash 46, Edit 40, Read 35, `browser_batch` 26 — 182 tool calls.**

Edit outnumbering Bash signals more actual fixing than searching. The `browser_batch` calls were load-bearing: each one gave a screenshot at the real rendered viewport, not DevTools emulation.

## The Bug That Passed Every Static Check

Session 6 surfaced a regression. The preterview mock interview page was showing button text as raw translation keys: `interview.room.endInterview`, `portfolio.section.overview`.

next-intl outputs the full key path when a key isn't found. First hypothesis: key files broken. Check: both `en/` and `ko/` had the keys. Components called `tr("room.endInterview")` correctly. Type checking passed. i18n key integrity checks passed.

Both passed clean. The bug was still there.

At that point the problem wasn't in the keys — it was in the **delivery path** between keys and the client.

The culprit: `lib/i18n/request.ts` and its `scopeClientMessages` function.

`scopeClientMessages` is an optimization layer. It reads the `x-cc-pathname` header to determine which route is being rendered, then sends only the i18n namespaces relevant to that route rather than the full message bundle.

The problem: when the header is absent or resolves to `/`, the function excludes the `interview` and `portfolio` namespaces entirely.

```
x-cc-pathname = "/" → interview + portfolio namespaces dropped → raw key output
```

`proxy.ts` injects this header, but when traffic passes through the next-intl middleware, the header isn't always propagated through to RSC. Two fixes were possible: guarantee header propagation, or make namespace scoping less aggressive. Chose the second — more robust against similar edge cases.

`app/[locale]/layout.tsx` updated. Playwright e2e tests added to `e2e/i18n-softnav.spec.ts` to catch regressions.

**Bash 64, Read 14, Edit 13, Write 10 — 113 tool calls.**

Bash dominates because all verification is shell: dev server up, `curl` with custom headers to trace the header chain, build check, Playwright run. The actual code change was small. The diagnostic work to confirm the hypothesis consumed most of the calls.

The real lesson from this session: **type checking and key integrity verification address the wrong layer**. The bug wasn't in key definitions or component calls. It was in the optimization logic that decides what gets transmitted to the client at runtime. Static analysis can't reach that.

## 12 Agents, 34 Minutes, 1.27M Tokens

Session 7 was the heaviest by token count. The ask:

> For both the dental automation project and preterview — produce technically and commercially rigorous business plans plus analysis of government and private funding programs.

First move: check existing data. `~/funding/` had 56 entries plus 57 alternatives from a prior research session. Two funding deadlines were imminent: one on June 22 (tomorrow), one on June 28. Context was already in place — no starting from scratch.

**Workflow structure: 5-phase pipeline, 12 agents.**

**Phase 1 — Foundation** (6 agents, parallel):
- Product profiles for both products
- Government and public non-equity programs
- Private VC and accelerator landscape
- Government PSST acceptance framework
- Private IR formula

**Phase 2 — Plans** (2 agents, high effort):
- preterview: PSST application + IR deck + 3-year financials + technical architecture
- dental automation: same

**Phase 3 — Strategy**: funding program matching and execution calendar

**Phase 4 — Verify**: fact-check pass + completeness critic agent

**Phase 5 — Assemble**: synthesize into a single unified document

34 minutes later: 7,747 words. PSST documents, IR framework, financial projections, architecture summaries, funding catalog with fit scores, execution calendar, adversarial verification notes included.

Converted to HTML and delivered.

The key structural choice: each agent generates its section independently in parallel. The assembler joins them at the end. Compared to one agent writing sequentially, this produces better section quality and less total wall-clock time — because section quality doesn't depend on how much context budget remains at that point in a linear conversation.

A full business plan written manually takes a minimum of two days. This took 34 minutes.

## The Full Day

| Session | Duration | Tool Calls | Work |
|---------|----------|------------|------|
| Dental measurement | 9 min | 2 | SERP 6 keywords + commit |
| preterview GTM | ~22 min | 35 | PH judgment + validation |
| Mobile UI | 4 hours | 182 | 22 files patched |
| Business plans (v1) | ~27 min | 98 | 6 docs + Telegram delivery |
| Agency analysis | 38 min | 32 | solo-agency playbook |
| i18n bug fix | 50 min | 113 | scopeClientMessages patch + e2e |
| Business plans (v2) | 58 min | 27 | 12-agent workflow + HTML |

**489 total tool calls. Bash 189, Read 71, Edit 66, Write 26, `browser_batch` 26, TaskCreate 16, TaskUpdate 29.**

Bash leads because all verification routes through it: dev server, SERP measurement, header tracing, build confirmation, Playwright. That's not overhead — it's the evidence layer.

Two products running in parallel required different routing strategies. Dental: subagent delegation with full context isolation, main session receives only results. preterview: direct main session work with runtime measurement and live browser verification.

The most instructive session wasn't the largest. It was the i18n bug — 50 minutes, a fix that was a few lines of code, and a reminder that type checking and key integrity checks can both pass clean while a runtime-only bug is actively breaking production. `scopeClientMessages` sits in an optimization layer that static analysis doesn't reach. Measure at runtime first.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
