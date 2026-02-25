---
title: Why You Shouldn't Let AI Do Your Fortune Telling — And How to Do It Right
published: true
description: I asked an LLM to calculate a birth chart. The base numbers were wrong. 3 weeks wasted.
tags:
  - ai
  - webdev
  - llm
  - architecture
series: AI Fortune App Build Log
id: 3284915
date: '2026-02-25T14:48:51Z'
---

> **TL;DR** — LLMs can't do calendar math. Code computes, AI interprets. That one line is the entire architecture.

The first lesson I learned building a fortune-telling app: it's not about what you ask AI to do — it's about **what you don't**.

This series is a build log toward launching a saju (Korean four-pillar fortune telling) app. Revenue is still $0. Real conversion and revenue data will come after launch. This isn't a success story — it's a debugging diary.

---

"Tell me the fortune for someone born March 15, 1990."

I threw this straight at an LLM. The response looked great. Smooth sentences, Five Elements this, Wood-Fire-Earth-Metal-Water that.

But there was a problem. **The base calculations were wrong.**

```
Me: "Analyze the Four Pillars for March 15, 1990, 6 AM"
Claude: "The year pillar is Geng-Wu, month is Ji-Mao..."
Me: "...Ji-Mao is wrong."
```

LLMs can't do manseryeok (traditional Korean astronomical calendar) calculations. More precisely, they appear to get it right probabilistically, but they don't actually compute anything.

The Heavenly Stems and Earthly Branches follow a 60-cycle system. Month pillars shift at solar term boundaries. Hour pillars depend on the day's Heavenly Stem. This isn't reasoning — it's arithmetic.

When you ask a language model to do arithmetic, it gets things wrong.

And when the base stems are wrong, everything downstream is garbage. Wrong Five Elements. Wrong Ten Gods. Wrong structure analysis.

A beautifully written paragraph with incorrect data isn't fortune analysis — it's **fiction**.


---

## The Right Architecture: Code Computes, AI Reads

Once I realized this, I rebuilt the whole thing.

```
[Birth date + time] → [Calendar Engine] → [Accurate JSON] → [LLM] → [Interpretation]
```

I built the calendar engine in code. It's based on the lunar-typescript library, with solar term correction, leap month handling, and midnight boundary logic — all deterministic algorithms.

The output is JSON. Heavenly Stems, Earthly Branches, Five Element distribution, Ten Gods relationships, structure type, favorable elements. All precise.

The LLM gets this JSON. "Read this data and interpret it." That's the entire prompt strategy.

Code handles the calendar calculations — the part that must be 100% accurate. AI handles turning that data into readable, insightful language.

Once this separation was in place, testing became possible. 99 test cases, 42 golden cases, cross-verified against multiple traditional calendar databases.

If the engine is wrong, the test fails immediately. When you let the LLM do everything, you can't even tell *where* it went wrong.


---

## "It's Perfect" — And Then It Wasn't

When I first built the engine, the test results came back clean. "All tests passing." So I moved on.

Later, I ran edge cases. Subtle errors appeared.

Real example. February 4, 2024 is Lichun (Start of Spring) — the day the year pillar switches from Gui-Mao to Jia-Chen. But **the exact transition time is 4:27 PM**.

Someone born that morning is still Gui-Mao year. Someone born at 5 PM is Jia-Chen. The engine only checked the date, not the time. The entire year pillar was wrong, and every Five Element analysis built on top of it collapsed.

The Zi hour (11 PM to 1 AM) had similar issues. Whether the first half (23:00-23:59) belongs to the current day or the next depends on which school of thought you follow. The code hadn't made that choice at all.

These bugs don't surface with ordinary dates like 1990-03-15.

"All tests passing" didn't mean it was correct. It meant **"which cases haven't we tested yet?"** was the real question.

I overhauled the QA process. Solar term boundary days, leap months, Zi hour transitions, year-end rollovers — all added as edge cases. Mandatory cross-checks against three or more external sources. One failure triggers re-verification of the entire suite.

The new standard: not "tests pass" but "QA can't find any more bugs."


---

## This Isn't Just About Fortune Telling

While adding name analysis to the same project, I nearly made the same mistake.

In Korean nameology (seongmyeonghak), whether the surname "Park" has 6 or 7 strokes completely changes the Five Element reading. Ask an LLM and it says "usually 6." But in traditional nameology, the original Chinese character has **7 strokes**.

One stroke difference. The entire numerological analysis flips.

So stroke counts come from a code lookup table. "Explain what this numerical combination means" goes to AI.

The key question when building any AI app:

"Does this task need to be **accurate** or **fluent**?"

Accurate — code. Fluent — AI. Both — code computes first, AI reads the result.

> "The most important decision in AI app development isn't what to ask AI to do — it's what not to."
