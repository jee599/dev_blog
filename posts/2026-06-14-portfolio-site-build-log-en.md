---
title: "532 Tool Calls, 28 Hours: What Claude Code's Ultracode Mode Actually Does"
published: true
description: "9 sessions, 5 projects, 1,000+ tool calls in 3 days. Here's what running Claude Fable 5 with ultracode actually looks like at scale."
tags: claudecode, ai, webdev, productivity
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-14-portfolio-site-en
---

532 tool calls. 28 hours. One session. That's not a typo.

Last week I ran a single Claude Code session that lasted 27 hours and 48 minutes, touched 70+ new files, and shipped admin panels, payment integration, multilingual support, TTS, and a resume builder — all in one uninterrupted run. The model was `claude-fable-5` with the `ultracode` flag.

Here's what I learned about long-running AI sessions, and why the failure modes are just as interesting as the wins.

---

**TL;DR:** Between June 11–13, I ran 9 sessions across 5 simultaneous projects. `ultracode` isn't just "faster Claude" — it's a switch that automatically enables fan-out workflow orchestration. The `/goal` hook is what makes 28-hour sessions possible (and occasionally dangerous).

---

## Why Would a Session Last 28 Hours?

Normal Claude Code sessions run 30 minutes to 2 hours. This week was different.

| Session | Duration | Tool Calls | Project |
|---------|----------|------------|---------|
| Session 4 | 25h 26min | 356 | Saju Global Redesign |
| Session 5 | 27h 48min | 532 | CoffeeChat Admin/Payments |
| Session 6 | 24h 48min | 105 | AEO Outreach Engine |

The mechanism is the `/goal` hook. When you set a goal condition, Claude won't end the session until that condition is satisfied. Session 5's goal was roughly: *"Add per-user admin panel + token usage tracking + payments + full multilingual support to CoffeeChat."* That's a wide condition. Wide conditions create long sessions. All 532 tool calls ran toward a single goal state.

The catch: sessions this long compress context over time. Early architectural decisions get fuzzy. I developed a `/clear` + `/goal` reset pattern — basically a manual context refresh to re-anchor direction mid-session. It's not elegant, but it works.

In Session 5, the breakdown was: Bash (190), Edit (136), Write (66). If you're trying to hold a session together at this scale without `/clear`, you're betting on context coherence across 20+ hours. That bet sometimes loses.

---

## What `ultracode` Actually Does

Running `/effort ultracode` adds `xhigh + dynamic workflow orchestration` to the system configuration. Here's what that looked like in practice:

**Session 2 — Funding Research Fan-Out**

I gave it: *"Exhaustively survey primer-level seed investment and grant programs."*

What happened: it spun up 5 parallel search agents by category, ran 209 searches and verifications, filtered 57 programs down to 7 recommendations matching a solo-founder profile. Doing this manually would have taken two days. The key thing — I didn't tell it to parallelize. It decided the task structure warranted fan-out and did it.

**Session 9 — Outreach Failure Audit**

Prompt: *"JDLab Dynamic Outreach Failure Audit."*

It first performed reconnaissance on Gmail access permissions, then hunted for quota DSN messages to diagnose the actual failure cause. The agent determined its own workflow structure based on what it found during the recon phase. This is the meaningful shift with `ultracode`: the orchestration pattern emerges from the task, not from instructions.

---

## The Saju Global Payment Positioning Problem

Session 4 started with a genuine business question: *"If we reposition this as traditional Korean fortune-telling instead of AI-powered, does that help us get approved for payment processing?"*

The empirical answer was no — and the data was interesting.

A natural experiment on Etsy told the story: a shop that led with "AI Reading" had 0 sales after one month. A shop using a human persona (연화 만신 / Yeonhwa Mansin) had 464 sales, 130 reviews, and a $34 average price. Payment platform review processes look at service category, not landing page copy. If your service takes birth date and time as inputs and returns fortune-based content, it gets classified as divination regardless of what the headline says. "AI saju" and "traditional saju" land in the same bucket.

We confirmed that repositioning wouldn't circumvent the payment review, kept the traditional positioning for product reasons, and resolved the payment rails separately.

For the actual build: we ran the `open-design` skill and built `landing-midnight.html` through v1 → v2 → v3 iterations. `gpt-image-2` was generating images in the background while v3 code was being written in parallel. This matters because image generation is the slowest part of the pipeline — parallelizing it avoided a sequential bottleneck that would have added hours.

---

## The Git Email Block That Stopped a Deploy

Session 5 hit a wall that had nothing to do with AI:

```
The deployment was blocked because the commit author email
(jidong@jidongui-iMac.local) is not valid.
```

The local machine hostname had been committed into `git config`. The author email was literally `username@machinename.local` — which Cloudflare's deployment pipeline rejected.

Fix was manual: update `.gitconfig` directly with the correct email, recommit. Claude Code won't touch `git config` by policy (security constraint), so this required a human in the loop. It's a small thing, but in a 532-tool-call session you don't expect a deploy to fail because of a config file you set up two years ago.

---

## How the `design-gate` Hook Forced Better Decisions

My `CLAUDE.md` has a rule: *"No HTML artifacts without passing through Open Design or an equivalent design system pass."* The hook `hooks/design-gate.sh` enforces this by blocking `.html` file writes until a pass is acknowledged.

When Session 6 triggered the `report-builder` skill, it had to clear the gate first:

```bash
bash ~/.claude/hooks/design-pass.sh "report-builder design system pass"
```

Initially this felt like friction. But the forced pass made one decision happen that wouldn't have happened otherwise: choosing between Stripe, Notion, and Linear design systems before writing a line of CSS. This produced a comparison page (`_theme-directions.html`) that documented the choice. Without the hook, there's a high probability I would have written improvised CSS and ended up with something inconsistent.

The hook creates a forcing function. The forcing function creates a decision record. The decision record is worth something six weeks later when you can't remember why the typography looks the way it does.

---

## P0 Before GTM: The spoonai Session

Session 7 started as a "how do we market this" conversation. The session opened with a P0 bug audit instead.

Two critical issues surfaced immediately: new subscribers couldn't receive emails permanently (silent failure in the subscription flow), and the unsubscribe link returned a 404. Shipping a marketing strategy on top of broken email delivery would have been actively harmful.

The fixes:
- Added `/unsubscribe` and `/feedback` pages
- Changed `/api/unsubscribe` GET from a deletion endpoint to a 302 redirect to a confirmation page

Committed at `4a3c598`, deployed to `spoonai.me`, response codes verified against live URLs. The whole sequence — P0 diagnosis, fix, test, deploy, verify — ran in 56 tool calls over 22 minutes.

This is a pattern worth internalizing: when you give an agent a broad business question, it may correctly determine that the answer is "fix what's broken first." That's usually right.

---

## How 9 Sessions Share Context Without Repeating Themselves

Nine sessions, each starting fresh. Without a memory system, each one would require a full context dump to re-establish what's been done.

The setup: `~/.claude/projects/-Users-jidong/memory/` holds per-project memory files. Session start automatically reads relevant memories. The result is that "what's left to do?" gets a direct answer about Vercel Blob storage flows and admin tab structures — because that was written into memory by a previous session.

Session 3 (daemun site) is the extreme case: 6 tool calls, 5 minutes. The brevity is only possible because the relevant memory already existed. That session didn't need to re-establish context; it just picked up where the last one left off.

The practical implication: memory hygiene matters as much as prompt quality. A session that doesn't write useful memory creates debt for the next session.

---

## What's Still Unfinished

Shipping 5 projects in 3 days sounds clean. The actual state is messier:

- **CoffeeChat**: Turso DB connection and PayPal webhook production testing are incomplete. The scaffolding exists; the live integration doesn't.
- **Saju Global v3**: Landing page code is done. Integration into the Next.js app hasn't happened.
- **AEO Outreach Engine** (`hermes-dashboard/aeo-engine`): Structure exists, but the actual prospect pipeline isn't connected.

Session 8 hit a model availability error: `claude-fable-5[1m]` returned "It may not exist or you may not have access." The session recovered, but it added unnecessary friction. Running `/model` before starting a session to confirm availability should be standard practice — it's now on my checklist.

---

## Numbers That Stuck

- **532 tool calls in one session**: mostly Bash (190), Edit (136), Write (66)
- **70+ new files** created in Session 5
- **209 searches** to filter 57 funding programs to 7 recommendations
- **22 minutes** to diagnose, fix, deploy, and verify two P0 bugs
- **5 minutes / 6 tool calls** for a full project handoff session (when memory exists)

The ratio between the 22-minute session and the 28-hour session is what I keep thinking about. Both were productive. The difference is scope management, not model capability.

---

## One Thing That Would Have Made This Week Better

The `/goal` hook is powerful enough to run sessions longer than a workday. That's both the feature and the risk. A goal that's too broad creates sessions that are hard to interrupt, and context compression at hour 20 is real — early decisions get fuzzy and you start seeing the model hedge on things it was confident about early on.

The pattern that works better: set a goal for a discrete milestone, not an entire feature set. "Add payment integration" is a better goal than "add payment + admin + multilingual + TTS." The second goal works if you're willing to babysit context resets. The first goal mostly runs itself.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
