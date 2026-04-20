---
title: "DataForge, Atropos, and a 30K-Token Guillotine: Reverse-Engineering Hermes 4's Training Stack"
published: true
description: "Nous Research generated 5 million post-training samples with DataForge, rejection-sampled them through ~1,000 Atropos verifiers, then force-terminated chain-of-thought at 30,000 tokens. Part 3 unpacks how, and what it cost."
tags:
  - ai
  - llm
  - machinelearning
  - opensource
series: "The Hermes 4 Teardown"
canonical_url: https://jidonglab.com/posts/2026-04-18-hermes-4-part-3-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-18-hermes-4-training-stack'
---

A 78.4% reduction in overlong outputs — bought at a 4.7–12.7% accuracy hit. That's not a footnote in Nous Research's 94-page Hermes 4 technical report. That's the central tension of their entire post-training philosophy: control costs latency and reliability, but it taxes the exact problems that need the most thinking.

I spent a weekend reading through the report and trying to reconstruct exactly how Hermes 4 was trained. Three components stood out. DataForge, a DAG-based synthetic data generator that chains PDDL-style transformations across 5 million samples. Atropos, a rejection-sampling framework backed by roughly 1,000 verifiers. And a second-stage SFT pass that hard-caps `<think>` traces at 30,000 tokens — what I've been calling the guillotine.

---

**Part 2 showed that Hermes 4's tool-calling behavior is a training-time choice.** [Part 3 asks: how did that training actually happen?](https://dev.to/jee599/hermes-4s-tool-calling-is-trained-as-a-separate-skill-heres-why-your-agent-cares)

---

## TL;DR

Nous built a composable synthetic data graph (DataForge) seeded with DCLM and FineWeb, ran outputs through ~1,000 task-specific verifiers via rejection sampling in Atropos (not online RL), trained on 60B tokens across 9,000 steps on 192 B200 GPUs, then added a second SFT pass to terminate reasoning traces at 30K tokens. The termination SFT cut AIME'24 overlong outputs from 28.2% to 6.1% — a real production win — but cost 4.7–12.7% on raw accuracy. The harder the problem, the more that trade-off hurts.

---

## DataForge: Why Post-Training Data Is a Graph

Most synthetic data pipelines are linear. You write a prompt template, call a teacher model, filter the outputs, repeat. OpenAI's original Self-Instruct paper works this way. The quality ceiling is wherever your template writer's imagination stopped.

Nous built DataForge differently. It's a directed acyclic graph where each node is a PDDL action: a unit with declared preconditions, postconditions, and a transformation. Connect nodes, and you get a pipeline. Connect pipelines, and you get a dataset. The seeding corpus is DCLM and FineWeb — large pretraining web datasets, not hand-curated task examples.

The compositional trick is what matters. A sample transformation chain might look like this:

```
[DCLM article: Wikipedia / Science]
           |
           v
   [Node A: Rewrite as rap song]
           |
           v
   [Node B: Extract instruction-answer pair from rap content]
           |
           v
   [Output: training sample with unusual domain coverage]
```

That's not a contrived example — the technical report describes exactly this kind of chain. The point is that by varying which nodes you connect and in which order, you generate training data that covers distributions no human would explicitly design. The model sees Wikipedia-as-rap-as-instruction-pair and learns something that rote template generation wouldn't surface.

Compared to OpenAI-style self-instruct with verifiers, DataForge adds one meaningful layer: the transformations are composable by construction, not by iteration. You don't have to re-engineer the pipeline every time you want a new data modality. You add a node, declare its interface, and it slots into any compatible position in the graph.

The result at scale: 5 million post-training samples, 60 billion tokens total. That's 5x the sample count of Hermes 3 and a 50x token increase. Of those 5M samples, 3.5 million are reasoning-heavy sequences up to 16K tokens each. The remaining 1.6 million are non-reasoning — standard instruction following, schema adherence, tool use.

Whether DataForge's code is publicly available is something I couldn't confirm cleanly. [unverified — check the Nous GitHub and the arXiv paper at https://arxiv.org/abs/2508.18255 for current release status.]

---

## Atropos Doesn't Do Online RL. Most People Miss This.

When you hear "1,000 RL verifiers," the instinct is to picture something like PPO or GRPO running online during training — the model generating rollouts, a reward model scoring them, policy gradients propagating. That's not what Atropos does.

Atropos is a rejection sampling framework. You generate candidate responses, you run them through verifiers, you keep the ones that pass. No online gradient updates from a reward model. No policy optimization loop. The RL framing is accurate in the sense that the verifiers are task-specific reward signals, but the training mechanism is closer to filtered SFT than to true online reinforcement learning.

This matters for two reasons.

First, rejection sampling scales more predictably than online RL. You don't need the infrastructure to run a live reward model during training. You can parallelize verification across many verifiers without coupling them to the gradient update schedule. For a team like Nous, which is not operating at the scale of Google DeepMind or OpenAI, this is a real practical advantage.

Second, the verifier coverage is genuinely broad. Atropos runs roughly 1,000 task-specific checks across categories including Answer Format Training, Instruction Following, Schema Adherence, Tool Use, and the Internbootcamp suite — which alone contributes 70,000 trajectories. Schema adherence and tool use being explicit verifier categories is why Part 2 found that Hermes 4's structured output behavior is reliable. It wasn't bolted on. It was filtered for.

The tradeoff is that rejection sampling is only as good as your generator. If the upstream model can't produce correct outputs at any temperature, rejection sampling can't surface them. For the hardest reasoning problems, this is a real ceiling — and it connects directly to why the 30K-token guillotine is so consequential.

---

## 5M Samples, 60B Tokens, 192 B200s

The compute picture that emerges from the technical report is specific enough to be useful and vague enough to be frustrating.

What's published: 192 NVIDIA B200 GPUs, global batch size 384, context length 16,384 tokens during training, cosine learning rate schedule with 300 warmup steps and 9,000 total steps. The 405B and 70B models both run on Llama 3.1 bases, which sets the knowledge cutoff at August 31, 2024 — a hard constraint inherited from the pretrained weights.

What's not published: exact GPU-hours, wall-clock training time, dollar cost. [unverified — these numbers were not surfaced in the technical report, the model cards, or any third-party review I found.] For a research lab releasing 94 pages of methodology, the absence is notable. It's not unusual — most labs treat compute costs as competitive information — but it makes independent cost estimation impossible.

What you can infer: 9,000 steps at batch 384 with context 16,384 on 192 B200s is substantial. The B200 is NVIDIA's current-generation training GPU, and 192 of them puts this firmly in the "well-resourced research lab" category, not the "one team with a cloud budget" category. The 60B-token post-training corpus at this context window means the model saw diverse sequence lengths throughout training, which is likely why the hybrid reasoning mode (which requires handling both short and very long contexts) works at all.

One inherited constraint worth flagging: the 405B model's knowledge cutoff is August 31, 2024. HN commentary on launch day noted that "the Llama 3.1 base is showing, especially in long contexts." That's not a training methodology failure — it's a fundamental limitation of post-training only. Post-training cannot add knowledge that isn't in the base weights. If you're building on the 405B for anything time-sensitive, this is a real gap.

---

## The 30,000-Token Guillotine (And Its Cost)

This is the part of the Hermes 4 training stack that deserves the most scrutiny.

Before the length-control intervention, Hermes 4's `<think>` traces had a runaway problem. On AIME'24, 28.2% of outputs exceeded a practical token budget. The 14B model regularly hit the 40,960-token context ceiling mid-reasoning and was simply cut off. For a production deployment where you're paying per token and need predictable latency, this is a serious operational problem.

Nous's fix was a second-stage SFT pass specifically designed to teach the model to terminate reasoning traces at 30,000 tokens. Not to reason more efficiently — to stop at a hard ceiling.

The result: overlong outputs on AIME'24 dropped from 28.2% to 6.1%. A 78.4% reduction. In production terms, that's a meaningful improvement in cost predictability and latency consistency.

The cost: 4.7–12.7% relative accuracy regression on benchmarks.

That range deserves unpacking. A 4.7% hit on a benchmark that's already near ceiling is different from a 12.7% hit on a benchmark where you're at 80%. But the deeper issue is which problems get hurt most.

The problems that benefit most from longer reasoning chains are the hard ones. AIME problems. GPQA Diamond. The tail of LiveCodeBench. These are exactly the problems where Hermes 4's reasoning mode is supposed to differentiate itself from a standard instruct model. By capping thinking at 30,000 tokens, Nous traded some of that differentiation for operational predictability.

I'm not saying it was the wrong call. If you're running Hermes 4 in production at scale, you cannot have 28% of your hard-math requests balloon into 40K-token outputs. The guillotine is a reasonable engineering decision. But it should not be framed as a win — it is a trade-off, and the thing being traded is accuracy on your hardest inputs.

The number they chose — 30,000 tokens — also invites the question: why 30K and not 20K, or 40K? The technical report doesn't explain the selection criteria. Whether that number was ablated across multiple thresholds or set by intuition is not documented. [unverified — no ablation table across token-cap thresholds was found in the available sources.]

---

## What This Means If You're Building on Hermes 4

Four things follow directly from the training stack.

Schema adherence is real. When Atropos runs explicit Schema Adherence verifiers across 5 million samples, the resulting model has seen structured output failures filtered out at training time. This is different from a model that was fine-tuned on JSON examples. The adherence behavior was rejection-sampled, which means edge cases that would normally fail were systematically excluded from the training signal.

The reasoning is capped. Any use case where chain-of-thought length directly predicts accuracy — hard math, multi-step code generation, complex planning — will hit the 30K ceiling before saturating. If you find yourself in that regime, you're working with a model that was deliberately curtailed there. That's not a bug in your setup.

The base is aging. August 31, 2024 knowledge cutoff on the 405B and 70B. In April 2026, that's 20 months of world events, code library updates, and model ecosystem changes that aren't in the weights. Long-context recall is also a known weakness of the Llama 3.1 base, and the technical report's training context of 16,384 tokens doesn't address the 131,072-token window's practical limits.

The synthetic data pipeline is architecturally interesting but not a magic multiplier. DataForge produces compositional diversity, which is real value. But 5 million rejection-sampled examples still can't substitute for pretraining-scale knowledge. What you get is a model that follows instructions reliably, handles tool calls predictably, and stays within its operational constraints. What you don't get is a model that knows more than its base.

---

## Part 4 Is the Honest Question

The interesting question isn't how Hermes 4 was trained — it's whether you should run it.

The training stack is coherent. DataForge generates diverse data at scale. Atropos enforces quality via rejection sampling across a wide verifier surface. The length-control SFT keeps production costs predictable. These are real engineering contributions from a team that knows what they're doing.

But knowing how a model was built and deciding whether it belongs in your production stack are different problems. The 405B costs $3/M output tokens on OpenRouter and requires 8x H100s to self-host. The knowledge cutoff is 20 months old. The accuracy-vs-latency trade-off is baked in at the training level.

> The next part is the checklist I wish existed when I started evaluating Hermes 4 for deployment. Not benchmarks — production decisions. Read [Part 4: the honest production checklist](https://dev.to/jee599/hermes-4-production-checklist-teardown) before you commit to a deployment path.

---

**Sources:**

- Hermes 4 technical report (arXiv): https://arxiv.org/abs/2508.18255
- Technical report review (Moonlight): https://www.themoonlight.io/en/review/hermes-4-technical-report
- MarkTechPost coverage: https://www.marktechpost.com/2025/08/27/nous-research-team-releases-hermes-4-a-family-of-open-weight-ai-models-with-hybrid-reasoning/
- Hermes 4 405B model card: https://huggingface.co/NousResearch/Hermes-4-405B
- HN launch thread: https://news.ycombinator.com/item?id=45037064
- OpenRouter listing: https://openrouter.ai/nousresearch/hermes-4-405b
