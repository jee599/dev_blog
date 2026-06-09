---
title: "73 Tool Calls, 3 Parallel Opus Workers — Credit Wall Hits Right Before Final Synthesis"
published: true
description: "Three Claude Opus workers ran 73 tool calls in parallel researching FateSaju's global expansion. Monthly credit limit hit at exactly the wrong moment."
tags: claudecode, multiagent, ai, productivity
series: "Building with Claude Code: saju_global"
canonical_url: https://jidonglab.com/posts/2026-06-10-saju_global-en
---

Three parallel Claude Opus sessions. 73 tool calls. 39 minutes of actual work. Then, mid-synthesis, a hard stop:

```
You've hit your monthly spend limit · raise it at claude.ai/settings/usage
```

This is a build log for a multi-worker research sprint on FateSaju's global market expansion. The research is done. The final synthesis isn't.

**TL;DR** Used a multi-agent pattern — one orchestrator (Hermes) coordinating three independent Opus workers — to run parallel research across market sizing, competitor analysis, and viral channel strategy. All three research files landed. The consolidation step hit the monthly credit ceiling. Key finding: PayPal gateway constraints collapse the viable target market from "global" down to four countries: KR, US, JP, TH.

## The Hermes Pattern — One brief.md Controls Three Workers

The orchestrator (Hermes) is a Claude Code session that doesn't do research itself. It distributes work. Each worker is a separate Claude Code session with one job: read `brief.md`, write markdown to the assigned output path, report completion.

Worker assignments:
- **Worker A**: Market sizing, country analysis, customer demand → `outputs/research_market_country.md`
- **Worker B**: Competitor landscape, pricing, funnel structure, positioning → `outputs/research_competitor_pricing.md`
- **Worker C**: Viral mechanics, channel strategy, content loops → `outputs/research_viral_channels.md`

The three sessions ran independently. No shared context between them. The only shared contract: `brief.md` format and the `outputs/` path convention. Each session took 11–14 minutes and 14–28 tool calls.

The pattern is deliberately minimal. There's no message-passing, no state machine, no shared memory. Workers write files. The orchestrator reads them. That's the entire protocol.

This matters because complexity in multi-agent systems usually lives in coordination overhead. When workers don't need to talk to each other — because their research domains are genuinely independent — you can skip all of that. The brief is the spec. The output path is the handoff.

## Worker A — PayPal Carved Up the Addressable Market

Worker A ran 15 WebSearches and 2 WebFetches. It pulled market data across the US, India, Japan, Korea, and Southeast Asia — Yano Research Institute figures on Japan's fortune-telling market, Obrio/Nebula revenue estimates, Pew Research astrology consumer demographics.

A socket error killed the file write mid-session. Worker A restarted, rebuilt the output from already-fetched data, and completed the write. One of the practical rough edges of long-running research sessions: network errors happen, and recovery is manual.

The headline finding wasn't about market size. It was about payment infrastructure. **FateSaju's PayPal integration blocks payment in countries where PayPal isn't supported.** Vietnam, Indonesia, India — hundreds of millions of potential users — are already tagged `REGION_UNAVAILABLE` in the codebase. That single constraint narrows the viable market from global to four countries: KR, US, JP, TH.

This flips the framing entirely. The question isn't "what's the global TAM for astrology apps?" It's "which markets can actually process a payment?" Payment infrastructure is the strategy constraint, not market size. Any expansion roadmap that starts with market size analysis and ignores the payment layer is working with the wrong inputs.

## Worker B — Four Competitor Clusters, Four Agents in Parallel

Worker B classified competitors into four clusters:
- **Global AI astrology apps**: Nebula, Co-Star, CHANI, Pattern
- **Live advisor platforms**: Keen, Purple Garden, AstroTalk
- **KR/JP local apps**
- **Viral report sellers**

One Agent dispatched per cluster, all running in parallel. Task objects tracked the sub-agent results as they came back.

The pricing anchor was FortuneLab's actual rate matrix: KR ₩5,900 / US $4.99 / JP ¥690 / TH ฿149 — per-report, single purchase. This is structurally different from the subscription-first model that dominates global competitors. Nebula, Keen, Pattern — all push users toward recurring billing. FortuneLab doesn't. That gap is the positioning entry point.

Worker B used 4 Agent calls, 5 TaskCreates, 6 TaskUpdates, and Bash for result aggregation. Total: 28 tool calls. Managing sub-agent output through Tasks is what kept context from fragmenting across parallel branches. When you have four agents writing back to the same session, you need somewhere to park intermediate results without losing them to context compression.

The structural insight here: using `TaskCreate`/`TaskUpdate` as a lightweight result store within a Claude Code session is an underrated pattern. It keeps parallel agent outputs accessible without requiring file I/O between every step.

## Worker C — 30 Concepts, All Anchored to Features That Already Exist

Worker C sent parallel agents into four domains: short-form video, messenger share loops, SEO/pSEO, and community UGC. The results came back and got cross-referenced against the actual product feature list in `STATUS.md`.

The output requirement wasn't abstract strategy. The constraint was: **every concept had to connect directly to a feature already in FateSaju.** Forced compatibility share loop (friend chart), saju card screenshot mechanic, constellation daily streak, free tarot lead magnet, 2,304 pSEO pages — all of these already exist in the product. All 30 content concepts mapped to live features.

This is the right way to run this kind of research. Viral strategy that assumes features you'll build later is fiction. Strategy that attaches to what ships today is actionable immediately.

The brief included `STATUS.md` precisely to enforce this. Workers that don't know what's already built will generate half their output around features that don't exist yet. Including the current product state in the brief redirects that energy toward what can be executed now.

Worker C: 14 tool calls — multiple WebSearch rounds, parallel Agent calls, Bash for merging results, Write for the output file.

## Sessions 4 and 5 — The Credit Wall

Worker D's job: read the three research files, generate a final decision-ready report in `.md` and HTML. Four file reads, two Bash calls. Then:

```
You've hit your monthly spend limit · raise it at claude.ai/settings/usage
```

Session 5 logged zero tool calls. Same message on open, immediate close.

Three research files written. Final synthesis: not written. Running multiple Opus sessions back-to-back in the same day depletes the monthly budget faster than the per-session cost suggests. The aggregate bill hits before the last step completes.

This isn't an edge case — it's a predictable failure mode of running Opus for research-heavy tasks. Each session costs more than it looks like because context loading, web fetches, and sub-agent calls compound. Five sessions of research-grade Opus in one day will exhaust most monthly plans before the last session finishes.

## Tool Stats

| Tool | Calls |
|---|---|
| Bash | 20 |
| WebSearch | 15 |
| Read | 10 |
| Agent | 8 |
| TaskUpdate | 6 |
| TaskCreate | 5 |
| ToolSearch | 4 |
| Write | 3 |

Total: 73 tool calls across 5 sessions. ~39 minutes of actual work (sessions 1–3).

## What This Pattern Gets Right — and Where It Breaks

The multi-worker pattern works well for independent research tasks. Workers don't need to share context because their outputs don't depend on each other. `brief.md` plus `outputs/` path conventions is enough protocol to coordinate three parallel agents. When the brief is specific, each worker maintains its own role boundaries without enforcement.

**What works:**
- Zero coordination overhead between workers for non-overlapping research domains
- File-based handoff is durable — workers can fail and restart without losing work
- Task objects give the orchestrator visibility into parallel sub-agent results
- Constraining workers to existing product features via `STATUS.md` keeps output actionable

**What breaks:**
- Budget burns faster than expected across multiple Opus sessions
- The synthesis step — the most expensive step — gets no explicit budget allocation
- Adding more workers increases coverage but reduces the budget available for final consolidation
- No built-in mechanism to detect "I'm about to run out of budget before synthesis"

The design fix is explicit credit reservation: estimate synthesis cost upfront, reserve that budget before dispatching workers, and cap worker spend accordingly. The current design treats credit as abundant until it isn't.

For this sprint, the research is complete. The synthesis will run in the next billing cycle. The three research files cover everything needed — it's a pipeline stall, not a loss.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
