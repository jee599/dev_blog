---
title: "One Script, Two Languages: Building a Bilingual AI News Pipeline"
published: true
description: "A single bash script generates English and Korean AI news, handles Cloudflare edge cases, and publishes to DEV.to — with 90% less code duplication."
tags:
  - ai
  - automation
  - productivity
  - devops
id: 3353615
date: '2026-03-15T07:10:12Z'
---

I added an AI news section to my portfolio site and needed both English and Korean versions published simultaneously — English for the main site, Korean for DEV.to cross-posting. Building separate scripts per language was the obvious approach. It was also the wrong one.

## The Problem With Separate Scripts

Two scripts meant duplicated API call logic, duplicated error handling, duplicated file creation. The only differences were the output collection name and the language in the prompt. So I asked the AI:

> "Build a single bash script that takes a language parameter and generates news in either English or Korean. Share the API call logic; only differentiate frontmatter and filenames."

The result: `generate-ai-news.sh` with `$1` as the language flag.

```bash
./scripts/generate-ai-news.sh en
./scripts/generate-ai-news.sh ko
```

The branching logic inside the script was minimal:

```bash
if [ "$LANGUAGE" = "ko" ]; then
  COLLECTION="ai-news-ko"
else
  COLLECTION="ai-news"
fi
```

API calls, error handling, and file generation logic stayed shared. Code duplication dropped by 90%.

## Language Must Be the First Word in the Prompt

When calling the AI API, ambiguity about language produces mixed-language output. The fix is trivial but easy to forget:

Bad: "AI 뉴스 4건 만들어줘" (language implied but not stated)

Good: "Generate 4 AI news articles in English. Use professional tech journalism tone. Each article should be 150-200 words with clear headlines."

State the language in the first sentence. Every time.

## Cloudflare Broke Everything

The API endpoint worked locally but failed on Cloudflare Pages:

```
Error: Cannot resolve "node:fs"
```

The `generate-ai-news.ts` file imported `node:fs`, which Cloudflare Workers does not support. I fed Claude the error log:

> "Cloudflare Pages throws `node:fs` import error. This API receives news JSON and creates markdown files. What are the alternatives for file creation in a Cloudflare environment?"

Claude's recommendation: remove the API entirely. For a static site, generate files at build time via shell script, not at runtime via a serverless function. The Node.js API became a direct `curl` call to OpenAI in bash.

**Before (Node.js API):**
```typescript
import fs from 'node:fs';
fs.writeFileSync(filepath, content);
```

**After (Bash):**
```bash
echo "$content" > "src/content/ai-news/$filename"
```

Simpler, no Cloudflare compatibility issues.

## GitHub Actions: 53 Lines Deleted

The DEV.to publish workflow was trying to publish every blog post. Only AI news needed cross-posting. The fix was targeting the `ai-news` directory:

```yaml
- name: Publish AI news only
  run: |
    find src/content/ai-news -name "*.md" | head -10 | while read file; do
      # DEV.to API call
    done
```

Unnecessary filtering logic — gone. The workflow trigger also got a `paths` filter so it only runs when news files change.

## Skills for Consistent Tone

Claude Code's skills system solved the tone inconsistency problem. Before applying the `blog-writing` skill, headlines varied wildly:

**Before:** "AI Chatbot Regulation Passes! Surprising Changes?"
**After:** "AI chatbot safety legislation passes committee review"

The skill definition in `CLAUDE.md`:

```markdown
### blog-writing
- Tech journalism tone
- Fact-based headlines (no clickbait)
- 150-200 words per article
- Structure: headline → summary → key points → impact
```

Referencing the skill in the API prompt:

> "Use blog-writing skill to generate 4 AI news articles. Apply consistent tech journalism tone across all articles."

Every article came out in the same register.

## Error Handling at the Script Level

Three failure modes kept recurring:

**Duplicate files.** The AI occasionally generated two articles about the same story from different angles. Fix: keyword-based dedup before file creation.

```bash
if ls src/content/ai-news/*anthropic* 1> /dev/null 2>&1; then
  echo "Anthropic article already exists. Skipping."
  exit 0
fi
```

**Bad filenames.** Special characters and spaces in AI-generated filenames. Fix: sanitize at creation time.

```bash
filename=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]/-/g' | sed 's/--*/-/g')
```

**Empty files.** API failures sometimes produced zero-byte files. Fix: size check before commit.

```bash
if [ ! -s "$filepath" ]; then
  rm "$filepath"
  exit 1
fi
```

## What Could Be Better

**RSS-driven topic selection** instead of manual input. Parsing AI news feeds with `rss-parser` would make the pipeline fully autonomous.

**A separate "editor" agent** for fact-checking and grammar review before publication. Claude Code's agent mode could split this into a writer agent and an editor agent.

**OpenAI's batch API** for parallel generation. Currently the 4 articles are generated sequentially. Batch processing would cut wall time by 75% and API cost by 50%.

## Takeaways

- A single parameterized script beats language-specific scripts — 90% less duplication
- Cloudflare Workers cannot use Node.js built-in modules; shell scripts are the simpler path for static site generation
- Claude's skill system maintains consistent tone across articles
- Script-level error handling (dedup, filename sanitization, empty file checks) eliminates most manual intervention

<details>
<summary>Commit log</summary>

641d577 — fix: remove node:fs import from generate-ai-news API (Cloudflare build error)
c4b0055 — feat: apply blog-writing skill to AI news script
358bf9c — fix: DEV.to workflow publish ai-news only + remove chatbot regulation news
e615288 — feat: AI news script — English (jidonglab) + Korean (DEV.to) dual generation
a00b3bf — feat: AI news 2026-03-14 (4 posts, en)
069ca0d — feat: AI news CLI generation script + 2026-03-14 4 news items
6788360 — feat: AI news auto-generation (2026-03-14)

</details>
