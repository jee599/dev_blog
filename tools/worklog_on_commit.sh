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

# Project-specific default tags (max 4, lowercase)
tags="ai, webdev, productivity, buildinpublic"
case "$project" in
  saju)
    tags="ai, llm, webdev, saju"
    ;;
  coffeechat)
    tags="webdev, nextjs, supabase, saas"
    ;;
  tradingbot)
    tags="ai, trading, python, automation"
    ;;
  dev_blog)
    tags="ai, webdev, productivity, buildinpublic"
    ;;
  *)
    tags="ai, webdev, productivity, buildinpublic"
    ;;
esac

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
---
title: "[${project}] ${subject}"
published: false
description: "${project} 작업 로그. 커밋 ${sha}."
tags: ${tags}
---

${subject}

이 커밋은 기록용이다.

---

이유는 이거다.

(여기에 배경을 짧게 쓴다. 길어지면 문단을 나눈다.)

---

바뀐 파일은 이렇다.

    $(printf "%s\n" "$name_status" | head -n 200 | sed 's/^/ /')

---

검증은 이렇게 했다.

    (여기에 실제로 돌린 커맨드를 붙인다)

PASS/FAIL을 한 줄로 적는다.

---

메모.

(의도, 리스크, 롤백, 다음 작업을 짧게)

---

Refs.

commit ${sha}
branch ${branch}
remote ${remote}

> "Ship small. Log everything."
MD

# Also append one-line pointer to dev_blog/publish-log.txt for visibility (optional)
# echo "${date} ${project} ${sha} ${subject}" >> "$DEV_BLOG_ROOT/publish-log.txt"

exit 0
