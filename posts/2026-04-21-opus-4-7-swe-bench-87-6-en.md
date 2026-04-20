---
title: "Claude Opus 4.7 Hit 87.6% on SWE-bench. The Story Is What It Didn't Charge You."
published: true
description: "Opus 4.7 jumps from 80.8% to 87.6% on SWE-bench Verified, adds 3× vision resolution, and keeps pricing flat at $5/$25 per million. The tokenizer quietly bills you more. Here's the real cost math."
tags:
  - ai
  - claude
  - llm
  - engineering
canonical_url: https://jidonglab.com/posts/2026-04-21-opus-4-7-analysis-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-21-opus-4-7-swe-bench-87-6'
---

Claude Opus 4.7 scored 87.6% on SWE-bench Verified — up from 80.8% on Opus 4.6, a +6.8 point absolute jump announced on April 17, 2026. The sticker price stayed exactly where it was: $5 per million input tokens, $25 per million output. Anthropic shipped faster code, better vision, a new effort level, and a non-engineer product in the same week — and didn't raise the price on any of it.

That's not a product decision. That's a market-positioning decision.

> **TL;DR:** Opus 4.7 is a meaningful coding-agent upgrade at flat sticker price. The tokenizer may quietly inflate your bill 0–35% depending on your input text — measure it before you budget. The 87.6% SWE-bench number is real and large. The flat pricing is Anthropic betting developer-agent share over near-term margin. Claude Design, shipping the same week, is their first serious non-engineer product.

---

## Why +6.8 Points on SWE-bench Is Bigger Than It Looks

SWE-bench Verified measures whether a model can actually resolve real GitHub issues — not toy problems, not summarization, not reasoning puzzles. It's the closest benchmark we have to "does this thing write code that ships."

Going from 80.8% to 87.6% in one model generation is not incremental. For context, Opus 4.6's CursorBench score was 58%; Opus 4.7 brings that to 70%. Rakuten's internal SWE-bench variant shows 3× more production tasks resolved. Each of those numbers is measuring something slightly different — GitHub issues, cursor-driven IDE completions, production task resolution — and the direction is consistent across all three.

I ran Opus 4.7 via the API this past weekend on a real agentic workflow: a multi-file TypeScript refactor with test generation and a final diff review pass. I'm not going to give you fake numbers on my end — I didn't instrument it formally — but qualitatively, the model handled ambiguous intermediate steps better than I expected. It asked fewer clarifying questions when the context was sufficient and hallucinated fewer import paths. Whether that maps cleanly to the benchmark gain, I can't say. But the benchmark gain is large enough that I was looking for it in practice, and something measurable is there.

The benchmark jump matters most because it compresses the gap to human senior-engineer performance on well-scoped tasks. 87.6% is not "better than most humans" — the long tail of weird repo configurations is hard and the benchmark knows it. But it's the kind of score where an agentic loop running Opus 4.7 stops being a curiosity and starts being a production dependency.

---

## The Flat Pricing Is the Real Strategic Signal

Anthropic kept Opus 4.7 at $5/$25 per million tokens. That's unchanged from Opus 4.6. They also expanded availability simultaneously: Amazon Bedrock across 27 self-serve regions, Google Cloud Vertex AI, and Microsoft Azure AI Foundry — all on the same day as GA.

Think about what that means structurally. A better model, available on every major cloud runtime, at the same price, with no premium for the new capabilities. That is not a company trying to expand margin. That is a company trying to maximize the number of developers who run their model in production.

OpenAI's strategy through 2025 was tiered pricing as capability expanded — higher scores, higher prices. Anthropic's Opus 4.7 launch is a direct counter to that. If you're an engineering team evaluating coding agents today, the switching cost to Opus 4.7 is zero on the pricing side. The only friction is integration time.

This is worth watching because flat pricing at this scale is a bet. Anthropic has to believe that winning developer-agent share now converts to durable lock-in later — through context, through Claude Code adoption, through the Anthropic ecosystem — rather than just racing to the bottom on token economics. Whether that bet pays off is a 2027 question. Right now, the pricing is a gift to anyone building on top of it.

If you're building multi-step agentic pipelines, the [contextzip approach to token efficiency](https://dev.to/jee599/66-5-of-my-claude-code-tokens-were-wasted-a-200-line-wrapper-got-them-back) becomes even more relevant when per-token sticker price is held flat — your budget goes further, but only if you're not wasting tokens on repeated context.

---

## The Tokenizer Tax You Pay Without Noticing

Here is where I need to be honest about uncertainty.

The sticker price is flat. But multiple third-party analyses published around the 4.7 launch claim the new tokenizer splits the same input text into more tokens than the 4.6 tokenizer did. Some outlets quoted a 47% increase. Anthropic's own documentation gives a range of **1.0–1.35×** — meaning the same text could tokenize into anywhere from the same number of tokens to 35% more. [unverified: The 47% figure comes from a single third-party analysis; I have not independently confirmed it, and Anthropic's stated range is 1.0–1.35×.]

What this means in practice: if your input text tokenizes at 1.35× the old rate, you're paying 35% more per request at flat sticker price. At 1.0×, nothing changes. Most use cases probably sit somewhere in between, depending on code density, comment volume, and whitespace.

The way to measure this yourself is straightforward. Take a representative sample of your actual production inputs — a few hundred requests, ideally with the same prompts you use in your pipeline. Count tokens with Anthropic's tokenizer library before and after migrating to `claude-opus-4-7`. The ratio you get is your actual cost multiplier, not the 1.0–1.35× range that covers all users in aggregate.

I'd suggest doing this before any budget conversation with your team. "Flat pricing" is accurate on the sticker. "Flat cost" may not be.

---

## 3× Vision Resolution + xhigh Effort + 1M Context: What This Enables

Opus 4.7 now handles images up to 2,576 pixels on the long edge — approximately 3.75 megapixels, roughly 3× the prior resolution. The new `xhigh` effort level sits between the existing `high` and `max` settings, giving you a middle gear for latency-sensitive workflows that still need more reasoning depth than `high` provides.

Combined with 1M token context and 128k max output, this starts to look like a single-model agent runtime. One model call can now ingest a full codebase, a set of high-resolution screenshots or design mockups, and a long conversation history — then produce a 128k-token output in a single pass. That scope was previously distributed across multiple model calls with context stitching.

For agentic workflows that involve UI analysis, the 3× vision resolution is not cosmetic. At 2,576 px, you can feed a full-resolution Figma export or a dense dashboard screenshot and expect the model to accurately read small-type labels, color-coded states, and layout grids. At the old resolution, that kind of input required pre-processing or downsampling workarounds.

The `xhigh` effort level matters most for workflows where `high` undershoots and `max` is too slow for the loop frequency. That middle gear is a practical addition if you're running multi-step reasoning inside a tight latency budget.

For deeper background on how effort levels interact with reasoning quality in production agentic systems, the discussion in [The Honest Hermes 4 Production Checklist](https://dev.to/jee599/the-honest-hermes-4-production-checklist-april-2026-edition) is relevant even though it covers a different model — the tradeoffs transfer.

---

## Claude Design Is the Non-Engineer Play

Anthropic shipped Claude Design the same week as Opus 4.7 GA — April 17. It generates prototypes, slides, one-pagers, and design systems inside the chat interface, free for Pro, Max, Team, and Enterprise plans, with hand-off to Claude Code.

This is Anthropic's first product pitched primarily at non-engineers. Every previous Claude product — the API, Claude Code, MCP integrations, the prompt engineering tooling — assumed a technical user. Claude Design does not. It assumes someone who knows what they want to communicate visually and doesn't want to open Figma or brief a designer.

The strategic framing is clear when you see it next to Opus 4.7. The model launch locks in the developer segment. Claude Design opens the adjacent non-technical segment — PMs, marketers, founders. Both ship the same week, both sit inside the same subscription tiers, and the hand-off from Design to Code creates a collaboration loop that keeps both user types in the Anthropic ecosystem.

This is a direct counter to OpenAI's consumer expansion through GPT image generation and canvas features. It's also the first time Anthropic has signaled they're not just competing for API spend — they're competing for the full product-team workflow.

For reference, the model capability framing here connects directly to the competitive analysis I ran on [Hermes 4 and what changed at the architecture level](https://dev.to/jee599/the-963-is-a-trap-what-hermes-4-405b-actually-changed) — the coding-agent specialization pattern is consistent across labs right now.

---

## What I'm Actually Watching

The 87.6% SWE-bench number is real and it's large. The flat pricing is a deliberate positioning choice, not an oversight. The tokenizer may cost you 0–35% more per request at the same sticker price — measure it on your actual inputs before budgeting. The vision upgrade and `xhigh` effort level make the model more useful as a single-runtime agent. Claude Design is the first sign Anthropic is competing for the full product workflow, not just the API.

The question for 4.8 or whatever comes next is whether the coding-agent moat deepens fast enough to justify the flat-price bet before a competitor prices below them. That math plays out over the next two to three model generations.

> The flat sticker price is not Anthropic being generous. It's Anthropic deciding that developer adoption now is worth more than margin now. If you're building coding agents in 2026, they're pricing specifically to get you locked in before you decide.
