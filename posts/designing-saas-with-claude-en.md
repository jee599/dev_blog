---
title: "How I Designed an Entire SaaS Using Claude Alone"
published: true
description: "9 sessions. 20 deliverables. 6 virtual experts. A consulting firm would charge weeks and tens of thousands. Solo, one day, $0."
tags: [ai, claude, saas, promptengineering]
series: "AI Fortune App Build Log"
---

> **TL;DR** — Tell Claude to "assemble a panel of 6 experts and hold a meeting."
> It catches blind spots a solo builder would miss. Not real experts, but way better than flying solo.

"Remove the login wall first. Magic link auth is your biggest drop-off point."

That wasn't a person. It was Claude simulating a "PM" during an expert panel session.

In one day, I ran 9 sessions with Claude. Twenty deliverables came out. Business strategy docs, landing page designs, expert panel meeting minutes, LLM cost analysis, global expansion strategy, and task files ready to feed into Claude Code.

If I'd hired a consulting firm for this, it would've been weeks and tens of thousands of dollars.

Solo, one day, $0.

---

## The Key: Progressive Detailing

I didn't dump everything at once. The conversation deepened naturally.

```
Turn 1: "Is a fortune-telling app viable?" (abstract)
Turn 2: "Design a revenue model with free and paid tiers" (concrete)
Turn 3: "Calculate free tier API cost per token" (very concrete)
Turn 4: "Compare scenarios A/B/C with prompt caching" (ultra-concrete)
```

Asking "write me a business plan" in one shot gets generic output.

Ramp up depth gradually, and each step benefits from the full context of everything before it. The results get dramatically more precise.

---

## The Expert Panel Cheat Code

The most effective technique was "expert panel simulation."

```
Me: "Assemble a panel of 6 experts:
    1 PM, 1 biz dev, 1 localization specialist,
    1 US market expert, 1 full-stack dev, 1 UI/UX designer.
    Give them names and perspectives.
    Have them review our current STATUS.md and discuss."
```

Claude created six characters, each debating from their own angle. The PM prioritized tasks. Biz dev challenged market assumptions. The developer flagged technical complexity. The designer raised UX concerns.

When you're building solo, you only have your own perspective. This gives you six at once.

It's not the same as six real experts — but it's remarkably effective at catching blind spots a solo builder would miss.

---

## Six Key Decisions From the Panel

**First, remove the login wall.** The PM pointed out magic link auth was the biggest drop-off point. Free analysis switched to fully anonymous.

**Second, cut free tier costs by 94%.** Algorithm formatting plus a one-line AI summary instead of full LLM calls. Per-request cost: $0.085 → $0.005.

**Third, register the business immediately.** Don't wait for user validation — payment integration needs it now.

**Fourth, GA4 and rate limiting are non-negotiable.** No analytics means driving blind. No rate limits on a free API means a cost bomb.

**Fifth, prioritize KakaoTalk sharing and OG images.** For a fortune service, viral sharing is the only free marketing channel.

**Sixth, Korea PMF first.** No English localization resources until paid conversion hits 3%.

Would I have thought of all six on my own? Honestly, items three (immediate registration) and four (rate limiting) would have come to me much later.

---

## This Conversation Is a Framework

The process maps to any project:

```
1. Share the vision    → "I want to build this" (big picture)
2. Set the strategy    → "Design the business model" (choose from options)
3. Expert review       → "Have the panel validate this" (simulation)
4. Design              → "Build a landing page for this strategy" (working HTML)
5. Cost analysis       → "How much does this cost to run?" (per-token)
6. Expansion design    → "What if we go international?" (architecture)
7. Task generation     → "Make this executable in Claude Code" (TASK MD)
```

Using AI as a tool and thinking with AI are different things.

As a tool: "Write me the code." As a thinking partner: "Is this the right structure? What am I missing? What perspective am I blind to?"

For solo builders, the second mode is far more valuable.

---

One honest caveat. Some numbers from this panel — "30% conversion rate," "₹99 is the optimal price" — have no evidence behind them. They're hypotheses Claude generated, not data-driven conclusions.

Hypotheses stay hypotheses until real post-launch data proves or disproves them.

> "Think with AI and you get six perspectives at once. They're not real experts, but they're far better than flying solo."
