---
title: "Claude Code Automation: What 14 Sessions and 700+ Tool Calls Taught Me About Email Discovery"
published: true
description: "14 sessions, 700+ tool calls, Claude Opus running every hour. Target: 220 leads. Reality: 15. WebSearch hallucinates emails—I caught it fabricating domains."
tags: claudecode, automation, ai, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-07-portfolio-site-en
---

14 sessions. 700+ tool calls. Claude Opus firing on a 1-hour cron, scraping public emails from small business websites around the world. By end of day, one thing was undeniable: WebSearch's summarization model makes up email addresses.

**TL;DR** I run a global outreach pipeline on `/jdlab-daily-cron`, firing every hour. Target per session: 220 verified leads. Real ceiling: 15–20. In session 7, I caught WebSearch fabricating both a domain name and an email that don't exist — in a pipeline that actually sends emails.

## How the Pipeline Works

When `/jdlab-daily-cron` triggers, Claude runs 15 discovery lanes in parallel. Each lane targets a specific segment of independent small businesses likely to have public email addresses: `us_home_services`, `us_food_cafe`, `us_pet_services`, `uk_ie_local_services`, `shopify_dtc`, `woocommerce_independent`, and more.

Each lane produces a `{items:[...]}` JSON file. Only leads that pass both a safety gate and a quality gate get aggregated into the final output.

Per-session output structure:
- `outputs/outbound_runs/{date}/discovery_batches/{run_id}/` — 15 per-lane JSON files
- `data/exports/{run_id}.csv` — input for the Gmail builder
- `outputs/sheets_payloads/{run_id}.json` — Sheets payload

The downstream builder is strict by design: one bad email address can compromise an entire send run.

## Seven Sessions Before 7AM: The Numbers

Here's the tool call breakdown for the morning outreach sessions:

| Time  | Duration | Tool Calls | WebFetch | WebSearch |
|-------|----------|------------|----------|-----------|
| 00:49 | 31 min   | 91         | 23       | 28        |
| 01:49 | 22 min   | 71         | 33       | 15        |
| 02:49 | 40 min   | 122        | 68       | 26        |
| 03:50 | 18 min   | 76         | 30       | 22        |
| 04:50 | 19 min   | 76         | 33       | 16        |
| 05:50 | 29 min   | 90         | 44       | 20        |
| 06:50 | 18 min   | 47         | 22       | 8         |

Session 3 stands out: 40 minutes, 122 tool calls, with WebFetch alone accounting for 68. Verification was consuming more than twice the tool calls of discovery. That ratio tells you where the bottleneck lives.

## WebSearch Fabricates Emails — With Confidence

Session 7 surfaced the most important finding of the day.

WebSearch doesn't just retrieve — it summarizes. And in summarizing, it generates. The model produces email addresses and domain names that look completely legitimate but don't exist anywhere on the web.

Concrete example from this run: the search summary returned the domain `austinpettingsservices.com` and email `info@walkatx.com`. The actual business domain was `austinpetsittingservices.com`. The real contact domain was `walkatxpets.com`. The LLM generated plausible-looking strings — structurally valid, grammatically reasonable, completely made up.

This breaks any pipeline that trusts search results for contact info. An email sent to a hallucinated address either bounces or — worse — lands in someone's inbox who has no idea why they received it. The fix is non-negotiable: every email address must be confirmed via WebFetch against the actual page. No exceptions for "the snippet looked right."

## One Character Makes You a Spammer

Session 1 showed the same problem at the character level. A business called Toyne showed `craig@` in the search snippet. Actual page: `admin@`. Hair Studio Day Spa had `hairstudiodaypa@gmail.com` in the snippet — one letter short of the real address.

If you had sent without verifying, you'd have either reached the wrong person or gotten a hard bounce. Either way, your domain reputation takes the hit.

The agent's recorded principle after this: *"No unverified email is included in an automated send pipeline."* Leads that failed verification were logged as `not_found`. The pipeline didn't lower the bar to hit a number.

## WebFetch Has Its Own Constraint

Session 7 confirmed a second limitation worth knowing. WebFetch redacts most email addresses to `[email protected]` for PII protection. So WebFetch alone can't always retrieve the actual address either.

The working approach uses both signals together:

1. Collect email candidates from search snippets (treat as unverified)
2. Use WebFetch to confirm the domain and business exist
3. Cross-check whether the snippet email matches what appears in the page's raw HTML before redaction kicks in
4. Both signals must agree before an item is included

It's more friction than trusting the search result — but it's the only way to build a pipeline you can actually trust.

## 220 Target. 15 Actual.

Every session ran with `target=220`. Every run delivered 10–19 verified leads.

This isn't an agent failure. The agent wrote this in session 3's own notes:

> "Reaching 120 verified public emails would require 250+ successful page fetches. Honest quality in a single session makes this impossible."

The structural reasons why 220 is unreachable:

**Aggregator dominance.** Most search results for local businesses point to Yelp, Google Maps, and booking platforms. No direct email — that's their business model.

**Contact form-only sites.** Roughly half of businesses with their own domain use contact forms exclusively. No email exposed anywhere in the HTML.

**JavaScript-rendered emails.** A large portion renders email addresses dynamically through JS, often with Cloudflare email obfuscation. The `a[href^="mailto:"]` the agent is looking for simply doesn't exist in the fetched DOM.

The per-lane reachability data accumulates in `~/.claude/projects/.../memory/jdlab-lane-reachability.md` after each session — so the next run inherits this understanding instead of rediscovering it from scratch.

If your AI automation pipeline has more WebSearch calls than WebFetch calls, there's a good chance you're trusting unverified data somewhere downstream.

## Parallel Automation: Two Pipelines, One Day

While the outreach pipeline ran through the night and morning, a separate session executed a dental advertising research agent. 8 minutes, 26 tool calls. It accumulated Naver ad policy updates and Korean local search ranking patterns into rolling knowledge base files: `rolling-knowledge-base.md`, `source-index.md`, and `competitive-serp-observations.md`.

That session's finding: no new Korean healthcare advertising regulations since 2026-06-05. The ADVoost Screen DOOH notice (28168) — which prohibits digital out-of-home advertising for medical clinics — was re-confirmed via full-text re-read.

Two completely different multi-agent automation workflows, feeding different downstream processes, running in parallel on the same day. The Claude Code harness makes this feel straightforward to set up — the hard part is the domain knowledge baked into each agent's memory files.

## What's Next

The WebFetch verification bottleneck is still unresolved. 22–68 WebFetch calls per session for a 40–50% email capture rate is expensive. Next experiments:

- **Lane reprioritization** — rank lanes by historical email exposure rate, concentrate WebFetch budget where it actually returns results
- **Query pattern improvements** — target searches more likely to surface contact pages directly, reducing the aggregator-to-direct-site ratio in results

The ceiling of ~15 verified emails per session isn't a bug to fix. It's the actual market density of publicly-reachable independent businesses in these lanes. Claude Code running 700+ tool calls in a day is impressive — the value only holds if the data it's acting on is real.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
