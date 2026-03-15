---
title: "GPT-5 Codex Shorts Pipeline, How I Bootstrapped 5,800 Lines in 4 Commits"
published: true
description: "Built a saju-to-Shorts video pipeline with GPT-5 Codex. Architecture docs first, types second, code last — the pattern that keeps AI-generated projects coherent."
tags:
  - ai
  - gpt5
  - productivity
  - webdev
id: 3353620
date: '2026-03-15T07:12:34Z'
---

I generated 5,800 lines of new code with GPT-5 Codex across four commits. A pipeline that takes saju (Korean fortune-telling) data and produces vertical Shorts videos, from scratch. Here is the prompting strategy that made it work.

## What I Was Building

The project is a pipeline that accepts saju profile JSON, processes it through a Python backend, and renders video through a Remotion-based React renderer. The commit log shows a `gpt-5-codex:` prefix on every message — that was deliberate. Every piece of code came from structured AI collaboration.

## Architecture Documents Before Code

The first thing I created was `PROJECT_BRIEF.md` and `ARCHITECTURE.md`. Without these, the AI produces inconsistent code across files.

The prompt that worked:

> "Design a Shorts generation pipeline using Python CLI and a Remotion renderer.
>
> Requirements:
> - Accept saju JSON, output MP4
> - CLI invocation: `python -m shortsmaker generate profile.json`
> - Hooks system for extensibility
> - Multilingual support (Korean, English)
> - Remotion renders React components
>
> Specify folder structure, module separation, and data flow. Describe each component's responsibility in one sentence."

The prompt that fails:

> "Make a saju app"

Without explicit tech stack and constraints, GPT-5 Codex wanders. The key instruction is demanding folder structure and module responsibilities upfront.

## Types Before Implementation

I defined `src/shortsmaker/models.py` and `renderer/src/types.ts` before writing any business logic. This is the single most important step in a multi-stack project.

The prompt:

> "Create Pydantic models for saju analysis results.
>
> Fields: name, birth date, gender, eight characters (heavenly stems and earthly branches — the core elements of Korean astrology), personality analysis, fortune, advice (each multilingual).
>
> Must be JSON-serializable with field validation. Generate matching TypeScript types."

The critical clause is **"Generate matching TypeScript types."** This forces the AI to keep Python and TypeScript in sync from the start. The resulting `models.py` Pydantic models matched the `types.ts` interfaces exactly. No manual synchronization needed.

## CLI and Job System Design

For the CLI, a bare "make a CLI" prompt produces something generic. Structured requirements produce something usable:

> "Build a Typer CLI with these commands:
>
> ```
> python -m shortsmaker generate input/profile.json
> python -m shortsmaker validate input/profile.json
> python -m shortsmaker render job_123
> ```
>
> Each command: generate = JSON validation + Job creation + render queue. validate = schema check only. render = retry by Job ID.
>
> Errors go through Rich. Success prints Job ID and output path."

This works because: (1) interface examples make the contract unambiguous, (2) each command's responsibility is one line, (3) output format is specified.

For the Job state machine, the constraint that matters most is atomicity:

> "Job states: pending → processing → completed → failed. Store as individual JSON files in `jobs/`. File name: `{job_id}.json`. Atomic state transitions — no race conditions."

Without the "atomic state transitions" constraint, the AI produces code that is not thread-safe. On file-based storage, this detail is critical.

## React + Remotion Renderer

The `ShortsComposition.tsx` component is 194 lines. I generated it in one pass by **defining layout numerically**:

> "Build a 9:16 vertical Shorts React component.
>
> Layout: top 20% for title + subtitle, middle 60% for main content, bottom 20% for summary + CTA.
>
> Animation: title slides in from top (0-1s), content fades in with scale (1-2s), footer slides up (2-3s).
>
> Use SajuProfile from types.ts. Use Remotion's useCurrentFrame and interpolate."

Percentage-based layout and second-precise animation timing are what make this prompt produce usable output. "Make it look nice" produces nothing consistent.

For the render script that bridges Python and Node.js:

> "Remotion render script. Accepts job JSON path as CLI arg. Parse JSON, extract SajuProfile, call renderMedia for MP4. Print result path to stdout (Python subprocess will parse it). Errors to stderr with exit codes. Render at 1080x1920, 30fps, 10 seconds."

The stdout specification is the key detail — Python's subprocess needs a parseable output contract.

## Test and Sample Data

> "Create a sample saju JSON for a woman born March 15, 1990 at 10 AM in Seoul. Include accurate heavenly stems and earthly branches, personality analysis (Korean/English), 2024 fortune (Korean/English), 3 pieces of advice (Korean/English). Must be valid against SajuProfile type."

GPT-5 Codex knows enough about saju to produce plausible data, but the "valid against SajuProfile type" constraint is mandatory.

## What Could Be Better

**Type sync automation.** I manually kept Python and TypeScript types aligned. A `datamodel-code-generator` + `json-schema-to-typescript` pipeline would automate this:

```bash
pydantic-to-typescript src/shortsmaker/models.py renderer/src/types.ts
```

**The "Role + Constraint + Example" prompt pattern** produces more consistent results than the "requirement list" pattern I used here. Defining a role ("You are a Python/TypeScript fullstack developer"), constraints (Python 3.11+, Pydantic v2, type hints required), and a code example as seed — this combination locks down code style better.

## Takeaways

- Generate architecture documents before code — they give the AI a coherent reference frame
- Define type systems first; Python/TypeScript sync becomes trivial
- Explicit constraints (atomicity, output format, error handling) are the difference between demo code and production code
- Sample data and tests can be AI-generated, but validation conditions must be human-specified

5,800 lines in 4 commits happened because of AI, but making AI produce coherent output across a multi-stack project requires structured thinking on the human side.

<details>
<summary>Commit log</summary>

65f233a — gpt-5-codex: bootstrap project workspace
07e6f61 — gpt-5-codex: build saju shorts pipeline
d6e1582 — gpt-5-codex: fix repo-relative cli paths
6cc0e4f — gpt-5-codex: log sample short validation

</details>
