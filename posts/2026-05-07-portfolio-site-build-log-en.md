---
title: "16 Sessions, 416 Tool Calls: How Codex Caught an SRI Bug Before Production"
published: true
description: "16 Claude Code sessions across 3 projects: 5 parallel design variants, a Codex-caught SRI hash bug, spoonai editorial redesign, and a compliance-first dental SEO report pipeline."
tags: claudecode, ai, webdev, devlog
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-05-07-portfolio-site-en
---

Ran 16 Claude Code sessions across three projects in a single day — 416 tool calls, 21 new files, and one SRI hash bug that would have silently broken JavaScript for real users if Codex hadn't reviewed the diff with fresh eyes.

Three projects: a coffee chat platform redesign, a spoonai production site migration, and SEO/AEO diagnostic reports for two dental clinics. Completely different domains, same underlying workflow: parallel generation to explore the space, cross-verification to catch what same-context models miss.

**TL;DR** Parallel design generation works, but direction matters more than volume. Codex cross-verification caught a production-breaking bug that went unnoticed across 5 independently generated variants. Medical advertising compliance reporting requires hard separation between public data and anything that needs admin access — no estimates, no interpolation.

## Generating 5 Designs in Parallel, Then Hearing "All of These Suck"

The coffee chat site redesign started with a clear directive: generate at least 5 distinct variants and let the client pick. The site is a mentoring platform for the Korean game industry — 1:1 sessions with active game developers and designers, resume reviews, and mock interviews.

First step was analyzing the current site and mapping the service category. Then `plan-orchestrator` produced a `plan.md` with design goals and constraints. From there, 5 `frontend-implementer` agents were dispatched simultaneously, each running in isolated context:

- V1: Editorial Magazine — editorial grid, bold typography, content-forward
- V2: Soft Brutalist — high contrast, raw structure, unconventional layout
- V3: Floating Gradient — soft blobs, ambient color, modern SaaS aesthetic
- V4: Object-oriented UI — card-heavy, structured hierarchy, systematic components
- V5: Brief Format — stripped down, portfolio-style, information density

Because each agent ran in isolation with no shared state, none of the variants influenced the others. The outputs were generated in roughly the same wall-clock time as producing a single variant.

Feedback: *"These all look generic. None of them feel like a professional service."*

The diagnosis: every variant explored visual design trends, but none addressed service category fit. The platform is an edtech mentoring service — it needs the credibility signals of platforms like Inflearn or Teachable, not the indie game jam aesthetic that "game industry mentoring" suggested. The right reference class wasn't gaming culture; it was structured professional education.

Reset the direction, reclassify the brief, queue another round.

The bottleneck in parallel design workflows isn't compute time or context capacity. It's direction accuracy. Get the service category right before dispatching the first variant, or you get 5× the wrong answer delivered faster. The research step — understanding what kind of platform this actually is — is load-bearing, not optional.

## The SRI Bug That Same-Context Models Consistently Miss

After the direction reset, `design-reviewer` ran against all five variants and flagged a blocker in V3: floating gradient blobs with WCAG contrast failures, no focus indicators, background animations that violated `prefers-reduced-motion`.

Fixed the blocker, saved the patch as `diff.patch`, and ran Codex cross-verification.

Codex came back with a finding unrelated to the accessibility fix: an SRI (Subresource Integrity) hash mismatch in V2, V3, V4, and V5. All four variants loaded React from CDN, but the `integrity` hash values had been computed against the development build (`react.development.js`), not the production file:

```html
<!-- Wrong: production file URL, development build hash -->
<script
  src="https://unpkg.com/react@18/umd/react.production.min.js"
  integrity="sha384-[development-hash]"
  crossorigin="anonymous">
</script>
```

How this breaks in practice: browsers verify the hash against the actual downloaded content before executing the script. When the hash doesn't match, the browser blocks execution — silent `Integrity check failed` in the console, non-functional React app. Local development doesn't reproduce it reliably because cached files often skip integrity verification. It surfaces post-deployment, on real user browsers with cold cache, as a complete app failure.

Why did 5 independently generated variants all have the same bug? Because all 5 agents worked from the same base prompt template that included the CDN link — and that template had the wrong hash. The bug propagated at generation time, not review time.

Why did same-context review miss it? A model that generates code and then reviews it carries a strong prior toward accepting its own output as correct. The integrity hash looks legitimate — right length, right prefix, right format. Without independently computing the hash from the actual CDN file, there's no signal that it's wrong. An external model reviewing the diff from a clean context has no such prior.

Fixed: fetched the correct production hashes for React and ReactDOM CDN URLs, replaced them across all 5 variants.

Session 1: 78 tool calls, 28 `Agent` calls, 25 `Bash` commands.

## Chasing Korean Glyph Boxes

Session 2 started with a screenshot full of □□□□ where Korean text should be. Labels in a deployed infographic rendering as empty glyph boxes.

Root cause: a self-generated infographic JPG (58KB) had been embedded in two posts. The image was exported without Korean fonts embedded in the raster, so every Korean character outside the available system glyphs rendered as a replacement character.

```bash
grep -r 'credit.*spoonai' src/content/posts/
```

Found two posts referencing the file (Korean and English versions). Removed the `image:` block from both frontmatters, deleted the JPG. Three files touched, single commit:

```
chore: remove self-generated infographic image with broken Korean fonts
```

Vercel picked up the commit and auto-deployed.

The credit field attribution pattern made this a one-liner search. Without it, finding all self-generated images with the same potential font embedding issue would have required manual inspection across every post.

The spoonai editorial redesign ran in the same session. Round 1 produced 5 variants simultaneously. The user identified one as the right directional anchor, so a second round iterated 5 more variants from that base. 10 total variants, 2 user decisions. Final selection applied to the actual codebase: 7 files changed, 442 insertions, 725 deletions on a dedicated feature branch.

Session 2: 130 tool calls, 87 `Bash`, 22 `Agent` calls.

## Dental Diagnostic Reports: The Hard Line Between Public Data and Estimates

Sessions 3 through 16 covered building SEO/AEO diagnostic reports for two dental clinics.

The non-negotiable constraint: Korean medical advertising law prohibits fabricated, misleading, or unverifiable claims in any material produced for a medical institution. This applies to internal diagnostic reports handed to clinic owners, not just published ads.

Practically, any metric requiring platform admin access gets labeled "requires verification / metric unconfirmed." The list is longer than you'd expect:

- Search platform view counts
- Phone click-through counts
- Appointment conversion data
- Monthly keyword search volume
- CPC and CTR estimates

For every one of these, the report has a dedicated placeholder rather than a filled cell. No interpolation from public proxies, no estimates with error bars, no "approximately X based on similar clinics." The report clearly separates what it knows from what it doesn't.

This produces a report that looks incomplete compared to marketing dashboards that fill every cell with a number. But presenting estimated figures as real clinic data creates compliance liability for the clinic. The diagnostic report shouldn't manufacture that liability.

There was also a naming collision. Searching a medical review platform for "Dongbaek Seoul Pediatric Dental" surfaced a listing for "Dongbaek Seoul Dental" — one character difference in Korean, different clinic type (general vs. pediatric), different address. In Korean, the difference is a single syllable in the clinic name. Easy to conflate in automated search.

Every external search result was tagged "candidate / needs direct confirmation." The user confirmed the correct platform URL directly, and only that confirmed URL was used as the data anchor.

After the initial build, Codex cross-verification returned `request-changes` with three findings:

1. Mobile responsive `data-label` attributes missing from comparison summary tables
2. Residual performance-guarantee language in one section — prohibited under Korean medical ad rules
3. One metric labeled "estimated" instead of "requires admin access" — weaker disclaimer than required

Fixed with 23 `Edit` calls and a grep pass to confirm no performance-guarantee language remained anywhere in the report files.

The last session ended with: *"The report looks too AI-generated."*

Built a separate direction selection board — 8 distinct HTML layouts based on reference research across medical report design, consulting firm deliverables, and SaaS dashboard aesthetics. The user picks a direction first, then the final report renders in that style. Separating "what does this look like" from "generate the final output" is worth the extra step when the output gets handed to a client.

## Day Stats

| Metric | Count |
|---|---|
| Sessions | 16 |
| Total tool calls | 416 |
| Files created | 21 |
| Files modified | 7 |
| Bash | 167 |
| Agent | 50 |
| WebSearch | 41 |
| Edit | 27 |

Bash at 40% of total calls: CDN URL validation, git operations, build verification, dev server management. `Agent` at 50 calls: parallel design dispatch and per-stage cross-verification runs.

Three things that held across all three projects:

**Direction before generation.** Parallel design workflows save time only when the direction is right. Generating 5 wrong variants simultaneously is just faster failure.

**Cross-verification catches what same-context review misses.** The SRI hash bug existed in all 5 variants and passed every internal review pass. External model, clean context, no prior on the generated code — that's what it took to catch it. For anything that ships to real users, this step is not optional.

**Compliance requirements shape data architecture.** The dental report pipeline is a data classification problem before it's a content generation problem. Which fields can be filled vs. which must remain "unconfirmed" has to be decided before the first report generates, not retrofitted after.

> Parallel generation expands the search space. Cross-verification catches what was missed. Neither is about speed — both are quality insurance.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
