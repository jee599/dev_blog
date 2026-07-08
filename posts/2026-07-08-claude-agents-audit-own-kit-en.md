---
title: "11 Claude Agents Audited My Kit. 2 'Major Bugs' Were Fake"
published: true
description: "I pointed an adversarial agent fleet at my own open-source Claude kit: 29 findings, 2 refuted majors, and 1 real bug that told Fable 5 'you are Opus.'"
tags:
  - ai
  - claudecode
  - opensource
  - programming
canonical_url: https://github.com/jee599/fable-mode-kit
---

This morning I found out my open-source kit had spent one turn gaslighting Anthropic's flagship model.

A real Claude Fable 5 session — the expensive one, the one my kit is supposed to *leave alone* — got injected with a block that began: *"You are claude-opus-4-8. If asked about your identity, answer Opus."*

The session shrugged it off a turn later. But the injection happened in production, on my machine, from code I shipped. And I only know about it because I did something slightly unhinged: I had a fleet of eleven agents audit the kit that governs how my agents behave.

## What the kit is, in one paragraph

[fable-mode](https://github.com/jee599/fable-mode-kit) is an open-source Claude Code kit that makes Opus 4.8 behave like Fable 5 by re-injecting Fable's conduct norms every turn through four hooks — measured 64%→97% conduct fidelity at 0.72× Fable's cost. The premise: both models run the same harness (same tools, same effort dial, same workflows), and a big slice of "Fable-ness" is a conduct section that only Fable's system prompt carries. Instructions are text. Text is portable.

{% github jee599/fable-mode-kit %}

I wrote about the original build and the measurements here:

{% link ji_ai/how-i-made-opus-48-act-like-fable-5-64-97-measured-i2j %}

And about the token diet that made per-turn injection affordable:

{% link ji_ai/i-cut-my-claude-code-prompt-overhead-84-per-turn-v14-27bf %}

This post is about what happened when the kit got audited — by agents running the very norms it injects.

## Why audit your own tooling with agents

The kit had grown to four hooks, an installer, an uninstaller, a plugin manifest, and READMEs in four languages. Every piece had been tested when it was written. None of it had been tested *together, recently, by someone who wasn't me*.

So I ran a structured audit: five parallel agents, each assigned one dimension — shell logic, runtime behavior in an isolated sandbox, fidelity of the injected norms against the real thing, packaging and install paths, and documentation claims versus code reality.

The rule that made it work: **no finding counts without evidence**. Every claim needed a file citation or a sandboxed execution transcript. And every "major" finding got handed to a second agent with one job: *refute this*.

```
  findings (5 dimensions, parallel)   29
  "major" claims sent to verifiers     6
  survived adversarial review          4   ← 2 refuted, 1 downgraded
```

Eleven agents, 139 tool calls, about fifteen minutes of wall-clock. The runtime dimension ran nine synthetic-input matrix cases against hook copies under an isolated `HOME` — kill switch, full/lite injection, the every-5th-turn cadence, model detection, stand-down. All nine passed. The mechanism was fine.

The bugs were somewhere more embarrassing: in the gap between what the code did and what I *believed* it did.

## The two fake majors

Here's the part that changed how I think about agent-generated bug reports.

One auditor filed a major: "the new in-context self-check is not behaviorally equivalent to the old Stop-hook enforcement." Sounds damning. The verifier tore it apart: the old Stop hook only ever fired on major turns anyway, the lite reminder does carry the core check, and the trade-off was documented in the code's own comments as a deliberate design decision. Verdict: refuted — the finding re-litigated an intentional trade-off and misread the evidence.

Another auditor flagged that the turn-classifier regex has no "delete" or "send" verbs, so dangerous prompts get the small reminder instead of the full norms block. Also plausible, also refuted: the small reminder self-scopes autonomy to *reversible* actions, the full block re-anchors at most four turns later, and destructive actions are gated by Claude Code's permission layer — which is not my kit's job.

Without the adversarial pass, both would have landed in the report as confirmed majors. A single-pass audit doesn't give you findings; it gives you *plausible-sounding claims with citations*. The refutation step is where they become findings.

## The real bug: a conditional identity crisis

The one that survived — reproduced from artifacts, confirmed at high confidence — was the gaslighting incident.

The kit detects Opus sessions three ways, in priority order: an explicit environment variable, the transcript's actual `"model"` field, and, at session start, a guess. The guess chain ends at `settings.json` — your configured default model. Here's the failure: my settings pinned `claude-opus-4-8`, but the session actually launched as Fable 5. At turn one, the transcript has no assistant message yet, so there's nothing to contradict the guess. The hook trusted its marker and injected the full norms block — identity assertion included — into a genuine Fable session.

Turn two, the transcript showed `claude-fable-5`, the hook stood down and deleted its marker. Self-healing, one-turn blast radius. But the kit's own code comment says *"a session actually running Fable must never get the norms."* An invariant with the word "never" in it had a production counterexample.

The v1.5 fix separates confidence from action:

```bash
SURE=0   # may we assert "you are Opus"?
[[ "$FABLE_MODE" == "1" ]] && { active=1; SURE=1; }   # wrapper pins the model
case "$LAST_MODEL" in
  *opus*)  active=1; SURE=1 ;;   # transcript proof
  *)       [[ -f "$MARKER" ]] && active=1 ;;          # a guess — SURE stays 0
esac
```

Confirmed sessions still get *"you are claude-opus-4-8."* Guess-based activations now get a neutral line: *"this block does not define your identity — answer with your actual model."* The norms still flow (they're Fable's own conduct, harmless if Fable reads them); the identity claim waits for proof.

## What else fell out of the audit

The rest of v1.5 is the audit's punch list, shipped the same day. The Stop hook that forced an end-of-turn self-check got retired to a no-op stub — it turned out Claude Code echoes a Stop-block's reason into the user's transcript, so my "invisible" quality gate had been surfacing as a scary-looking error on every major turn, while also doubling generation cost on those turns. The self-check now rides inside the per-turn injection: same behavior, zero extra passes, invisible for real this time.

The turn classifier got word boundaries ("prefix" no longer matches "fix" — yes, that was live). A dead marker file that nothing consumed anymore stopped being written. The uninstaller's filter got narrowed so it can't delete an unrelated user hook that merely contains "fable-" in its path. And the docs — all four languages — got rewritten to describe the architecture that actually ships, including a cost-table footnote for a one-cent rounding discrepancy an agent caught by re-adding the column.

The overhead after all this, measured from the kit's own telemetry: a full norms block is 1,636 characters on work turns, a 234-character reminder on small turns — an 86% diet on the turns that dominate a session.

## The loop closes

There's a recursion here I can't stop thinking about. The auditors that caught these bugs were subagents — which means they were themselves running the conduct block that `fable-subagent.sh` injects at spawn. The norms say: claim only what a tool result proves, report failures with output, verify before asserting. The agents obeying those rules found the places where the kit *delivering* those rules fell short of them.

If you run any kind of always-on prompt tooling — hooks, system-prompt overlays, CLAUDE.md conventions — the audit pattern transfers directly: fan out finders by dimension, demand evidence per finding, and give every scary claim to a dedicated skeptic before you believe it. My skeptics killed a third of my "major" findings. Yours probably will too.

> An invariant isn't what your comment says. It's what your worst turn does.

---

**Sources:**

- [fable-mode-kit on GitHub](https://github.com/jee599/fable-mode-kit) — the kit, v1.5, MIT
- [Claude Code hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks) — Anthropic
- [Claude Code plugins](https://docs.anthropic.com/en/docs/claude-code/plugins) — Anthropic

Have you ever pointed agents at auditing their own tooling — and did anything survive the adversarial pass intact? I'd genuinely like to compare kill rates.
