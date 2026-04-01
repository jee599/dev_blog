---
title: "I Analyzed 330 Naver Dental Blogs in One Day Using Claude Code — Here's the Full Pipeline"
published: true
description: "3 sessions, 604 tool calls, 13-hour sprint. How Claude Code scraped 330 blogs, extracted S-grade patterns, and built a dental marketing automation pipeline."
tags: claudecode, automation, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-01-portfolio-site-en
---

604 tool calls. Three sessions. One day. The longest session ran 13 hours and 13 minutes — 422 tool calls without stopping.

The goal: build a dental blog ranking automation pipeline for Naver (Korea's dominant search engine). Scrape the top-performing blogs, extract structural patterns, generate HTML card templates, and cache AI-generated images. One day, zero prior code.

**TL;DR** — Claude Code built a complete dental content pipeline in a single day: data collection → pattern analysis → template generation → image caching. The data showed that top-ranked posts have 27+ components, 36+ images, and follow a specific content sequence. We built templates that replicate it.

## The Day Started With a Telegram 409 Conflict (15 min, 14 tool calls)

First prompt of the day:

```
텔래그램 설정 다시 해줘 지금 메세지가 안돼
(Fix the Telegram setup, messages aren't working)
```

Simple enough. But Claude pulled the MCP server logs and found `409 Conflict`. The same bot token was being polled from two simultaneous sessions — the `fakechat` plugin had just been installed, which spun up a second connection.

The fix: release the polling lock, close the other session. Done in 14 tool calls (Bash: 10, Read: 3, Skill: 1).

What made this fast: Claude read `~/.claude/channels/telegram/.env` directly and reconstructed the full state — token status, DM policy, allowlist — without needing to reproduce the bug. The config file was the source of truth.

## Broken Images Were Actually HTML Files Saved With `.jpg` Extensions (42 min, 168 tool calls)

Session two:

```
spoonai 이미지 다 깨져서 올라가 있고, 중복되는 기사들도 있어
(All spoonai images are broken, and there are duplicate articles)
```

The cause: the image generation script was silently swallowing errors and writing raw HTTP response bodies to disk with `.jpg` extensions. Of five image files, four were HTML. `anthropic-mythos-01.jpg` was a 919-byte error page. The fix was adding response validation to the skill config.

Four duplicate articles were handled by stripping the `image` field from frontmatter. Eight files, same pattern — batch-fixed with Edit.

Then scope expanded. Next prompt:

```
AI 검색결과 / 구글검색결과에 자주 노출될 수 있는 모든 효과적인 전략 적용해줘
(Apply every effective strategy for ranking in AI and Google search results)
```

Claude worked through the full SEO stack: `robots.txt` improvements, `sitemap.xml.ts` generation, JSON-LD structured data injected into `Base.astro`, `feed.xml` / `llms-full.txt` / `opensearch.xml` added, canonical URL config in `next.config.ts`.

168 tool calls. Read fired 37 times — every file was read before being modified. That discipline is consistent across all three sessions.

## The 13-Hour Session: 330 Naver Blogs, Fully Analyzed (422 tool calls)

Session three started with a single Naver blog URL and the ask: "Build a comparison table of the top 10 results for implants in Bundang."

That escalated. By the end, the pipeline covered 16 regions × 7 dental procedures × top 3 results = 336 posts collected and analyzed.

### contextzip Was Eating the API Responses

After getting a Naver API key, the first script run returned nothing. `contextzip` — a token-compression proxy that sits between Claude and shell output — was compressing the API responses before Claude could read them.

Workaround: redirect output to a file, use the Read tool.

```bash
# contextzip compresses stdout — pipe to file instead
curl "https://openapi.naver.com/..." > /tmp/naver_results.json
```

This became the standard pattern for the rest of the session. Python scripts write to files; Claude reads them with Read. Large HTML parses, API responses, analysis output — everything went through files. A token-saving optimization had broken an entire category of tasks. Once the cause was clear, the fix took five minutes.

### Background Tasks for Parallel Collection

Scraping 330 blogs sequentially would have been painfully slow. Claude switched to background task execution:

```
<task-notification>
<summary>Background command "Run full dental blog collection pipeline" completed (exit code 0)</summary>
</task-notification>
```

While collection ran in the background, HTML template work continued in parallel. This is why TaskUpdate appears 33 times in the stats — tracking pipeline state across concurrent work streams.

### `/compact` Saved the Session Mid-Sprint

Around hour nine, context hit its limit. Running `/compact` produced a summary that preserved the critical state: S-grade patterns extracted so far, which regions were complete, what was left to do.

```
This session is being continued from a previous conversation that ran out of context.
The summary covers: 330+ posts collected across 16 regions × 7 treatments...
```

One `/compact` in 13 hours. The session never lost its thread. The quality of the summary determines whether you can keep going — this one held up.

### What the #1 Ranking Blog Actually Looks Like

The top Bundang implant blog had 27 components, 36 images, and 26 slides. Claude parsed the HTML and extracted the component sequence:

```
OTHER→TEXT→QUOTE→(TEXT↔IMAGE)×7→MORE_SLIDE...
```

Repeating this across all 330 posts and cross-referencing against ranking position revealed the S-grade pattern: the top 20% of posts share a specific content structure that lower-ranked posts don't follow. Read fired 170 times during this phase — every parsed HTML file was read back to verify the extraction.

### Image Caching: Pre-Generate Once, Reuse Forever

The original approach called Gemini's API fresh for every blog card. The request that changed it:

> Instead of calling the API every time, pre-generate dozens of images and reuse them with different text injected via HTML.

Claude designed a three-layer caching system:

1. `generate_illustrations.py` pre-generates 30–50 base images via Gemini
2. `assets/manifest.json` caches the image inventory
3. Blog card generation uses cache-first lookup — only calling the API when the requested image doesn't exist

```python
# generate_illustrations.py — cache-first strategy
def get_or_generate(prompt_key, output_path):
    if output_path.exists():
        return output_path  # cache hit
    return generate_with_gemini(prompt_key, output_path)
```

Pre-generation ran as a background task. While 30–50 images were being generated, HTML template work ran in parallel.

### The Feedback Loop That Took Most of the Day

First draft cards shipped. Feedback came back:

```
Font / dark navy tone / logo not rendering correctly / generated images are all bad
```

Then: **"Rewrite the logic from scratch."**

Claude treated this as a full rewrite, not incremental edits. Edit fired 75 times during this phase — font replacement, color contrast, logo positioning, image captions. The final output is 8 card variants for implant posts: title card, checklist, procedure steps, three info+image variants (bone graft, digital guide, aftercare), doctor introduction, legal disclaimer, and CTA.

## Tool Usage Breakdown

| Tool | Count | Primary Use |
|------|-------|-------------|
| Read | 210 | Verify HTML parse output, config files |
| Bash | 164 | Python scripts, curl, file operations |
| Edit | 101 | HTML card revisions, skill config updates |
| Write | 53 | New file creation |
| TaskUpdate | 33 | Background task state management |

Read dominates at 210. The "read before you write" principle shows up directly in the stats. Exploration (Read + Bash: 374) outpaced implementation (Edit + Write: 154) by **2.4×**. The session was mostly investigation, not code generation.

## What This Session Confirmed

**Claude Code handles large-scale exploratory work well.** Analyzing 330 blogs and extracting patterns didn't require a detailed spec upfront — the data shaped the direction. The pipeline emerged from what the data showed, not from what was planned in advance.

**Visual quality feedback still requires a human.** "These images are all bad" and "rewrite the logic from scratch" aren't things that can be expressed as code. Claude iterated fast once the feedback arrived — but the 13-hour length reflects how many feedback loops ran.

**Silent failures in tooling compound fast.** The `contextzip` collision was the most interesting friction point. A token-saving optimization broke an entire category of tasks. Debugging it took less than five minutes because Claude read the actual config rather than guessing. When output disappears unexpectedly, the proxy layer is worth checking first.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
