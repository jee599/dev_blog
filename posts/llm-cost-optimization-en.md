---
title: How I Cut LLM API Costs by 88%
published: true
description: 'One free analysis costs $0.085. At 1,000 users/day, that''s $2,550/month. Here''s how I got it to $406.'
tags:
  - ai
  - webdev
  - llm
  - costoptimization
id: 3285130
date: '2026-02-25T16:06:42.188Z'
hashnode_url: 'https://plzai.hashnode.dev/llm-cost-optimization'
---

One free analysis: $0.085. At 1,000 daily users, that's $2,550/month — for a free tier.

Even at a 3% paid conversion rate, revenue couldn't cover the free tier costs.

That's not a business. That's a charity.

So I tore apart the cost structure.


---

## Prompt Caching — Stop Buying the Same Textbook Every Class

Every LLM API call sends a "system prompt." The fortune interpretation guidelines, Five Elements rules, output format specs — identical every time, sent from scratch every time.

Like buying a new textbook for every lecture.

Prompt caching sends this system prompt once, then reuses the cached version.

```
Doesn't change (cache): interpretation guidelines, element rules, output format
Changes every time (fresh): user's birth data, engine calculation JSON
```

Claude's cache_control cuts input costs by 90% on cache hits. Gemini Context Caching gives 75%. OpenAI's prefix caching applies automatically at 50%.

In real numbers: if the system prompt is 2,000 tokens and user data is 500 tokens, 80% of the input is cacheable.

Input cost drops to nearly one-fifth.


---

## Model Routing — Stop Calling a Professor for Every Question

At first, I ran everything through Claude Sonnet — free and paid. "Better model, better results, right?"

**$4,500 vs $238.** Same work. Same output quality. 19x difference.

When an intern can do the job, calling a professor at 100x the hourly rate is just waste.

```
Simple free summary (3 lines)  → Gemini Flash   $0.001/request
Standard paid analysis (10sec) → Claude Sonnet   $0.02/request
Deep premium consultation      → Claude Opus     $0.045/request
```

Free analysis **barely needs an LLM at all.** The engine already computes Five Element distribution and Ten Gods relationships accurately. Format that into text with code — $0 LLM cost. Add one line of yearly fortune from a lightweight model — $0.001.

The free tier breaks down like this: personality analysis and career fit use algorithm formatting at $0 each, yearly fortune gets a lightweight 3-line summary at $0.001, and the overall score is another lightweight 1-line call at $0.001. Total: $0.002 per request.

From $0.085 to $0.002. **A 97% cut.**

Users barely notice the difference — the free tier is a teaser anyway. The real depth lives in the paid analysis.


---

## Structured Output — Cut the Small Talk

LLMs are chatty. "Let me begin the analysis. First, looking at the Five Elements..." That preamble costs tokens. And output tokens are **3-5x more expensive** than input tokens.

Force a JSON schema and the fluff disappears.

```
Before: "I'd like to share the analysis results. Your elements..." (200 tokens)
After:  { "personality": "...", "career": "..." }                 (80 tokens)
```

<details>
<summary>Example JSON schema used</summary>

```json
{
  "personality": "personality analysis text",
  "career": "career aptitude text",
  "yearly_fortune": "this year's fortune summary",
  "summary": "one-line overall assessment"
}
```

Add "Respond only in this JSON structure" to the prompt. No preamble, just data.

</details>

50-80% reduction in output tokens. Since output is the expensive side, the impact is significant.


---

## The Combined Effect

```
Before optimization:   $3,316/month (1,000 requests/day)
Prompt caching:        → $1,660 (-50%)
Model routing:         → $580  (-65%)
Structured output:     → $406  (-23%)
After optimization:    $406/month (88% reduction)
```

These numbers are simulation estimates based on 1,000 requests/day. Actual operating data will be shared post-launch.

All three strategies are independent — apply them in any order or all at once. And none of this is specific to fortune telling. Any LLM-powered service can use these same techniques almost as-is.

The core idea is simple. Cache what doesn't change. Use cheap models where they're sufficient. Minimize output when you can.

> "Don't call a professor for every question. When an intern can do the job, calling a professor costs 100x the hourly rate."
