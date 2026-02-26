# dev_blog

Automated publishing pipeline for DEV.to blog posts.

## How it works

1. **Write a post** — Add a markdown file to `posts/` with this frontmatter:

   ```yaml
   ---
   title: Your Post Title
   published: true
   description: A short summary
   tags:
     - tag1
     - tag2
   ---
   ```

2. **Push to `main`** — The GitHub Actions workflow (`.github/workflows/publish.yml`) runs automatically and publishes any post that doesn't yet have an `id:` field in its frontmatter.

3. **After publishing** — The workflow writes `id:` and `date:` into the post's frontmatter and commits the change. This prevents re-publishing on future runs.

## Publishing strategy

- **Draft-then-publish**: Articles are first created as drafts (`published: false`), then updated to `published: true`. This avoids 403 errors that some direct-publish calls trigger.
- **Duplicate detection**: Before creating a new article, the pipeline queries `/api/articles/me` and matches by title. If a duplicate exists on DEV.to, the existing `id` is written to the file without creating a new article.
- **Retry with backoff**: HTTP 403, 429, and 5xx responses are retried up to 4 times with exponential backoff + jitter (starting at 15 s).
- **Rate-limit awareness**: The pipeline waits 35 seconds between posts and logs `x-ratelimit-remaining`, `x-ratelimit-reset`, and `retry-after` headers on failures.

## Schedule

The workflow runs on:
- Every push to `main` that touches `posts/*.md` or the workflow file
- Manual trigger (`workflow_dispatch`)
- Every 6 hours (cron) to retry any remaining unpublished posts

## Recovering from failures

1. Check `publish-log.txt` for the error details (HTTP status, response body, rate-limit headers).
2. If a post was created as a draft but not published, its frontmatter will have `date: 'draft'`. The next run will detect it via the `id:` field and skip it. To retry publishing, remove the `id:` and `date:` lines and push.
3. If DEV.to already has the article (duplicate), the pipeline will detect it by title and write the existing `id` automatically.
4. To force a re-run: go to **Actions → Publish to DEV.to → Run workflow**.

## Setup

1. Go to your DEV.to **Settings → Extensions → API Keys** and generate a key.
2. In this repo, go to **Settings → Secrets → Actions** and add `DEVTO_TOKEN` with the API key.
3. Push a post to `posts/` — the workflow handles the rest.
