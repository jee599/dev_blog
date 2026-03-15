---
title: "Structured Prompting for Multi-Stack Project Bootstraps With AI"
published: true
description: "Python CLI + React renderer in 4 commits. The prompt patterns that keep AI coherent across languages, frameworks, and 5,800 lines of generated code."
tags:
  - ai
  - productivity
  - python
  - react
id: 3353614
date: '2026-03-15T07:09:36Z'
hashnode_url: 'https://plzai.hashnode.dev/ai-multistack-bootstrap-strategy'
---

ShortsMaker is a tool that generates short-form video from saju (Korean astrology) data. Python CLI for processing, React/Remotion for rendering. I bootstrapped the entire project with gpt-5-codex in 4 commits. Starting with code would have failed. Here is the structured approach that worked.

## Design the Whole Architecture in One Pass

When handing a multi-stack project to an AI, the most important rule is: **draw the full picture before writing any code.** Code-first fails 100% of the time on complex projects.

The bootstrap prompt:

> "Design a ShortsMaker project that takes saju data and generates short-form video.
>
> Technical constraints:
> - Python CLI (typer) for data processing pipeline
> - RemixJS for video rendering (remotion)
> - Input: saju data as JSON
> - Output: 9:16 MP4 file
>
> Create first:
> 1. `PROJECT_BRIEF.md` — project overview and requirements
> 2. `ARCHITECTURE.md` — tech stack and component diagram
> 3. `README.md` — installation and usage
> 4. Directory structure and core files
>
> Do not:
> - Write all code at once
> - Create code that does not work independently
> - Build untestable structures"

The anti-pattern: "Code me a saju video app."

The key is **documents before code.** Making the AI write `PROJECT_BRIEF.md` and `ARCHITECTURE.md` first forces it to maintain consistency throughout the project.

## Checkpoint Verification at Every Stage

The biggest risk in project bootstrapping is **the project silently going off track.** Verification prompts at each stage prevent this.

**Stage 1: Structure verification** (after first commit)

> "Review the project structure you just created:
> 1. Build viability: do `pip install -e .` and `npm install` actually work?
> 2. Circular dependencies: any cycles between Python and Node.js?
> 3. Path issues: are relative/absolute paths correctly set?
> 4. Missing files: are `.gitignore`, `pyproject.toml`, `package.json` complete?"

**Stage 2: End-to-end test with sample data** (after second commit)

> "Create sample saju data and test the full pipeline from CLI to renderer.
>
> Test: `shortsmaker create-job input/profiles/sample_saju.json output/`
>
> Verify: JSON schema validation, file I/O error handling, TypeScript type compatibility, render parameter passing."

The pattern: **make the AI verify its own work.** Not just generate code, but take responsibility for whether that code runs.

## Context Management in Multi-Stack Projects

The hardest part of a Python + Node.js project is **the AI losing context** when switching between languages. Two patterns kept gpt-5-codex on track:

**Share type definitions first.** Type mismatches between Python and TypeScript are the number one failure mode. Define `types.ts` and `models.py` first, then reference them in every subsequent prompt:

> "Work from these type definitions:
>
> Python model (`src/shortsmaker/models.py`): [Pydantic model code]
> TypeScript type (`renderer/src/types.ts`): [interface code]
>
> Now write the CLI command handling logic. Type safety is required."

**State file dependencies explicitly.** In complex projects, the AI misses inter-file dependencies. Include a dependency diagram with each task:

> "Maintain this dependency structure:
> ```
> cli.py → job.py → config.py
>    ↓
> render-job.ts → ShortsComposition.tsx → types.ts
> ```
>
> job.py serializes Python data to JSON. render-job.ts reads JSON and passes it as React props. ShortsComposition.tsx handles video rendering."

## Pre-Emptive Trap Avoidance

Certain failures repeat across every multi-stack project. Blocking them in the prompt is more efficient than debugging them later.

**Path issues:**

> "The CLI calls a Node.js renderer script.
>
> Must: work regardless of current working directory, work after `pip install -e .`, be compatible with Windows/macOS/Linux.
>
> Must not: use hardcoded absolute paths, depend on `../` relative paths, use `os.system()` for command execution."

**Dependency version conflicts:**

> "In `package.json`: pin major versions, allow minor/patch updates (`^`). Lock exact versions for packages with peer dependency conflicts. Sync `@remotion/cli` and `remotion` versions. Unify all React packages on React 18."

These constraints are predictable. Stating them upfront saves a debugging round every time.

## Commit Strategy as a Verification Tool

I used Claude Code's `/commit` command not just for commit messages, but as a tool to define **logical work units:**

```bash
git add pyproject.toml README.md ARCHITECTURE.md
/commit  # → "bootstrap project workspace"

git add src/shortsmaker/ renderer/package.json
/commit  # → "build saju shorts pipeline"

git add tests/ input/profiles/
/commit  # → "log sample short validation"
```

Each commit is an independently verifiable unit. The `/review` command before large commits catches type safety issues, performance concerns, and cross-file inconsistencies.

## What Could Be Better

**MCP servers for automated validation.** Combining `filesystem` and `git` MCP servers would enable automatic dependency verification on file changes, pre-commit test execution, and type compatibility checks — all without manual prompting.

**Incremental generation over bulk generation.** This project generated large chunks at once. A stage-by-stage approach with human review at each checkpoint produces higher final quality: architecture → review → core models → review → CLI → test → renderer → test → integration.

**Template systems for reuse.** If you build similar projects often, creating a Cookiecutter or Yeoman template from the generated structure makes the pattern reusable across domains.

## Takeaways

- Design the full architecture first, write code second — documents give the AI a coherent reference frame
- Set verification checkpoints at every stage — make the AI validate its own output
- Manage types and dependencies explicitly — in multi-stack projects, context management determines success
- Pre-empt predictable failures in the prompt — path issues, version conflicts, and platform compatibility are always the same problems

<details>
<summary>Commit log</summary>

65f233a — gpt-5-codex: bootstrap project workspace
07e6f61 — gpt-5-codex: build saju shorts pipeline
d6e1582 — gpt-5-codex: fix repo-relative cli paths
6cc0e4f — gpt-5-codex: log sample short validation

</details>
