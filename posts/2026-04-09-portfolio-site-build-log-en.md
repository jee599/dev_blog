---
title: "I Fixed the Same Bug 6 Times in One Day: iOS overflow-x, 624 Tool Calls, and a Full Redesign"
published: true
description: "14 sessions, 624 tool calls, one day. How a mobile scroll bug turned into 6 separate fixes — and what I learned about Claude Code worktrees."
tags: claudecode, webdev, ai, javascript
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-09-portfolio-site-en
---

14 sessions. 624 tool calls. And I fixed the same bug six times.

Not six *different* bugs — the same one. Horizontal scroll on iOS Safari. Every time I pushed a fix, it came back. By session 6, I started wondering if I was the bug.

**TL;DR** On 2026-04-06, my portfolio site logged 624 tool calls across 14 Claude Code sessions. The root cause of the mobile overflow bug wasn't one thing — it was three overlapping issues, including an iOS Safari compatibility gap that I kept missing across different worktrees. I also shipped a full redesign (dark mode, Cmd+K command palette, indigo color system) the same day. Here's the breakdown.

## Why the Same Bug Needed Six Fixes

The progression looked like this:

1. **Session 1**: Added `body { overflow-x: clip }` — seemed to work
2. **Session 2**: Added `html { overflow-x: hidden }` — worktree didn't have session 1's fix
3. **Session 3**: Applied `img { max-width: 100%; height: auto }` globally
4. **Session 4**: Removed `-mx-5 px-5` negative margin in `HomeContent.tsx`
5. **Session 5**: Removed `-mx-4` from `BlogList.tsx`
6. **Session 6**: Fixed hardcoded `width={640}` in `ImageWithCredit.tsx`

Three root causes, not one.

**Root cause 1: iOS 15 compatibility.** `overflow-x: clip` falls back to `visible` on iOS 15 and below Safari. I caught this in session 1, but session 2 was running in a different worktree — no visibility into the previous fix, so the diagnosis started fresh.

**Root cause 2: Layer structure.** Even with `overflow-x: clip` on `body`, mobile Safari scrolls the `html` element when the viewport overflows. You need to block it at the root. I didn't confirm this until session 6.

**Root cause 3: Negative margins.** The category tab bar used `-mx-5 px-5` for a full-bleed effect — pushing 16px past the viewport on each side. Under `overflow-x: hidden` it was invisible. Under certain layout conditions, it came back.

The complete fix list, confirmed in session 11:

```
1. HomeContent.tsx:98 — remove -mx-5 px-5
2. BlogList.tsx:33 — remove -mx-4
3. globals.css — add overflow-clip-margin, word-break: break-word
4. layout.tsx — overflow-x: clip on both html and body
```

If I'd had this list in session 1, it would have taken two sessions, not six. The real problem wasn't Claude's diagnosis — it was that worktrees don't share context. Each worktree starts cold, with no awareness of what a parallel session already changed.

## How the Systematic Debugging Skill Actually Changes Behavior

Every bug session auto-loaded `superpowers:systematic-debugging`. The core principle:

> "NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST"

The difference is measurable. Without the skill: "fix horizontal scroll" → Claude adds `overflow: hidden` in one line, done. With the skill loaded: Claude runs Grep across all components for `100vw`, `-mx-`, `w-screen`, checks whether `position: fixed` elements are overflowing the viewport, *then* proposes changes.

Session 1 logged 54 tool calls: Bash 22, Read 13, Edit 8. More Reads than Edits. That ratio — reading more than writing — is what the skill enforces.

The discipline is real but it has limits. If two sessions run independently in separate worktrees and both start cold, the skill gives each one the same investigation framework. What it can't do is remember that session 1 already checked `overflow-x: clip` compatibility and confirmed it as the fix.

## Escaping the "Apple Clone" Trap with Two Design Skills

Sessions 3, 8, 9, 12, and 14 were design-focused — roughly 330 tool calls combined.

Before session 9, I installed `ui-ux-pro-max` and `frontend-design`, and configured every design session to read both before starting. Session 9 was analysis-only:

> "This site faithfully references Apple's design language — Pretendard font, `#fbfbfd` background, `#0071e3` brand color, hairline borders, backdrop-blur header. The visual grammar is clean and consistent. The problem is it reads as an Apple clone."

That framing drove session 12: a full redesign. 7 hours 33 minutes. 148 tool calls — the largest single session of the day.

Direction: deep indigo (`#4f46e5`) base, CSS variable migration, dark mode system, Cmd+K command palette. Tool breakdown: Edit 43, Bash 34, Read 30, Write 15. The Write count is high because 22 new files were created: `ThemeProvider.tsx`, `SearchCommandPalette.tsx`, `ScrollReveal.tsx`, and others.

The leverage from loading two design skills: I didn't specify color codes, font pairings, or component patterns in the prompt. "Full redesign in indigo blue" was enough — the skills supplied the palette, pairing choices, and token naming conventions. Claude applied them coherently across the system without micromanagement.

## Worktrees at Scale: 12 Branches and the Vercel CANCELED Loop

Over the day, 12+ worktrees were active: `recursing-mccarthy`, `funny-chatelet`, `inspiring-babbage`, `keen-buck`, and others.

Two Vercel problems repeated:

**Problem 1: Consecutive push cancellation.** Vercel auto-cancels a running build when a new push arrives. With multiple worktrees pushing to the same project, builds constantly stepped on each other.

**Problem 2: Branch isolation.** Worktree branches aren't `main`. Vercel's automatic deployments only trigger on the production branch — worktree pushes just sat there without deploying.

The fix was direct CLI deployment:

```bash
PATH="/opt/homebrew/opt/node@22/bin:$PATH" /opt/homebrew/bin/vercel --prod
```

For cases where changes were already on `main` but Vercel wasn't triggering, an empty commit did the job:

```bash
git commit --allow-empty -m "chore: trigger build"
git push
```

Both are workarounds, not solutions. The cleaner approach: finish all worktree work, merge to `main`, then do one clean push. Instead, iterative merges and pushes created the cancellation loop throughout the day.

## Parallel Agent Dispatch: AgentCrow in Action

Session 14 dispatched 3 agents in parallel using the AgentCrow pattern:

```
🐦 AgentCrow — dispatching 3 agents:
1. @frontend_developer → HomeContent.tsx + ArticleCard.tsx
2. @frontend_developer → PostContent.tsx
3. @frontend_developer → DailyBriefing.tsx + content
```

The key is non-overlapping file scope. Each agent gets a domain that doesn't touch the others, so they run concurrently without merge conflicts. Session 14 shows 26 tool calls in the main thread, but the actual work was multiplied across three agents running in parallel.

This is where the worktree context-loss problem is partially mitigated: if you're dispatching parallel agents for *new* work (not re-diagnosing the same bug), the pattern works well. It's when you try to apply parallel agents to a debugging loop that confusion compounds.

## Day Stats

| Metric | Count |
|---|---|
| Sessions | 14 |
| Total tool calls | 624 |
| Bash | 218 |
| Read | 173 |
| Edit | 100 |
| TodoWrite | 38 |
| Write | 17 |
| Agent | 16 |
| Grep | 15 |
| Files modified | 39 |
| New files created | 17 |

Bash is more than double Edit. The dominant pattern isn't writing code — it's run → check → run again. That's what debugging days look like in tool call terms.

## What Actually Needs to Change

Fixing the same bug six times isn't a Claude Code quality problem. It's a workflow problem. Worktrees are designed to be isolated — that isolation is valuable for parallel feature work. But for debugging, isolation means each session re-diagnoses from scratch.

Two rules that would have cut this to two fixes:

**1. Merge before the next debugging session.** If session 1's fix is on `main`, session 2 starts with it already applied. No re-diagnosis.

**2. Include previous fix history in the prompt.** Four sentences of context would have avoided four sessions:

> "We already tried `overflow-x: clip` on `body` — iOS 15 falls back to `visible`. The fix needs to be on `html` too. Also check for negative margin sources like `-mx-5` and `-mx-4` in tab components."

Claude Code's memory doesn't cross worktrees. That's by design. Working with it means treating cross-session context as your responsibility, not the tool's.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
