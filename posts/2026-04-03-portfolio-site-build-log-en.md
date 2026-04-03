---
title: "8 Hours Chasing the Wrong Bug: How Claude Code Found a SyntaxError in 3 Minutes"
published: true
description: "Spent 8 hours hunting a missing DEV.to API key. The real bug was a duplicate const declaration in GitHub Actions. Claude Code fixed it in 3 minutes."
tags: claudecode, githubactions, automation, debugging
series: "Building with Claude Code: portfolio-site"
canonical_url: https://jidonglab.com/posts/2026-04-03-portfolio-site-en
---

I spent 8 hours looking for an API key that was never missing.

**TL;DR** DEV.to auto-publishing was failing because of a `SyntaxError` — a duplicate `const lang` declaration inside a GitHub Actions workflow. The API key was in GitHub Secrets all along. 8 hours on the wrong trail, 3 minutes to fix the actual bug with Claude Code.

## The Wrong Starting Point

The prompt seemed straightforward enough.

```
Publish the two posts in blog-factory/devto/ to DEV.to via API.
Look for the API key in env vars or config files. Report back if you can't find it.
```

Claude fanned out 4 parallel tasks immediately: search for scripts referencing DEV.to, search for env files, search for JSON files with DEV.to references, search for publishing scripts. 28 Bash calls, 2 Reads, 1 Glob. The places it checked:

- `~/.devto`, `~/.config/devto` — not found
- `~/.env.local` — only `ANTHROPIC_API_KEY`
- `.env*` files in the project — not found
- macOS Keychain — not found
- Environment variables — not found

`DEVTO_API_KEY` existed in GitHub Secrets. But GitHub Secrets are write-only — you can't read the value back via CLI. Claude kept arriving at the same conclusion: "paste the API key and I'll publish immediately."

That same session burned 31 tool calls reaching the same dead end. A duplicate session reached the exact same conclusion.

The problem wasn't that the key was missing. The problem was that Claude was looking in all the wrong places, and I kept asking it to look harder.

## The Question That Changed Everything

Instead of continuing to hunt for the key, I changed the frame entirely.

```
Check the .github/workflows/publish-to-devto.yml workflow.
Figure out when it triggers.
If the files aren't on main, merge or push them directly.
```

The moment Claude read the workflow file, it found the bug.

```javascript
// Inside the workflow — same scope, declared twice
const lang = file.match(/-ko\.md$/) ? 'ko' : 'en';
// ... some code in between ...
const lang = frontmatter.lang || effectiveLang; // SyntaxError!
```

`const lang` was declared twice in the same scope. Every single workflow run had been failing with a `SyntaxError` before it could even attempt to reach the publishing step. The API key was in GitHub Secrets the whole time — the workflow just never ran far enough to use it.

A second issue surfaced at the same time: the EN post files only existed in `blog-factory/devto/`, not in `src/content/blog/` where the workflow was scanning. Even after fixing the syntax error, the workflow wouldn't have found the files.

## The 3-Minute Fix

Two things to fix:

```
1. Remove the duplicate const lang declaration → rename to effectiveLang
2. Copy the 2 EN files into src/content/blog/ and push to main
```

1 Edit call, 14 Bash calls, 2 Reads. The actual code change was a single line.

```javascript
// Before
const lang = frontmatter.lang || effectiveLang;

// After
const effectiveLang = frontmatter.lang || detectedLang;
```

After the push, the workflow triggered automatically. The Claude Agent SDK post published successfully. The Harness CI/CD post hit a 429 rate limit on the first run, but a manual re-run published both posts without issue.

## One More Thing: Cleaning Up Dead Image URLs

Before the final push, there was a small cleanup task. The `blog-factory/devto/` files had `cover_image` fields pointing to R2 URLs and `![...]` hero image tags in the body — but those images didn't actually exist in R2 storage yet. Leaving them in would've resulted in broken images on DEV.to.

```
Remove cover_image R2 URLs (both files)
Remove body ![...] hero image tags + captions (both files)
```

2 Edit calls. Clean.

## Three Lessons From a Wasted Day

**Parallel search amplifies the wrong direction.** Claude's parallel execution is genuinely impressive — 4 tasks firing simultaneously, fast results. But if the premise is wrong, fast wrong answers are just faster waste. "The API key is missing" was never the real problem, so no amount of parallelism was going to fix it.

**The prompt's abstraction level changes what Claude looks at.** "Publish directly with the API key" kept Claude's attention on secrets and environment variables. "Figure out how the GitHub Actions workflow is supposed to work" immediately redirected attention to the actual execution path — and that's where the bug was hiding. Same request, different frame, completely different outcome.

**Claude spots duplicate declarations faster than humans do.** Reading `publish-to-devto.yml` as a single block, Claude immediately flagged the duplicate `const lang` across a 200-line file. A human skimming the same file — especially someone who didn't write it — would've needed multiple passes and probably still missed it the first time.

The session totals: Bash 45, Read 6, Edit 3, Glob 3. The vast majority of that was spent on the API key hunt that turned out to be irrelevant. The actual fix took a small fraction of those calls.

The debugging wasn't slow because Claude was inefficient. It was slow because I was asking the wrong question.

---

*More projects and build logs at [jidonglab.com](https://jidonglab.com)*
