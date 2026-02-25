---
title: How I Designed an Entire SaaS Business Using Claude Alone
published: true
description: 9 sessions. 20 deliverables. 6 virtual experts. One day.
tags: [ai, saas, claude, solodev]
series: AI Fortune App Build Log
---

Six people are sitting in a conference room. The PM lays out a priority list. The biz dev lead argues: "We need to remove the login wall." The designer pushes back: "Then the report URL becomes public — what about sharing?" The developer cuts in: "If we don't add rate limiting first, we'll get hit with an API cost bomb."

All six of them are characters Claude made up.

When you're building solo, you only have your own perspective. PM thinking, designer thinking, business thinking — you're supposed to do all of it, but one person holding six viewpoints simultaneously is nearly impossible. So I asked Claude to do it. "Assemble 6 experts and have them review our current status."

Over the course of one day, I ran 9 sessions like this. Business strategy docs, six landing page designs in working HTML, expert panel meeting minutes, LLM cost analysis, global expansion architecture, Claude Code task files — 20 deliverables total.

## What the Expert Panel Actually Delivered — And Where It Failed

Six key decisions came out of the panel.

First, remove the login wall — the PM identified magic link auth as the biggest drop-off point. Second, cut free tier costs by 94% using algorithm formatting instead of full LLM calls. Third, register the business immediately (payment integration requires it). Fourth, GA4 and rate limiting are non-negotiable. Fifth, prioritize KakaoTalk sharing and OG images. Sixth, Korea PMF first — no English localization until paid conversion hits 3%.

Items three and four were genuine blind spots. When you're a developer, your brain defaults to "build first." The business perspective that "business registration is a prerequisite for payment integration" is easy to miss.

But I need to be honest about the limitations.

The designer character said "making the input form inline on mobile will increase conversion by 30%." There's no basis for that number. Claude generated a plausible-sounding statistic. Whether it's actually 30%, 15%, or 5% requires a real A/B test.

The biz dev character stated that "₹99 is the optimal price for the Indian market" with full confidence. That's a hypothesis, not validated data. Claude synthesized general pricing information from the web — it has never surveyed Indian users about their willingness to pay for a Four Pillars reading.

The bottom line: expert panels are excellent for "finding blind spots" and "expanding perspectives." They're genuinely useful for surfacing things you didn't think of. But any numbers or confident claims the panel produces should be treated strictly as hypotheses. Validation comes from production data, not simulated experts.

## What I Learned About Prompting

Three patterns that clearly worked best.

The first was "uploading context before asking." I had prepared two LLM comparison reports — benchmarks, pricing, agent capabilities across Claude, GPT, Gemini, and Grok. I uploaded both and asked: "Based on this data, what do you recommend for our project?" The difference between this and "what LLM should I use for a fortune app?" was night and day. Claude looked at the actual pricing tables and proposed role assignments: "Flash for free tier, Sonnet for paid, Opus for deep consultations." When I asked "why?", the answers came with specific numbers because the evidence was right there.

The second was "admitting what I didn't understand." After hearing the cost reduction explanation, I said: "I didn't get the cost reduction part." Claude recalibrated immediately — real dollar figures ($0.90 vs $0.15), analogies ("buying a new textbook every class"). The "professor vs. intern" metaphor from Part 2 of this series came directly from this exchange. Saying "I don't understand" pulls better explanations. Pretending you understand hurts both sides.

The third was "providing failure context." I said: "Last time you said the engine was perfect, and there were bugs. Don't let that happen again." One sentence, and Claude's QA recommendations jumped dramatically — cross-verification, external checks, "it's done when QA can't find bugs anymore." Feeding past failures into the prompt redirects the AI toward preventive design. Failure context is more powerful than success context in prompts.

## This Process Becomes a Framework

The sequence works for any project: share the vision → set strategy → expert review → design → cost analysis → expansion architecture → generate executable tasks. Each step builds on the context of the previous one, so outputs get more precise as you go deeper.

Using AI as a tool and thinking with AI are different things. As a tool: "write me the code." As a thinking partner: "is this the right structure? What am I missing? What perspective am I blind to?" For solo builders, the second mode is far more valuable.

That said, thinking with AI doesn't mean everything AI says is correct. Claims involving numbers almost always need verification. "30% conversion improvement" is a hypothesis, not a fact. AI excels at finding your blind spots, but it can't fill those blind spots accurately. That's data's job.

This series covers the build process up to launch. Real post-launch data — conversion rates, revenue, actual costs — will be shared separately. That's when the real answers arrive.

> "AI excels at finding your blind spots. But it can't fill them accurately. That's data's job."

---

*Full series: [Part 1 — Why You Shouldn't Let AI Do Fortune Telling](/blog/ai-fortune-architecture) | [Part 2 — Cutting LLM Costs by 88%](/blog/llm-cost-optimization) | Part 3 (this post)*
