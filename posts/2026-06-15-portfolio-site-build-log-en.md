---
title: "1,085 Tool Calls in One Day: What Claude Code's Multi-Agent Mode Actually Built"
published: true
description: "11 sessions, 1,085 tool calls, 5 parallel projects. How Claude Code multi-agent fan-out shipped a Pokemon card price tracker from zero to 90+ files in one day."
tags: claudecode, ai, webdev, programming
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-15-portfolio-site-en
---

357 Bash calls. 240 edits. 191 reads. 131 file writes. 11 sessions. One day.

That's the raw breakdown of 2026-06-15 in my dev logs. 1,085 total tool calls across 5 parallel projects — a new Pokemon card price tracker built from scratch, a compliance audit on a payments project, a security scan of public repos, a Godot sprite pipeline experiment, and a mobile UI audit with real browser verification. All in the same day.

The number that matters isn't 1,085. It's that none of these were queued — they ran in parallel via Claude Code's multi-agent fan-out. Sequential processing would have capped me at 2-3 sessions. Here's what actually happened.

## TL;DR

- **Session 2** (342 tool calls, ~20 hours): Built a Pokemon card price tracker from zero — Next.js + Neon Postgres + Drizzle, 90+ files generated in one session after pivoting away from a blocked scraping target
- **Session 5** (142 tool calls): Ran a 7-agent parallel audit on a payments project, caught a real VAT compliance blocker hiding behind outdated docs
- **Session 6** (34 tool calls): Installed `gitleaks` 8.30.1, scanned git history (not just current files) on public repos
- **Session 7** (141 tool calls): Experimented with `gpt-image-2` for walk animation sprites in a Godot pipeline
- **Session 8** (161 tool calls): 8-agent static audit + live Chrome verification at 390px on a coffeechat mobile UI
- **Sessions 9-11** (59+122+59 tool calls): Extracted a 70KB bash heredoc into external JSON policy files, passed 4 Codex reviewers after addressing blockers

---

## When Your Scraping Target Blocks You: Pivoting a Data Source Mid-Build

Session 2 was the heaviest single session of the week: 342 tool calls, roughly 20 hours of wall time. The project spec came in complex from the start — a Japanese Pokemon card price tracker with historical price comparison, rarity filters, price prediction, box/pack-level analysis, and dual-currency support (JPY + KRW).

The original plan involved scraping yuyutei (遊々亭), a major Japanese card retailer with solid price data. That hit a wall fast. Rather than spending time engineering around anti-scraping measures on a single source, I spun up data source validation agents in parallel to evaluate alternatives.

The pivot: TCGdex is free, natively supports Japanese card data, and provides images, rarity metadata, and pricing all through one API. Pairing it with TCGcsv for supplemental data covered the gaps. Stack decision: Next.js + TypeScript, Vercel deployment, Neon Postgres with Drizzle ORM, Tailwind v4.

With ultracode mode active, the session fanned out — data source validation running while schema design progressed in parallel. By the time the source question was settled, the DB schema and provider adapter patterns were ready to plug into. From there: schema → provider adapters → signals logic → full UI component tree. 90+ files generated, GitHub repo created, all in one session.

The counterfactual is worth spelling out: running data source validation sequentially before starting schema work would have consumed roughly half the session time before any code existed. Multi-agent AI automation compresses that overlap into a single pass.

---

## Your Docs Are Lying: How a Parallel Audit Caught a Real VAT Compliance Blocker

Session 5 — 142 tool calls, 1 hour 42 minutes — was a full audit of `saju_global`, a payments-enabled project targeting international users.

Seven agents ran in parallel across distinct audit domains: payment rails (Toss + PayPal), waitlist logic, Meta Pixel integration, OG/social card rendering, refund handling, currency conversion, and admin tooling.

The first thing that surfaced: `STATUS.md` had "Toss + Lemon Squeezy" in the header. The actual code had already migrated to PayPal. Docs and implementation had drifted completely out of sync — the kind of thing that's invisible until someone reads both at once.

The more serious finding was a VAT compliance gap. EU visitors could complete USD-denominated payments without any geographic routing or tax handling. Under EU VAT rules, that creates a real obligation. This got classified as a blocker immediately. The fix: route EU visitors to a waitlist instead of the payment flow, and add blocking logic at the checkout entry point.

The session also covered AI-generated copy removal (legal exposure in some jurisdictions), Meta Pixel event wiring, and PayPal refund handler corrections. Seven parallel streams let the blocker surface during the first pass rather than after the other six domains were already closed.

Sequential auditing has a compounding cost: each domain review blocks the next. When you're looking at seven independent surfaces simultaneously, a cross-domain issue like VAT exposure becomes visible before any one domain is "done."

---

## Deleted Files Don't Delete Secrets: Git History Is the Attack Surface

Session 6 was short — 34 tool calls, 25 minutes — but the finding is worth documenting separately.

The task: security scan of public repos under the `jee599` GitHub account. Tool: `gitleaks` 8.30.1.

The critical distinction in how to run gitleaks: scanning current files vs. scanning git history. These are different commands, and they catch different things. A secret that was committed and later deleted still exists in every commit between its introduction and its removal. On a public repo, that history is publicly accessible to anyone.

```bash
# Current files only — misses deleted secrets
gitleaks detect --source .

# Full git history — catches what's actually exposed
gitleaks git .
```

After confirming the risk profile, the decision was to proceed with git history cleanup. Three local commits that had been held back were pushed to origin during this session.

If you have public repos and haven't scanned the full commit history, run `gitleaks git` on them. Not just the working tree. The working tree is the smallest part of your attack surface.

---

## AI-Generated Sprites in a Godot Pipeline: First Experiment

Session 7 (141 tool calls) was the most exploratory session of the day — a game development experiment rather than a production deliverable.

The starting point: four game concept documents covering two projects (Guild Master and a wuxia-themed game with three variants). Two agents ran in parallel reading and analyzing the specs. Simultaneously, a separate research thread evaluated open-source sprite tooling and AI image generation options.

The experiment: using `gpt-image-2` to generate walk animation sprites, then handling alpha channel processing to get assets into a usable state for Godot. The goal wasn't production-quality sprites — it was establishing whether the pipeline makes sense at all for early-stage prototyping.

Result: a new repo (`game-concepts-preview`) was created, the asset pipeline was documented, and the alpha processing workflow was tested end-to-end. The question of AI-generated images as prototyping scaffolding (rather than final assets) is a different question from "can AI replace an artist." For early concept validation — proving out mechanics before commissioning real art — the pipeline is viable.

This was the first time I've connected a Claude Code session directly to a game asset pipeline. The parallel spec analysis + tooling research pattern compressed what would normally be sequential research-then-experiment into a single session.

---

## Static Analysis vs. Real Chrome: Why You Need Both

Session 8 (161 tool calls, 1 hour 46 minutes) was a mobile UI audit of `coffeechat`, a networking app with resume, portfolio, interview, and payment flows.

The session ran in two phases. Phase one: 8 agents across distinct UI domains — global nav, landing, resume flow, portfolio flow, interview flow, payment, admin, and authentication. Static code analysis, looking for common mobile layout issues: overflow, tap target sizing, flex/grid behavior at small widths, font scaling.

Phase two: launch Chrome with a 390px mobile viewport and actually verify. `mcp__claude-in-chrome` was called 13 times across different flows.

Static and dynamic analysis disagreed on several points. The most significant: a missing signup route that static analysis hadn't flagged because the route simply didn't exist — there was nothing to analyze. Chrome verification hit the gap directly when navigating the actual auth flow. Code analysis can only find problems in code that exists.

Fixes shipped in the session: nav layout improvements, resume preview rendering corrections, the missing signup route was created, and disposable email filtering was added to registration.

The pattern generalizes: static analysis is fast and covers the code that exists. Browser verification catches what the code doesn't have and what renders differently than the code implies. Running both isn't redundant — they find different categories of problems. The mobile audit with `mcp__claude-in-chrome` at 390px is now a standard step before shipping any frontend changes.

---

## When 4 Codex Reviewers All Request Changes: Extracting a 70KB Heredoc

Sessions 9 through 11 (59 + 122 + 59 tool calls) were all focused on `local-commerce-agent` — specifically, refactoring the cron architecture.

The problem was structural. Business logic was hardcoded inside a 70KB bash worker heredoc. Any policy change meant editing the bash file directly, with no separation between execution infrastructure and policy configuration.

The design goal: Claude acts as policy architect, Codex acts as repeatable executor. That division only works if the policy is readable by Codex without parsing bash logic.

The refactor extracted policy into two external files:
- `jdlab-codex-cron-policy.json` — business rules, lane configurations, processing constraints
- `jdlab-codex-lanes.json` — lane definitions and routing logic

The bash worker reads these files at runtime rather than having the policy baked in.

Four Codex reviewers each submitted `request-changes`. The blockers were legitimate — edge cases in the lane routing logic and missing validation on the policy file schema. After addressing them, all four passed.

Along with the structural changes: `min_per_lane` increased from 12 to 30, queue size expanded, and a `country-gate` module was added.

The practical difference: when business policy changes, you edit a JSON file. The execution infrastructure stays untouched. Codex can validate policy changes independently without needing context on the bash internals. The heredoc had merged two concerns that should have been separate from the start.

The four simultaneous `request-changes` responses were a useful signal in themselves: multiple independent reviewers finding multiple independent problems means the initial design had structural issues, not edge cases. Running the review before the logic was fully settled added a round trip. The right sequence is to resolve obvious structural concerns internally before going to reviewers.

---

## The Pattern Behind 1,085 Tool Calls

The number itself isn't the point. The composition is.

Every major session today used the same structure: parallel fan-out first, then synthesis. Pokemon card data source validation while schema design ran. Seven audit domains simultaneously on the payments project. Eight UI areas in parallel before browser verification. Two agents reading game specs while tooling research ran concurrently.

Sequential processing would have hit a hard limit around 2-3 substantive sessions in a day. Not because the work is slow, but because each research-then-build cycle has a minimum time cost that stacks linearly.

The tool call breakdown reflects the work structure:

| Tool | Count | What it represents |
|------|-------|-------------------|
| Bash | 357 | `gitleaks` runs, build checks, git status, npm commands |
| Edit | 240 | Modifications to existing files |
| Write | 131 | Net-new file creation |
| Read | 191 | Code review and verification during audits |

Write (131) vs. Edit (240) tells you something: most of the day was modifying existing codebases and adding to structures, not building greenfield. The Pokemon card tracker was the exception — Session 2's 90+ new files is visible in that Write count.

Read (191) concentrated in the audit sessions. Reviewing code without a task to execute is undervalued — the saju VAT blocker and the `STATUS.md` drift were both found by reading, not by running anything.

The gitleaks session (34 tool calls) had the highest impact-per-call ratio of the day. 25 minutes, one tool installed, one command variant changed, one risk confirmed. Short sessions that ask a specific question tend to produce cleaner decisions than long sessions that try to fix everything at once.

## What This Doesn't Tell You

1,085 tool calls in a day is a metric, not a goal. There were sessions today that ran long because the initial framing was wrong and needed correction mid-session. The Pokemon tracker session hit 342 calls partly because the data source pivot required rebuilding assumptions that had already been embedded in early design decisions. A better upfront data source validation step would have shortened the session.

Multi-agent fan-out scales well when the work items are genuinely independent. The coffeechat audit and the Godot experiment share no dependencies — running them in parallel costs nothing. The heredoc refactor and the Codex review pass are sequential by nature — the review can't start until the refactor is complete. Knowing which is which matters more than defaulting to parallelism everywhere.

The VAT compliance finding is a good example of where Claude Code's multi-agent AI automation earns its keep: it's the kind of issue that's easy to miss in a sequential review because you close one domain before the implications of another are fully visible. Seven agents reading seven domains simultaneously means the cross-domain connection surfaces immediately rather than after the fact.

The static-vs-dynamic gap in the coffeechat audit is the other example worth noting. No amount of additional static analysis would have found the missing signup route. You have to run the thing.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
