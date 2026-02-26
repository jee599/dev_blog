#!/usr/bin/env bash
set -euo pipefail

DEV_BLOG_ROOT="/Users/jidong/dev_blog"
HOOK_SCRIPT="$DEV_BLOG_ROOT/tools/worklog_on_commit.sh"

if [[ ! -x "$HOOK_SCRIPT" ]]; then
  chmod +x "$HOOK_SCRIPT" || true
fi

install_hook() {
  local repo="$1"
  local hook_dir="$repo/.git/hooks"
  local hook_file="$hook_dir/post-commit"

  if [[ ! -d "$hook_dir" ]]; then
    echo "SKIP: not a git repo: $repo" >&2
    return 0
  fi

  mkdir -p "$hook_dir"

  if [[ -f "$hook_file" ]]; then
    # Backup once
    if [[ ! -f "$hook_file.bak" ]]; then
      cp "$hook_file" "$hook_file.bak"
      echo "Backed up existing post-commit hook: $hook_file.bak"
    fi
  fi

  cat > "$hook_file" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

# Auto-generate a centralized worklog entry in dev_blog on every commit.
/Users/jidong/dev_blog/tools/worklog_on_commit.sh || true
SH

  chmod +x "$hook_file"
  echo "Installed post-commit hook in: $repo"
}

# Default repos
install_hook "/Users/jidong/saju_global"
install_hook "/Users/jidong/projects/coffeechat"
install_hook "/Users/jidong/xrp-trading-bot"
install_hook "/Users/jidong/dev_blog"

echo "Done. New worklogs will appear in: $DEV_BLOG_ROOT/logs/YYYY-MM-DD/"
