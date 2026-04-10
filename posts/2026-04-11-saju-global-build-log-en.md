---
title: "How I Auto-Generated 1,152 Compatibility Descriptions in 8 Languages with Claude Haiku"
published: true
description: "144 zodiac combinations × 8 languages = 1,152 content pieces. Built with Claude Haiku, strict JSON schema enforcement, and 824 API sessions with zero parse errors."
tags: claudecode, claudeai, automation, contentgeneration
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-04-11-saju_global-en
---

1,152 content pieces. 8 languages. 824 API sessions. Zero parse errors after the first prompt fix.

That's the scale of the content generation pipeline I built for the saju app's zodiac compatibility feature. The 12 Chinese zodiac signs produce 144 unique pairings (12 × 12). Multiply by 8 languages and you have content that would take months to write manually. With Claude Haiku and a well-designed prompt, it took hours.

**TL;DR** — Give Haiku a strict JSON schema and explicit paragraph-level instructions, and it produces consistent, structured compatibility descriptions across all 8 languages. One API key error on session 1 was the only interruption across 824 sessions.

## Why Haiku, Not Sonnet

Compatibility descriptions need consistency, not creativity. A rat + ox pairing should read the same way whether the user is in Seoul or Jakarta — same structure, same information hierarchy, just different languages.

Sonnet or Opus would cost 10x more per call. For 1,152 content pieces, that difference compounds fast.

I tested `claude-haiku-4-5-20251001` on this task and it handled it cleanly. Feed it a structured prompt with a clear schema, and it follows the schema reliably. The language quality was sufficient for production use across all 8 targets.

## The Prompt That Made Parsing Reliable

The first test run came back with markdown fences mixed into the JSON response:

````
```json
{"description": [...], "faq": [...]}
```
````

That breaks parsing. One line at the end of the prompt fixed it:

> `Respond ONLY with valid JSON, no markdown fences:`

Then I embedded the exact output schema directly in the prompt:

```
{"description":["p1","p2","p3"],"faq":[{"q":"...","a":"..."},{"q":"...","a":"..."},{"q":"...","a":"..."}]}
```

No ambiguity about the shape of the output. After this change: 0 parse errors across the remaining 823 sessions.

This is the single highest-leverage prompt change I've made on any content generation project. LLMs are helpful but they default to human-readable output — markdown, prose, formatting. When your downstream code needs machine-readable JSON, you have to be explicit about suppressing every non-JSON element.

## Forcing Paragraph Structure

"Write a 3-paragraph description" leaves the model free to decide what goes in each paragraph. That produces inconsistent output at scale.

Instead, I assigned each paragraph a specific job:

```
Paragraph 1: Overall compatibility summary (2-3 sentences).
             Start with the core answer: reference the specific score and relationship.
Paragraph 2: Strengths of this pairing (2-3 sentences).
             Reference specific elements and interactions.
Paragraph 3: Potential challenges and advice (2-3 sentences).
```

The phrase `reference the specific score and relationship` was load-bearing. Without it, Haiku would sometimes skip mentioning the numerical score (e.g., 50/100) and the relationship type (same, overcoming, generating) in the opening paragraph. With it, the key data points appeared in a predictable position every time.

This is the difference between instructing a model and *constraining* a model. Instructions can be interpreted loosely. Constraints that name specific variables and where they must appear leave no room for interpretation.

## Running 8 Languages in Sequence

For each of the 144 combinations, the pipeline loops through all 8 languages sequentially. The same pairing — rat + ox, score 60, relationship: overcoming — gets requested in English, Korean, Japanese, Chinese, Thai, Hindi, Indonesian, and Vietnamese, one after another.

Quality varied by language, predictably:

- **English, Korean, Japanese, Chinese** — natural phrasing, culturally appropriate nuance
- **Thai, Hindi** — slightly literal but service-level quality
- **Indonesian, Vietnamese** — somewhere in between

I deployed without per-language review. The strategy: let real user feedback surface quality issues, then fix per-language if needed. For an initial launch, Haiku's output was good enough.

## The Only Incident: Invalid API Key on Session 1

Session 1 failed immediately. The model showed up in logs as `<synthetic>` and the error was `Invalid API key`.

After a server restart, `ANTHROPIC_API_KEY` wasn't loaded into the environment. The `.env` file existed locally but the key wasn't registered in the deployment config. I added it directly to the deployment environment variables and restarted.

Session 2 onwards: clean Haiku runs. One environment variable misconfiguration was the only thing standing between 0 generated content pieces and 1,152.

## The Numbers

| Metric | Value |
|--------|-------|
| Total sessions | 824 |
| Time per session | 0–1 min |
| Tool calls per session | 0 |
| Content pieces generated | 1,152+ |
| Parse errors (post-fix) | 0 |

Tool calls being 0 is worth noting — this isn't a Claude Code interactive session. It's a script iterating through all 144 combinations, calling the Haiku API directly, and writing results to the database. No agentic loop, no multi-step reasoning. Just structured bulk generation at the API level.

## What Worked, What Didn't

**Worked:**

- `Respond ONLY with valid JSON, no markdown fences:` — eliminated all parse errors immediately
- Per-paragraph role assignment with sentence-level guidance — enforced structural consistency across 824 sessions
- Injecting `target language` as an explicit prompt variable — prevented language mixing in bilingual outputs
- Injecting score and relationship type as variables — guaranteed accurate data points appeared in the output

**Didn't work:**

- Soft instructions like "write naturally" — Haiku frequently ignores vague stylistic guidance
- Explaining the FAQ format without a concrete schema — output shape was inconsistent until I showed an exact example

The pattern is consistent: anything that requires the model to *infer* your intent is a liability at scale. Anything that gives the model *no choice* about format, position, or value scales cleanly.

## The ROI Calculation

Writing 1,152 compatibility descriptions by hand, even at 10 minutes each, is 192 hours of work. That's 4-5 weeks of full-time writing. Realistically, you'd need a team and still spend weeks on review and QA.

The alternative: one day designing the prompt and pipeline, a script run that completes in hours. The output quality isn't meaningfully different from what a competent human writer would produce at this kind of volume.

> The higher the content volume and the clearer the structure, the better the ROI on LLM automation.

The key is **strict output schema enforcement**: JSON-only responses, paragraph-level role assignment, variable injection for critical data. Without these three, you can't guarantee consistency across hundreds or thousands of generations.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
