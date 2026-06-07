---
title: "7 Hourly Runs, 573 Tool Calls: Claude Opus Caught an AI Fabricating Business Emails"
published: true
description: "A global outreach pipeline ran 7 times in one night. On run 7, Claude Opus caught search AI fabricating domain names and email addresses."
tags: claudecode, ai, automation, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-07-portfolio-site-en
---

Seven times between 00:49 and 06:50, Claude Opus woke up and crawled the internet for small business contact info. 573 tool calls total across 15 business lane categories. On the seventh run, it caught something worth writing about.

**TL;DR** — A nightly global outreach pipeline using `/jdlab-daily-cron` ran 7 automated sessions across 15 business categories. Session 7 confirmed that search summary AI fabricates email addresses and domain names. All leads now require direct WebFetch verification against the actual page before they enter the database.

## The Night in Numbers

Each session ran with `target=220` — the goal was 220 verified leads per night. Here's what actually happened:

| Start time | Duration | Tool calls | WebFetch | WebSearch | Write |
|------------|----------|------------|----------|-----------|-------|
| 00:49 | 31 min | 91 | 23 | 28 | 21 |
| 01:49 | 22 min | 71 | 33 | 15 | 19 |
| 02:49 | 40 min | 122 | 68 | 26 | 19 |
| 03:50 | 18 min | 76 | 30 | 22 | 19 |
| 04:50 | 19 min | 76 | 33 | 16 | 19 |
| 05:50 | 29 min | 90 | 44 | 20 | 19 |
| 06:50 | 18 min | 47 | 22 | 8 | 12 |

Session 3 is the outlier: 122 tool calls in 40 minutes, with 68 WebFetch calls. The verification ratio spiked hard. Session 7 is the opposite: 47 calls total, only 8 WebSearch calls — the lowest of any session. Something caused a deliberate shift.

## What Session 7 Found

Session 7 started cautiously. Early in the run, the agent cross-referenced WebSearch summaries against actual pages and caught a pattern.

Search snippets returned `austinpettingsservices.com`. The real business domain was `austinpetsittingservices.com`. A contact email showed as `info@walkatx.com`. The real domain was `walkatxpets.com`.

The search summary AI assembled plausible-looking strings. Plausible, not real.

This pipeline sends actual outreach emails. If those leads had gone into the database unverified, dozens of messages would have landed in inboxes that don't exist — or worse, inboxes belonging to someone else entirely. After this discovery, WebSearch calls dropped to 8 for the rest of session 7. WebFetch direct visits took over at 22 calls.

## Snippets Are Not Evidence

Session 1 documented two concrete discrepancies from earlier that same morning.

A business called Toyne showed `craig@` in search snippets. WebFetch on the actual contact page returned `admin@`. Hair Studio Day Spa appeared in snippets as `hairstudiodaypa@gmail.com`. The actual email differed by one character. Without visiting the page, both errors go undetected and the emails get sent.

The pipeline rule is simple: if a public email can't be confirmed via WebFetch on the actual page, it gets logged as `not_found`. Accurate count beats padded count.

## WebFetch Isn't Clean Either

Session 7 hit a second constraint. WebFetch redacts email addresses at the tool level, replacing them with `[email protected]`. PII protection happens before the content reaches the agent.

The workaround: cross-validate between search snippets (where emails sometimes appear in plain text) and WebFetch page content. Both signals have to agree before a lead is recorded. Either source alone doesn't qualify.

This is why session 3 used 68 WebFetch calls. Search returned a lot of candidates that session. Each one needed a page visit to confirm, and WebFetch redaction meant confirmation required matching against the snippet signal — not just reading the fetched content.

## 15 Lanes, Very Different Reachability

Each session searches across 15 business lane categories simultaneously:

- `us_home_services`, `us_food_cafe`, `us_pet_services`, `us_auto_services`
- `us_salon_spa`, `us_wedding_events`, `us_hospitality_bnb`
- `ca_local_services`, `uk_ie_local_services`, `anz_local_services`
- `shopify_dtc`, `woocommerce_independent`, `wix_squarespace_studio`
- `specialty_retail_classes`, `b2b_service_firms`

Reachability varies drastically by lane. US local service businesses often publish email addresses directly. UK/Ireland and ANZ lanes have high reliance on booking platforms — Treatwell, Fresha, OpenTable — with no direct contact info surfaced. B2B firms rarely publish emails publicly. Wix and Squarespace studios default to contact forms.

These lane-level patterns accumulate in `~/.claude/projects/.../memory/jdlab-lane-reachability.md` after each session. The next session reads that file before starting. No repeating searches that are structurally guaranteed to return nothing.

## Target 220, Reality 10–19

Every session ran with `target=220`. Actual verified leads per session: 10 to 19.

The agent wrote this analysis itself: *"Getting 120 verified emails would require 250+ successful page fetches. Maintaining honest quality within a single session makes that number unreachable."*

This isn't pipeline failure. It's structural reality.

Most search results link to Yelp, Google Maps, or booking aggregators — not business websites. Of businesses with their own domain, roughly half use contact forms only. Of the remaining half, many serve email addresses via JavaScript rendering behind Cloudflare bot mitigation.

`not_found` is the correct output for those cases. Lowering the verification bar to hit a number defeats the purpose of running verification in the first place.

## A Second Automation Running in Parallel

On the same day, a separate regulatory research agent ran independently. 8 minutes, 26 tool calls. Purpose: knowledge accumulation for Korean dental advertising compliance.

It confirmed no new regulatory notices had been issued after 2026-06-05. It re-read ADVoost Screen DOOH public notice 28168 at the body level and confirmed that medical/dental category businesses are explicitly excluded from digital outdoor advertising eligibility. Findings were appended automatically to `rolling-knowledge-base.md`, `source-index.md`, and `competitive-serp-observations.md`.

Two different automations — global outreach and domain-specific regulatory research — running in parallel on the same day, each writing to isolated memory layers.

## The Memory Flywheel

All 7 sessions share and update the same memory file: `jdlab-lane-reachability.md`. At the end of each session, observed values get appended — lane reachability rates, WebFetch block patterns, email exposure percentages, which categories produced nothing.

The next session reads this file before doing anything else. It doesn't repeat searches that returned only aggregators. It doesn't try WebFetch on domains that blocked it last time. Seven sessions at different hours, each building on the last.

This is what running an AI agent as a worker rather than an assistant looks like. Not answering questions. Producing a defined output on a schedule, with each run leaving structured knowledge behind for the next one.

The fabricated email discovery from session 7 is now in the memory file. Session 8 won't rely on WebSearch summaries alone for email addresses. The compounding already happened — no human intervention required.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
