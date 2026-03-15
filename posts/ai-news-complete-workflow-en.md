---
title: "From Script to Deploy: A Complete AI News Generation Workflow"
published: true
description: "Built an end-to-end system where Claude writes, validates, and publishes bilingual AI news daily — with skill-based prompting and platform-specific formatting."
tags:
  - ai
  - automation
  - productivity
  - webdev
id: 3353617
date: '2026-03-15T07:11:23Z'
---

Getting AI to produce a single article is easy. Getting it to produce consistent, publication-ready content every day through an automated system is a different problem entirely. Here is the prompting and workflow design that makes daily AI news generation reliable.

## The Goal

`jidonglab.com` publishes daily AI industry news. The system needed to: find stories, write analysis, format for two platforms (English on the main site, Korean on DEV.to), and deploy — without manual intervention. "Set it and forget it" was the target.

## Teaching Claude a Writing Skill

The biggest quality lever was not the prompt itself but the `blog-writing` skill definition. Rather than asking for "news," I asked for analysis with insight.

```bash
SKILL_CONTEXT="Use blog-writing skill to produce AI industry analysis that reads like it was written by a domain expert"
```

Good prompt:
> "Use blog-writing skill to write AI industry news analysis. Include technical background, industry impact, and forward outlook. The audience is AI developers and tech founders."

Bad prompt:
> "Summarize this news"

The word "analysis" versus "summary" changes the output depth significantly.

## Tone Differentiation by Platform

Same story, different audience. The English version targets global readers who want concise, data-driven updates. The Korean version targets developers who want deeper context.

```bash
if [[ "$lang" == "en" ]]; then
    TONE="concise, fact-focused for global tech audience"
    TARGET_WORDS="300-400"
else
    TONE="detailed analysis with context for Korean developers"
    TARGET_WORDS="400-600"
fi
```

The reasoning: `jidonglab.com` readers want quick updates. DEV.to readers want understanding.

## Deduplication Strategy

AI occasionally generates the same story under slightly different headlines. File-based dedup catches this:

```plaintext
Deleted: 2026-03-14-ai-legislation-chatbot-safety.md
Kept:    2026-03-14-ai-chatbot-safety-legislation.md
```

The filename generation rule given to the AI:

> "Filename format: `YYYY-MM-DD-primary-keyword-secondary-keyword.md`. Primary keyword is company or technology name. Secondary keyword is the core topic. Example: `2026-03-14-anthropic-partner-network-100m.md`"

Script-level dedup before generation is cheaper than generating and discarding:

```bash
existing_files=$(ls src/content/ai-news/${DATE}-*.md 2>/dev/null || true)
if echo "$existing_files" | grep -q "$base_filename"; then
    echo "Similar news already exists: $base_filename"
    continue
fi
```

## GitHub Actions Optimization

The original DEV.to publish workflow was 53 lines of complex filtering logic. Only AI news needed automated cross-posting. The rewrite:

```yaml
- name: Publish AI news only
  run: |
    find src/content/ai-news -name "*.md" -newer .last-publish | \
    while read file; do
      publish_to_devto "$file"
    done
```

Blog posts get manual review before publishing. News gets published immediately. Different content types require different deployment strategies.

The `paths` trigger filter prevents unnecessary workflow runs:

```yaml
on:
  push:
    paths:
      - 'src/content/ai-news/**'
  schedule:
    - cron: '0 9 * * *'
```

## Localization, Not Translation

The multilingual prompt pattern uses different audience contexts, not just different languages:

**English version:**
> "Write an AI industry news analysis for global tech professionals. Focus on technical implications, market impact, competitive landscape. Style: Professional, data-driven, concise."

**Korean version:**
> "Write AI industry news analysis for Korean developers and tech founders. Include technical background, impact on the Korean market, practical application ideas. Style: friendly but professional, insight-driven."

The key difference: it is not "translate to Korean." It is "write for Korean developers" — different audience context, different emphasis, different examples.

Metadata also reflects this:

```markdown
# English
title: "Anthropic Partner Network Reaches 100M Users"

# Korean
title: "Anthropic Partner Network 1억 사용자 돌파 — 한국 AI 시장에 미치는 영향"
```

The English title states the fact. The Korean title adds "impact on the Korean AI market" because that is what the audience cares about.

## Claude Code vs Shell Scripts: When to Use Which

This project used shell scripts for the pipeline, not Claude Code's agent mode. The decision criteria:

**Claude Code for:** complex code generation, multi-file dependency analysis, code quality review.

**Shell scripts for:** repetitive content generation, API calls and filesystem operations, workflow automation.

AI news generation is simple logic that needs consistency and reliability. Shell scripts are the better fit:

```bash
for news_item in "${news_items[@]}"; do
    generate_content "$news_item" "$lang"
    validate_output "$output_file"
    if [[ $? -eq 0 ]]; then
        commit_and_push "$output_file"
    fi
done
```

## What Could Be Better

**RSS feed monitoring** instead of manual topic input. Parsing feeds from TechCrunch, The Verge, and Ars Technica would make topic selection autonomous.

**MCP server for news source aggregation.** Connecting NewsAPI, Reddit, and Hacker News through an MCP server would give Claude access to diverse sources without prompt engineering.

**Quality scoring before publish.** A second AI pass that rates each article on factual accuracy (0-10), reader usefulness (0-10), and grammar (0-10) — rejecting anything below threshold.

**OpenAI batch API** for parallel bilingual generation. Processing English and Korean simultaneously would halve total execution time.

## Takeaways

- Skill-based prompting produces more consistent content than ad-hoc "write news" prompts
- Multilingual content needs localized prompting, not translation — different audiences need different framing
- Deduplication and error handling in the automation layer are what make daily generation sustainable
- Claude Code vs shell scripting is a complexity/repeatability tradeoff — pick based on the task

Building a fully automated content system is not about asking AI to write. It is systems engineering: designing the workflow, applying the right tool at each stage, and building guardrails that catch failures before they reach production.

<details>
<summary>Commit log</summary>

c4b0055 — feat: apply blog-writing skill to AI news script
358bf9c — fix: DEV.to workflow publish ai-news only + remove chatbot regulation news
e615288 — feat: AI news script — English (jidonglab) + Korean (DEV.to) dual generation
a00b3bf — feat: AI news 2026-03-14 (4 posts, en)
069ca0d — feat: AI news CLI generation script + 2026-03-14 4 news items
6788360 — feat: AI news auto-generation (2026-03-14)

</details>
