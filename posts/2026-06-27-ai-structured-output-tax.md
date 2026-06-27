---
title: "Structured Output Isn't Free: The Constrained-Decoding Tax"
published: true
description: "Why forcing a model into a JSON schema can quietly lower its accuracy, how grammar masking actually works, and how to get structure without paying the reasoning tax."
tags: ai, llm, structuredoutput, claude
id: 4003603
date: '2026-06-27T07:09:16Z'
---

Run the same extraction prompt twice against the same model. First time, ask for free-form prose. Second time, attach a strict JSON schema with `response_format` or a tool definition. On hard inputs, the schema version is often *worse* — it misses an entity, picks the wrong enum, or confidently fills a field it should have left null. Same weights, same prompt, lower accuracy. The schema didn't just change the output shape; it changed what the model was allowed to think.

This is the constrained-decoding tax, and most teams pay it without knowing it exists. Here's the mechanism, the failure modes, and how to keep the structure while getting the reasoning back.

## What "structured output" actually does at decode time

There are two ways a provider can give you guaranteed-valid JSON, and they have completely different cost profiles.

**Post-hoc validation** is the naive version: sample normally, parse, retry on failure. No effect on the token distribution, but no guarantee either — you eat retries and latency on every malformed sample.

**Constrained decoding** is what OpenAI's Structured Outputs, vLLM/TGI guided decoding (via `outlines`, `xgrammar`, `llguidance`), and Anthropic's tool-use machinery actually do. The schema is compiled into a finite-state machine (or a pushdown automaton for recursive grammars). At every decode step, the FSM knows which characters — and therefore which *tokens* — are legal next. The sampler builds a boolean mask over the entire vocabulary and sets the logits of every illegal token to `-inf` before the softmax.

```python
# Simplified guided-decoding step (outlines-style)
def masked_logits(logits, fsm_state, token_id_to_str, vocab_size):
    allowed = fsm.allowed_token_ids(fsm_state)   # precomputed per state
    mask = torch.full((vocab_size,), float("-inf"), device=logits.device)
    mask[allowed] = 0.0
    return logits + mask                          # illegal tokens -> -inf

# Then sample as usual; the chosen token advances the FSM:
next_id = sample(masked_logits(logits, state, ...))
state = fsm.advance(state, next_id)
```

The model literally cannot emit a token outside the grammar. That's the guarantee. The compile step (regex/JSON-schema → FSM → per-state token masks) is the expensive part, which is why providers cache compiled grammars and why a brand-new schema can add first-token latency.

So far this sounds free — you're only ever masking tokens that would have broken the JSON anyway. It isn't free, for three reasons.

## Failure mode 1: tokenizer/grammar misalignment

FSMs operate on characters; models operate on tokens. These don't line up. The string `"true"` might be one token in some contexts and `"tr` + `ue"` in others. When the FSM allows the *character* `t`, it has to allow every token whose string representation *starts a valid path* — which can split a token the model strongly preferred as a single unit into a less-probable multi-token path.

The result: the highest-probability *legal* token sequence under the mask is not the sequence the model would have produced unconstrained, even when both are valid JSON. The model wanted to say `null` as one token; the grammar, mid-string, forces a fragmentation that the model assigns lower probability to, and now you're sampling from a distorted tail. This is the same family of bug as the "token healing" problem in prefilling, and it's why naive grammar engines occasionally produce subtly degraded text inside otherwise-valid structure.

Good engines (`xgrammar`, `llguidance`) handle this with token-level lookahead and healing. Roll your own regex masker and you will hit it.

## Failure mode 2: key order freezes the reasoning order

JSON Schema objects have a defined property order, and constrained decoders emit keys in that order. That sounds cosmetic. It is not.

Autoregressive models reason *in the tokens they emit*. There is no scratchpad — the only place computation accumulates across steps is the generated sequence itself (plus the KV cache built from it). If your schema is:

```json
{ "diagnosis": "...", "evidence": "...", "confidence": 0.0 }
```

the model must commit to `diagnosis` **before** it has written a single token of `evidence`. You've forced the conclusion to be generated before the support. For an easy input that's fine. For a hard one, you've removed exactly the intermediate reasoning that would have produced the right diagnosis. The model answers first and rationalizes second — and because `evidence` is now conditioned on an already-emitted (possibly wrong) `diagnosis`, it tends to confabulate support rather than correct course.

This is the single biggest, most fixable cause of "schema made it dumber."

## Failure mode 3: the format itself competes for capacity

Even with perfect token alignment and good field ordering, holding a rigid grammar consumes the model's attention. It is spending probability mass on getting brackets, quotes, and enum spelling exactly right at every step. Empirically, across the open literature on format restriction, tighter output constraints tend to trade off against reasoning-heavy task accuracy — the more the decoder is boxed in, the more reasoning quality can slip. I won't quote a specific number because it's model- and task-dependent, but the direction is consistent enough that you should treat "strict schema" as a knob with a cost, not a free safety wrapper.

## How to keep structure and get the reasoning back

The fixes are mostly about *where* you put the constraint, not whether.

**1. Reasoning-first field ordering.** Put a free-text thinking field first in the schema, then the structured fields. This is the highest-leverage change.

```json
{
  "type": "object",
  "properties": {
    "reasoning": { "type": "string",
      "description": "Work through the evidence step by step BEFORE deciding." },
    "diagnosis": { "type": "string" },
    "evidence":  { "type": "string" },
    "confidence": { "type": "number", "minimum": 0, "maximum": 1 }
  },
  "required": ["reasoning", "diagnosis", "evidence", "confidence"],
  "additionalProperties": false
}
```

Now `diagnosis` is conditioned on tokens of actual reasoning. You're letting the model think inside the grammar instead of around it. The cost is output tokens you'll discard — worth it on anything non-trivial.

**2. Two-pass: reason free, format constrained.** Pass one is unconstrained and asked to reason and answer in prose. Pass two takes that prose and *only* reformats it into the schema — a near-mechanical task where the constraint costs almost nothing because no reasoning is happening at format time. Twice the calls, but you can use a cheaper/faster model for the formatting pass, and accuracy on the hard pass is unconstrained.

**3. Prefer tool-use semantics over `json_schema` mode when you can.** With Claude (Opus 4.x / Sonnet 4.x), tool use is the structured-output path: define a tool with an `input_schema`, and the model fills the arguments. Crucially, you can let the model emit a normal text/thinking block *before* the tool call, so reasoning happens unconstrained and only the tool arguments are schema-bound. Force the call with `tool_choice`:

```python
import anthropic
client = anthropic.Anthropic()

resp = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=[{
        "name": "record_diagnosis",
        "description": "Record the structured diagnosis after reasoning.",
        "input_schema": {  # same JSON Schema as above
            "type": "object",
            "properties": {
                "reasoning":  {"type": "string"},
                "diagnosis":  {"type": "string"},
                "evidence":   {"type": "string"},
                "confidence": {"type": "number"},
            },
            "required": ["reasoning", "diagnosis", "evidence", "confidence"],
        },
    }],
    tool_choice={"type": "tool", "name": "record_diagnosis"},
    messages=[{"role": "user", "content": case_text}],
)
args = next(b.input for b in resp.content if b.type == "tool_use")
```

Keep the `reasoning` field in the tool schema anyway — `tool_choice` forcing a specific tool still benefits from making the model write its work before the verdict.

**4. Loosen the grammar where the model needs room.** Enums and booleans are cheap to constrain and rarely hurt. The fields that bleed accuracy are long free-text and numeric judgments forced early. Constrain the cheap structural skeleton; leave `string` fields genuinely open (don't over-specify with regex unless you must); and never put a forced numeric `confidence` *before* the text that justifies it.

**5. Watch first-token latency on new schemas.** Grammar compilation is per-unique-schema. If you generate schemas dynamically per request, you defeat the provider's compiled-grammar cache and add latency. Stabilize your schemas and reuse them.

## The rule of thumb

Constrained decoding is a guarantee about *syntax* bought with a tax on *semantics*. The tax scales with how much the grammar interferes with the order and freedom of the model's own token-by-token reasoning. So the move is never "schema vs. no schema" — it's: let the model reason in unconstrained tokens first, then apply the tightest possible grammar only to the part that's pure formatting. Reasoning-first ordering, tool-use over rigid JSON mode, and a two-pass split when the input is hard will recover almost all of the accuracy you didn't know you were losing.

If you've ever shipped a JSON-mode pipeline and quietly accepted that it's "a bit dumber but at least it parses" — that tradeoff was never required. You were just paying the constrained-decoding tax in the wrong place.
