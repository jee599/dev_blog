---
title: "The Build Error Was Lying: Chasing a False YAML Exception Back to a Missing React Component"
published: true
description: "445 tool calls, 5 sessions. Vercel blamed YAML. The real blocker was a missing CountUp.tsx. One Telegram message triggered 5 parallel agents doing JP/SEA market research."
tags: claudecode, debugging, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-28-portfolio-site-en
---

The Vercel build log said `YAMLException`. After parsing 481 files with `gray-matter` and finding zero errors, the actual culprit turned out to be a missing `CountUp.tsx` component that had never been created. Meanwhile, a single Telegram message triggered 5 parallel Claude Code agents doing market research on fortune-telling markets in Japan and Southeast Asia. Here's what 445 tool calls across 5 sessions looked like on April 28.

**TL;DR:** spoonai's Vercel deploys were CANCELED with a misleading YAML error. The real cause: `HomeContent.tsx` imported a `CountUp` component that didn't exist on disk. Two separate Claude Code sessions (91 and 117 tool calls respectively) investigated the same bug without sharing context — the first fixed it in 9 minutes by reproducing the build locally, the second spent 13 minutes on a full file audit and reached no conclusion. On the same day, one Telegram message triggered 5 parallel agents researching JP/SEA markets, which surfaced one real bug (inconsistent brand name across i18n files) and one false positive (a Korean currency symbol flagged as a localization issue that was actually scoped to the Korean checkout path only).

## The YAML Error That Had Nothing To Do With YAML

All spoonai Vercel deployments between April 27 and April 28 had the same status: CANCELED. The error was specific:

```
YAMLException: incomplete explicit mapping pair; a key node is missed;
or followed by a non-tabulated empty line at line 3, column 277
```

It even named a file: `/posts/2026-04-05-furiosa-ai-rngd-commercial-launch-en`. Hard to argue with that level of detail. The obvious starting point was auditing YAML.

`gray-matter` swept through `content/posts/`, `content/daily/`, `content/blog/`, and `content/weekly/`. 481 files total. Zero errors. Then `js-yaml` ran the same pass. Also zero. Opening the named file directly showed 204 characters on line 3 — a valid, well-formed string. Git history confirmed: commit `3095c96` had already patched that exact file on **April 14th**.

The YAML error had been fixed two weeks earlier. The Vercel build log was surfacing a stale message from an old failure, not the current blocker.

Pulling the actual build trace revealed the real failure: `HomeContent.tsx` imported `CountUp`, but `CountUp.tsx` didn't exist in the project. Next.js 16 with Turbopack hit this module resolution failure and surfaced it as a YAML parse error in Vercel's output. The error message pointed at an already-resolved historical issue while the real build stopper sat quietly undetected.

The fix was straightforward:

1. Create `CountUp.tsx`
2. Patch two daily posts — `2026-04-10-en.md` and `2026-04-10.md` — that had broken frontmatter (both missing the closing `---` delimiter)

Local build after the fix: 480 static pages generated clean. Committed as `8aa059b` and pushed. Vercel auto-deploy triggered.

| Item | Before | After |
|------|--------|-------|
| spoonai Vercel deploys | CANCELED (Apr 27–28) | Auto-deploy resumed |
| CountUp.tsx | Missing (import existed) | Created |
| Broken frontmatter in content/daily | 2 files | 0 |
| Local build | Failure | 480 pages generated |

## The Same Bug, Investigated Twice, With No Shared Context

The notable detail about this debugging run: it happened twice.

**Session 4** — 9 minutes, 91 tool calls. It reproduced the build failure locally, traced the missing `CountUp` import, created the component, patched the broken frontmatter, and shipped the fix.

**Session 5** — 13 minutes, 117 tool calls. It started fresh — different context window, no knowledge of what Session 4 had found — and spent most of its time on the exhaustive file audit. It reached the same intermediate conclusion: zero YAML errors across 481 files. But without the local build reproduction step, it couldn't surface the module resolution failure and ended without identifying the root cause.

Two Claude Code agents, same failing build, no shared context, different strategies, different outcomes. Session 4 got there by reproducing first. Session 5 did a more exhaustive audit of the wrong layer.

This is a workflow problem more than a tool problem. When multiple sessions investigate the same issue without coordination, duplicate work is inevitable. In this case, Sessions 4 and 5 together spent 208 tool calls on a bug that Session 4 alone had already fixed in 91. The overhead doesn't show up in individual call counts — it shows up when you add them together.

The fix would have been straightforward: store Session 4's intermediate findings somewhere Session 5 could read before starting its audit. That's a coordination problem, not a capability problem.

> Error messages describe what surfaced, not what caused it. Reproduce first, then read the logs.

## One Telegram Message, Five Parallel Agents

Same day, different project. saju_global is a four-pillar astrology (사주) web app targeting Korean users. The session trigger was a Telegram message asking whether anyone had visited or paid recently.

Direct DB query:

- Lifetime payments: **30**
- Total revenue: **₩171,000**
- Payments since March: **0**
- April sessions: **87**
- Payment platforms: Toss operational (29 validated transactions), LS Payment rejected outright (fortune-telling is a blocked merchant category), PayPal configured for live processing but zero completed transactions

Revenue had stalled. Traffic was still coming in. The follow-up:

```
Run agents to generate revenue in SEA and Japan. Use everything — ads, site redesign, viral.
```

Five Claude Code agents launched as parallel background tasks:

- `JP fortune market data` → `jp-market-data.md`
- `SEA fortune market data` → `sea-market-data.md` (136 inline sources)
- `Viral fortune video pattern decode` → `viral-formula.md`
- `Top-converting fortune site references`
- `Site CRO audit JP/TH` → `cro-audit-jp-th.md`

While the agents ran, the PayPal live endpoint got manual testing independently: a real $1.99 order created in the DB, approval URL generated, complete flow saved to `scripts/paypal-live-test.sh`. The point was confirming payment infrastructure actually works before spending any effort driving traffic to it.

## What Agents Got Right, and Where They Went Wrong

When the five agents finished, their outputs needed code-level cross-checking before anything could become an action item.

**The real bug:** The Japanese locale had `運命研究所` in `common.json:3`. But `countries.ts:142` referenced the same product as `FortuneLab`. Two different brand names for the same app, in the same codebase. Any Japanese user who encountered both strings would see an inconsistency. A legitimate i18n defect that had slipped through review.

**The false positive:** The CRO audit agent flagged that Thai users were seeing the `₩` (Korean won) symbol. Sounds like a real localization problem. Looking at the actual code: that rendering path lives inside the `toss` namespace, which only executes in the Korean Toss checkout flow. Thai users route to a PayPal-hosted payment page — they never reach the code that renders `₩`. The agent flagged it without enough context to distinguish checkout routing from display logic.

One real issue. One phantom. The ratio matters because false positives consume investigation time. The more agents running in parallel, the more cross-validation work lands on whoever is reviewing the results. Each agent has its own pattern-matching surface area and its own blind spots. Running 5 agents in parallel doesn't produce 5× the signal — the signal-to-noise ratio drops unless there's a verification pass before outputs turn into actions.

This isn't an argument against parallel agents. The five agents together pulled 136 inline sources for the SEA market analysis, decoded viral video patterns in the fortune-telling category, and ran a conversion audit across Japanese and Thai user flows — all simultaneously, in the background while PayPal testing happened in the foreground. That's genuinely hard to do any other way at this speed.

The lesson is narrower: **treat agent output as a first draft, not a conclusion.** Every flag needs a code-path check before it becomes a ticket.

> Agents retrieve answers fast. Verifying those answers against actual code is a separate job that can't be skipped.

---

After reviewing the agent reports, the next instruction was direct: update the design. Modified i18n message files for 10 languages (`ko`, `en`, `ja`, `th`, `id`, `hi`, `zh`, `vi`, and others), updated `page.tsx`, `paywall/page.tsx`, and `globals.css`. Deployed.

## Tool Usage Breakdown

| Session | Duration | Tool Calls | Top Tools |
|---------|----------|-----------|-----------|
| saju_global JP/SEA | 33m 47s | 237 | Bash(126), Edit(25), TG reply(18) |
| spoonai recovery A | 9m | 91 | Bash(76), Read(13) |
| spoonai recovery B | 13m | 117 | Bash(100), Read(9) |
| **Total** | — | **445** | **Bash(302), Read(56), Edit(26)** |

68% of today's tool calls were Bash. The pattern that emerged naturally, without being planned: agents handle research, Bash handles verification. DB queries, build reproduction, PayPal endpoint testing — all shell. The agents handled broad information gathering. Bash handled everything that needed confirmation against the actual running system.

There's a clean boundary here that's worth naming explicitly. When the question is "what does the Japanese fortune-telling market look like?" — that goes to an agent. When the question is "does this PayPal order actually create a DB record?" — that goes to Bash. One is about gathering information from external sources. The other is about verifying behavior of code you control.

The two spoonai sessions illustrate what happens when that boundary gets blurred. Both sessions spent Bash calls auditing YAML files — work that could have been done once if the sessions had shared context. 117 tool calls to reach no conclusion, when 91 calls in a parallel session had already fixed the issue. That's coordination overhead made visible in the numbers.

> Research goes to agents. Verification goes to Bash. Both are necessary; neither replaces the other.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
