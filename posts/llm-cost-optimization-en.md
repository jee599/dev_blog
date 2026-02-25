---
title: How I Cut LLM API Costs by 88% With Three Techniques
published: true
description: $3,316/month → $406. Same service. Same quality. One-eighth the cost.
tags: [ai, llm, costoptimization, promptcaching]
series: AI Fortune App Build Log
---

When I first calculated the cost of running my fortune-telling app, I froze. One free analysis cost $0.085. At 1,000 daily users, that's $2,550/month — for a free tier. Even at a 3% paid conversion rate, revenue couldn't cover the free tier costs.

That's not a business. That's a charity.

So I tore apart the cost structure. Three changes. 88% reduction. To be precise, that's a simulation-based estimate — actual production numbers will depend on traffic patterns and cache hit rates. But the direction is clear.

## 1. Prompt Caching — Stop Buying the Same Textbook Every Class

Every LLM API call sends a "system prompt." The fortune interpretation guidelines, Five Elements rules, output format specs — identical every time, sent from scratch every time. Like buying a new textbook for every lecture.

Prompt caching sends this system prompt once, then reuses the cached version.

```
Doesn't change (cache): interpretation guidelines, element rules, output format
Changes every time (fresh): user's birth data, engine calculation JSON
```

The cost difference:

```
Claude cache_control:    90% reduction on cache hits
Gemini Context Caching:  75% reduction
OpenAI prefix caching:   50% reduction (automatic)
```

For our fortune prompt specifically: the system prompt is about 2,000 tokens, user-specific birth data JSON is 300-500 tokens. Roughly 80% of each request is identical content. Caching alone cuts input costs to nearly one-fifth.

## 2. Model Routing — Stop Calling a Professor for Every Question

At first, I ran everything through Claude Sonnet — free and paid. "Better model, better results, right?"

$4,500 vs $238. Same work. Same output quality. 19x difference.

That's model routing. When an intern can do the job, calling a professor at 100x the hourly rate is just waste.

```
Simple free summary (3 lines)  → Gemini Flash   ~$0.001/request
Standard paid analysis (10sec) → Claude Sonnet   ~$0.02/request
Deep premium consultation      → Claude Opus     ~$0.045/request
```

The Gemini Flash number: system prompt 1,500 tokens + birth JSON 300 tokens + output 200 tokens ≈ 2,000 tokens total. At Flash pricing (input $0.075/1M, output $0.30/1M), that's $0.0002–$0.001 per request. With caching, even lower.

But free analysis barely needs an LLM at all. The engine already computes Five Element distribution and Ten Gods relationships accurately. Format that into text with code — $0 LLM cost. Add one line of yearly fortune from a lightweight model — $0.001.

Free tier breakdown:

```
Personality:     algorithm formatting  → $0
Career fit:      algorithm formatting  → $0
Yearly fortune:  lightweight 3-line    → ~$0.001
Summary score:   lightweight 1-line    → ~$0.001
Total:           ~$0.002/request
```

From $0.085 to $0.002. A 97% cut. Users barely notice the difference — the free tier is a teaser anyway. The real depth lives in the paid analysis.

## 3. Structured Output — Cut the Small Talk

LLMs are chatty. "Let me begin the analysis. First, looking at the Five Elements..." That preamble costs tokens. And output tokens are 3-5x more expensive than input tokens.

Force a JSON schema and the fluff disappears. Here's what the prompt looks like:

```
Respond ONLY with the following JSON schema. No preamble, no explanation, just JSON.

{
  "personality": "2-3 sentence personality analysis",
  "career": "2-3 sentence career aptitude",
  "yearly_fortune": "1-2 sentence yearly forecast",
  "summary": "one-line overall assessment"
}
```

The difference:

```
Before (free-form response):
"Hello! I'd like to share my analysis of your Four Pillars chart.
 Looking at the elemental distribution, we can see a strong presence
 of Wood energy, which suggests growth and creativity, particularly
 in fields that involve..."
→ ~200 tokens

After (schema-enforced):
{"personality": "Strong Wood energy in the chart. Creative and...",
 "career": "Well-suited for planning, content, education...",
 "yearly_fortune": "First half brings momentum for change...",
 "summary": "A year of growth. Structure favors new ventures."}
→ ~80 tokens
```

60% reduction in output tokens. Since output costs 3-5x more than input, cutting output is the most direct way to reduce spend. Bonus: the frontend just parses JSON instead of scraping text, so response handling gets cleaner too.

## The Combined Effect

These are independent estimates combined into a simulation. Real numbers will vary with cache hit rates, traffic patterns, and free-to-paid ratios — treat this as order-of-magnitude, not exact.

```
Before (all Sonnet, no caching):   ~$3,316/month

Change 1 — Prompt caching:        ~80% reduction on input costs
Change 2 — Model routing:         ~97% reduction on free tier costs
Change 3 — Structured output:     ~60% reduction on output tokens

Combined estimate:                 ~$400/month (~88% reduction)
```

Based on 1,000 requests/day with a 97:3 free-to-paid ratio. Since free requests dominate, change 2 (model routing) has the biggest impact, followed by caching, with structured output primarily affecting paid-tier costs.

None of this is specific to fortune telling. Any LLM-powered service can use these same techniques almost as-is. The core idea is simple. Cache what doesn't change. Use cheap models where they're sufficient. Minimize output when you can.

> "Don't call a professor for every question. When an intern can do the job, calling a professor costs 100x the hourly rate."

---

*Next: How I Designed an Entire SaaS Business Using Claude Alone — 9 Sessions, 20+ Deliverables*
