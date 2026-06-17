---
title: "Why My Design Extractor Only Grabbed Colors — and How Playwright Fixed It"
published: true
description: "Traced why my open-design skill only extracted hex colors. Replaced grep-based CSS parsing with Playwright getComputedStyle — now captures Inter 510 weight and -1.584px letter-spacing from Linear.app."
tags: claudecode, playwright, designtokens, ai
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-06-18-portfolio-site-en
---

171 tool calls across 2 sessions to fix a bug that turned out to be a single wrong assumption baked into a one-liner.

The `open-design` skill has a reference extraction step — before cloning a site's design, it pulls design tokens from the target. Problem: it only ever returned colors. Font family, weight, letter-spacing, layout structure — all missing. I assumed it was an edge case. It wasn't. The extraction recipe was literally only looking for colors, and nothing else.

**TL;DR** Replaced `grep '#[0-9a-fA-F]'` CSS string parsing with Playwright `getComputedStyle` against a live browser. Now extracts font stack, weight, letter-spacing, radius, shadow, container width, and section structure — not just hex values.

## The Bug Was a One-Liner

The original recipe in `SKILL.md` was this:

```bash
grep -E '#[0-9a-fA-F]{3,8}' site.css   # extract hex colors
# estimate typography from screenshot
```

Five things fail simultaneously here:

- `rgb()`, `hsl()`, and CSS custom properties like `var(--color-*)` don't use hex syntax — all skipped
- Font family, size, weight, and `letter-spacing` aren't color values — grep ignores them
- Section structure (hero → benefits → changelog → CTA) lives in HTML, not CSS
- Custom fonts loaded via `@font-face` show up as filenames, not rendered weights
- "Estimate from screenshot" is OCR guesswork, not computed values

The root issue: grep is a string pattern matcher. Design tokens are rendered DOM state. Wrong layer entirely.

## What Playwright Actually Pulls Out

Rewrote `~/.claude/skills/open-design/scripts/extract-reference.mjs` to launch a real browser via Playwright and call `page.evaluate()` to read computed styles directly from DOM nodes.

```js
const tokens = await page.evaluate(() => {
  const h1 = document.querySelector('h1')
  const cs = (el) => window.getComputedStyle(el)
  return {
    heading: {
      fontSize: cs(h1).fontSize,
      fontWeight: cs(h1).fontWeight,
      fontFamily: cs(h1).fontFamily,
      letterSpacing: cs(h1).letterSpacing,
    },
    colors: {
      background: cs(document.body).backgroundColor,
      text: cs(document.body).color,
    },
    container: {
      maxWidth: cs(document.querySelector('main')).maxWidth,
    },
    // radius, shadow, spacing...
  }
})
```

Running this against Linear.app produced:

```
h1: 72px / weight 510 / Inter Variable / letter-spacing -1.584px
body: 15px / 400 / same font stack
loaded fonts: Inter Variable + Berkeley Mono
canvas: rgb(8,9,10)
signature green: rgba(0,255,5,0.1)
section structure: hero → benefits → PageSection ×5 → changelog → CTA
```

Weight 510 and letter-spacing -1.584px. That's what "the Linear feel" actually is. Not 400. Not positive spacing. Both values were completely invisible to the grep approach — the screenshot-based estimate would've landed somewhere around "Inter, large, bold, dark" and stopped there.

## Enforcing the Gate with a Hook

Building the extractor wasn't enough. If Claude starts writing HTML before extraction runs, the tokens are never used. I registered `reference-gate.sh` as a PreToolUse hook that blocks any `.html` Write attempt when `reference-tokens.json` doesn't exist in the project directory.

```bash
# ~/.claude/hooks/reference-gate.sh
if [[ -n "$REFERENCE_ARMED" ]] && [[ ! -f "$PROJECT_DIR/reference-tokens.json" ]]; then
  echo "BLOCK: run extract-reference.mjs first."
  exit 1
fi
```

`design-router.sh` handles detection — when it spots patterns like "make it look like [Brand]" or "reference Linear" in the user prompt, it arms the gate. Once armed, any HTML write attempt is blocked until tokens exist.

`compare-tokens.mjs` runs post-build. It headless-renders the finished HTML, compares against the extracted reference tokens, and outputs a 0–100 fidelity score. Below 70 triggers a warning. The comparison logic got a second pass in Session 4: the initial version only compared colors, so the weighted average was expanded to cover font, spacing, and radius as well.

## What's Still Broken

Brands registered in `brand-urls.tsv` (Toss, Linear, Vercel, X, etc.) get automatic URL resolution. Unregistered brands require a URL passed explicitly. When TSV lookup fails, extraction is currently skipped silently — the router just moves on. That needs to become an explicit error, not a quiet no-op.

## Meanwhile: Rebuilding coffeechat as an AI Interview Prep SaaS

The same week I also pivoted `~/coffeechat` from a mentor-mentee platform to an AI interview prep SaaS. Resume builder (5-step wizard), portfolio review, and mock interviews with three distinct AI interviewer personas — all implemented in a single extended session.

Session 5's scope was wide enough that I ran a 6-dimension parallel audit workflow first — logic, token efficiency, interview AI, resume AI, UX, and design — to map the codebase before writing a single line. Then implemented against verified findings: 182 Edit calls, 110 Bash, 111 Read. 437 tool calls. 14 hours.

Some implementation decisions worth noting:

- Interview sessions use Opus 4.8; resume generation uses Sonnet 4.6 — different quality requirements, different cost tiers
- Credit pricing: API cost × 7
- Negative balances are absorbed server-side and displayed to users as 0
- The credit gate issues a session key at interview start to block duplicate report generation for the same interview — a lightweight caching layer against credit abuse

Sessions 5 + 6 (Fable 5-based) combined for 796 tool calls.

## Numbers

| Item | Value |
|---|---|
| Open Design reference sessions | 2 |
| Total tool calls (Sessions 2 + 4) | 171 |
| Time spent | 11h 14min |
| New scripts | `extract-reference.mjs`, `compare-tokens.mjs`, `shot.mjs` |
| New hooks | `reference-gate.sh`, `reference-required.sh` |
| coffeechat tool calls (Sessions 5 + 6) | 796 |
| Files modified/created (coffeechat combined) | 75+ |

The grep-based extractor was never going to work for anything beyond hex colors. `getComputedStyle` is the right abstraction — it reads what the browser actually computed, not what the CSS file says. The hook layer ensures that no matter how a session starts, it can't skip the extraction step.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
