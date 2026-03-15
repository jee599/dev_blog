---
title: "Claude-Powered News Pipeline: From API Call to Production Markdown in One Script"
published: true
description: "A shell script that calls Claude API, generates structured news with validation, handles bilingual output, and commits production-ready markdown — no manual editing."
tags:
  - ai
  - automation
  - claude
  - productivity
id: 3353616
date: '2026-03-15T07:10:47Z'
hashnode_url: 'https://plzai.hashnode.dev/ai-news-claude-automation'
---

Running an AI news site means generating content every single day. I automated the entire workflow: one command produces 4 validated, formatted, publication-ready markdown files. Claude API + shell script + MCP file access + git hooks. Here is how each piece fits together.

## The One-Command Target

The goal was simple: type `"generate 4 AI news for 2026-03-14"` and get finished markdown files committed to the repo. Not ChatGPT-quality drafts that need editing — production-ready content with correct frontmatter, validated structure, and consistent tone.

## Structured News Generation Prompts

The prompt that produces publishable content:

> "Write 4 AI news articles in Korean for 2026-03-14. Each article:
> 1. Title: 40-60 characters, keyword-rich, no clickbait
> 2. Body: 3-4 paragraphs, lead with the key fact, close with outlook
> 3. Tags: ['AI', 'News'] required + 2-3 company/tech names
> 4. Filename: date-keyword-2-3-words.md format
>
> Do not cover: rumors, speculation, stock-related content
> Focus on: technical advances, policy changes, product launches, research results"

I chose Claude over GPT-4 and Gemini for this task because of its stronger instruction following on long, structured output. When the prompt says "3-4 paragraphs" and "40-60 characters," Claude delivers within bounds more reliably.

The failing prompt: "Write some AI news." No length constraint, no structure, no source filtering. Every run produces different quality.

## The Shell Script Pipeline

`generate-ai-news.sh` is not just an API wrapper. It orchestrates the full content pipeline:

```bash
#!/bin/bash
DATE=${1:-$(date +%Y-%m-%d)}
COUNT=${2:-4}
LANG=${3:-ko}

response=$(curl -s -X POST https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  --data "{
    \"model\": \"claude-3-sonnet-20240229\",
    \"max_tokens\": 4000,
    \"messages\": [{\"role\": \"user\", \"content\": \"$PROMPT\"}]
  }")

echo "$response" | jq -r '.content[0].text' | split_and_save_files "$DATE"
```

The `split_and_save_files` function parses Claude's response (4 articles in one response), extracts keywords for filenames, and saves each article as a separate file.

## Bilingual Generation in a Single API Call

Instead of two separate API calls for English and Korean, I bundled both in one request:

> "Write 4 news articles. For each, provide both Korean and English versions. Do not translate — write each version for its target audience with appropriate tone and examples.
>
> Output format:
> ## News 1 (Korean)
> [content]
>
> ## News 1 (English)
> [content]"

One API call, two languages, consistent pairing. Translation quality is significantly better than running separate calls because Claude maintains context across both versions.

## MCP for Direct File System Access

Claude Code's MCP (Model Context Protocol) enabled direct file system access, eliminating the copy-paste workflow:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": {
        "ALLOWED_DIRECTORIES": ["/Users/jidong/projects/jidonglab.com/src/content"]
      }
    }
  }
}
```

With MCP, Claude reads existing articles (for dedup checking), writes new files directly, and updates metadata across 20+ posts in a single batch operation. For the batch metadata update:

> "In `src/content/blog/`, across all .md files: rename `publishedDate` to `publishDate`, deduplicate `tags` arrays, truncate `description` to 150 characters. Show the change plan before applying."

The "show before applying" clause lets me review 20 file changes at once instead of editing one by one.

## Content Quality Validation

AI-generated content has inconsistent quality. Three validation strategies brought it under control:

**Self-check in the prompt:**

> "After writing each article, verify: does the title match the content? Does the lead paragraph contain the key fact? Are sources and dates accurate? Are technical terms explained? Revise if any check fails."

**Template enforcement:**

```markdown
---
title: "Title (40-60 chars)"
description: "Summary (100-150 chars)"
publishDate: "YYYY-MM-DD"
tags: ["AI", "News", "keyword1", "keyword2"]
---

## Key Summary (2-3 sentences)
## Main Content (bullet points with specifics)
## Industry Impact
## Related Links
```

Forcing a template reduces omissions. It also makes later human editing faster because the structure is predictable.

**Context-based deduplication:**

> "Recent topics covered: Anthropic Claude, NVIDIA H100, OpenAI GPT-5, Google Gemini... Write new stories that do not overlap with these topics."

Cannot fit full articles in context, but keywords and summaries are enough to prevent duplicates.

## Git Hooks for Automated Commit

The script does not stop at file creation. It commits and optionally deploys:

```bash
git add src/content/ai-news/
git commit -m "feat: AI news $DATE ($COUNT posts, $LANG)"

if [[ "$DEPLOY" == "true" ]]; then
  npm run build && npm run deploy
fi
```

A pre-commit hook runs markdown lint on generated content. AI-authored content meets the same quality bar as human-authored content.

## What Could Be Better

**RSS feed monitoring** for autonomous topic selection. Currently I specify "generate 4 news items" manually. Parsing RSS feeds from major tech outlets would make the system fully autonomous.

**Vector DB deduplication.** Keyword matching misses semantic duplicates. Embedding articles and computing cosine similarity against the existing corpus would catch stories that use different words for the same event.

**Claude tool use for live fact-checking.** Instead of post-generation validation, tool use functions could verify company data and source URLs during generation.

**Analytics feedback loop.** Feeding Google Analytics data (page views, time on page, shares) back to Claude as context would let the system learn which article styles perform best.

## Takeaways

- Specific constraints in prompts (character count, structure, source filtering) produce consistent quality
- MCP file system access lets Claude manage content directly — no copy-paste intermediary
- Template-based structure is more reliable than free-form generation for daily content
- Automating the full workflow (generation → validation → commit → deploy) eliminates the human bottleneck

<details>
<summary>Commit log</summary>

a00b3bf — feat: AI news 2026-03-14 (4 posts, en)
069ca0d — feat: AI news CLI generation script + 2026-03-14 4 news items
6788360 — feat: AI news auto-generation (2026-03-14)

</details>
