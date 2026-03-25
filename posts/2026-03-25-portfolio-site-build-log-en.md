---
title: "3 Sessions, 336 Tool Calls: i18n Switch, Skill Refactor, and Hover Animations with Claude Code"
published: true
description: "How Claude Code handled a default language switch, skill cleanup, hover animations, and a security audit across 3 sessions and 336 tool calls."
tags: claudecode, ai, webdev, automation
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-25-portfolio-site-en
---

336 tool calls. 3 sessions. 12 files changed. More decisions made than lines written.

**TL;DR** — Switching the default language from Korean to English sounds trivial. It's not. Every text-bearing element across the entire layout needs to be audited. Claude Code mapped the change scope before touching anything, which is why it finished in one pass with no regressions.

## Session 1: "English Should Be the Default" — 13 Reads, 12 Edits

The prompt was direct.

```
The language toggle isn't working right. The site needs to default to English —
all translations should be complete for English.
```

Claude Code read `Base.astro` first, then returned with three specific problems instead of just starting to edit.

**Problem 1**: `var lang = 'ko'` — default language hardcoded to Korean. Every first visit fell back to Korean regardless of browser preference.

**Problem 2**: The toggle button showed `EN`. If English is the default, the button should offer `KO` — not the other way around.

**Problem 3**: Every `data-ko`/`data-en` element had Korean as its rendered baseline text in the HTML. Flipping `lang = 'en'` wouldn't fix the flash — the text nodes served from the server are still Korean.

That third point was the real problem. The site's i18n doesn't use server-side routing or translation files. Instead, every text element carries both languages as HTML attributes:

```html
<span data-ko="최근 포스트" data-en="Recent Posts">Recent Posts</span>
```

JavaScript reads `localStorage.getItem('lang')`, then walks the DOM replacing `textContent` with the matching attribute value. Client-side, zero dependencies, no framework overhead.

The catch: the default inline text must match the default language. If default text is Korean but English is the new default, you get a Korean flash on every load before JS runs. The fix required changing the default `lang` *and* updating every text node to English.

Strategy: keep the `data-ko`/`data-en` attribute structure as-is, replace inline default text with English, and at JS initialization read `localStorage` for a saved preference. Korean users get `data-ko` values applied on top.

25 of the 50 tool calls in this session were Read and Edit. The other half went to a delegated Agent.

```
Check all the English translations — are they complete, natural, no typos?
```

One prompt. The Agent crawled the entire site, flagged missing translations, caught awkward phrasing. Faster than clicking through every page, and it doesn't start rushing by page 4.

## Session 2: Removing Naver from the auto-publish Skill — 37 Bash, 23 Edits

The original goal was publishing three Claude-update articles to DEV.to and Hashnode. But opening the `auto-publish` skill showed Naver still listed as a publish target.

```
Remove the Naver stuff from that skill.
```

Six references removed: Agent 3 (Naver Korean HTML), the `naver-seo-rules.md` reference, Phase 4 Naver publishing section, Phase 5 Naver queue check. Platform count dropped from 3 to 2 — spoonai.me and DEV.to only.

The Hashnode token setup was more work than expected. Even after providing the token directly, Claude Code ran a Bash sequence: locate the env var, patch `publish-to-hashnode.mjs`, verify the result. That's where the 37 Bash calls came from. One token, a lot of shell.

One SEO decision worth keeping in any multi-platform publishing setup: set `canonical_url` to the personal site on every syndicated post. Whichever platform Google crawls first, the original source stays attributed to `jidonglab.com`. That's how you publish to DEV.to and Hashnode simultaneously without duplicate content penalties.

## Session 3: Hover Animations and a Security Audit — 100 Bash, 33 Edits

The longest session. 196 tool calls, 100 of them Bash.

It started with a UX question about card components.

```
Can you make the previews animate on hover? Like a scroll or re-trigger animation?
```

Three animation variants added to `ArticleCard.tsx`:
- **Hero card**: 1.05x image zoom + shimmer scanline effect
- **Default card**: 1.05x image zoom on hover
- **Compact card**: 1.1x thumbnail zoom on hover

A `scan` keyframe animation landed in `globals.css` for the shimmer.

Then Vercel deployments started canceling. Three consecutive `git push` triggers, three `CANCELED` statuses. Claude Code bypassed the stalled auto-deploy with `vercel build --prod && vercel deploy --prebuilt --prod` directly. Not elegant, but it shipped.

The security audit was a single delegated prompt.

```
Are there any security issues in this site? API attack vectors, token exposure, anything?
```

The Agent returned one CRITICAL finding: an API route with no input validation. Finding that manually would have meant reading every route file from scratch. Delegated and triaged in under 15 minutes.

The hover animation itself went through five revision cycles. "Scroll on hover" → "Why does it scroll every 4 seconds?" → "Only scroll while hovering" → "2.5x the scroll speed" → "Actually, half that." The 33 Edit calls are mostly this loop. Requirements don't arrive fully formed — Claude Code follows the iteration.

## Tool Distribution Across All Three Sessions

| Tool | Count |
|------|-------|
| Bash | 149 |
| Edit | 68 |
| Read | 54 |
| Agent | 25 |
| Other | 40 |

Bash is nearly half the total because build verification, deployments, and env var setup repeated across all three sessions.

25 Agent calls for a single day's work. Translation review, security audit, and reference HTML improvements all delegated. Each task would have taken 1–2 hours manually.

## The Prompting Pattern That Made the Difference

The language switch went cleanly because of how it was framed. Not "switch the site to English" — that's an instruction to act. Instead: "how does the current translation system work, and what are the problems?"

Analysis before action. Claude Code read the files, mapped the change scope, identified three problems, and proposed a strategy. By the time editing started, the blast radius was already understood.

The same pattern applies to security audits: don't ask for a checklist, ask what's actually wrong. The Agent finds things you didn't know to look for.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
