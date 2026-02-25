---
title: Why You Shouldn't Let AI Do Your Fortune Telling — And How to Do It Right
published: true
description: Computation goes to code. Interpretation goes to AI. One line I wish I'd known three weeks earlier.
tags: [ai, llm, architecture, promptengineering]
series: AI Fortune App Build Log
---

The first lesson I learned building a fortune-telling app: it's not about what you ask AI to do — it's about what you don't.

A note before we start: this series is a build log, not a success story. Revenue so far is $0. I'll share real conversion and revenue data after launch. Think of this as a journal of mistakes made and lessons learned.

"Tell me the fortune for someone born March 15, 1990."
I threw this straight at an LLM. The response looked great. Smooth sentences, Five Elements this, Wood-Fire-Earth-Metal-Water that.

But there was a problem. The base calculations were wrong.

```
Me: "Analyze the Four Pillars for March 15, 1990, 6 AM"
Claude: "The year pillar is Geng-Wu, month is Ji-Mao..."
Me: "...Ji-Mao is wrong."
```

Some context if you're not familiar with this system: Four Pillars of Destiny (known as 사주 in Korean) is an ancient East Asian system that maps your birth date and time into a combinatorial structure — think of it as a calendar-based personality and fate analysis with 518,400 possible combinations. It uses a 60-cycle system of "Heavenly Stems" and "Earthly Branches" (essentially a base-10 × base-12 calendar encoding) to create four "pillars" from your birth year, month, day, and hour.

LLMs can't compute this. More precisely, they appear to get it right probabilistically, but they don't actually calculate anything. The month pillar shifts at solar term boundaries — not calendar month boundaries. The hour pillar depends on the day's Heavenly Stem. This isn't reasoning — it's arithmetic. And when you ask a language model to do arithmetic, it gets things wrong.

When the base stems are wrong, everything downstream is garbage. Wrong Five Elements. Wrong Ten Gods. Wrong structure analysis. A beautifully written paragraph with incorrect data isn't fortune analysis — it's fiction.

## The Right Architecture: Code Computes, AI Reads

Once I realized this, I rebuilt the whole thing.

```mermaid
graph LR
    A[Birth date + time] --> B[Calendar Engine]
    B --> C[Accurate JSON]
    C --> D[LLM]
    D --> E[Interpretation]
```

I built the calendar engine in code. It's based on the lunar-typescript library, with solar term correction, leap month handling, and midnight boundary logic — all deterministic algorithms. The output is a JSON object: Heavenly Stems, Earthly Branches, Five Element distribution, Ten Gods relationships, structure type, favorable elements. All precise.

The LLM gets this JSON. "Read this data and interpret it." That's the entire prompt strategy.

Code handles: calendar calculations (must be 100% accurate).
AI handles: turning that data into readable, insightful language (linguistic ability).

Once this separation was in place, testing became possible. 99 test cases. 42 golden cases. Cross-verified against multiple traditional calendar databases. If the engine is wrong, the test fails immediately. When you let the LLM do everything, you can't even tell *where* it went wrong.

## "It's Perfect" — And Then It Wasn't

Here's another lesson. When I first built the engine, the test results came back clean. "All tests passing." So I moved on.

Later, I ran edge cases. And things broke.

One real example. February 4, 2024 is "Ipchun" — the solar term that marks the start of spring and the boundary where the year pillar changes. The year shifts from Gui-Mao to Jia-Chen on this day. But here's the thing: Ipchun doesn't happen at midnight. In 2024, it hit at 4:27 PM. Someone born that morning is still in the previous year. Someone born at 5 PM is in the new year. My engine looked at the date alone and assigned the new year to everyone born on February 4th. It didn't account for the *time* of the solar term transition. One wrong year pillar, and the entire Five Element analysis collapses.

A similar bug surfaced with the "Zi hour" — the two-hour window spanning 11 PM to 1 AM. Different schools of thought disagree on whether 11:00-11:59 PM belongs to the current day or the next day. My code needed to pick one rule, but it hadn't made that choice explicitly. The default behavior was ambiguous.

These bugs never show up with normal test cases like "1990-03-15." The lesson: "all tests passing" doesn't mean "it's correct." It means "you haven't tested the cases that would break it."

So I overhauled QA completely. Beyond the 42 golden cases, I added every solar term boundary, leap month edge, Zi hour case, and year-end transition I could find. Cross-checks against three or more external sources became mandatory. One failure triggers re-verification of the entire suite. The new standard: not "tests pass" but "we can't find anything left to break."

The takeaway is simple. Don't trust the engine — trust the tests. And then question whether your tests are sufficient.

## This Isn't Just About Fortune Telling

The "code computes, AI interprets" principle applies beyond Four Pillars.

I almost made the same mistake adding name analysis to the same project. In Korean name numerology, the stroke count of each character is a precise mathematical input. The surname "Park" (박) could be 6 strokes or 7 strokes depending on which standard you follow. When I asked the LLM, it said "usually 6." But in traditional numerology, it's 7 — based on the original Chinese character form. That one-stroke difference flips the entire numerological profile. So stroke counts come from a code lookup table, and the AI only handles "explain what this numerical combination means."

The key question when building any AI app: "Does this task need to be *accurate* or *fluent*?" If accurate, use code. If fluent, use AI. If both, code computes first, and AI reads the result.

> "The most important decision in AI app development isn't what to ask AI to do — it's what not to."

---

*Next: How I Cut LLM API Costs by 88% — Prompt Caching, Model Routing, and Structured Output*
