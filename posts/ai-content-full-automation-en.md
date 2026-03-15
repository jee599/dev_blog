---
title: "Full Content Automation: One Script Generates, Formats, and Publishes in Two Languages"
published: true
description: "A shell script that calls Claude API, generates bilingual AI news, applies platform-specific frontmatter, and publishes to jidonglab.com and DEV.to simultaneously."
tags:
  - ai
  - automation
  - devops
  - productivity
id: 3353613
date: '2026-03-15T07:09:01Z'
---

Generating content with AI is table stakes. Generating it in two languages, formatting it for two platforms, and publishing it automatically — that is the system I built. One script execution produces 8 files (4 stories x 2 languages) and pushes them live.

## The Pipeline

`jidonglab.com` is a portfolio and tech blog. It publishes 4 AI news items daily, targeting both English and Korean readers. The old workflow was manual: pick stories, write them, format frontmatter, publish. The new workflow is a single command.

Core requirements:
- 4 AI news articles generated daily
- English and Korean versions simultaneously
- Platform-specific frontmatter and formatting for each language
- Claude API for high-quality content generation

## Prompt Engineering Drives Quality

The difference between usable and unusable AI-generated news is entirely in the prompt constraints.

The prompt that works:

> "Generate 4 AI news articles for 2026-03-14. Each article:
> - Title: SEO-optimized, under 50 characters, include primary keyword
> - Body: 300-500 words, technical accuracy first
> - Sources: trusted tech media only (TechCrunch, The Verge, Wired)
> - Tone: neutral, no exaggeration, fact-driven
> - Category: AI/ML, Robotics, or Enterprise AI
> - Frontmatter: title, date, category, tags"

The prompt that does not:

> "Write some AI news"

The working prompt specifies character counts, structure, source constraints, and output format. The failing prompt specifies nothing and produces inconsistent results every time.

## Tone Differentiation Is Not Translation

English and Korean versions need different tone because the audiences are different:

**English (jidonglab.com):**
> "Generate AI news in professional English tone. Target: tech professionals, startup founders. Style: concise, data-driven, business impact focused. Avoid hype and marketing speak. Include specific numbers and technical details."

**Korean (DEV.to):**
> "Generate AI news in Korean for the developer community. Tone: friendly but professional, informal speech. Style: practical perspective, developer-relevant content. Include tech stack details, open-source status, Korean market impact. Avoid translated-sounding Korean."

Same stories, different framing. The English version is 300-400 words and business-focused. The Korean version is 400-600 words with deeper technical context.

## Multi-File Generation With Context Coherence

The script generates 8 files per run. The generation order matters for Claude's context management:

```bash
# 1. Generate 4 English originals first
generate_english_news() {
  # Request all 4 from Claude in a single call
}

# 2. Localize each English article to Korean
translate_to_korean() {
  for file in $english_files; do
    # Not translation — localized rewriting
  done
}
```

English first, then Korean localization. This way Claude maintains full context while adapting tone and framing for each language.

## Agent Mode vs Script Mode

I used both Claude Code's agent mode and raw shell scripting. Each serves a different phase:

**Agent mode for prototyping:**
> "Build an AI news generation script. Requirements: Claude API calls for 4 articles, English/Korean simultaneous generation, auto-frontmatter, auto-filename from date and title."

Agent mode lets you refine requirements conversationally, modify multiple files simultaneously, and discover edge cases early.

**Shell scripts for production:** The actual daily pipeline is pure bash — `generate-ai-news.sh` with direct `curl` calls to Claude API. No interactive session needed. The script runs on a cron, commits results, and deploys.

## MCP for Real-Time Data

News quality improves with real-time source data. MCP (Model Context Protocol) servers feed Claude live information:

```json
{
  "servers": {
    "news-feeds": {
      "command": "node",
      "args": ["mcp-servers/news-rss.js"],
      "env": { "FEEDS": "techcrunch,theverge,wired,arstechnica" }
    }
  }
}
```

With MCP, Claude references current headlines instead of relying on training data. The generated content is more accurate and timely.

## CLAUDE.md for Quality Consistency

Daily content generation demands consistency. `CLAUDE.md` locks down the quality standard:

```markdown
## Content Standards
- Fact-check all claims with multiple sources
- Include specific numbers and dates
- Avoid speculation unless clearly marked

## English Version
- Professional, concise tone
- Business impact focus
- 300-500 words per article

## Korean Version
- Developer-friendly tone
- Use 반말 consistently
- Include technical implementation details
- 400-600 words per article

## File Naming
- Format: YYYY-MM-DD-{key-topic}-{company/tech}.md
- kebab-case, max 60 characters
```

With this in place, Claude produces consistent quality regardless of session.

## Platform-Specific Frontmatter

Same content, different metadata requirements:

**jidonglab.com (Astro):**
```yaml
title: "Nvidia Announces Rubin GPU Architecture at GTC 2026"
date: 2026-03-14
category: "ai-hardware"
tags: ["nvidia", "gpu", "gtc", "rubin"]
```

**DEV.to:**
```yaml
title: "Nvidia GTC 2026에서 Rubin GPU 아키텍처 공개"
published: true
tags: ai, gpu, nvidia, hardware
canonical_url: https://jidonglab.com/ai-news/2026-03-14-nvidia-gtc-rubin
series: "AI 뉴스"
```

A `convert_frontmatter()` function handles the transformation between formats. The GitHub Actions workflow runs the generation script, converts frontmatter, publishes to DEV.to, commits, and deploys — all on a daily cron.

## What Could Be Better

**Tool Use for real-time fact-checking.** Claude's tool use feature could verify company information, funding rounds, and source accuracy during generation rather than after.

**Vector DB for semantic deduplication.** Keyword-based dedup misses articles that use different words for the same story. Embedding-based cosine similarity would catch those.

**Two-stage generation for cost optimization.** Use Claude 3.5 Haiku for first drafts (cheap), then Claude 3.5 Sonnet for quality review (accurate). Daily generation adds up, and this pipeline cuts costs significantly.

## Takeaways

- Constraint-heavy prompts produce consistent quality; open-ended prompts produce variance
- MCP server integration gives Claude access to real-time data for more accurate content
- Template-based structure is more reliable than free-form generation
- Full automation means designing the entire workflow — generation, formatting, validation, deployment — not just the writing step

<details>
<summary>Commit log</summary>

e615288 — feat: AI news script — English (jidonglab) + Korean (DEV.to) dual generation
a00b3bf — feat: AI news 2026-03-14 (4 posts, en)
069ca0d — feat: AI news CLI generation script + 2026-03-14 4 news items
6788360 — feat: AI news auto-generation (2026-03-14)

</details>
