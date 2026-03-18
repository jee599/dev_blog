---
title: "827 Tool Calls, 6 Sessions: What Claude Code Looks Like at Scale"
published: true
description: "6 sessions, 827 tool calls, 117 files touched. Plus the accidental discovery: Claude Code already logs everything as JSONL — build logs can write themselves."
tags: claudecode, ai, automation, productivity
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-03-18-portfolio-site-en
---

827 tool calls. 117 files. 6 sessions.

One week of Claude Code, measured in raw numbers. The work: build a monorepo from an empty repo, convert a portfolio site, fix a payment compliance issue, and ship dental clinic content updates. Nearly all of it delegated to Claude Code.

Along the way, one discovery changed how I think about build logs.

**TL;DR** Claude Code stores every session as JSONL under `~/.claude/projects/`. Parse those files and you get a full record: every prompt sent, every tool called, every file created or modified. Feed that into Claude API and build logs write themselves. That pipeline generated this post.

## One SPEC.md, Zero Commits, 370 Tool Calls

Session 1 started with a single prompt:

```
/Users/jidong/Downloads/SPEC.md implement this.
Create a detailed implementation plan first, as a markdown file.
```

The repo was completely empty. No commits, no scaffold, nothing. `git@github.com:jee599/llmmixer_claude.git`.

Claude made `IMPLEMENTATION_PLAN.md` before writing a single line of code — Phase 0 through 3: project setup, CLI + dashboard, LLM Decomposer + Router, then Codex/Gemini adapters. Once the plan existed, I gave one more instruction to drive the entire session:

```
Implement each phase, objectively review the implementation,
fix issues up to 3 times per phase until solid,
then move to the next phase
```

"Build → self-review → fix → next phase." One prompt. The whole loop.

The Phase 0 self-review caught three issues before I had to point them out: an `outputFileTracingRoot` warning in the Next.js config, unhandled dev server process cleanup, and a `tsconfig.json` module compatibility mismatch. Claude found them unprompted during its own review pass.

370 tool calls later: `packages/core/`, `packages/dashboard/`, `bin/`, `config/templates/` — 69 new files total, the full monorepo skeleton in place.

One snag mid-session: the `workspace:*` protocol in `package.json`. npm doesn't support that format — it's a pnpm/yarn convention. Build broke. Claude updated the manifest and kept going.

The key insight: front-loading a plan eliminates the "what are we building" discovery phase entirely. When the SPEC is attached upfront, Claude executes from line one.

## When Your Own Blog Isn't Your Blog

jidonglab.com started as an AI news aggregator. GPT, Claude, Gemini news twice a day, automated. The pipeline ran fine.

Looked at honestly: this wasn't a blog. It was a content farm I happened to operate.

I'm running LLM Mixer, a saju fortune-telling app (Korean four-pillar astrology), a dental clinic site, a trading bot — all simultaneously. I needed somewhere to show what I'm actually building. "What am I making with AI" should be the center of the portfolio, not an automated news feed.

Session 2 opened with the implementation plan pasted directly into the prompt:

```
Implement the following plan:

# jidonglab Portfolio Hub Renewal

Convert jidonglab.com from AI news/blog site to
project portfolio hub.
```

`admin.astro` was 58KB — a single file handling auth, content management, and all admin UI. Claude read it, built a model of the existing structure, then added a Projects tab and Build Logs tab without touching what was already working.

The data model: `scripts/project-registry.yaml` maps local git paths, `src/content/projects/` holds per-project YAML, and a `visible` flag controls what's publicly shown. No database, no remote API — just YAML and the filesystem.

Then came a `github api error 403`.

The admin projects GET endpoint was calling the GitHub API unnecessarily. The project data was already in local YAML files — no reason to burn API rate limits fetching it remotely.

```typescript
// Before: GitHub API call (burns rate limit)
const repos = await fetch(`https://api.github.com/user/repos`, { ... });

// After: Read local YAML directly
const registry = yaml.load(fs.readFileSync('scripts/project-registry.yaml'));
```

GitHub API calls removed entirely. Commit `bccb9c9`.

The lesson here applies beyond this project: before reaching for an external API, check whether the data already exists locally.

## The Build Logs Were Already Being Written

During one of the sessions, I asked:

```
How can we use the JSONL logs to document what happened in each project —
prompts, tool usage, what actually got built?
```

It turns out Claude Code saves every session to `~/.claude/projects/` as JSONL. Each line is one event:

```json
{"type":"user","message":"..."}
{"type":"tool_use","name":"Bash","input":{"command":"..."}}
{"type":"tool_result","content":"..."}
```

Parse this file and you get everything: every prompt sent, every tool called, every file created or modified. `scripts/parse-sessions.py` handles the extraction. `generate-build-log.sh` feeds the parsed output to Claude API and gets back a draft build log.

This post came through that pipeline.

It's not fully automated — reviewing and editing the draft still takes time. But "start from nothing and write a build log by hand" versus "review and refine a generated draft" are meaningfully different starting points. The JSONL files have been accumulating since the first Claude Code session. The data was already there. It just needed to be read.

If you use Claude Code, your `~/.claude/projects/` directory already contains a complete history of everything you've built. Worth knowing.

## 9 Minutes, 39 Tool Calls, Payment Compliance Done

Session 4: 9 minutes, 39 tool calls. Task: handle TossPayments contract audit requirements for the saju app.

TossPayments is Korea's dominant payment gateway. Before activation they do a manual compliance review of the merchant's site. I pasted the email from their review team directly into the prompt — verbatim, not a summary:

```
1. Please list at least one purchasable product or service on your homepage.
2. Please include business registration information in the footer.
```

Four requirements total. Two needed code changes. Two were outside the codebase.

The CSS was the culprit. `.constellationPage` had `overflow: hidden; height: 100vh` set — the business registration footer was sitting outside the viewport. Nobody could see it, including the compliance reviewers checking the live site.

The pricing section was already fully built. The i18n files had `pricing` keys for all 8 locales, ready to go. It just wasn't being rendered anywhere. One template change and it appeared.

The reason "paste the original email" beats "explain what needs to change": Claude gets exact context without any translation loss between what the requirement says and what you think it says. The compliance email took 9 minutes. Any paraphrase I could write would have taken longer and introduced ambiguity.

## What 827 Tool Calls Actually Look Like

Full breakdown across all 6 sessions:

| Tool  | Calls |
|-------|-------|
| Bash  | 400   |
| Read  | 142   |
| Edit  | 119   |
| Write | 116   |
| Grep  | 15    |
| Agent | 15    |
| Glob  | 10    |

Bash is nearly half. Build checks, server restarts, git status, process management — short commands that accumulate fast. Edit + Write combined (actual code production) is still only half of Bash usage. If you're trying to understand what Claude Code actually *does* in a session, watching Bash calls is the most honest signal.

The 15 Agent calls are worth examining separately. Tasks like "translate 6 build logs to English" got delegated to sub-agents running in parallel, without consuming the main session's context window. This is one of Claude Code's more underutilized patterns — as sessions get longer, offloading discrete tasks to sub-agents becomes increasingly valuable.

Two things showed up consistently across all 6 sessions.

**Front-load the plan.** When the SPEC or implementation plan is attached to the prompt, Claude skips straight to execution. The longer the task, the more this matters. Session 2 — plan pasted, execution starts immediately — was noticeably faster than sessions that began with open-ended goals.

**Use the exact error or requirement text.** Sessions with a compliance email or error stack pasted verbatim resolved faster than sessions with paraphrased descriptions. The raw text carries context that summaries drop.

What didn't work: vague success criteria. "Fix everything and make all features work as intended" from late session 1 led to more revision cycles than prompts with specific expected behavior. Same model, same codebase — just a different definition of done.

> Better prompts aren't for Claude's benefit. They save your own time.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
