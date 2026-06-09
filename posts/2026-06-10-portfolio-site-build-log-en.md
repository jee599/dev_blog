---
title: "917 Tool Calls in One Session: Building a Dental Marketing Agent with Claude Code"
published: true
description: "How a simple 'show me the report' prompt turned into 70 hours, 917 tool calls, and a full dental marketing automation system built with Claude Code."
tags: claudecode, ai, automation, agents
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-10-portfolio-site-en
---

917 tool calls. 70 hours and 56 minutes of wall-clock time. 412 Bash executions, 232 file edits, 163 reads, 50 writes, 26 browser automation calls — all in a single Claude Code session.

This is the story of building a dental marketing automation system from scratch. It wasn't planned to be this large. It rarely is.

**TL;DR** Built `dental-clinic`, a context-aware agent for dental clinic marketing automation: owner-facing diagnostic reports, a Naver blog image pipeline (GPT Image-2 + PIL), and ad performance analysis. Biggest lesson: a session with two context compressions runs at half efficiency. Split early, not late.

## A Single Prompt That Opened a Rabbit Hole

The initial prompt was about as simple as it gets:

> "Let's launch the dental report we were working on. Use Claude Chrome to verify it directly."

First wall: Naver SmartPlace bot protection. Naver is South Korea's dominant search and local business platform — think Google Maps + Yelp combined, but with aggressive anti-scraping measures. Automating data collection from SmartPlace wasn't viable.

The pivot: use the Naver Search Advertising API for keyword data, and accept PDF/PNG screenshots from the clinic director for SmartPlace stats. Slower than automated collection, but real data from the actual source rather than a scraped approximation.

That pivot shaped the architecture for everything that followed.

## Three Reports Instead of One

The initial ask was one report. After hours of conversation, there were three:

**Owner's Diagnostic Report** — A summary of the clinic's current online presence: which channels drive traffic, what's underperforming, specific improvement directions. Readable by a non-technical clinic director.

**Internal Work Report** — The execution playbook: ad budget allocations, keyword targeting strategy, prioritized action items with estimated effort and impact.

**Tracking Dashboard** — `~/dental-promo/_tracker/index.html`, deployed to Vercel for external access.

Each report cycled through 10–15 rounds of revision requests. "Logo at 60% size," "center-align this section," "more whitespace around the header," "make the font consistent throughout." The visual consistency kept breaking between edits.

Root cause: raw HTML without a design system. Every revision introduced drift. Typography tokens weren't locked. Spacing values weren't variables. One edit fixed one thing and broke two others.

If the session had started by binding a minimal design system — or even just defining CSS custom properties for colors, spacing, and type scale — revision cycles would have been cut in half. The cost of skipping design system setup is paid in revision overhead. Every round of "make it consistent" is a deferred bill.

## Building the Blog Image Pipeline

For dental clinics on Korean platforms like Naver Blog, images aren't optional — they're how content gets ranked and indexed visually. Analyzing top-ranking competitor blogs revealed a consistent pattern: card-news format, information-dense, clinic logo in the bottom corner, tight typographic consistency.

Card-news is a Korean digital content format — structured information layouts in a multi-panel visual format, common on Korean blog and social platforms.

Started with Gemini for illustration-style images. Korean text rendering was inconsistent. Switched to GPT Image-2 — Korean label text on card-news images became reliable enough for production.

The `cardnews.py` pipeline:

```python
# Step 1: Generate base image
image = generate_with_gpt_image2(prompt, style_params)

# Step 2: Composite clinic logo using PIL
image = composite_logo(image, logo_path, position="bottom-right", opacity=0.9)

# Step 3: Filter medical advertising law violations
image = filter_medical_violations(image, text_content)
```

Step 3 is specific to Korean medical advertising regulations (의료법). Korean law prohibits certain claims in medical advertising — comparative effectiveness statements, unsubstantiated before/after claims, and others. The filter checks generated text against a prohibited phrase list before any image goes live.

This pipeline became the `dental-blog-image-pipeline` skill, reusable across any future dental clinic project.

## When Data Contradicts Your Assumptions

Starting hypothesis: Naver PowerLink ads are essential for this clinic. PowerLink is Naver's equivalent of Google Search Ads — paid listings at the top of search results.

Keyword research said otherwise.

Local search terms like `동백 치과` (Dongbaek dentist area) and `동백 임플란트` (Dongbaek implant procedure) showed monthly search volumes around 10. Not 10,000 — 10. Zero competing dental clinics in the area were running PowerLink ads. The traffic wasn't there to capture.

Meanwhile, the clinic's Naver Place page pulled 915 monthly visits — but 80% came from direct brand searches (`유디치과`, `동백유디치과`). People already knew the clinic name.

The revised conclusion: PowerLink has no meaningful traffic to capture at this location. The real opportunity is blog SEO — ranking for procedure-specific keywords through content, since those searches exist but have no competition.

This became the most actionable section of the owner's report. Having the data — timestamped, sourced from Naver's own keyword tool — made the recommendation concrete rather than advisory.

The broader lesson: "we should run search ads" is an assumption, not a strategy. Spending 30 minutes on keyword research before committing to an ad budget prevents months of wasted spend.

## The dental-clinic Agent Design

As the session accumulated scope and the context window compressed once, then twice, one inefficiency became clear: re-establishing per-clinic context from scratch at every new task.

The `dental-clinic` agent addresses this. On session start, it reads:

- `~/dental-promo/{slug}/clinic.json` — clinic profile, ad account identifiers, baseline metrics
- `~/dental-promo/{slug}/history.json` — previous session work log
- `~/dental-promo/_kb/LESSONS.md` — accumulated lessons from all past sessions

After loading, "write a blog post for Dongbaek UD Dental" starts with full context already restored. No re-briefing.

The routing rule in the global `CLAUDE.md`:
```
Dental-promo work → delegate to dental-clinic subagent.
Main session → intent, approval gates (budget/publish/secrets).
Subagent → execution, worklog updates, lesson appends.
```

For continuing work on the same clinic within a session, `SendMessage` reuses the existing agent instance instead of spawning fresh — maintaining accumulated state across tasks.

## 22 Parallel Agents for Market Research

On a separate project (a Korean fortune-telling app), a different workflow challenge came up: comprehensive market research across 10 monetization strategies simultaneously.

The pattern: fan out 11 research topics in parallel, then verify each finding adversarially.

```javascript
const results = await pipeline(
  TOPICS,
  topic => agent(`Research ${topic.name}`, { schema: FINDING_SCHEMA }),
  finding => agent(`Adversarially verify: ${finding.claim}`, { schema: VERDICT_SCHEMA })
)
```

Total: 22 concurrent agents, approximately 916k tokens.

Why adversarial verification? An agent tasked with researching "premium subscription revenue for Korean apps" will find numbers that support the market — confirmation bias is a real problem with LLM research. An adversarial agent tasked with *refuting* that number produces more reliable estimates.

Each finding gets labeled: `verified` (passed adversarial check), `adjusted` (revised after verification), or `unverified` (no adversarial pass, treat as directional). This makes it explicit which numbers are load-bearing and which are rough guides.

## What This Session Made Clear

**Context compressed twice = half efficiency.** The 917 tool call session had two mid-session context compressions. Work from earlier became fuzzy — the specific decisions, reasons for design choices, context behind code structures. Continuing after two compressions means rebuilding context implicitly, which introduces inconsistencies.

The fix is structural: split large work into sessions from the start. Report design, ad analysis, agent architecture, and image pipeline are four sessions, not one.

**Raw HTML under iterative revision diverges.** Works for a first draft, breaks at revision 8. CSS variables as tokens, at minimum, need to be in place before the first feedback round. This is the price of skipping design system setup.

**Validate "obvious" strategies with data.** The PowerLink assumption seemed self-evident. 30 minutes of keyword research completely reversed the recommendation. The cost of not checking: potentially months of ad spend on keywords with single-digit monthly search volume.

---

Week total: 6 sessions, 1,000+ tool calls, 70+ modified files.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
