---
title: "27 Hours, 335 Tool Calls, $1/Session: Building AI Visual Interviewers with Claude Code"
published: true
description: "How I shipped photorealistic AI interviewers with HeyGen + Simli lip-sync into preterview using Claude Code — and crushed cost to under $1 per 20-min session."
tags: claudecode, ai, multiagent, productivity
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-24-portfolio-site-en
---

27 hours and 28 minutes. 335 tool calls. One Claude Code session. That's what it took to wire a visual interview feature into preterview.

**TL;DR** — Three photorealistic AI interviewers powered by HeyGen streaming + Simli lip-sync, running at under $1 per 20-minute session. Getting cost that low turned out to be harder than the implementation itself.

## "Not 3D — Make It Look Like Zoom"

The initial ask was: three AI interviewers with faces, lip-sync, my camera on screen too. Before touching code, I ran a feasibility pass.

Two scopes emerged. Scope A: turn-based with push-to-talk over HTTP. Scope B: real WebRTC with continuous streaming. B had 2× the implementation complexity and 10× the cost. We went with A.

First pass used 3D avatars. They worked. The feedback was immediate: "Not like that — make it look like a real video call." Pivot to photorealistic avatars.

## Why HeyGen + Simli

I ran vendor comparison as a multi-agent workflow — four parallel agents benchmarking HeyGen Streaming API, Simli, D-ID, and Tavus against three criteria: streaming latency (anything over 3 seconds breaks conversational flow), concurrent stream count (three interviewers means three simultaneous streams), and Korean TTS quality with 2026 pricing.

HeyGen won on avatar quality and had a free tier for API testing. Simli's lip-sync accuracy was noticeably better than every other vendor on the shortlist. The final stack: HeyGen handles avatar streaming, Simli handles mouth tracking.

New components: `SimliAvatarTile.tsx`, `HeyGenAvatarTile.tsx`, combined into a three-panel layout in `VisualInterviewPoc.tsx`. Also added external streaming domain allowances in `next.config.ts`.

## The Real Battle: Getting to $1/Session

> "This is way too expensive. One interview session needs to cost around a dollar — under that for 20 minutes."

Initial implementation landed at $5–10 per 20-minute session. HeyGen's streaming billing was higher than projected. I ran a dedicated cost optimization workflow — 24 agents, 880k tokens — and landed on three changes that got us under the target.

**1. Only stream the active speaker.** Don't stream all three interviewers simultaneously. Only the one currently speaking is active.

**2. Replace TTS where it doesn't matter.** Swap HeyGen's TTS for the Web Speech API wherever audio quality delta is imperceptible to users.

**3. Gate HeyGen streaming to speech segments only.** Because it's turn-based, interviewer dialogue can be pre-generated and timed ahead of delivery — which means HeyGen is idle for most of the session.

These three together got cost under $1/session.

## Ad Strategy Research, Also via Workflow

After shipping the visual feature, a separate session focused on paid acquisition. The question: "Is Instagram better? Give me objective numbers on where to spend and who to target."

Five parallel research agents: Naver PowerLink (Korea), Meta Korea, global Meta + TikTok, Google, YouTube, and job-seeker channel density analysis. 24 agents total, 880k tokens, 245 web searches, 8 hours 46 minutes to synthesize.

Conclusion: **Naver PowerLink (Korea) + Google Search Ads (global)**. Job-seeker intent keywords had low CPC and high conversion intent. Ad pixel integration followed — `consent-banner.tsx`, `conversions.ts`, `track.ts` — all in the same session.

## A Competitor Launched Six Days Earlier

Codeit, one of the larger Korean coding bootcamp platforms, shipped an AI mock interview product called Ascent six days before I ran this analysis. Needed to know if preterview was walking into a direct collision.

Workflow: four parallel research tracks (Ascent live product audit, Codeit strategy + KADE acquisition context, Korean AI interview competitive landscape, cross-verification of key claims) → individual verification of five major claims → synthesis.

The cross-verification step caught an important correction. The initial finding — "Ascent supports GitHub/portfolio URL parsing" — came back **refuted**. The feature doesn't exist.

What Ascent actually is: Korean-language-only, targeting all job categories (marketing, PM, manufacturing, ~113 company-specific interview sets). Preterview is developer-specific and globally capable. The overlap is a shared skeleton — voice mock interview plus multi-dimension feedback — but the target user is different enough that it's adjacent markets, not direct competition.

## Session Stats

| Session | Time | Tool Calls |
|---------|------|------------|
| Visual interview implementation | 27h 28min | 335 |
| Competitor analysis + bug fixes + logging | 10h 25min | 163 |
| Ad strategy research | 8h 46min | 69 |
| Demo page | 1h 10min | 43 |
| PRD | 10min | 23 |

The 335 tool calls in the visual interview session: `Bash (110), Edit (72), mcp__claude-in-chrome (48), Write (18)`. Browser automation was 14% of total — Claude directly operated the browser to check the HeyGen dashboard, visually verify lip-sync output, and confirm Simli credit balances in real time.

## The Pattern That Solidified

After running these sessions back to back, the split is now clear:

- **Multi-agent workflow**: vendor comparison, keyword CPC research, competitor analysis — anything that fans out across independent sources
- **Single session with context**: component-level implementation, anything that requires maintaining state across a file tree

Research goes to workflow. Implementation stays direct. That's it.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
