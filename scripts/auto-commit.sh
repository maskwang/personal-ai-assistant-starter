#!/usr/bin/env bash
# 每日自动快照：vault 有变更就提交一次，配了远端就顺手推送。
# 适合放在 cron / LaunchAgent 里每天跑一次（例如 23:50），保证知识库永远有版本可回滚。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG="$ROOT/scripts/auto-commit.log"

if [[ -f "$ROOT/scripts/config.env" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT/scripts/config.env"
fi
VAULT_ROOT="${VAULT_ROOT:-$ROOT/vault}"

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/homebrew/bin:$PATH"

cd "$VAULT_ROOT" || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# 没有变更就安静退出，不制造空提交
if [[ -z "$(git status --porcelain)" ]]; then
  exit 0
fi

git add -A
git commit -q -m "chore(auto): 每日快照 $(date +%F)"
echo "$(date '+%F %T') committed" >> "$LOG"

# 有远端才推送；凭据不可用时保留本地提交并记一行日志，不阻塞
if git remote get-url origin >/dev/null 2>&1; then
  BRANCH="${GIT_BRANCH:-$(git branch --show-current)}"
  if git push origin "$BRANCH" >>"$LOG" 2>&1; then
    echo "$(date '+%F %T') pushed to $BRANCH" >> "$LOG"
  else
    echo "$(date '+%F %T') push failed (credentials?), commit kept locally" >> "$LOG"
  fi
fi
