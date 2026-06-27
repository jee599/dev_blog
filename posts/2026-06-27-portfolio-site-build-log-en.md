---
title: "Paddle Rejected Me Twice. Claude Code Researched 6 Alternatives in 28 Minutes."
published: true
description: "Two Paddle rejections in 36 hours, 6 parallel payment research agents, 24-agent ad strategy session, and dental SEO wins — all in one day with Claude Code."
tags: claudecode, aiagents, saas, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-27-portfolio-site-en
---

Two rejection emails. Thirty-six hours of KYC forms, domain verification waits, and documentation reading. The first email said my identity verification had expired. The second said my domain fell "outside what Paddle is able to support."

This is what attaching a Western Merchant of Record to a Korean developer's SaaS actually looks like in practice.

What follows is a build log from one day across 7 sessions and 448+ tool calls: a payment provider pivot for [preterview.com](https://preterview.com), a 24-agent ad research run that consumed 880k tokens, dental SEO measurement via a single subagent call, and a fraudulent award email identified in five minutes.

**TL;DR**

- Paddle rejected preterview.com twice — KYC expiration on account one, domain miscategorization on account two
- Ran 6 parallel research agents via `ultracode` to evaluate payment alternatives in 28 minutes
- Pivoted to Polar (Individual KYC, usage-based billing)
- 24-agent ad session (~880k tokens, 245 web tool-uses) concluded Naver Power Link is the right first channel
- Dental clinic subagent: one `Agent()` call from the main session, post #1 back to blog tab #3, post #2 at #1 on target keyword
- Identified a pay-to-win award scheme in 5 minutes with 4 WebSearch calls

## The Interview App That Got Called a Resume Builder

[preterview.com](https://preterview.com) is an AI mock interview platform. Fully automated — no human coaches, no consultants, no resume building. You answer a practice question on video or audio, the AI evaluates delivery, pacing, and filler words, and returns structured feedback with scores. That's the entire product.

Paddle looked at it and classified it as: **Resume/CV Builders + Human Services/Consulting or Advisory Services.**

This was the second Paddle account rejection. The email:

> We identified the following product categories on this domain:
> **Resume/CV Builders**, Human Services/Consulting or Advisory Services.
> These categories fall outside what Paddle is able to support.

The classifier presumably keyed on "interview" → job prep → resume. I submitted an appeal with explicit language: "Fully automated AI product. Zero human interviewers, zero coaches, zero consultants. AI generates all feedback." But with no timeline on the appeal, I needed to evaluate alternatives in parallel.

## What Happened Before This: KYC Expired on Account One

The second rejection was on a second account. The first had been created earlier under "FortuneeLab" and sat dormant long enough that Paddle's KYC window closed:

```
Verification status: Action required
We're unable to verify your identity as the 
verification process has expired.
```

Re-submitting on a lapsed account requires Customer Support. Rather than wait, I created a fresh account and rebuilt the entire integration in a 211-tool-call session:

- Product catalog: Starter (800 credits / $7.99), Standard (5,000 credits / $39), Pro (12,000 credits / $79)
- Client-side checkout token
- Webhook endpoint

The `feat/paddle-checkout` branch shipped: 23 commits, 47 files, +4,960 lines, merged clean into main.

Then came the domain rejection on the new account two days later.

## 6 Research Agents in Parallel, Results in 28 Minutes

The moment the second rejection arrived, I opened `ultracode`. The prompt wasn't structured — just the raw question in Korean, roughly: "What payment providers can I attach to preterview? Paddle is under review — how long does it take? What about Lemon Squeezy or Polar? Any issues with credits? Korean options?"

The Workflow spun up 6 parallel research agents, each investigating one question:

1. **Paddle review timelines** — official "48 hours" vs. actual community-reported data
2. **Lemon Squeezy post-Stripe acquisition** — stability for new SaaS signups
3. **Polar KYC scope** — specifically for Korean individual (non-corporate) sellers
4. **Stripe direct signup** — whether it's actually available for Korean sellers
5. **Korean PG (payment gateway) international coverage** — Inicis, Toss Payments, etc.
6. **AI usage credits as "stored value"** — regulatory classification risk across key jurisdictions

Four of the most consequential findings were routed to adversarial cross-verification agents — separate agents tasked with actively trying to disprove each claim before it made it into the output.

Total: 12 tool calls, 28 minutes to actionable conclusions.

| Provider | Decision | Reason |
|---|---|---|
| Paddle | Hold | Domain rejection, appeal pending |
| Lemon Squeezy | Pass | Post-Stripe acquisition instability for new SaaS signups |
| Stripe | Unavailable | No direct merchant signup for Korean sellers |
| Korean PG | Later | Requires registered sole proprietorship first |
| **Polar** | ✅ Go now | Individual KYC accepted, usage-based billing supported |

One finding that reframed the whole decision: Paddle's official "48-hour review window" is marketing copy. Actual user reports from community forums show 2–4 weeks for domains with any categorization ambiguity. That changes the risk profile entirely — waiting on Paddle means a month with a blocked payment flow.

## Why Individual KYC Was the Right Call (W-8BEN vs W-8BEN-E)

Polar's onboarding asks whether you're signing up as an Individual or Business. I have a registered Korean sole proprietorship (`개인사업자`). The question: does that qualify as a Business?

The answer matters because it determines your tax withholding form. On Western fintech platforms, "Business" means an *incorporated legal entity* — a corporation or LLC. A Korean sole proprietorship is legally a natural person operating under a trade name, not a separate legal entity.

- Individual → **W-8BEN** (for individuals)
- Business → **W-8BEN-E** (for entities)

Selecting Business with a sole proprietorship creates a document mismatch that stalls or kills verification — and the error message when this happens is not particularly helpful. This isn't documented anywhere obvious on Polar's onboarding screens.

Actual selections:

- **Using Polar as**: Individual
- **What are you selling**: Software / SaaS
- **Pricing model**: Usage-based (AI credit top-ups)

## 24 Agents, 880k Tokens, One Ad Channel Decision

Separate from the payment situation, I needed to commit to an advertising channel for preterview. Another `ultracode` session: "Thinking about running ads for preterview — is Instagram better? What target and budget is most cost-effective? Objective data, domestic and global."

24 agents ran in parallel. ~880k tokens consumed, 245 web tool-uses covering CPC benchmarks, conversion intent signals, and platform performance data across Korean and English sources.

The key quality gate: 13 core metrics went through adversarial verification before the final synthesis. LLM-generated research reliably inflates engagement numbers and blends correlation with causation. The adversarial pass caught and corrected several figures that looked plausible but didn't trace back to real primary sources.

Key findings:

- **At ₩500k (~$370) monthly budget: concentrate entirely on Naver Power Link** — don't split the budget
- Highest-value keywords by efficiency ratio:
  - `면접말버릇` (interview speech habits) — mid search volume, ₩70–120 CPC (~$0.05–0.09), high conversion intent
  - `면접습관교정` (interview habit correction) — similar profile
- Gaming industry interview keywords — too low search volume at this budget
- Instagram: high CPM, lower purchase intent for job-prep tools at this price point

Naver Power Link copy and Google RSA headlines were also drafted in the same session.

What shipped:

- GA4 (`G-ES6SENFGM2`) and Naver conversion tracking pixel added to `app/layout.tsx`
- New files: `components/marketing/analytics-scripts.tsx`, `lib/marketing/conversions.ts`, `lib/marketing/track.ts`
- Naver Biz Channel domain verification: passed same day

## Dental SEO via One Subagent Call

I maintain a parallel workstream managing content and SEO for a dental clinic. That work lives inside a dedicated `dental-clinic` subagent with its own state in `~/dental-promo/dongbaek-uddental/`.

From the main session, this was a single tool call: `Agent(1)`.

The subagent handled everything: read `clinic.json`, `cache/`, and `history.json` to restore context, ran `_kb/blog_probe.py` to measure live SERP positions for 7 keywords, wrote the digest.

Results:

- **Post #1** (implants keyword) → **back to blog tab #3**. Had dropped outside top 12 after a competitor content-flooding event. The oscillation is timing-dependent — the fix is publishing volume, not optimization.
- **Post #2** (pediatric dentistry) → **#1** on the primary target keyword. Not yet ranking on a secondary geographic keyword — first checkpoint scheduled 2026-07-23 per experiment EXP-004.

Digest written to `digests/measure-2026-06-27.md` (9.1KB), synced in a 28-file commit.

The pattern: the entire measurement cycle — context restoration, live SERP measurement, digest generation, sync — ran without touching the main session's context. One tool call as the boundary between concerns.

## Identifying a Pay-to-Win Award in 5 Minutes

An email arrived nominally from a Korean financial news outlet, nominating preterview.com for a "Good Startup Award" in the AI Mock Interview category.

Three phrases in the body were worth checking:

> "Coverage support (membership eligibility)"  
> "Morning edition 5-column advertisement placement"  
> "If you decline this award, we will have to recommend another company"

Four WebSearch calls, five minutes. Conclusion: classic paid-award + PR contract scheme. The award is the hook; the actual product being sold is a media membership or PR contract. The "if you decline we'll pick someone else" line is a manufactured-scarcity pressure mechanic.

Doesn't matter whether the email was genuine or spoofed. The economics are the same either way. Pass.

## Where Things Stand

| Item | Status |
|---|---|
| Paddle appeal | Awaiting decision |
| Polar onboarding | In progress |
| preterview payments | PayPal (global USD) live |
| Naver Power Link | Setup complete, pending domain approval |

## What Two Rejections Actually Taught Me

Attaching a Western Merchant of Record to a Korean developer's SaaS is not a documentation problem. It's a series of structural mismatches:

**KYC expiration windows.** Paddle's KYC window doesn't pause while you wait for other review steps. Come back too late and you start over from Customer Support.

**Automated domain categorization.** Classifiers are trained on majority-market products. An AI mock interview tool has no clean match in typical category trees. "Interview" → job prep → resume builder. No way to pre-clear this.

**Entity type selection.** Western fintech's Individual vs. Business split assumes sole proprietorships are incorporated entities. Korea's `개인사업자` is a natural person with a trade name, not a corporation. Wrong selection → W-8 form mismatch → stalled verification.

**Review timelines.** Published windows are aspirational. Real timelines for non-trivial domains run 4–10× longer.

Two rejections in 36 hours is approximately the median experience for Korean indie developers trying to attach a credit-based SaaS to a Western MoR without a foreign incorporated entity. The 28-minute parallel research session compressed 2–3 days of research into actionable findings. The adversarial verification pass is what separates usable output from plausible-looking noise — a distinction that matters a lot when you're making an infrastructure decision under time pressure.

**Tool stats across 7 sessions:** Bash ×230, Edit ×50, Read ×51, Workflow ×12, Agent ×1.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
