---
title: "Error Messages Lie: 445 Tool Calls, Three Projects, One Day with Claude Code"
published: true
description: "445 tool calls, 5 sessions, 3 projects. The spoonai build failure wasn't YAML — a missing component was. Here's what multi-agent AI automation looks like when it goes sideways."
tags: claudecode, debugging, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-28-portfolio-site-en
---

445 tool calls. Five sessions. Three projects. That was today — and roughly half the debugging time was wasted because I trusted the error message.

**TL;DR:** The spoonai build failure had nothing to do with YAML parsing. A missing `CountUp.tsx` was the real cause, and the error message pointed in the wrong direction entirely. On saju_global, five Claude Code agents ran in parallel to complete Japan and Southeast Asia market research and ship a full redesign in a single session. The portfolio automation pipeline failed twice today — same expired API key both times.

## The "YAML Error" Where 481 YAML Files All Passed Validation

spoonai builds were all CANCELED between April 27 and April 28. The error looked specific and actionable:

```
YAMLException: incomplete explicit mapping pair; a key node is missed;
or followed by a non-tabulated empty line at line 3, column 277
```

It even named the offending file: `/posts/2026-04-05-furiosa-ai-rngd-commercial-launch-en`. Hard to argue with that level of detail. Started with YAML validation.

Ran `gray-matter` across all four content directories — `content/posts/`, `content/daily/`, `content/blog/`, `content/weekly/`. 481 files. Zero errors. Switched to `js-yaml` and ran the same pass. Still zero. Opened the named file directly: line 3 was a 204-character string with nothing wrong. Checked git history: commit `3095c96` from April 14 had already patched that exact file two weeks earlier.

By this point Session 4 had burned through 76 Bash calls on files that were all clean.

The real error only appeared when I reproduced the build locally:

```
Module not found: Can't resolve './CountUp'
```

`HomeContent.tsx` imports a `CountUp` component. `CountUp.tsx` didn't exist. Next.js 16 runs Turbopack by default, and when Turbopack encounters a missing module it terminates the build. During shutdown, the content loading pipeline also exits, and the YAML parser throws an exception that ends up at the top of the visible log output.

The YAML exception was real. YAML was not the problem.

This failure mode is worth naming: when a build tool runs multiple parallel processes, a fatal failure in process A can surface secondary exceptions from process B first. You see process B's complaint, chase it, find nothing wrong, and waste cycles on a clean layer while the actual broken thing sits uninvestigated.

**The fix:** Create `CountUp.tsx`. Also patched two broken frontmatter files in `content/daily/` — `2026-04-10-en.md` and `2026-04-10.md` — both missing their closing `---`. Those weren't causing the build failure, but they would have eventually.

After the fix:

```
480 static pages generated
✓ Build complete
```

Committed as `8aa059b`. Vercel auto-deployment resumed.

| Item | Before | After |
|------|--------|-------|
| spoonai Vercel deploys | CANCELED (Apr 27–28, all) | Auto-deploy resumed |
| CountUp.tsx | Missing (import existed) | Created |
| Broken frontmatter in content/daily | 2 files | 0 |
| Local build | Failure | 480 pages generated |

## The Same Bug, Investigated Twice, With No Shared Context

The notable detail about this debugging run: it happened twice.

**Session 4** — 9 minutes, 91 tool calls. Reproduced the build failure locally, traced the missing `CountUp` import, created the component, patched the broken frontmatter, and shipped the fix.

**Session 5** — 13 minutes, 117 tool calls. Started fresh — different context window, no knowledge of what Session 4 had found — and spent most of its time on the exhaustive file audit. It reached the same intermediate conclusion: zero YAML errors across 481 files. But without the local build reproduction step, it couldn't surface the module resolution failure and ended without identifying the root cause.

Two Claude Code sessions, same failing build, no shared context, different strategies, different outcomes. Session 4 got there by reproducing first. Session 5 did a more exhaustive audit of the wrong layer.

This is a workflow problem more than a tool problem. When multiple sessions investigate the same issue without coordination, duplicate work is inevitable. Together, Sessions 4 and 5 spent 208 tool calls on a bug that Session 4 alone had already fixed in 91. That overhead doesn't show up in individual call counts — it shows up when you add them together.

> Error messages describe what surfaced, not what caused it. Reproduce first, then read the logs.

## One Telegram Message → Five Parallel Agents → Design Shipped

Same day, different project. saju_global is a four-pillar astrology (사주) web app. The session trigger was a single Telegram message asking whether anyone had visited or paid recently.

Direct DB query:

- Lifetime payments: **30**
- Total revenue: **₩171,000**
- Payments since March: **0**
- April sessions: **87**
- Payment platforms: Toss operational (29 validated transactions), LS Payment rejected (fortune-telling is a blocked merchant category), PayPal configured for live but zero completed transactions

Revenue had stalled. Traffic was still arriving. The follow-up:

```
Run agents to sell this in SEA and Japan — ads, redesign, viral, all of it
```

Five Claude Code agents launched as parallel background tasks:

- `JP fortune market data` → `jp-market-data.md`
- `SEA fortune market data` → `sea-market-data.md` (136 inline sources)
- `Viral fortune video pattern decode` → `viral-formula.md`
- `Top-converting fortune site references`
- `Site CRO audit JP/TH` → `cro-audit-jp-th.md`

While the agents ran, I tested the PayPal live endpoint directly: created a real $1.99 order in the DB, confirmed approval URL generation, saved the test script to `scripts/paypal-live-test.sh`. The point was confirming payment infrastructure actually works before spending effort driving traffic to it. That's the category of verification agents can't substitute for.

## What Multi-Agent AI Automation Gets Right — and Where It Goes Wrong

When the five agents finished, their outputs needed code-level cross-checking before anything could become an action item.

**The real bug:** `i18n/messages/ja/common.json:3` had `運命研究所` (roughly "Fate Research Institute"), but `apps/web/countries.ts:142` referenced the same product as `FortuneLab`. Two different brand names for the same app, in the same codebase. Any Japanese user encountering both strings would see an inconsistency. A legitimate i18n defect that had slipped through.

**The false positive:** The CRO agent flagged that Thai users were seeing the `₩` (Korean won) symbol. Sounds like a localization bug. Looking at the code: that rendering path lives inside the `toss` namespace, which only executes in the Korean Toss checkout flow. Thai users route to the PayPal-hosted checkout page and never reach the code that renders `₩`. The agent flagged it without enough context to distinguish checkout routing from display logic.

One real issue. One phantom. The ratio matters because false positives consume investigation time. More agents running in parallel means more findings — and proportionally more noise. Each agent has its own pattern-matching surface area and its own blind spots. Running 5 agents in parallel doesn't produce 5× the signal. The signal-to-noise ratio drops unless there's a code-level verification pass before outputs turn into actions.

This isn't an argument against parallel multi-agent AI automation. The five agents together pulled 136 inline sources for the SEA market analysis, decoded viral video patterns in the fortune-telling category, and ran a conversion audit across Japanese and Thai user flows — simultaneously, in the background while endpoint testing happened in the foreground. That's hard to replicate any other way at this speed.

The lesson is narrower: **treat agent output as a first draft, not a conclusion.** Every flag needs a code-path check before it becomes a ticket.

> Agents retrieve answers fast. Verifying those answers against actual code is a separate job that can't be skipped.

After reviewing the results, the next message was direct: update the design. Modified i18n message files for 10 languages (`ko`, `en`, `ja`, `th`, `id`, `hi`, `zh`, `vi`, and others), updated `page.tsx`, `paywall/page.tsx`, and `globals.css`. Deployed.

## The Automation Pipeline That Failed Twice, Same Reason Both Times

The portfolio site runs an automated build log generation pipeline. It ran twice today. Failed twice today:

```
Error: Invalid API key
```

An external API key had expired. Sessions 1 and 2 each ended at zero tool calls — Claude Code initialized, hit the auth failure immediately, and had nothing to execute. After rotating the key, the pipeline completed normally.

Second time today I hit the same pattern: not a code bug, but an environment state that had drifted under the code. spoonai had a component that was imported but never created. The portfolio pipeline had an API key that was referenced but no longer valid.

Both errors surfaced in misleading ways. The spoonai error looked like a content parsing problem. The API key error looked like an integration failure. In both cases, reading the error at face value would push you into the wrong layer — the actual fix in each case was a one-step environment correction.

Error messages describe symptoms in the layer they originate from. Root causes often live elsewhere.

## Tool Usage Breakdown

| Session | Duration | Tool Calls | Top Tools |
|---------|----------|------------|-----------|
| saju_global JP/SEA | 33h 47min | 237 | Bash(126), Edit(25), TG reply(18) |
| spoonai recovery A | 9min | 91 | Bash(76), Read(13) |
| spoonai recovery B | 13min | 117 | Bash(100), Read(9) |
| portfolio automation × 2 | — | 0 | — |
| **Total** | — | **445** | **Bash(302), Read(56), Edit(26)** |

68% of today's tool calls were Bash. The pattern that emerged naturally: agents handle research, Bash handles verification. DB queries, build reproduction, PayPal endpoint testing — all shell. Agents handled broad information gathering across JP/SEA market research. Bash handled everything that needed confirmation against the actual running system.

There's a clean boundary here. "What does the Japanese fortune-telling market look like?" — that goes to an agent. "Does this PayPal order actually create a DB record?" — that goes to Bash. One is about gathering information from external sources. The other is about verifying behavior of code you control.

The two spoonai sessions illustrate what happens when sessions with overlapping scope don't coordinate. Both spent Bash calls auditing YAML files — work that could have been done once. 117 tool calls to reach no conclusion, when 91 calls in a parallel session had already fixed the issue.

> Research goes to agents. Verification goes to Bash. Both are necessary; neither replaces the other.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
