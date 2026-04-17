---
title: "The 96.3% Is a Trap: What Hermes 4 405B Actually Changed"
published: true
description: "Hermes 4 hit 96.3% on MATH-500 and 57.1% on RefusalBench — but the real story is the hybrid <think> toggle on a single checkpoint, not the leaderboard numbers. Part 1 of a 4-part teardown."
tags:
  - ai
  - llm
  - opensource
  - agents
series: "The Hermes 4 Teardown"
canonical_url: https://jidonglab.com/posts/2026-04-17-hermes-4-part-1-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-17-hermes-4-405b-teardown'
---

Hermes 4 405B hit 96.3% on MATH-500 when it launched on August 26, 2025. That number got copy-pasted into every coverage headline within 24 hours. Most of those headlines missed the actual story.

I've been running Hermes 4 on OpenRouter at $1/M input and $3/M output since the launch week, and I've had the 14B running locally on Apache 2.0. The benchmark framing bothered me from the start — not because the numbers are wrong, but because they describe a model that most readers aren't going to get when they hit "deploy."

This post is the correction.

---

**TL;DR**

Hermes 4 405B is not "Llama 3.1 but better at math." It is a single checkpoint that switches between standard inference and chain-of-thought reasoning via a `<think>` toggle — and the 96.3% MATH-500 score is the *reasoning-on* number, which most hosted deployments do not enable by default. The more interesting number is 57.1% on RefusalBench, which reflects a deliberate "neutral alignment" stance that has serious production implications. Artificial Analysis ranked the 405B #22 of 37 models specifically because they benchmarked it in non-reasoning mode. That detail alone changes who should care about this model and why.

---

## Why 96.3% on MATH-500 Is Less Impressive Than It Sounds

The 96.3% figure is real. It comes directly from the technical report published alongside the weights, and MarkTechPost and EmergentMind both confirmed it from the arXiv submission (2508.18255). On AIME 2024, Hermes 4 405B scores 81.9%, and 78.1% on AIME 2025. Those are strong numbers for an open-weight model.

The problem is the comparison class. Nous positioned the 405B as "competitive with DeepSeek R1 and Qwen3 235B." The HN launch thread (item 45037064) pushed back on that immediately: the community consensus was that DeepSeek R1 at 671B outperforms Hermes 4 on raw benchmarks, and Qwen3 235B is in the same conversation. "Competitive with" is doing a lot of load-bearing work in that sentence.

Then there is the Artificial Analysis number, which is the one benchmark operators actually use when they are deciding what to pay for. Artificial Analysis scored Hermes 4 405B at 18 on their Intelligence Index, placing it #22 out of 37 tracked models — below the 21-point average, and explicitly flagged as "below average in intelligence and particularly expensive." They benchmarked it in non-reasoning mode. That is not a flaw in their methodology; that is how most API users will hit the model. The 96.3% and the #22 ranking describe the same model running in different configurations. You do not get to pick which one is the "real" score.

The HN thread had another memorable moment. Someone opened the Hermes 4 website on a GTX 1050 Ti and watched the decorative JavaScript blob peg the GPU at 99%. iPad users reported load times over 30 minutes. Chromebooks locked up. The launch-day HN conversation was mostly about the website, not the model — which tells you something about how the release was packaged versus how it landed. A Nous employee clarified in the thread that the cyberpunk system prompt on the demo was not a default, just a demo configuration. Small thing, but it matters when you are evaluating what the model actually ships with.

GPQA Diamond came in at 70.5%, and LiveCodeBench at 61.3%. Arena-Hard v1 is 93.7%. These are respectable numbers. But the one that jumped out at me — the one that actually changes how you should deploy this model — is 57.1% on RefusalBench.

---

## The `<think>` Toggle Is the Real Product

Here is what Nous actually shipped that is technically novel: a single model checkpoint that can reason or not reason depending on how you invoke it. There is no separate "Hermes 4 Reasoning" variant and "Hermes 4 Instruct" variant. You get one set of weights and a toggle.

Three ways to activate reasoning mode. First, pass `thinking=True` to `apply_chat_template()`. Second, include a system prompt that instructs the model to use `<think></think>` tags. Third, on OpenRouter, set `reasoning.enabled: true` in your request. When reasoning is on, the output shape looks like this:

```
<|start_header_id|>assistant<|end_header_id|>
<think>
…internal chain of thought…
</think>
Final response…<|eot_id|>
```

When reasoning is off, the model responds immediately — no preamble, no `<think>` block, just the answer.

The 96.3% MATH-500 score requires reasoning mode on. The Artificial Analysis #22 ranking was measured with it off. Both are valid states of the same checkpoint. If you are benchmarking the model for your use case, you need to know which mode your production calls will run in, because the performance gap between the two is not marginal.

The Moonlight's technical report review confirmed something specific about the RefusalBench result: the 57.1% is also a reasoning-mode number. The model literally reasons itself into compliance with requests it would otherwise refuse. The `<think>` block processes the request, finds a frame where engagement is defensible, and then responds. That is a qualitatively different failure mode than a model that is simply undertrained on refusal.

For agent workflows, the single-checkpoint design is genuinely useful. You can run lightweight, fast calls in non-reasoning mode for routing and classification, then flip reasoning on for tasks that need it — without maintaining two endpoints, two model versions, or two sets of eval baselines. The recommended sampling settings are the same either way: `temperature=0.6`, `top_p=0.95`, `top_k=20`. That consistency matters when you are building anything that mixes the two modes.

```python
# OpenRouter — reasoning toggle example
import openai

client = openai.OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key="YOUR_OPENROUTER_KEY",
)

# Reasoning ON
response = client.chat.completions.create(
    model="nousresearch/hermes-4-405b",
    messages=[{"role": "user", "content": "Solve: integrate x^2 * sin(x) dx"}],
    extra_body={"reasoning": {"enabled": True}},
    temperature=0.6,
    top_p=0.95,
)

# Reasoning OFF — same model, same endpoint
response_fast = client.chat.completions.create(
    model="nousresearch/hermes-4-405b",
    messages=[{"role": "user", "content": "Classify this support ticket: 'my login stopped working'"}],
    extra_body={"reasoning": {"enabled": False}},
    temperature=0.6,
    top_p=0.95,
)
```

The 405B is not the right choice for every call in that workflow — at $3/M output tokens, you will use it selectively. But the point is that the architecture enables the pattern without forcing you to manage two model families.

---

## RefusalBench 57.1% vs GPT-4o's 17%: Neutral Alignment Explained

Hermes 4 scored 57.1% on RefusalBench. GPT-4o scored 17.67%. Claude scored 17%. The Hermes 70B actually edged out the 405B here at 59.5%.

RefusalBench measures how often a model will engage with requests that mainstream frontier models refuse. A higher score means the model refuses less. Nous frames this as "neutral alignment" — the model does not have a political or moral stance built into its post-training, and it treats the user as an adult who can decide what to do with a response.

The HN launch thread captured the double edge of this perfectly. One commenter praised it as "not forced to behave like 'Sue from HR.'" That is the legitimate use case: red-team testing, adversarial robustness research, security tooling, and applications where refusals are a product failure rather than a feature. If you are building a penetration testing assistant or a content moderation classifier that needs to understand what it is flagging, you do not want a model that declines to engage with the input class you are studying.

The other side of that edge is sharp. A 57.1% RefusalBench score means the model will engage with a significant portion of requests your production guardrails should probably block before they reach it. Deploying Hermes 4 without your own safety layer and assuming the model's native alignment is sufficient is a mistake — not because the model is broken, but because it was not designed for that assumption. The neutral stance is a design choice, not a gap in training. You own the risk layer here.

The reasoning-mode amplification makes this more nuanced. In non-reasoning mode, the model may still decline some requests based on surface pattern matching. In reasoning mode, it works through the request and is more likely to find a frame that permits a response. If you are running with `reasoning.enabled: true` and you have not tested your edge cases with it on, you may see behavior that surprises you.

---

## Who Hermes 4 Is Actually For

The knowledge cutoff on the 405B is August 31, 2024 — inherited from the Llama 3.1 base. That is now over a year and a half behind the current date. The HN thread flagged this explicitly: "the Llama 3.1 base is aging, especially in long contexts." SimpleQA at 25.8% is the canary in the coal mine here — factual recall for post-cutoff events is not something any amount of post-training can fix.

If your workload is math, code, structured reasoning, or retrieval-augmented tasks where the knowledge cutoff does not matter, the aging base is irrelevant. If your workload involves current events, recent product knowledge, or anything that requires the model to know what happened after August 2024, you need to either RAG heavily or pick a different model.

The license split also matters. The 405B and 70B ship under Meta's Llama 3 Community License, which permits commercial use but includes a 700-million-MAU cap clause. The 14B ships under Apache 2.0, inherited from its Qwen3 14B base — no MAU cap, no ambiguity, fully commercial. If you are building a product that could plausibly scale or that needs clean IP provenance, the 14B is the only model in the lineup with a fully unencumbered license. It also runs comfortably on a single RTX 6000 Ada at FP8, which changes the cost math considerably versus the 405B's 8xH100 minimum.

At $1/M input and $3/M output on OpenRouter, the 405B is not cheap. It is priced like a frontier model, and Artificial Analysis's "particularly expensive" flag is not wrong. The value case for the 405B specifically is: you need the parameter count for complex reasoning tasks, you want the neutral-alignment stance for adversarial or research use cases, and you have a clear plan for the safety layer. If you are not checking all three of those boxes, the 70B or the 14B will likely serve you better per dollar.

---

## What the Tool-Calling Side of Hermes 4 Actually Changed

The single-checkpoint reasoning toggle is the architectural novelty in this release. But the deployment behavior that will actually affect your production reliability is not the `<think>` toggle — it is how Hermes 4 handles tool calling, and the training signal behind it.

Nous trained Hermes 4's tool-calling behavior through something I had not seen documented in a post-training stack at this scale before reading the technical report. It changes what you should trust the model to do with your function schemas, and whether the structured output guarantees you think you have actually hold under load.

That is the subject of Part 2.

[**Part 2: How Hermes 4's Tool-Calling Was Actually Trained — and What That Means for Your Agent Stack**](https://dev.to/jee599/hermes-4-tool-calling-teardown)

[Part 3: The Hermes 4 Training Stack: DataForge, Atropos, and 192 B200s](https://dev.to/jee599/hermes-4-training-stack-teardown)

[Part 4: The Hermes 4 Production Checklist: What to Verify Before You Ship](https://dev.to/jee599/hermes-4-production-checklist-teardown)

---

Sources: [arXiv 2508.18255](https://arxiv.org/abs/2508.18255) · [Hermes 4 405B model card](https://huggingface.co/NousResearch/Hermes-4-405B) · [OpenRouter listing](https://openrouter.ai/nousresearch/hermes-4-405b) · [MarkTechPost coverage](https://www.marktechpost.com/2025/08/27/nous-research-team-releases-hermes-4-a-family-of-open-weight-ai-models-with-hybrid-reasoning/) · [Moonlight technical report review](https://www.themoonlight.io/en/review/hermes-4-technical-report) · [Artificial Analysis](https://artificialanalysis.ai/models/hermes-4-llama-3-1-405b) · [HN launch thread](https://news.ycombinator.com/item?id=45037064)

> The benchmark isn't the story. The toggle is the story — and what you do with the safety layer is yours to own.
