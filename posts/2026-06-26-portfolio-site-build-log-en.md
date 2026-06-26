---
title: "Claude Code, 10 Sessions and 846 Tool Calls: Catching a Live Email Bug and Getting Rejected by Paddle Twice"
published: true
description: "10 sessions, 846 tool calls: fixing a live email send bug, two Paddle rejections, IR rebuild with multi-agent ultracode, and a full homepage redesign."
tags: claudecode, ai, productivity, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-26-portfolio-site-en
---

17 real emails went out from a system explicitly designed never to send anything.

That's how the day started.

**TL;DR:** 10 Claude Code sessions, 846 tool calls across a full workday. A security audit on a local-commerce email agent caught 17 accidentally live-sent emails. Paddle rejected the preterview payment integration twice — once for expired KYC, once for product category misclassification. An IR deck was rebuilt using a 4-agent ultracode workflow that caught a factual inconsistency between the deck and the actual product. And the jidonglab homepage got a full redesign. Here's the full breakdown.

---

## The System That Promised Never to Send Anything — Then Sent 17 Emails

`local-commerce-agent` was built with one hard rule: fail-closed. No sending, no cron, no live dispatch unless every gate is manually opened. The design intent was that you'd have to explicitly override every guard to get an email out.

Session 1 (79 tool calls, 20 minutes) was a routine security audit. Claude Code crawled the configuration, then surfaced this:

```
classification=live_send
sent_count=17
dry_run=false
```

Sender: `jd@jidonglab.com`. Not the test account. The actual work email.

The culprit was a launch script: `jdlab_tryjdlab_live_send_launch.sh`. Someone — me, at some point — had set every gate flag to its open state:

```bash
JDLAB_DRY_RUN=0
JDLAB_DRAFT_CREATE_OK=approved
JDLAB_LIVE_SEND_OK=approved
```

That explains the send. But why did the banned-sender check miss it?

The banned-sender guard was checking the `--expect-profile` string, which was `jd@tryjdlab.com` — the intended test sender identity. The actual authenticated SMTP sender, `jd@jidonglab.com`, passed right through because the guard was looking at the wrong field. The profile string and the authenticated sender are separate concepts, and the check conflated them.

Classic fail-open bug: the guard checked a label, not the actual identity that the mail server authenticated.

Session 2 (89 tool calls, 31 minutes) was hardening. The fixes:

- Added `webmaster` and `mailer_daemon` — including underscore variants — to the never-send patterns
- Added detection for placeholder and likely-typo email addresses
- Fixed a `done` → `external_status` mapping confusion that was causing state tracking to drift

Two new test files landed: `jdlab_send_identity_guard.test.js` and `jdlab_goal_mode_hardening.test.js`. 32 Edit calls total across both sessions.

The lesson here isn't about Claude Code specifically — it's about security audit discipline. A system with explicit "never do X" semantics needs automated verification that the invariant holds, not just documentation that it should. The audit surface that Claude Code covers in 20 minutes would take a few hours manually, and it's exactly the kind of thorough cross-file check that human reviewers tend to skim.

---

## Paddle Rejected the Integration. Then Rejected It Again.

Session 8 was the biggest session of the day: 211 tool calls, most of any session. The task was finalizing Paddle payment integration for preterview, an AI mock interview product (voice-based, with performance reports).

The code was already done. `feat/paddle-checkout` had been merged to main: 23 commits, 47 files, +4,960 lines. New files included:

```
app/api/pay/paddle/
components/pricing/PaddleBuy.tsx
lib/payments/paddle.ts
```

The problem was on Paddle's end.

**Rejection 1:** The old Paddle account — originally created for an earlier project called fortunelab — had expired KYC. Paddle's message: *"Action required — verification process has expired."* Straightforward. Create a new account.

**Rejection 2:** The new account, registered with the `preterview.com` domain, was rejected with this:

> *"We identified the following product categories: Other/Resume/CV Builders, Human Services/Consulting"*

preterview is an AI mock interviewer. You speak, it listens, it scores your performance across multiple dimensions and generates a report. Paddle classified it as a Resume Builder, which falls outside their Acceptable Use Policy.

There's no clean appeal path when the classification is wrong — you resubmit with clarification materials and wait. That's what's happening now.

Meanwhile, the Korea payment alternative is being researched. payapp doesn't support credit-type products, so alternatives are needed. The integration code sits ready in main, waiting on a payment provider that will actually approve the account.

Two rejections in one day, for different reasons, for the same integration. The code problem was the easy part.

---

## Four Parallel Agents Caught a Fact the Deck Got Wrong

Sessions 4 and 6 were about preterview's investor IR deck. Session 4 used ultracode mode with the Workflow tool — 4 parallel agents, each running a different lens:

- VC framing (what investors actually care about at this stage)
- Competitive positioning
- Narrative structure
- Design and visual hierarchy

92 tool calls, 46 minutes. Tool distribution: Bash 35, Read 29, Edit 24.

The most useful thing the agents caught wasn't a weak slide or a missing market size number. It was a factual inconsistency between the deck and the actual product.

The IR deck claimed preterview evaluates candidates across "3 capability axes." The actual product report in the codebase showed 5: experience specificity, job expertise, problem-solving, communication, and fundamental skills. The product had been updated after the IR was written, and the deck was never synchronized.

This is exactly what multi-agent review is good for: one agent reads the deck, another reads the codebase, and you get cross-verification that a single pass misses. A human reviewer working only from the deck wouldn't catch it. The agents caught it by treating the codebase as a source of truth.

Session 6 ran a second rebuild pass based on actual investor feedback — a PDF of collected comments (`preterview_feedbacks_260626.pdf`). That's a different kind of input than a VC framework checklist, and it produced different structural changes.

The workflow for both sessions was the same pattern: fan out across independent lenses, collect findings, synthesize. The speed advantage over sequential passes is significant, but the quality advantage — catching cross-document inconsistencies — is the more interesting one.

---

## Six Logo Directions, One Indigo Monogram, Full Homepage Redesign

Session 5 (143 tool calls, 65 minutes) was the jidonglab homepage. The existing homepage was fine — it listed projects, had a bio, did the job. But preterview needed a proper showcase position, and the overall site needed work to reflect what the lab is actually building.

GPT Image (`gpt-image-2`) generated 6 logo direction options for the JL monogram. The indigo variant was selected and replaced the existing site logo.

For the homepage redesign, the direction was a dental ad agency dashboard feel — preterview featured at the top, with actual report screenshots showing real data, but with identifying numbers and names removed. New components:

```
BrandMark.tsx
DentalShowcase.tsx
Flagship.tsx
```

21 files changed total.

The dashboard aesthetic makes sense for the use case: the work is quantitative (tool call counts, session durations, ad performance numbers, dental clinic rankings), and a dashboard layout communicates that without having to say it explicitly.

---

## The Other Seven Sessions

The day wasn't only the four major tracks. Six other sessions covered:

**Session 3 — Dental clinic routine work:** Measurement for the Dongbaek UDI dental clinic was delegated to the `dental-clinic` subagent. A pediatric dentistry blog post (post #2 in a series) hit the top search result for "동백 소아치과" (Dongbaek pediatric dentistry) and #4 for "용인 소아치과" (Yongin pediatric dentistry) on day 1. Post log number `224326926066` verified.

**Session 7 — Grants and support programs:** A follow-up on the Pangyo Valueup support application, plus a new grants search. The search used an 8-angle parallel workflow — 36 programs verified, 23 candidates identified. Two output files: `MORE-2026-06-25.md`, `SEOUL-STARTUP-HUB-2026-06-25.md`.

**Session 9 — Email audit:** A Money Today "Good Company Award" solicitation email. 4 WebSearch calls established that it follows a paid award solicitation pattern (ad sales, not a legitimate award). Actionable: ignore.

**Session 10 — Ad strategy (162 tool calls):** Naver PowerLink keyword selection for preterview, Google Analytics 4 pixel insertion (`G-ES6SENFGM2`), and Google RSA copy. The keyword cluster with the best CPC ratio: "면접 말버릇" (interview speech habits) and "면접 습관교정" (interview habit correction). These keywords target the actual problem users have, not the solution category — which is why the CPC works better than "AI 면접" or similar.

---

## The Actual Numbers

| Session | Tool Calls | Duration | Primary Work |
|---------|-----------|----------|--------------|
| 1 | 79 | 20 min | Email agent security audit |
| 2 | 89 | 31 min | Email agent hardening |
| 3 | — | — | Dental clinic / SEO |
| 4 | 92 | 46 min | IR deck, 4-agent ultracode |
| 5 | 143 | 65 min | Homepage redesign |
| 6 | — | — | IR rebuild from feedback |
| 7 | — | — | Grants search, 8-angle parallel |
| 8 | 211 | — | Paddle integration |
| 9 | — | — | Email audit |
| 10 | 162 | — | Ad strategy |
| **Total** | **846** | | |

Tool distribution across all sessions:

```
Bash   268
Read   151
Edit   103
Write   21
Other  misc
```

The Bash-heavy distribution reflects the audit and hardening work in sessions 1-2. Edit-heavy sessions (5, 8) were the homepage and Paddle integration. The multi-agent IR sessions show high Read counts from parallel codebase verification.

---

## What This Day Actually Demonstrates

Three things stand out as genuinely useful patterns, versus things that just happened to work.

**Security audits benefit from AI automation more than most tasks.** The email bug in sessions 1-2 was caught because the audit covered every file that touched send logic, cross-referenced configuration values, and checked actual authenticated identities against declared identities. That's tedious to do manually and easy to cut short. 79 tool calls in 20 minutes is faster than a careful human pass and less likely to miss the wrong-field bug.

**Multi-agent review catches cross-document inconsistencies.** The "3 axes vs. 5 axes" catch in session 4 is the clearest example. A single-pass review of the IR deck wouldn't find it. You need an agent reading the deck and a separate agent reading the codebase, then comparison. The Workflow tool made this straightforward to set up.

**Payment provider rejection is a product problem, not just an ops problem.** Two Paddle rejections in one day — one for expired KYC, one for product classification — both landed after the integration code was complete and merged. The technical work was fine. The blocker was Paddle's understanding of what the product is. That's a communication and positioning problem, and it's not solvable with more tool calls.

846 tool calls for one day of work across 10 parallel tracks. The density reflects the nature of the work: each session picked up context from scratch, ran to a defined scope, and handed off. That's how Claude Code multi-agent automation actually works in practice — not one long session, but many short focused ones, each with a clear entry and exit condition.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
