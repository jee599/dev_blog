---
title: "26 Sessions, 3 Safety Rounds: Running Claude Code as an Unattended Cron Worker"
published: true
description: "What it takes to harden Claude Code for unattended cron use: 26 sessions, 600+ tool calls, Bash tool isolation, and on-page email verification before any draft hits Gmail."
tags: claudecode, ai, automation, webdev
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-06-portfolio-site-en
---

26 sessions in a single day. Over 600 tool calls. Not from an interactive session — from an unattended cron job running Claude Code every hour.

**TL;DR** Automated an outreach pipeline using Claude Code as the prospecting and drafting engine, scheduled via Hermes cron. Shipping it safely required three rounds of hardening: fixing Codex-flagged blockers, stripping Bash tool access in headless mode, and enforcing on-page email verification before any draft touches Gmail. The design principle that shaped everything: assume Claude will actually send real emails.

## The Pipeline: 8 Lanes, 100 Leads per Hour

The JDLab outreach pipeline has a simple structure. Eight discovery lanes (`shopify_selfhosted`, `us_google_local`, `yelp_local_service`, `tripadvisor_hospitality`, `linkedin_b2b`, `amazon_seller`, `etsy_seller`, `walmart_ebay`) prospect independently. A central builder (`build-jdlab-hourly-queue.mjs`) merges results, deduplicates, and enforces a 100-lead cap.

Hermes runs the whole thing hourly via `jdlab_hourly_100_approval_queue.sh`. Claude Code handles actual prospecting and draft writing. The constraint that shaped every other decision: **Claude sends real emails to real businesses.** Fake addresses, unverified contacts, or a copy filter slip means a legitimate hospitality business gets a nonsense cold email.

That constraint drove the entire safety architecture.

## The Dedupe Index: Starting from 429 URL Keys

By session 1, the deduplication index already contained 429 URL keys, 390 domains, and 316 emails from prior runs. By session 4 it had grown to 529 URLs / 464 domains / 383 emails.

```
dedupe_against_existing=true
```

That flag does one thing: scan all existing `outputs/approval_queue/` files, extract normalized URL and email keys, and cross-check against every new prospecting result before it enters the pool. In session 4, starting from a pool of 123, the deduper removed 2 historical URL duplicates and 21 over-capacity entries — landing at exactly 100.

This is why `build-jdlab-run-dedupe-index.mjs` was extracted as a standalone step. Each lane subagent prospects independently. For them not to conflict, the shared avoidance list has to be materialized before any lane starts. Dedup at discovery time, not assembly time — if you wait until assembly, 8 subagents already spent their exploration budget on candidates that will be removed anyway.

## Three Codex Review Rounds — Each Blocker Was a Design Decision

The most instructive part of the build. Every time Codex returned `VERDICT: BLOCK`, it wasn't a trivial bug — it exposed an architectural gap.

**Round 1 (Session 2):** Lock file recovery race condition, PATH resolution in cron environment, within-run URL and email duplicates. The gap: `~/.claude/settings.json` had `Bash(*)` globally, but cron runs with a different PATH. PATH-dependent tools silently failed instead of throwing. Fixed `jdlab_hourly_100_approval_queue.sh`, `validate-jdlab-queue.mjs`, and three test files. 12 Edit calls, 11 Bash calls.

**Round 2 (Sessions 6–7):** The validator hard-fails any draft containing a `$\d` pattern — dollar sign immediately followed by digits. Solid rationale: pricing language in first-touch cold email is a spam trigger. The problem: Claude was pulling prices from the businesses' own websites as copy diagnosis observations. A tour company with "Starting at $4,495" on their homepage would have that text appear in the draft, and the validator would reject the entire 100-lead queue.

```
ValidationError: draft contains $4,495 — hard fail on $ + digit in first-touch copy
items affected: 6
```

The fix was two-pronged. Extract the detection logic into a shared `detectHardFail()` function. Add a pre-filter in the builder that runs `detectHardFail()` immediately after loading the pool — before building the final 100. Only safe candidates enter the selection pool. This also fixed the divergence problem: before the refactor, both the builder and validator had independent implementations of the same check. One was the source of truth; the other would eventually drift.

**Round 3 (Session 12):** Codex required empirical proof that Bash tool access was actually absent when Claude ran headless in cron. Not "we set a flag." Actually demonstrate it.

```bash
claude --tools "" --no-settings-source user ...
```

Running Claude with that flag combination and then prompting internally with "Use the Bash tool to run: echo TAMPER_TEST" returned `NO_BASH — Bash tool not available here.` Even with `Bash(*)` in `~/.claude/settings.json`, `--tools ""` overrides it. Confirmed experimentally, not by reading docs.

After that: `--tools ""` added to the cron wrapper, plus a post-exit integrity check that captures file hashes immediately after Claude terminates. If any protected file changes, the cron stops. Claude's outputs validated at the filesystem level, not just the application level. 12 Bash calls, 5 Edit calls.

## Real Prospecting: Every Email Verified On-Page with WebFetch

Sessions 13, 14, and 15 show the prospecting loop in action. When a search result surfaces a candidate, the pipeline always calls `WebFetch` to load the actual page and verify the email and copy directly on-page.

- Session 13: 30 WebFetch calls, 19 WebSearch calls → 16 sendable + 13 no-email
- Session 14: 36 WebFetch calls, 19 WebSearch calls
- Session 15: 20 WebFetch calls, 12 WebSearch calls

One non-negotiable rule: if a page returns 401 or 403, the lead gets flagged `live_unverified` instead of `browser_verified`. Can't ground the copy diagnosis if the page is inaccessible. If an email was extracted from a search snippet but couldn't be confirmed on the actual page via WebFetch, it gets marked `not_found`.

Session 15 had a concrete example: a B&B homepage showed "INMERSE" — a real typo, not in search results. It only surfaces if you actually fetch the page. That's the kind of personalized hook that makes cold outreach not feel like cold outreach.

This distinction matters for deliverability too. Emails obfuscated as `info [at] domain [dot] com` go to `not_found` — they're intentionally hidden from scrapers. Contacting them through reconstructed addresses is poor practice regardless of technical validity.

## The Two-Tier Gate: Validator and Draft Gate Are Separate for a Reason

`validate-jdlab-queue.mjs` and `create-gmail-drafts-from-jdlab-queue.py` each have independent safety gates. It looks like redundancy. It isn't.

The validator inspects the queue file itself — structure, content patterns, deduplication state. The draft gate is the last line of defense before the Gmail API gets called. Running the draft script without `--allow-lead-ids-file` causes it to fail hard. In session 9, a `--only-lead-id` flag was added to block manual single-lead overrides from bypassing the allowlist check.

`jdlab_gmail_reply_reconcile.py` imports the draft script as a module and reuses `load_credentials` and HTTP utilities — but `main()` is never called. Making the allowlist mandatory doesn't break the reply reconciliation flow because the reply script never invokes the draft pipeline's entry point. Two gates at different abstraction levels, each doing its own job.

## Tool Call Breakdown

Aggregated across key sessions: 130+ Bash, 90+ Edit, 100+ WebFetch, 60+ WebSearch, 80+ Read, 18+ Agent calls. The WebFetch-to-WebSearch ratio tells the story: search to discover, fetch to verify. Claude Code running as a genuine prospecting worker, not just an editor.

## What Comes Next

Next: expand from 8 lanes to 15+, and rotate search strategies across runs. Session 19 diagnosed the current bottleneck — lane repetition. The pipeline surfaces only 10–17 sendable leads per hour because the same search patterns keep hitting the same results. Randomizing the search rotation is the fix.

If you're running Claude Code unattended in any automated pipeline, the three patterns here are worth the setup time: per-invocation tool stripping (`--tools ""`), file hash verification after each run, and two-tier validation gates at the queue level and the action level. Each one sounds like overhead until you consider what it prevents.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
