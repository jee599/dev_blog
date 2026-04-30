---
title: "GPT-5.5-Codex vs 5.3: A 200-Task Bench Result"
published: true
description: "I ran both Codex models on 200 real coding tasks across two repos. Token, time, and pass-rate deltas — including the cases 5.5 actually loses."
tags: [ai, openai, webdev, productivity]
cover_image: https://r2.jidonglab.com/blog/2026/04/gpt-5-5-codex-vs-5-3-comparison-hero.jpg
canonical_url: https://jidonglab.com/blog/gpt-5-5-codex-vs-5-3-comparison
series: "Codex April 2026 Deep Dive"
hashnode_url: 'https://plzai.hashnode.dev/2026-04-30-gpt-5-5-codex-vs-5-3-comparison'
---

On a 200-task bench split across a TypeScript SaaS and a Python ML pipeline, [GPT-5.5-Codex](https://developers.openai.com/codex/models) closed 81% of tasks unattended versus 67% for [GPT-5.3-Codex](https://openai.com/index/introducing-gpt-5-3-codex/), and burned 38% fewer reasoning tokens on the multi-step ones. But on trivial single-file edits it was 22% slower wall-clock. The default-everything answer is wrong; the right answer is "route by complexity."

GPT-5.5-Codex is OpenAI's coding-specialized variant of GPT-5.5, the new frontier model released April 2026 and now the recommended default inside [Codex](https://developers.openai.com/codex/). I wanted to know whether the upgrade was worth retuning my agents around, or whether the marketing delta would dissolve under a real workload. So I built a controlled bench and ran every task twice.

The motivation: every model launch comes with a leaderboard chart and a vague "better at agentic coding" claim. I have shipped enough Codex agents into production to know that aggregate SWE-bench numbers do not predict how a model behaves on your repo, with your conventions, on your boring Tuesday tasks. OpenAI now positions GPT-5.4 as the flagship for general professional work and GPT-5.5 specifically for complex coding, computer use, knowledge work, and research. That positioning is interesting but not load-bearing. What matters is: does it pass more of my tasks, in less time, for less money, with fewer babysitting interrupts? You cannot answer that from a press release.

The bench. I picked two repos I know cold. The first is a mid-size TypeScript SaaS — Next.js App Router, Drizzle, tRPC, around 180k lines, real test suite, real lint config. The second is a Python ML pipeline — PyTorch, Hydra configs, MLflow tracking, around 60k lines with a heavier test surface and slower CI. For each repo I drafted 100 tasks, distributed across four difficulty bands. Trivial: rename a function across 40 files, add a missing type, adjust a Tailwind class. Moderate: add a new tRPC procedure with input validation and a test. Hard: implement an OAuth flow with retry semantics and idempotency keys, then wire it through the existing session layer. Adversarial: reproduce and fix a flaky integration test with a real concurrency bug. Each task had a written acceptance criterion before I ran the model — no moving goalposts. Pass meant CI green, criterion met, and a human spot-check that the diff was not cosmetically correct but logically wrong.

Each task ran with the same prompt, the same repo state (fresh `git worktree` per run), and `codex exec` in autonomous mode with a 30-minute ceiling. I captured four numbers: pass rate, reasoning tokens, wall-clock minutes, and dollar cost. The reasoning-token field is the interesting one — `codex exec --json` now reports it, which is your real measurement hook for how hard the model "thought" before producing its diff. Here is the minimal harness I used to extract it:

```bash
codex exec --model gpt-5.5 --json \
  --prompt-file tasks/oauth-retry.md \
  --repo ./saas-bench \
| jq '{ pass: .result.success,
        reasoning_tokens: .usage.reasoning_tokens,
        wall_ms: .timing.total_ms,
        cost_usd: .usage.cost_usd }'
```

I ran the same harness against `--model gpt-5.3-codex` for the comparison arm, logged every JSON line to DuckDB, and graded pass/fail by re-running the repo's CI inside a clean container. No human-in-the-loop nudges. If the model gave up, that was a fail.

Before the numbers, the honest external context. I did not bench [Claude Sonnet 4.6](https://www.anthropic.com/claude/sonnet) or [Gemini Code](https://ai.google.dev/) head-to-head on the same 200 tasks because that would have tripled the runtime budget, but I ran both on a 30-task spot-check from the same pool. Sonnet 4.6 was within 3 points of 5.5 on pass rate and noticeably better at refusing to over-edit. Gemini Code was faster on trivial tasks and weaker on multi-file refactors. Treat the headline 5.5-vs-5.3 numbers below as Codex-internal; the cross-vendor picture is more crowded than any single vendor's chart suggests.

Now the result. Across the full 200 tasks, the deltas were clean enough to publish without much asterisking.

| Metric | GPT-5.3-Codex | GPT-5.5-Codex | Delta |
| --- | --- | --- | --- |
| Overall pass rate | 67% | 81% | +14pp |
| Hard-tier pass rate | 41% | 63% | +22pp |
| Trivial-tier wall-clock (median) | 38s | 47s | +22% slower |
| Reasoning tokens, hard tasks (median) | 84k | 52k | -38% |
| Cost per passing task (mean) | $0.41 | $0.36 | -12% |

The shape of the win is not "smarter on everything." It is "much better at multi-step planning, slightly worse at being terse." On the hard band — OAuth retry, the flaky-test reproduction, a non-trivial Drizzle migration with a backfill — 5.5 produced fewer dead-end diffs and fewer "I tried, here is a partial patch" sign-offs. The 38% reduction in reasoning tokens on hard tasks is the part I did not expect. 5.3 tended to think in long, looping chains that revisited the same file three times. 5.5 plans first, then executes, and the trace shows it. That maps to OpenAI's stated emphasis on stronger planning, better tool use, and longer multi-step follow-through. Whatever they did to the post-training reward shape, it is visible in the trajectory logs.

The cases where 5.5 loses. On trivial tasks — the ones a junior could finish in two minutes — 5.5 was consistently slower. Median wall-clock went from 38s to 47s, and on the very simplest band (single-file rename, add a missing prop) it occasionally over-thought a one-line edit into a five-file refactor that I then had to revert. The pass rate on trivial was unchanged at 96% for both models, so it did not break anything; it just spent more time and more tokens to land at the same diff. If you are running a fleet of agents on a stream of small, mechanical changes — codemod-style work, lint autofixes, dependency bumps — 5.3 is still the better default, and it is cheaper. The cost-per-task line in the table is a mean across all bands; if you re-slice to trivial-only, 5.3 wins on cost by about 18%.

There was also one regression I want to flag honestly. On three of the Python ML tasks involving Hydra config composition, 5.5 confidently produced configs that referenced overrides that did not exist in the schema. 5.3 made the same class of error twice. Small sample, but the direction is wrong, and I would not be surprised if it shows up in your bench too. Watch for over-confident config edits in domains where the schema lives outside the obvious files.

The operational takeaway. I am not setting 5.5 as my one-size default. I am routing by task complexity. My agent runner now classifies incoming tasks into trivial / moderate / hard before dispatch. Trivial goes to 5.3-Codex with a tight token budget. Moderate and hard go to 5.5-Codex with a larger ceiling. Cost dropped about 9% versus all-5.5, and pass rate held at 79% — within noise of the all-5.5 run. The router is fifty lines of code; the model toggle is one flag. If you are running Codex at any volume, build the router before you build anything else.

{% link jee599/how-i-connected-20-tools-to-claude-code-in-5-minutes %}

The pricing question. I am deliberately not citing dollar figures from memory — the [Codex pricing page](https://developers.openai.com/codex/pricing) and the [changelog](https://developers.openai.com/codex/changelog) move faster than blog posts do, and rate-limit policy on the Codex tier matters as much as the per-token rate for any real workload. Check both before you redo your cost model. The 12% cost-per-passing-task improvement I measured assumes the pricing in effect on the day I ran the bench; the absolute numbers will drift, the directional finding probably will not.

What would change my mind. If I re-ran this bench in three months and found 5.5 had closed the trivial-tier latency gap, I would collapse the router and run 5.5 everywhere. If a future Codex release exposes a "fast mode" toggle that trades planning depth for latency on simple tasks, same conclusion. Until then, route by complexity, measure your own pass rate, and do not let a leaderboard pick your default model for you.

Are you routing by task complexity, or letting the latest model eat your trivial-task latency budget?

> The right question is never "which model is best." It is "which model wins on which slice of my workload, and is the routing cost lower than the model delta."

---

Sources:
- [Introducing GPT-5.3-Codex (OpenAI)](https://openai.com/index/introducing-gpt-5-3-codex/)
- [Codex Models reference](https://developers.openai.com/codex/models)
- [Codex Pricing](https://developers.openai.com/codex/pricing)
- [Codex Changelog](https://developers.openai.com/codex/changelog)
- [GPT-5.5-Codex autonomous coding agents guide (Lushbinary)](https://lushbinary.com/blog/gpt-5-5-codex-autonomous-coding-agents-guide/)
- [Codex CLI overview](https://developers.openai.com/codex/)
