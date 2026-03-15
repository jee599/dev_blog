---
title: "5,800 Lines in One Day: Bootstrapping a Full Pipeline With gpt-5-codex"
published: true
description: "From zero to a working saju-to-video pipeline in 4 commits. Constraint-driven prompts, multilingual domain handling, and the scaffolding pattern that scales."
tags:
  - ai
  - gpt5
  - python
  - react
---

The hardest part of a new project is "where do I start." I started by handing the entire scaffolding job to gpt-5-codex. ShortsMaker — a tool that takes saju (Korean astrology) data and produces short-form video — went from zero to 5,800 lines across 4 commits in a single day.

## Scaffold Everything in One Shot

Do not create files one by one. Generate the entire skeleton at once.

The prompt:

> "Bootstrap a Python project that generates short-form video from saju data.
>
> 1. CLI: `shortsmaker create profile.json` produces an MP4
> 2. Architecture: Python backend + React/Remotion renderer
> 3. pyproject.toml, src layout
> 4. Hooks system for extensibility
> 5. Multilingual support (Korean, English, Japanese, Chinese)
>
> Include directory structure, core modules, config files, and sample data. The result must be immediately runnable."

The failing version: "Make me a Python project."

The difference: a specific invocation example (`shortsmaker create profile.json`), named tech stack, architecture pattern (hooks, src layout), and a completion criterion ("immediately runnable").

## Constraints Determine Code Quality

Giving gpt-5-codex too much freedom produces inconsistent code. `CLAUDE.md` locked down the standards:

```markdown
## Project Standards
- Python 3.11+, type hints required
- src layout structure
- CLI: typer
- Models: pydantic
- Hooks: pluggy pattern
- Tests: pytest

## Code Style
- Functions: snake_case
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE
- Docstrings: Google style
```

With these constraints, even the 256-line `hooks.py` pluggy system followed a consistent pattern.

## Multilingual Domain Handling

The hardest part was not code generation — it was multilingual saju terminology. Saju terms have culture-specific translations that go beyond dictionary lookup.

The prompt:

> "Create a `languages.py` module mapping saju terminology across 4 languages.
>
> Terms: heavenly stems, earthly branches, five elements, ten gods
> - Korean: include hanja (甲子)
> - English: meaning-based translation (Wood Rat)
> - Japanese: on'yomi preferred (きのえね)
> - Chinese: traditional characters (甲子)
>
> Also provide short-form expressions suitable for video overlays. Example: '대운' → 'Major Luck Cycle' → 'Life Phase'"

Saju (사주) is a Korean astrology system based on the Four Pillars of Destiny — the year, month, day, and hour of birth, each represented by a pair of heavenly stem and earthly branch characters. The result was a 223-line module with full terminology mapping and short-form variants.

## Type Safety Across Languages

Language code typos are the most common bug in multilingual projects. The fix:

```python
from enum import Enum
from typing import Literal

class Language(str, Enum):
    KOREAN = "ko"
    ENGLISH = "en"
    JAPANESE = "ja"
    CHINESE = "zh"

SupportedLanguage = Literal["ko", "en", "ja", "zh"]
```

The instruction: "Use both enum and literal type to ensure type safety and runtime validation simultaneously." This gives IDE autocomplete and runtime error on invalid language codes.

## React + Remotion: Structure Before Code

Generating frontend code with AI is tricky. Remotion is a niche library that most models know partially. The approach: define component structure first, generate code second.

> "Design a React component tree for saju Shorts using Remotion.
>
> 1. 9:16 vertical, 15 seconds
> 2. Intro (3s) → Main (9s) → Outro (3s)
> 3. Saju data via props
> 4. Spring-based animations
> 5. Noto Sans CJK font
>
> Show the component tree first, then write the code."

The AI proposed:

```
ShortsComposition
├── IntroScene (0-45f)
├── MainScene (45-225f)
│   ├── ProfileCard
│   ├── FortuneText
│   └── AnimatedBackground
└── OutroScene (225-270f)
```

After confirming the structure, "now write the code for this structure" produced a 194-line component that matched the spec.

## CLI Error Handling

Happy-path-only CLI code breaks on first real use. The prompt included failure scenarios:

> "Build a typer CLI supporting: create, validate, render.
>
> Error scenarios:
> - File not found
> - JSON parse failure
> - Required field missing
> - Renderer execution failure
>
> Each error: user-friendly message with suggested fix."

The result: when a profile file is missing, the CLI says "profile.json not found. Run `shortsmaker init` to generate a sample file." Not a stack trace.

Pipeline verification test:

```python
def test_create_command_with_valid_profile():
    result = runner.invoke(app, ["create", "input/profiles/sample_saju.json"])
    assert result.exit_code == 0
```

25 lines of test code that validate the entire pipeline is connected.

## What Could Be Better

**MCP servers for cross-file awareness.** Currently each file was generated individually. An MCP `filesystem` server would let the AI track import paths and type definitions automatically, reducing inconsistencies.

**Incremental generation beats bulk generation.** Generating everything at once works but produces more bugs than a step-by-step approach with verification at each stage. The ideal flow: architecture → verify → models → verify → CLI → test → renderer → test.

**Project templates for reuse.** If you bootstrap similar projects often, turning the generated structure into a Cookiecutter template makes the pattern reusable.

## Takeaways

- Project bootstrapping is most efficient when you specify constraints clearly and generate the full scaffold in one pass
- Multilingual domain handling requires cultural context and type safety in parallel
- For React + backend integration, define interfaces first and generate components second
- CLI pipelines need error handling and validation logic baked into the prompt, not added afterward

<details>
<summary>Commit log</summary>

65f233a — gpt-5-codex: bootstrap project workspace
07e6f61 — gpt-5-codex: build saju shorts pipeline
d6e1582 — gpt-5-codex: fix repo-relative cli paths
6cc0e4f — gpt-5-codex: log sample short validation

</details>
