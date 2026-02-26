#!/usr/bin/env bash
set -euo pipefail

# Centralized commit worklog generator.
# Intended to be called from a repo's .git/hooks/post-commit.
# It writes a new markdown file under dev_blog/logs/YYYY-MM-DD/.

DEV_BLOG_ROOT="/Users/jidong/dev_blog"
LOG_ROOT="$DEV_BLOG_ROOT/logs"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${repo_root}" ]]; then
  exit 0
fi

# Avoid logging commits made inside dev_blog itself unless explicitly enabled.
if [[ "$repo_root" == "$DEV_BLOG_ROOT" ]]; then
  # Allow dev_blog commits to be logged too (set to true if you want)
  :
fi

# Map repo root -> project slug (override via env WORKLOG_PROJECT)
project="${WORKLOG_PROJECT:-}"
if [[ -z "${project}" ]]; then
  case "$repo_root" in
    "/Users/jidong/saju_global") project="saju";;
    "/Users/jidong/projects/coffeechat") project="coffeechat";;
    "/Users/jidong/xrp-trading-bot") project="tradingbot";;
    "/Users/jidong/dev_blog") project="dev_blog";;
    *) project="$(basename "$repo_root")";;
  esac
fi

# Gather commit metadata
sha="$(git rev-parse --short HEAD)"
subject="$(git log -1 --pretty=%s)"
date="$(date +%F)"
time="$(date +%H:%M:%S)"
branch="$(git branch --show-current 2>/dev/null || true)"
remote="$(git remote get-url origin 2>/dev/null || echo "")"

# Create destination
out_dir="$LOG_ROOT/$date"
mkdir -p "$out_dir"
out_file="$out_dir/${project}-${sha}.md"

# Prevent overwrite
if [[ -f "$out_file" ]]; then
  exit 0
fi

# Changed files summary (compact)
name_status="$(git show --name-status --pretty="" -1 | sed '/^$/d' | head -n 200)"

# Diffstat (compact)
diffstat="$(git show --stat --pretty="" -1 | sed '/^$/d' | tail -n 5)"

cat > "$out_file" <<MD
# [${project}] worklog — ${date} ${time}

${subject}

---

## Context

(why this commit happened)

## What changed

$(printf "%s\n" "$name_status" | sed 's/^/""/g' | sed 's/^""//')

## QA / Gate

(paste the exact commands you ran and PASS/FAIL)

## Links

- Commit: ${sha}
- Branch: ${branch}
- Remote: ${remote}

---

> "Ship small. Log everything."
MD

# Also append one-line pointer to dev_blog/publish-log.txt for visibility (optional)
# echo "${date} ${project} ${sha} ${subject}" >> "$DEV_BLOG_ROOT/publish-log.txt"

exit 0
