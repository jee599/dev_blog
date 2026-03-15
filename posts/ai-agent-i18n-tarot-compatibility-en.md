---
title: "i18n + Tarot + Compatibility in One Day: Constraint Design Is the Real Skill"
published: true
description: "Added 78-card tarot, overhauled compatibility analysis, and fixed 8 locales in 20 commits. The decomposition and verification patterns that made it possible."
tags:
  - ai
  - webdev
  - productivity
  - llm
---

I added AI tarot reading, rebuilt compatibility analysis, and overhauled translations across 8 languages — all in one day. 20 commits, 139 files changed. What made this possible was not coding speed. It was prompt decomposition.

## What I Was Building

A saju (Korean astrology) analysis service built on Next.js + Supabase + OpenAI API. Saju uses Four Pillars of Destiny — year, month, day, and hour of birth — to generate personality and fortune readings. This session added three features:

1. AI tarot reading (78-card deck)
2. Compatibility analysis overhaul (birth time input, 6 sections, pricing)
3. Translation fixes across 8 locales (ko, en, ja, zh, hi, th, id, vi)

Doing all three manually in one day is not realistic. Doing all three with structured AI prompting is.

## Decompose or Fail

Tarot reading requires card deck data, UI components, LLM interpretation prompts, and i18n strings. Asking Claude to build it in one prompt **guarantees failure.** Too many moving parts, too much left to the AI's discretion.

The decomposition:

> Step 1: "Create JSON data for 78 tarot cards. Major Arcana 22 cards, Minor Arcana 56 cards. Fields: name, number, suit, keywords, upright_meaning, reversed_meaning."

> Step 2: "Build a TarotReading component that imports the card data and draws 3 random cards. Card flip animation using CSS flip."

> Step 3: "Write an LLM prompt that synthesizes the 3 drawn cards into a reading. Input: user's question + card combination. Output: 3-paragraph interpretation."

The anti-pattern:

> "Build a tarot reading feature"

A single-sentence prompt means the LLM decides card data structure, UI patterns, and interpretation format on its own. Results vary wildly, and rework cost skyrockets.

## CLAUDE.md as Persistent Context

Project root `CLAUDE.md` gives Claude Code session-persistent context. No need to re-explain the project structure every time:

```markdown
# Project Structure
- apps/web/ — Next.js frontend
- packages/engine/ — saju + LLM prompt engine
- 8 locales: ko, en, ja, zh, hi, th, id, vi

# Rules
- New components go under apps/web/app/[locale]/
- i18n uses next-intl, JSON files in messages/
- LLM prompts go in packages/engine/prompts/
```

With this in place, "build a tarot component" produces files in the right directory, with the right i18n pattern, without additional instructions.

## i18n: Generation Is Easy, Verification Is Hard

The commit `feat(i18n): comprehensive translation overhaul across all 8 locales` touched all 8 language files in one pass. Getting Claude to translate is trivial. Catching mistranslations is the real challenge.

The generation prompt with constraints:

> "Find missing keys in all 8 locale JSON files. Translate missing entries using en.json as reference. Rules:
> 1. Do not translate proper nouns (saju, tarot)
> 2. Maintain existing tone (check if formal or informal)
> 3. Show only modified keys in diff format"

Without these constraints, three things go wrong:
- "사주" (the brand name) gets translated to "Four Pillars"
- Thai translations flip from informal to formal register
- Existing correct translations get overwritten

The follow-up commit `fix(i18n): fix mistranslations across en, hi, th, id locales` proves the point — first-pass translation always needs a verification round.

The verification prompt:

> "Check the translations you just made:
> 1. Any entries where meaning changed from the original
> 2. Any proper nouns that got translated
> 3. Any broken placeholders ({name}, {count}, etc.)"

Running this verification prompt alone catches most mistranslation issues.

## LLM Prompt Engineering in 4 Rounds

The commit log shows `engine round 1` through `round 4`. Four iterations of the LLM interpretation prompt. This was intentional — **LLM prompts do not converge in one pass** the way code often does.

**Round 1:** Base prompt with output format and tone specification.
**Round 2:** QA — prompt consistency validation, add input validation rules.
**Round 3:** Eliminate redundancy, raise compatibility score threshold (was clustering at 70-80).
**Round 4:** Locale-specific cultural adjustments, palmistry reading depth tuning.

The iteration prompt:

> "Current prompt produces this output [paste result]. Fix these problems: 1) Korean and English results have different tone 2) Compatibility scores always land between 70-80 3) Palm reading interpretations are too shallow"

The key: **show the current output and point to specific problems.** "Improve the prompt" produces nothing useful.

## Navigation: What Not to Delegate to AI

Four consecutive `fix(nav)` commits. Menu visibility decisions changed four times. This is a textbook example of **product decisions that should not be delegated to AI:**

- Tarot is still in beta — hide from main nav
- Name generation is complete but only appears in cross-sell
- Desktop and mobile show different menu items

These are business decisions. The AI should only handle implementation: "Remove this item from the `topNav` array." The human decides what and why. The AI handles how.

## What Could Be Better

**Crowdin + AI hybrid for i18n.** Crowdin's AI Translation references Translation Memory, producing more consistent results than direct Claude translation. Verification cost drops significantly.

**Prompt version control.** Running 4 prompt rounds with manual comparison is tedious. Git-versioning prompts and using Anthropic's prompt caching (up to 90% cost reduction on long system prompts) would make iteration cheaper and traceable.

**Claude Code hooks for automated validation.** A pre-commit hook that checks i18n JSON key parity across locales would catch missing translations before build:

```json
{
  "hooks": {
    "pre-commit": ["node scripts/check-i18n-keys.js"]
  }
}
```

**MCP servers for external data.** Instead of pasting tarot card data into prompts, an MCP server could expose structured datasets that Claude references directly.

## Takeaways

- Large features must be decomposed into 3+ steps — single-prompt requests produce high variance
- i18n requires two passes: generation then verification — skipping verification guarantees mistranslations
- LLM prompts improve through rounds — show current output and name specific failures
- Product decisions stay with humans — AI handles "how," humans decide "what" and "why"

<details>
<summary>Commit log</summary>

4f9c985 — feat(compat): complete overhaul — birth time, 6 sections, i18n, pricing
a4384ed — feat(admin): add data export (JSON/MD) and comprehensive event tracking
0224e25 — feat(i18n): comprehensive translation overhaul across all 8 locales
2350272 — fix(i18n): fix mistranslations across en, hi, th, id locales
2812f4a — fix(nav): add compatibility and palm to desktop topNav
c01625e — fix(nav): show daily, saju, compatibility, palm in menu
342af78 — fix(nav): show only daily/saju in menu, restrict language selector to home
e9dc18d — fix(nav): remove tarot from nav (not public yet), add name
2ecb14f — feat(tarot): add AI tarot reading product with 78-card deck
af4f359 — feat: comprehensive platform improvements
dd0500e — feat(share): add viral sharing for palm and compat reports
3dfa113 — fix: engine round 4 - locale-specific thresholds, cultural fixes
4ee1cfc — fix: engine round 3 - eliminate prompt redundancy, raise compat threshold
eaa04ca — fix: engine round 2 - QA fixes for prompt coherence and validation
fe82dc3 — feat: engine upgrade round 1 - palm prompt overhaul + compat data

</details>
