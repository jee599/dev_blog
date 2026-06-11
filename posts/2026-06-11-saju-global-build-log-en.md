---
title: "5 Sessions, Zero File Changes: Auto-Generating Zodiac Compatibility Content with Claude Haiku"
published: true
description: "How claude-haiku-4-5 generates 144+ zodiac compatibility texts as structured JSON — 5 sessions, 0 code changes, multilingual output."
tags: claudecode, ai, contentgeneration, astrology
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-06-11-saju_global-en
---

Five sessions. Zero tool calls. Zero files modified. That's what a pure content generation workflow looks like — and it's what built the compatibility database for `saju_global` today.

Most Claude Code build logs cover code generation. This one doesn't. For `saju_global`, Claude Haiku handles a job that has nothing to do with writing or editing code: generating structured compatibility descriptions for every zodiac pairing, in multiple languages, at a cost that actually makes sense at scale.

**TL;DR** Pass a zodiac pair, a score, and a relationship type to `claude-haiku-4-5-20251001`. Get back 3 paragraphs of compatibility copy plus 3 FAQ pairs as structured JSON in the target language. Zero tool calls, pure inference. This is what AI content generation looks like when the output format is fixed and the model just needs to fill it in well.

## The Scale Problem That Made Hand-Writing Impossible

`saju_global` is a multilingual compatibility service built around two systems: Chinese Zodiac (12 animals) and Western Astrology (12 signs). Each system has 144 unique pairings (12 × 12). Add multilingual support — Simplified Chinese, Traditional Chinese, English, Japanese, Korean — and you're looking at thousands of text entries.

Nobody writes that manually. That's not a team problem; it's an economics problem. At 30 minutes per entry, writing all 144 Chinese Zodiac pairs in a single language would take over 70 hours. Multiply by languages and it simply doesn't happen.

The solution: treat Claude Haiku as a structured content generation API, not a chat assistant.

## What Today's Sessions Actually Produced

Five compatibility descriptions, all in Simplified Chinese (简体中文):

| Pair | System | Score | Relationship |
|------|--------|-------|--------------|
| Horse × Rooster | Chinese Zodiac | 40/100 | overcoming |
| Rat × Dragon | Chinese Zodiac | 65/100 | overcoming |
| Rabbit × Monkey | Chinese Zodiac | 40/100 | overcoming |
| Capricorn × Virgo | Western Astrology | 100/100 | same |
| Aquarius × Capricorn | Western Astrology | 45/100 | overcoming |

Three `overcoming` pairs from the Chinese Zodiac side, one perfect match, one challenged pairing. Today's sessions were weighted toward difficult combinations — which is actually the more interesting case for testing prompt robustness.

Each entry produces a 3-paragraph compatibility description plus 3 FAQ Q&A pairs.

## The Prompt Template That Does the Heavy Lifting

Every session runs the same template:

```
Generate a 3-paragraph compatibility description for {animal1} and {animal2}
({system}) in the target language.
Score: {score}/100, Relationship: {relationship}.

Paragraph 1: Overall compatibility summary (2-3 sentences).
  Start with the core answer: reference the specific score and relationship.
Paragraph 2: Strengths of this pairing (2-3 sentences).
Paragraph 3: Potential challenges and advice (2-3 sentences).

Also generate 3 FAQ Q&A pairs about this combination...
```

`{system}` gets either `Chinese Zodiac` or `Zodiac Sign (Western Astrology)`. The score and relationship type are injected directly from the database record. `target language` is resolved dynamically by the client at request time — today all sessions targeted Simplified Chinese.

The critical design decision: making score and relationship type *explicit inputs* rather than implied context. This gives the model enough signal to calibrate tone across the entire response — not just in the opening line, but throughout.

## The Output Format: JSON You Can Use Directly

```json
{
  "description": [
    "Paragraph 1 text",
    "Paragraph 2 text",
    "Paragraph 3 text"
  ],
  "faq": [
    { "q": "Question 1", "a": "Answer 1" },
    { "q": "Question 2", "a": "Answer 2" },
    { "q": "Question 3", "a": "Answer 3" }
  ]
}
```

No post-processing. No regex extraction. No response parsing layer. The frontend consumes the JSON directly.

When you specify output structure explicitly in the prompt, Haiku respects it consistently. This is the part people underestimate about smaller models: they follow format instructions well. The creativity ceiling is lower than Sonnet or Opus, but format compliance is solid.

## Score 100 vs Score 40: The Tone Difference Is Automatic

This is where the prompt design pays off. Compare the opening paragraph for two very different pairs.

Capricorn × Virgo (100 points, `same` relationship):

> 摩羯座和处女座堪称天作之合，这对组合的匹配度达到完美的100分。两个土象星座天生就说同一种语言——务实、稳重、坚定，他们用行动而非甜言蜜语来证明爱意...

*"Capricorn and Virgo are a match made in heaven — a perfect 100 out of 100. Two earth signs who naturally speak the same language: practical, grounded, committed. They prove their love through action, not sweet words..."*

Horse × Rooster (40 points, `overcoming` relationship):

> 马和鸡的配对指数只有40分，属于需要克服重重障碍才能相处的关系。两个生肖在性格和价值观上差异很大，但如果彼此足够坚定，这段关系并非没有可能。

*"The Horse and Rooster compatibility score is just 40 — a pairing that requires overcoming significant obstacles. The two signs differ substantially in personality and values, but if both are committed enough, this relationship isn't impossible."*

Same template. Completely different register. "达到完美的100分" (a perfect 100 points) vs. "只有40分" (a mere 40 points) — the model absorbed the numerical and categorical inputs and calibrated the entire response accordingly. That's not prompt magic; it's just giving the model sufficient context to make reasonable decisions.

## Why Haiku, Not Sonnet or Opus

At 144 Chinese Zodiac pairs × 144 Western Astrology pairs × N languages, the request volume lands in the hundreds to thousands per language. At Sonnet pricing, generating the full content database becomes financially prohibitive — you're not running a one-off query, you're running a factory.

Compatibility descriptions fall closer to structured information delivery than creative writing. The content pattern is predictable: overall assessment → strengths → challenges and advice. When the prompt is specific enough to constrain the creative space, Haiku produces output that's difficult to distinguish from more expensive models for this particular use case.

Today's Chinese output had natural sentence flow, accurate score and relationship reflection, and consistent structure across all five entries. The quality bar for "acceptable compatibility description" is lower than for, say, brand copy or technical documentation — and Haiku clears it comfortably when the prompt does its job.

Cost efficiency at scale isn't about being cheap. It's about making the economics of a content-heavy feature actually work.

## Tone Calibration Within the Same Relationship Type

The `overcoming` type spans a range. Rat × Dragon at 65 points and Rabbit × Monkey at 40 points are both `overcoming`, but the model produces noticeably different content:

- **65 points**: Acknowledges challenges while emphasizing genuine strengths. The tone is cautiously optimistic.
- **40 points**: Leads with difficulty. The tone is honest about friction before pivoting to what's salvageable.

Two parameters (score + relationship type) give the model enough signal to produce tonally appropriate content without over-specifying. The prompt doesn't enumerate tonal rules; it trusts the model to apply them correctly given the structured inputs.

## What Comes Next

**A/B testing the `overcoming` framing.** Three of today's five pairs are difficult combinations. The current prompt structure puts "challenges and advice" in Paragraph 3, which keeps negative content at the end and frames it constructively. Whether this pattern reduces user drop-off compared to a more upfront framing is testable — and worth testing, since it affects every challenging pair in the database.

**FAQ schema markup.** The 3 FAQ pairs per compatibility page are a deliberate SEO structure. Adding `application/ld+json` FAQ markup to each page is the next step — it's a direct signal to search engines that should show measurable impact on rich snippet eligibility. The content is already generated; it just needs the markup layer.

**Batching generation.** Right now, generation happens session by session. At 144 × 144 × N scale, a batched generation job with rate limiting and resumability is the next infrastructure piece. The prompt template is stable enough to run unattended.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
