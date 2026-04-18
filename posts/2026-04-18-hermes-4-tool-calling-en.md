---
title: "Hermes 4's Tool-Calling Is Trained as a Separate Skill. Here's Why Your Agent Cares."
published: true
description: "Nous's Atropos RL framework has ~1,000 task verifiers, with Schema Adherence and Tool Use as explicit categories. Part 2 explains what that means when you wire Hermes 4 into an agent loop."
tags:
  - ai
  - llm
  - agents
  - opensource
series: "The Hermes 4 Teardown"
canonical_url: https://jidonglab.com/posts/2026-04-18-hermes-4-part-2-en
hashnode_url: 'https://plzai.hashnode.dev/2026-04-18-hermes-4-tool-calling'
id: 3518218
date: '2026-04-18T06:08:33.028Z'
---

Nous Research's Atropos RL framework runs ~1,000 task-specific verifiers. Two of those categories are Schema Adherence and Tool Use — not as a shared bucket labeled "function calling," but as separate, explicitly trained behaviors. I wired Hermes 4 405B into my agent pipeline via OpenRouter and observed tool-call behavior across a range of structured-extraction and multi-step agentic tasks. What I found lines up with what the training methodology predicts — and the implications are worth unpacking before you commit to an architecture.

In Part 1 I argued that Hermes 4's headline benchmarks bury the lede — [link](https://dev.to/jee599/the-96-3-is-a-trap-what-hermes-4-405b-actually-changed). The tool-calling story is where that argument lands.

---

**TL;DR**

Hermes 4 treats tool-calling as a first-class training objective, not a prompt-format convention. Atropos rejection-samples against schema and tool-use verifiers explicitly. In practice this means the model emits structurally valid, constraint-respecting JSON — not just "JSON-shaped text." That's a real production difference, with real trade-offs around reasoning mode, token cost, and the one benchmark nobody has published yet.

---

## Atropos Isn't a Fine-Tuning Framework. It's a Rejection-Sampling One.

The framing matters here. When most people say "RL-trained for tool use," they mean the model was fine-tuned with RLHF-style reward signals applied to sampled completions in an online loop. Atropos works differently.

It generates candidate responses, then filters them through ~1,000 task-specific verifiers organized into named categories: Answer Format Training, Instruction Following, Schema Adherence, Tool Use, and a trajectory bank called Internbootcamp — 70,000 trajectories that provide structured demonstrations of multi-step reasoning chains. Only responses that pass the verifiers for a given category are kept. This is rejection sampling, not online policy optimization. The signal is binary per verifier: the response either satisfies the constraint or it doesn't.

The consequence is that the model's tool-calling behavior was shaped by a signal that explicitly asked: "does this JSON output satisfy the schema's structural constraints?" Not "does it approximately resemble a function call," but "does it pass the verifier." That distinction is what separates a model that emits `{"age": "thirty"}` from one that correctly emits `{"age": 30}` when the schema says `integer`.

No independently verified BFCL score has been published to confirm how this holds across arbitrary user-defined schemas. The technical report references IFEval in its evaluation suite, but third-party summaries don't surface the specific function-calling number. [unverified] I'm flagging this because it matters: the training methodology is principled, and my qualitative observations are consistent with it, but the absence of a published benchmark leaves a gap that production teams need to account for.

---

## The `<tool_call>` Tag Format, Decoded

Hermes 4 does not use OpenAI's `function` role / `tool_calls` array format. It uses in-turn XML-style tags. Tool definitions are injected into the context like this:

```xml
<tools>
{"type":"function","function":{"name":"get_weather","description":"Get current weather","parameters":{"type":"object","properties":{"location":{"type":"string"},"unit":{"type":"string","enum":["celsius","fahrenheit"]}},"required":["location"]}}}
</tools>
```

When the model decides to call a tool, it emits:

```xml
<tool_call>{"name":"get_weather","arguments":{"location":"Seoul","unit":"celsius"}}</tool_call>
```

The tool result is then injected back as a `<tool_response>` block, and the model continues.

This is meaningfully different from GPT-4o's function-calling, where the invocation lives in a structured `tool_calls` field on the assistant message, and from Claude's `tool_use` content blocks, which are typed JSON objects inside the message body. The Hermes approach is closer to how earlier open-source models handled it — in-band, tag-delimited — but the critical difference is that the verifier-based training should make the inner JSON more reliable, not just more syntactically correct.

For deployment, the two flags you need:

On **vLLM**: `--tool-call-parser hermes`

On **SGLang** (14B): `--tool-call-parser qwen25`

The 70B and 405B use the Llama 3.1 chat format, so for those on SGLang, check the current parser docs — the flag name depends on your SGLang version and the model's chat template. OpenRouter handles parsing automatically and exposes structured outputs, JSON mode, and function calling as first-class API features, so if you're accessing the 405B hosted rather than self-served, you don't set this flag yourself.

The in-turn tag design has one practical upside: it's inspectable. The full tool context is in the token stream, not a side channel. When a chain breaks, you can read the generation trace and see exactly where the call was malformed or where the model decided not to call. That's harder with OpenAI's format if you're not logging the structured fields explicitly.

---

## What I'd Trust Hermes 4 With (And What I Wouldn't)

The use cases where the schema-adherence training matters most are also the ones that break most often with lesser models: structured extraction from unstructured text (enforcing enums, required fields, type constraints), multi-step tool loops where each step's output becomes the next step's input schema, and agent workflows where a downstream system has zero tolerance for malformed calls.

I observed consistent schema adherence in these patterns — the model respected required fields, honored enum constraints, and didn't invent extra keys. For tasks involving more than three sequential tool calls, coherence held without manual re-prompting. These are qualitative observations across my specific pipeline configurations, not controlled ablations.

Where I'm cautious: any production environment that needs a published BFCL score to gate deployment. That number doesn't exist yet. The Berkeley Function-Calling Leaderboard is the industry standard for comparing models on function-calling accuracy across diverse schemas. Hermes 4's absence from it is not evidence of failure — the model launched in August 2025 and the Nous team is small — but it is a gap in the evidence base. If your organization requires a benchmark citation in a model evaluation doc, Hermes 4 doesn't have one for this category. [unverified]

The other caution: complex nested schemas. My observation is that constraint satisfaction degrades as schema depth increases — deeply nested `$ref` chains with conditional required fields push any model toward occasional violations. Hermes 4 is better than most open-weight alternatives here, but it is not robust against arbitrary schema complexity. Budget for output validation at the application layer regardless of what model you use.

---

## The Reasoning-Mode-ON vs OFF Tool-Call Trade

This is the part that should change how you architect your agent loop.

Tool calling works in both reasoning and non-reasoning modes. That's documented and I've confirmed it. The operational question is what you give up when you run tools without reasoning.

The 405B's RefusalBench score is 57.1% — but only in reasoning mode. The model reaches that number by reasoning through requests, not by pattern-matching to a refusal rule. In non-reasoning mode, that guardrail behavior degrades. The model can still follow schema constraints and call tools correctly, but the reasoning-backed judgment about whether a given tool invocation is appropriate is not active.

For most structured-extraction workflows this doesn't matter. You're not asking the model to evaluate the ethics of calling `get_weather`. But for agentic tasks where the model decides which tool to call, in what sequence, with what arguments — the reasoning mode is doing active work. It's evaluating intermediate states, catching its own inconsistencies, and sometimes declining to invoke a tool when the context doesn't support it.

Running tools in non-reasoning mode to save tokens is a legitimate architectural choice. The 405B's context is 131,072 tokens, and each reasoning trace can run long — Nous had to add a second-stage SFT pass specifically to cap `<think>` traces at 30,000 tokens because overlong traces were a real problem. Token cost is real. But if you switch to non-reasoning mode to manage cost, you should do it knowing that you're trading the model's self-checking behavior, not just its visible chain-of-thought.

The 30,000-token trace cap is worth knowing about for another reason: it constrains how much in-context deliberation the model can do before it must commit. For agentic loops with many tool calls across a long session, you may hit the cap mid-task if reasoning is on. Plan context budgets accordingly.

---

## This Is Stranger Than It Looks

The tool-calling behavior I've described here isn't just the result of better fine-tuning data. It's the output of a training pipeline that treats schema adherence as a verifiable constraint. That's a philosophical shift in how the model was shaped.

The training approach behind these behaviors is weirder than you think. Nous's DataForge pipeline — the one that generated the 5 million samples Hermes 4 was trained on — uses a PDDL-based synthetic data system that treats data generation as a planning problem. The implications for what kinds of behaviors can be reliably trained, and how, are significant.

I get into it in Part 3: [Hermes 4 Training Stack Teardown](https://dev.to/jee599/hermes-4-training-stack-teardown).

---

> Tool-calling isn't a prompt format. It's a training signal. Whether the model reliably respects your schema depends on whether schema adherence was part of the training objective — not whether the prompt template looks like a function spec.
