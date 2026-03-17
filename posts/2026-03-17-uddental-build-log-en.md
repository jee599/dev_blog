---
title: "7 Tool Calls to Understand Any Codebase: Claude Code's Initial Scan Pattern"
published: true
description: "One prompt, 7 tool calls, zero changes. How I use Claude Code's initial scan pattern to map an unfamiliar codebase before touching anything."
tags: claudecode, ai, nextjs, productivity
series: "Building with Claude Code: uddental"
canonical_url: https://jidonglab.com/posts/2026-03-17-uddental-en
---

Seven tool calls. No file changes. Complete picture of a codebase I'd never seen before.

That's the initial scan pattern I run every time I open a new project in Claude Code. It cost me a few tokens and saved me from the classic mistake: diving into code before understanding what's already there.

**TL;DR** One read-only prompt → Claude runs 7 tool calls (Read ×4, Bash ×3) → full project structure mapped. No guessing, no surprises.

## The Prompt That Does One Job

`uddental` is a dental website and ad strategy project. When I first opened it, I ran this:

```
Open this repository in Claude Code context and do a quick initial scan only:
1) confirm the repo is accessible
2) identify the stack/framework
3) list the most important top-level directories/files
4) report any obvious start/dev/build commands if present

Keep it concise and do not make changes.
```

The last line is load-bearing. `do not make changes`. Without it, Claude might generate a README, scaffold configuration files, or "helpfully" reorganize things. During onboarding, the goal is understanding — not modification.

The prompt is short. That's intentional. Narrow scope → focused output → faster scan.

## Opus vs. Sonnet for Initial Scans

I set the model to `claude-opus-4-6` for this session.

The reasoning: structural inference on an unfamiliar codebase is a different kind of task from completing a well-defined feature. Opus reasons about architecture more reliably — it's more likely to recognize that a top-level directory contains three parallel implementations rather than treating them as loosely related folders. That distinction matters when the structure *is* the insight.

The extra cost is worth it at scan time. Getting the structure wrong and correcting it mid-implementation is more expensive than a slightly higher input token count upfront.

For subsequent sessions — once context is established — Sonnet is fine.

## What 7 Tool Calls Found

`Read(4), Bash(3)`. That's the complete call log. Read-only throughout.

The result was more interesting than a typical dental website:

```
implementations/
├── claude/          — Main Next.js app (App Router, build complete, Vercel config)
├── codex/           — Codex implementation track
└── hybrid-claude-plan-co...  — Third implementation
```

Same project, built three different ways with three different AI tools, side by side for comparison. The `claude/` implementation is production-ready — it has a `.next` build directory and Vercel deployment configuration already in place. The other two tracks look experimental, without build artifacts.

Stack inside `implementations/claude/`: **Next.js 15 + React 19 + TypeScript + Tailwind CSS v4**.

That's not obvious from the repo root. You'd have to open three directories and read three separate `package.json` files to piece it together manually. Claude did it in 7 calls.

## Why the Initial Scan Gets Its Own Session

If you start with "fix this file" on an unknown codebase, Claude works without context. The output might conflict with existing patterns, duplicate something that already exists, or make structural assumptions that don't match what the project actually looks like.

A dedicated scan session gives two things.

**Claude's context.** Once Claude knows `implementations/claude/` is the main entry point, it doesn't need to be told again in future sessions (if you persist the output — more on that below). "Add a booking form" is enough — Claude already knows which directory it belongs in and which stack constraints apply.

**Your context.** You can't make good decisions about what to build without knowing what already exists. Skipping the scan means discovering "oh, this was already here" halfway through an implementation — or worse, building something incompatible with the existing structure.

The scan is a forcing function to look before you touch.

## What Happens When You Skip It

Here's the failure mode: you open a repo, ask Claude to add a feature, and it scaffolds a new component using a pattern that's inconsistent with the rest of the codebase. The code works, but it introduces a second way of doing the same thing. You now have two patterns to maintain.

Or Claude routes the change to the wrong subdirectory because it didn't know there were three parallel implementations. You spend time debugging why changes aren't showing up — until you realize you edited the wrong one.

Both of these are preventable with a 7-call read-only scan at the start.

## Persisting the Scan Results

The output of a 7-call scan compresses down to a few lines. Worth saving in `CLAUDE.md` or a project note so the next session doesn't repeat the work:

```markdown
# uddental project context
- Main implementation: implementations/claude/ (Next.js 15 + React 19 + Tailwind v4)
- Three-way AI implementation comparison (claude / codex / hybrid)
- Vercel deployment configured
- Dev server: cd implementations/claude && npm run dev
```

Next session opens with full context from line one. No redundant reads, no misrouted changes. The 7 calls you spent upfront pay forward into every subsequent session.

## The Pattern, Generalized

This isn't uddental-specific. The same pattern works for any unfamiliar repo:

1. Write a read-only scan prompt with explicit `do not make changes`
2. Use Opus for structural inference, Sonnet for everything after
3. Save the key findings to `CLAUDE.md` before closing the session

The scan itself takes under a minute. The alternative — figuring out project structure by trial and error mid-implementation — takes much longer and produces worse code.

> Read first, touch later. That's the rule for unfamiliar code — and it applies to Claude Code just as much as to humans.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
