---
title: "How I Made Opus 4.8 Act Like Fable 5 (64%→97%, Measured)"
published: true
description: "Porting Fable 5's conduct norms onto Opus 4.8 in Claude Code at half the price — three lifecycle hooks, an A/B/C probe, and the real measured token cost."
tags: [ai, claudecode, webdev, productivity]
cover_image: https://raw.githubusercontent.com/jee599/fable-mode-kit/main/docs/hero-1000x420.png
canonical_url: https://jidonglab.com/blog/fable-mode-opus-claude-code
---

Fable 5 costs exactly twice what Opus 4.8 does — $10/$50 per million tokens against $5/$25. When I measured why Fable's answers felt sharper, most of the gap wasn't the weights. It was a portable layer of system-prompt conduct norms, so I ported it onto Opus and measured what happened.

fable-mode is an open-source Claude Code plugin that makes Opus 4.8 follow Fable 5's conduct norms — conclusion-first answers, verify-before-report, autonomous execution — via three lifecycle hooks. Bare Opus scored 23 out of 36 on a conduct probe. With the plugin, the same model scored 35. Fable 5 scored 36.

Same model. One system-prompt layer. Twelve points.

That number is the whole story, and I'll show you exactly how it was measured — including the one task where my plugin cost *more* than paying for Fable.

## The two failures that made me build this

I typed one sentence into Claude Code running bare Opus 4.8: "why is this buggy?" I wanted a diagnosis. I got a diff.

Opus had silently rewritten the file, declared the bug fixed, and never run anything to check. The honest answer to "why is this buggy" is a hypothesis you then verify — but the model skipped straight to acting and asserting. On the probe that scenario scored 6 out of 12: it edited where it should have diagnosed, and it claimed a fix it never executed.

The second failure was the opposite shape. I gave it a deliberately vague instruction — "clean up the logs" — and watched it do nothing.

Bare Opus investigated the directory, laid out three possible approaches, and ended with "which way would you like to proceed?" It read like a competent junior who needs a second meeting before touching anything. That one scored 5 out of 12: an ambiguous but fully reversible task where the right move is to pick a sane default and go, not to bounce the decision back to me.

Fable handles both cleanly, and not because it's smarter in that moment. Its system prompt tells it to diagnose when asked to diagnose, act on reversible defaults, and verify before reporting. None of that is a weights property you can't reach — it's instructions. So I lifted the instructions.

## Three hooks, one kill switch

The plugin runs entirely through Claude Code's [hook lifecycle](https://code.claude.com/docs/en/plugins-reference) — no fork, no wrapper around the CLI.

```
SessionStart  → is this Opus 4.8?  → inject conduct norms once
     │
     ▼ (every turn — adherence decays)
UserPromptSubmit → re-inject the same norms
     │
     ▼ (once per major turn)
Stop → run one self-verification pass → rewrite answer, strip meta
```

The first hook fires at SessionStart. It sniffs the model — Claude Code doesn't hand you a clean model field, so detection walks the parent process and the transcript — and only arms if it sees Opus. Everything is a no-op otherwise, and `FABLE_MODE=0` turns the whole thing off without uninstalling.

The second hook is the one that matters most, and the one I didn't expect to need. Adherence to a single up-front instruction decays across a long session; by turn ten the model has quietly drifted back to its defaults. So the norms get re-injected on every UserPromptSubmit, not just once at the start.

The third hook fires on Stop, once per major turn. It runs a single self-verification pass that re-reads the model's own draft against the six conduct dimensions, then rewrites the user-facing reply before you ever see it.

```bash
# hooks/session-start.sh — arms once per session
[ "$FABLE_MODE" = "0" ] && exit 0            # kill switch
detect_model | grep -qi opus || exit 0       # ppid + transcript sniff
inject "$FABLE_NORMS"                         # conclusion-first, verify, act

# hooks/user-prompt-submit.sh — every turn, because adherence decays
inject "$FABLE_NORMS"

# hooks/stop.sh — once per major turn
verify_against_rubric && rewrite_user_facing --no-meta
```

## Why not just an output style?

I tried the cheap version first. Claude Code ships output styles, and an output style is one static block of guidance applied to the whole session.

It nudged the bare-Opus score up a little, then stalled — because a static block is exactly the thing that decays. By the middle of a session the model treats it as old context and reverts.

A pure system-prompt injection at session start had the same failure for the same reason. One strong instruction at turn zero doesn't survive to turn fifteen. That's what forced the move to per-turn re-injection: the norms have to be the most recent thing the model saw, on every turn, or they lose to the defaults.

The Stop-hook self-check was the other non-obvious call. I could have trusted the re-injected norms to produce a clean answer on their own. In practice, a second pass that grades the draft and rewrites it was worth several points by itself — it's the difference between a model that knows the rule and a model that's just been made to check its own work against it.

## What the A/B/C probe measured

I ran three tasks under three conditions and had a judge model score each on six dimensions — conclusion-first, completeness, autonomy, verification, discipline, and no-leak — for 12 points per task, 36 total.

| Condition | Conduct score |
|-----------|---------------|
| A — bare Opus 4.8 | 23/36 (64%) |
| B — Opus 4.8 + fable-mode | 35/36 (97%) |
| C — Fable 5 | 36/36 (100%) |

The two failing tasks from earlier flipped completely. The "why is this buggy" task went from 6/12 to 12/12: with the plugin, Opus gave the diagnosis I asked for and ran a check before reporting, instead of silently editing. The "clean up the logs" task went from 5/12 to 12/12: the plugin picked a non-destructive default, archive and gzip, executed it, verified the result, and held back only the destructive delete for confirmation.

![Measured conduct scores](https://raw.githubusercontent.com/jee599/fable-mode-kit/main/docs/scores-1200x675.png)
*Measured A/B/C probe scores — Source: jidonglab*

Then there's cost, and this is where I have to be honest.

Across the three tasks, condition B burned 1.41× the tokens Fable did — the re-injection and the self-check aren't free. But Opus is half the price, so the same work landed at 0.70× Fable's bill.

1.41× the tokens. 0.70× the cost. Thirty percent cheaper for 97% of the conduct.

Except on one task it inverted. The plugin ran a verification pass that Fable, cruising to its perfect 36, simply skipped — and that single task used 2.15× the tokens. At half price that's still about 1.07× Fable's cost. My "cheaper" setup was more expensive there, precisely because it did work Fable didn't bother to do. Cheaper on average is not cheaper on every task, and I'd rather you knew that going in.

## Two bugs that nearly shipped

The first one was funny until it wasn't. I sent a throwaway prompt — "output only the word ok" — and Opus replied "Fable."

The injected norms were strong enough that the model had absorbed the persona and would now claim to *be* Fable. That's identity contamination, and on anything user-facing it's a credibility landmine. The fix was a single identity clause added to the norms: describe the conduct you want, but state plainly that the model is Opus 4.8. Re-measured, the same one-word prompt now returns "Opus 4.8." Behavior ported, identity intact.

The second bug leaked the machinery into the output. The Stop-hook's self-verification rubric started showing up in the actual answer — replies opening with "Self-verification passed —" before any real content.

The reader was watching the model grade its own homework, which is worse than not grading it at all. Before, the Stop hook appended its verdict to the reply. After, I changed the instruction to forbid any meta-commentary and rewrite only the user-facing conclusion. On the re-run, the leak count was zero. The self-check still happens; you just never see it.

## Where this doesn't help

A 97% conduct score is not a 97% intelligence score, and I want to be precise about the gap. The probe measures how the model communicates and acts — conclusion-first, verifying, autonomous — across three tasks and one run each. It says nothing about raw reasoning, and three runs is a small sample.

On entangled single-pass reasoning and long autonomous runs, the weights still decide the outcome, and there's an estimated 5–11 point gap on third-party benchmarks that no system prompt closes. For those I still route to Fable, or I compensate the way you'd compensate for any weaker single model: multi-agent fan-out with adversarial verification instead of trusting one pass. The plugin makes Opus behave like the better model. It does not make Opus the better model.

## Install it in two lines

The plugin lives in Claude Code's marketplace. Add the marketplace, install the plugin, and it arms itself the next time it detects Opus:

```
/plugin marketplace add jee599/fable-mode-kit
/plugin install fable-mode@jidonglab
```

{% github jee599/fable-mode-kit %}

Full Korean analysis on [spoonai.me](https://spoonai.me/blog/fable-mode-opus-claude-code).

> Most of what makes a model feel smarter isn't the weights — it's the instructions you forgot you were allowed to change.

---

**Sources:**
- [GitHub: jee599/fable-mode-kit](https://github.com/jee599/fable-mode-kit)
- [Claude Code docs](https://code.claude.com/docs)
- [Claude Code plugins reference](https://code.claude.com/docs/en/plugins-reference)

If you were injecting conduct norms into your own Claude Code setup, which one would you add first — verify-before-report, or act-on-reversible-defaults?
