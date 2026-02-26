---
title: 'GPT-5 vs Gemini Flash vs Claude Opus — 6 Models, Same Fortune, Real Costs'
published: true
description: I ran the same birth chart through 6 LLMs. $0.0003 to $0.0442 per request. Here's what actually happened.
tags:
  - ai
  - llm
  - webdev
  - productivity
---

I'm building a saju app — saju is Korean four-pillar fortune-telling based on birth date/time. When it came time to pick LLM providers for production, I didn't trust benchmarks. I needed to run my actual prompts with real birth data and compare.

So I tested 6 models head-to-head.


## The Setup

Same input across all models: female, born April 28, 1995, 11:15 AM, solar calendar. Same system prompt forcing JSON output. Each model got its own token-saving optimizations — OpenAI got `response_format: { type: "json_object" }`, Gemini got `responseMimeType: "application/json"`, Claude got prompt caching with `cache_control: { type: "ephemeral" }`.


## GPT-5 Broke My API Calls

First call to GPT-5.2 returned a 400 error immediately.

```
Unsupported parameter: 'max_tokens'
```

Turns out GPT-5 models dropped `max_tokens` entirely. It's `max_completion_tokens` now. And `temperature: 0.7`? Also gone. GPT-5 only accepts temperature of 1.

```typescript
// Before — GPT-4 era
{ max_tokens: 4096, temperature: 0.7 }

// After — GPT-5 compatible
const isGpt5 = model.startsWith("gpt-5");
{
  ...(isGpt5
    ? { max_completion_tokens: 4096 }
    : { max_tokens: 4096 }),
  temperature: isGpt5 ? 1 : 0.7,
}
```

Two lines of code, thirty minutes of debugging. The error messages weren't helpful.


## The Results

**GPT-5.2** — 20.5s, $0.0117. Practical, specific advice. Mentioned exact timeframes like "career transition likely in late 2026." Clean JSON every time.

**GPT-5-mini** — 27.5s, $0.004. Slower than the full model somehow. JSON occasionally came back with empty text fields. Feels unstable.

**Gemini 3 Flash** — 10.3s, $0.0003. Fastest and cheapest by far. Got the saju terminology right — correctly identified the day pillar as 甲寅. Output was shorter but solid for a free tier.

**Claude Opus 4.6** — 36.6s, $0.0442. Slowest and most expensive. But the output was on another level. It showed its work — calculated the four pillars (을해년, 경진월, 기사일, 경오시) before interpreting. Deepest analysis of the bunch.

**Claude Sonnet 4.6** — 529 error. Overloaded. Failed all 3 attempts.

**Claude Haiku 4.5** — 5.9s, $0.0037. Short but accurate. Incredible value.


## The Price Gap Says Everything

Cheapest (Gemini Flash) vs most expensive (Claude Opus):

**$0.0003 vs $0.0442.**

That's 147x. Same input. Same prompt.

Opus is genuinely better. But at 1,000 requests/day, Opus costs $1,326/month. Flash costs $9. You can't run Opus on a free tier.


## The Decision

Kept it simple for now. Free tier gets Gemini Flash, paid tier gets GPT-5.2. Flash dominates on speed and cost. GPT-5.2 gives the most actionable, well-structured output.

When I build a premium tier later, that's where Opus goes. The "master fortune teller reads your chart personally" experience. At that price point, $0.044 per request makes sense.

> "Don't call a professor for every question. Sometimes the TA has the answer you need."
