---
title: "I Ran 5 Claude Agents in Parallel and Designed a 600-Video Pipeline in 83 Minutes"
published: true
description: "83 minutes, 5 parallel agents, 10 tool calls, 0 lines of code written. Here's what a pure design session with Claude Code looks like."
tags: claudecode, ai, automation, python
series: "Building with Claude Code: shortsmaker"
canonical_url: https://jidonglab.com/posts/2026-03-16-shortsmaker-en
---

83 minutes. 5 agents running simultaneously. 0 lines of code written.

That's the entire session for designing the shortsmaker pipeline — a system to auto-generate 600 short-form videos from fortune-telling content for TikTok and YouTube Shorts.

**TL;DR** Instead of researching TTS, video assembly, SNS upload, content generation, and short-form trends one by one, I handed Claude Code a single vague prompt and let it spin up 5 parallel agents. By the end of the session, the full tech stack was decided. The actual coding hadn't started yet, and that was the right call.

## Why Research in Parallel at All

The project is FortuneLab's short-form video arm. Saju (Korean fortune-telling) content, mass-produced for TikTok and YouTube Shorts, targeting Southeast Asian markets including Thai-speaking audiences.

Before writing a single line, I needed answers to five completely separate questions:

- Which TTS engine handles Korean and Thai well?
- What's the fastest way to assemble video frames programmatically?
- Can SNS upload be fully automated? What are the API constraints?
- How much does generating 600 scripts actually cost with Claude?
- Is the 18-22 second video length from my 2024 spec still valid?

Researching these sequentially would eat 4-5 hours. Each domain is independent — knowing the TTS answer doesn't block the video assembly research. So I didn't give Claude a structured task breakdown. I gave it this:

```
Feel free to set up agents however you think works.
Research the most practical, automation-friendly, high-quality approaches
based on the latest information.
```

No agent count specified. No domain breakdown. Claude decided how to parallelize.

## The 5-Agent Team Claude Assembled

Claude launched five subagents simultaneously in a single response:

1. **Content generation research** — batch script production cost analysis
2. **Video assembly research** — frame rendering and encoding options
3. **TTS research** — Korean and multilingual voice synthesis
4. **SNS upload research** — TikTok/YouTube automation feasibility
5. **Short-form trend research** — current optimal video length and format

All five fired as parallel `Agent` tool calls in one message. The reasoning was straightforward: no cross-domain dependencies, so no reason to serialize.

Results came back out of order. Content generation, video assembly, and TTS finished first. Trends came next. The SNS upload agent took longest — it needed more web research to map out platform API limitations.

Each agent returned actionable findings, not summaries.

**Content generation agent:** Haiku 3.5 + Batch API generates 600 scripts for under $1. Batch API trades async processing time for a 50% cost discount. For a pipeline where latency doesn't matter but budget does, it's the right tradeoff.

**TTS agent:** Edge TTS as the primary engine. Microsoft's free TTS service, with solid Korean quality. But there was a catch — Thai language support on Edge TTS is inconsistent. The agent flagged this proactively and recommended Google Cloud TTS as a Thai-language backup. This one detail would have caused a painful pipeline rewrite later if missed.

**Video assembly agent:** Pillow + FFmpeg hybrid over MoviePy. MoviePy wraps FFmpeg but adds overhead and CJK font rendering issues that surface with Korean and Chinese characters. Direct Pillow for frame generation, direct FFmpeg for encoding — faster and easier to control.

**SNS upload agent:** TikTok's Content Posting API and YouTube Data API v3 are both automatable, but each has rate limits and content policy review delays to plan around.

## When the Research Challenged the Original Spec

The trends agent delivered an unexpected result.

It analyzed optimal short-form video length based on 2025-2026 platform data and concluded: **45-90 seconds**. My original spec from 2024 said 18-22 seconds.

This created a real decision point mid-session. I pushed back — the project is Shorts-only, and TikTok Shorts has its own optimal range. Reframed for TikTok Shorts, the sweet spot is **15-60 seconds**, with a practical 30-45 seconds for hook + content + CTA.

The agent's data wasn't wrong. It answered a broader question than what the project needed. That's a useful reminder: agents return data based on the query; you apply context.

The spec updated. The correction took one message and happened naturally mid-session — exactly the kind of back-and-forth that's harder to do when you're doing the research yourself.

## Tool Usage Breakdown

```
Agent(5) — parallel agent execution
Read(3)  — existing plan docs, sample JSON schema
Bash(2)  — project state checks
```

Total: 10 tool calls, 1h 23min, 0 files modified, 0 files created.

The whole session was architecture work. Picking the wrong TTS library upfront — one that breaks on Thai — would mean ripping out a core pipeline component weeks later. The 83 minutes spent here is cheaper than that.

On the time math: sequential research at 15-20 minutes per domain would have been 75-100 minutes of wall time anyway. With 5 parallel agents, total time is gated by the slowest agent — the SNS upload research. When that finished, the other four were already done. The speedup wasn't exactly 5x, but it was close.

## What Got Decided

**Language: Python only.** TypeScript has no meaningful edge in video processing pipelines. FFmpeg bindings, TTS libraries, and the Claude API all have stronger Python ecosystems.

**Video assembly: Pillow + FFmpeg hybrid.** Skip MoviePy's abstraction layer. Direct frame generation + direct encoding gives better performance and eliminates CJK rendering edge cases.

**TTS: Edge TTS primary, Google Cloud TTS backup for Thai.** Free tier handles most of the workload. Thai gets a dedicated fallback.

**Script generation: Claude Haiku 3.5 + Batch API.** 600 scripts for under $1. Async is fine — this runs as a batch job, not a real-time service.

**Video length: 30-45 seconds** for hook + content + CTA structure.

Next session is Phase 1 implementation: environment setup, assembling a single video from sample data, and validating TTS output quality before scaling to 600.

---

> Parallel research doesn't give you 1/5th the time — it gives you the slowest agent's time. Once you know where the bottleneck is, you know what to optimize.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
