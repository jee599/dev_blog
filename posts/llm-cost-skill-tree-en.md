---
title: "The Skill Tree That Can Cut Your LLM API Bill by 70%"
published: true
description: "Cost engineering fundamentals I wish I knew before building my first AI service"
tags:
  - ai
  - llm
  - costoptimization
  - productivity
id: 3286732
date: '2026-03-15T06:01:44Z'
hashnode_url: 'https://plzai.hashnode.dev/llm-cost-skill-tree'
blogger_url: 'https://jidonglab.blogspot.com/2026/03/the-skill-tree-that-can-cut-your-llm.html'
blogger_id: '983203369509856792'
---

The first thing I thought when starting an AI side project was “how does the cost structure even work?”

I’m a developer building a Korean fortune-telling app (saju — four-pillar astrology) and a real estate analysis service as side projects.

Both will use LLM APIs.

Before writing a single line of service code, I wanted to understand the cost structure.

So I dug in.

The difference between a pro and an amateur isn’t writing better prompts.

It’s engineering the cost structure.

---

## Token economics — the foundation of everything

Every LLM API charges by tokens.

One token is roughly 0.75 English words, or 1-2 Korean characters.

Here’s the thing that matters most.

Output tokens cost 3-5x more than input tokens.

When you say “explain in detail,” the model dumps a wall of text.

That’s all output tokens, and that’s all money.

If you don’t set `max_tokens`, the model will write as much as it can.

Telling it “answer in under 20 words” is literally a cost optimization technique.

Say your fortune service returns 500-token responses for “today’s one-line fortune.”

Set `max_tokens: 100` and add “one line, under 20 characters” to the prompt.

Output cost drops to a fifth.

---

## Sending every request to Opus is like sending every email by registered mail

Model routing.

This is the single biggest knowledge gap.

Current API prices.

Gemini Flash at $0.15 per million input tokens.

Haiku at $1.

Sonnet at $3.

Opus at $15.

Opus costs 100x more than Flash.

“What’s my fortune today” does not need Opus.

If you’re designing a fortune service, “today’s one-line fortune” works fine with Haiku.

Only “deep four-pillar analysis” needs Sonnet.

Most requests will be simple fortunes.

Sending all of them to Sonnet is bleeding money.

```py
# Don't do this — everything to Sonnet
result = await call_sonnet(prompt)  # $0.01+ per request

# Do this — routed
if request_type == "daily_fortune":
    result = await call_haiku(prompt)  # $0.001
elif request_type == "deep_analysis":
    result = await call_sonnet(prompt)  # $0.01
```

This alone can cut costs by 70%.

---

## Prompt caching — Anthropic’s hidden weapon

Surprisingly few people know about this.

Anthropic’s API lets you mark system prompts with `cache_control`, so repeated system prompts aren’t reprocessed every time.

```json
{
  "system": [
    {
      "type": "text",
      "text": "You are a master of Korean four-pillar astrology...(2000 tokens)",
      "cache_control": {"type": "ephemeral"}
    }
  ]
}
```

First call pays full price.

Every call after that hits the cache.

Input token cost drops by 90%.

System prompt is 2,000 tokens, 1,000 users a day.

Without caching: 2 million input tokens.

With caching: effectively 200K.

Tens of dollars difference per month.

For one line of code.

OpenAI doesn’t have this level of explicit caching yet.

The price sheets look similar, but once you factor in prompt caching, Anthropic becomes meaningfully cheaper in practice.

---

## Conversations get expensive fast — quadratically fast

Every message in a conversation gets resent as input tokens on each turn.

A 10-turn conversation means turns 1 through 9 are all retransmitted every time.

Costs grow as a cumulative sum, not linearly.

Summarize.

Use a sliding window.

Or use RAG.

For a fortune app, most conversations end in 1-2 turns.

But a real estate service where users go “analyze this apartment” → “what about nearby ones?” → “compare both.”

That’s where multi-turn costs stack up.

Build summary injection into the design from the start.

---

## Semantic caching — don’t pay twice for the same question

If 100 people ask “fortune for a male born March 15, 1990,” there’s no reason to make 100 API calls.

Semantic caching uses embeddings to detect similar queries and returns cached responses.

Redis plus a vector DB gets this done.

Fortune-telling has high overlap.

Same birth dates repeat.

Worth building into the architecture.

Another 30-50% cost reduction on top of everything else.

---

Add it all up.

Model routing saves 70%.

Prompt caching saves 90% on input tokens.

Semantic caching adds 30-50%.

In theory, 60-80% total cost reduction is achievable.

The point isn’t to optimize after launch.

It’s to design the cost structure before writing the first line of service code.

> "Cost structure is your moat. If you run the same service 70% cheaper, that’s your edge."