---
title: "The Honest Hermes 4 Production Checklist (April 2026 Edition)"
published: true
description: "Which Hermes 4 variant for which job, what it costs, what will break, and what the Llama 3 Community License actually means when your MAU is 12 and scaling. Part 4 of 4."
tags:
  - ai
  - llm
  - opensource
  - agents
series: "The Hermes 4 Teardown"
canonical_url: https://jidonglab.com/posts/2026-04-18-hermes-4-part-4-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-18-hermes-4-production-checklist'
id: 3527813
date: '2026-04-20T15:42:19Z'
---

Four posts, one question that actually matters: should you ship this thing?

After three posts pulling apart Hermes 4's benchmarks, tool-calling architecture, and training stack, I've earned an opinion. The 405B is the wrong model for most workloads — including most of what Nous's own marketing implies. The 14B is probably the one you want. And the license situation is messier than the model cards suggest.

Here's the complete picture before you commit to an infrastructure decision.

---

## TL;DR

The 14B variant (Apache 2.0, ~28 GB FP16, Qwen3 base) is the clearest path to production for most teams. The 405B is impressive on benchmarks but costs ~$810 GB FP16 to self-host and $3/M output tokens on OpenRouter — a price that only makes sense for a narrow set of workloads. The 70B and 405B carry Meta's Llama 3 Community License with a 700M MAU cap. The 36B's license is unverified as of this writing. All variants share an August 2024 knowledge cutoff. Long-context reliability degrades well before the nominal 131K ceiling. You need your own guardrails.

---

## Series Recap in 60 Seconds

[Part 1](https://dev.to/jee599/the-96-3-is-a-trap-what-hermes-4-405b-actually-changed) covered why the 96.3% MATH-500 headline is real but misleading. That score requires reasoning mode ON, and Artificial Analysis scored the 405B at rank 22 of 37 in non-reasoning mode. The benchmark is right; the implication that this beats everything else is not.

[Part 2](https://dev.to/jee599/hermes-4s-tool-calling-is-trained-as-a-separate-skill-heres-why-your-agent-cares) went deep on why Hermes 4's tool calling is actually trustworthy — because it was RL-trained as a first-class skill via Atropos, not bolted on post-hoc. Schema adherence and structured output are among the model's genuine strengths. That distinction matters when you're building agents.

[Part 3](https://dev.to/jee599/dataforge-atropos-and-a-30k-token-guillotine-reverse-engineering-hermes-4s-training-stack) reverse-engineered the training stack: DataForge's DAG-based synthetic pipeline, Atropos's ~1,000 task verifiers, and the second-stage SFT that hard-caps `<think>` traces at 30,000 tokens. That length-control intervention cut overlong outputs by 78.4% on AIME'24 — at the cost of 4.7–12.7% benchmark accuracy. You pay for predictability.

---

## The Variant Decision Tree

There are four models in the Hermes 4 family right now. They are not interchangeable, and the right one depends on more than parameter count.

The 14B is built on Qwen3. It ships under Apache 2.0 — clean, fully commercial, no MAU cap, no negotiation with anyone. FP16 sits at roughly 28 GB of VRAM, which fits a single RTX 6000 Ada. It uses ChatML format. For structured extraction, schema-heavy agentic tasks, or any workload where license clarity matters, this is the default answer.

The 36B (Hermes 4.3) is the newest entry, released in November 2025 on the decentralized Psyche network. It's built on ByteDance Seed 36B and currently holds the best RefusalBench score in the family. The problem: both the chat format and the license are listed as unverified in my research. I would not make a production licensing call on this model until the Hugging Face model card confirms the terms explicitly. Use it for evaluation; hold on production.

The 70B is solid. MATH-500 at 95.6%, RefusalBench at 59.5%, based on Llama 3.1 70B. But it inherits the Llama 3 Community License, needs ~140 GB FP16 to self-host, and is harder to justify against the 14B unless you genuinely need the extra capability headroom.

The 405B is the benchmark flagship. It is also the most expensive model in the lineup by a considerable margin, and the one most people reach for first when they shouldn't.

| Variant | License | FP16 VRAM | Best Use Case | Caution |
|---|---|---|---|---|
| 14B | Apache 2.0 | ~28 GB | Structured extraction, agents, production | None — cleanest path |
| 36B (4.3) | Unverified | ~72 GB | Evaluation, RefusalBench testing | License unclear |
| 70B | Llama 3 Community | ~140 GB | High-accuracy reasoning without 405B cost | MAU cap, VRAM demand |
| 405B | Llama 3 Community | ~810 GB | Critical reasoning via API only | Cost, MAU cap, base aging |

---

## The License Trap Nobody Warns You About

The Llama 3 Community License reads fine until it doesn't. Meta permits commercial use — but caps it at 700 million monthly active users. If you cross that threshold, you need a separate license from Meta.

For an indie developer with 12 MAUs today, this feels irrelevant. It isn't. You're building something. If it works, it grows. The license clause doesn't trigger at launch; it triggers at the moment you'd least want to deal with it. You'd have to either renegotiate with Meta directly, migrate your stack to a different base model, or stop shipping while you sort it out.

I'm not saying the Llama license is bad. I'm saying it's a constraint you're accepting when you build on the 70B or 405B, and most people don't think about it until they're inside the problem.

The 14B has no such clause. Apache 2.0 means what it says: do what you want with it, commercially, at any scale. That's the actual clean path in this lineup, and it's not the 405B.

If you're evaluating the 36B, the ByteDance Seed license terms need to be verified before any production commitment. "Likely permissive" is not a legal posture.

---

## Failure Modes That Will Bite You

The knowledge cutoff is August 31, 2024. That's not a Hermes problem — it's inherited from the Llama 3.1 base, and Nous does post-training, not pretraining. But it means anything that happened in the last 20 months is a blind spot. If your application touches current events, recent documentation, or anything time-sensitive, you're building a RAG layer whether you planned to or not.

Reasoning traces can still run long. The 30K-token hard cap from the length-control SFT addressed the worst cases — overlong outputs dropped from 28.2% to 6.1% on AIME'24. But that cap is a ceiling, not a guarantee of concise output. In practice, complex prompts can still generate multi-thousand-token `<think>` blocks before the final response. Account for that in your latency budget.

Long-context performance degrades well before 131K tokens. The nominal context window is inherited from Llama 3.1 and community consensus is that effective recall weakens substantially past ~64K. There are no published NIAH (needle-in-a-haystack) results specific to Hermes 4. Treat 64K as your practical ceiling unless you've tested your specific retrieval pattern.

Neutral alignment means the model will engage with prompts that other models refuse. The RefusalBench results (57.1% for the 405B vs. GPT-4o's 17.67%) are a feature for adversarial testing workloads, and a liability if you're shipping a consumer-facing product without your own guardrails layer. This is not a model that ships safe by default. It ships capable. The difference matters.

There are also early community reports of repetition at low temperatures, consistent with complaints from Hermes 3 users. Not formally documented, but worth testing in your eval set before you lock in sampling parameters. The recommended defaults are `temperature=0.6, top_p=0.95, top_k=20`.

---

## The Hosting Math

OpenRouter prices the 405B at $1 per million input tokens and $3 per million output tokens. That sounds cheap until you do the arithmetic on volume.

Say your application generates $100/month on OpenRouter. That's a comfortable, manageable API bill. Now imagine you want to self-host the same model instead. The 405B requires roughly 8x H100 80GB GPUs at minimum — and that's FP8. At cloud rates, 8x H100 runs $20,000–$30,000 per month before you factor in storage, networking, and the engineering time to operate it.

The break-even point doesn't exist for small teams. You would need to be spending tens of thousands per month on OpenRouter before self-hosting the 405B becomes financially rational. And by the time you're at that scale, you have an ML infrastructure team to evaluate the decision properly.

The 14B changes this math entirely. At ~28 GB FP16, it fits on a single RTX 6000 Ada (roughly $300–400/month on cloud, less if you own the hardware). You can self-host it today on a machine you might already have.

The practical rule: self-host the 14B, rent the 405B if and when you need it.

---

## What I'd Actually Ship

For a structured-extraction agent today, I'd use Hermes 4 14B. Apache 2.0 license, schema adherence RL-trained as a first-class skill (Part 2 covers why that matters), fits on a single RTX 6000 Ada, ChatML format with clean tool-call parsing via SGLang's `--tool-call-parser qwen25`. No license negotiation, no MAU ceiling, no multi-GPU cluster.

For a workload that genuinely requires frontier-level reasoning — complex multi-step math, hard science QA, the kind of task where you'd otherwise reach for o3 or Gemini 2.5 Pro — I'd use the 405B via OpenRouter with `reasoning.enabled: true`. The MATH-500 score (96.3%) and GPQA Diamond (70.5%) are real numbers in reasoning mode. Pay $3/M output and don't build the infrastructure.

I would not ship the 70B as a primary production model today. The license and VRAM requirements give you less flexibility than the 14B and less raw capability than the 405B. It lives in an awkward middle.

I would not make a production commitment on the 36B until the license is confirmed. The benchmark numbers are interesting — new SOTA on RefusalBench — but "unverified license" is a hard stop.

One more thing to close the loop back to Part 1: the 96.3% MATH-500 figure is what Nous leads with, and it's accurate. But Artificial Analysis ranked the 405B 22nd of 37 models in non-reasoning mode at a "particularly expensive" price point. Both of those data points are true at the same time. The model is genuinely strong in reasoning mode for reasoning tasks. It's a mid-tier expensive option for everything else. Know which workload you're actually running.

---

> The honest production checklist for any open-weight model is never about peak benchmark scores. It's about which failure modes you're willing to own, which license terms you're willing to live inside, and whether the hosting math makes sense at your scale. Hermes 4 is a serious, well-engineered model family. For most teams, the right version of it is 14 billion parameters under Apache 2.0 — not the flagship.

---

## Related

- [66.5% of My Claude Code Tokens Were Wasted. A 200-Line Wrapper Got Them Back.](https://dev.to/jee599/66-5-of-my-claude-code-tokens-were-wasted-a-200-line-wrapper-got-them-back)
- [I Built an AI Newsletter for Myself. 11 Subscribers, 49 Posts, Zero Regrets.](https://dev.to/jee599/i-built-an-ai-newsletter-for-myself-11-subscribers-49-posts-zero-regrets)
