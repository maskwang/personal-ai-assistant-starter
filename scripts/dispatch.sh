#!/usr/bin/env bash
# 定时分发：由 LaunchAgent / cron 每分钟调用一次，命中时间点才推送。
# 想改提醒时间 → 改下面的 case；想改文案 → 改 notify.sh。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 只在工作日推送（1=周一 … 7=周日）。想一周七天都推送就删掉这段。
DAY_OF_WEEK="$(date +%u)"
if [[ "$DAY_OF_WEEK" -ge 6 ]]; then
  exit 0
fi

NOW="$(date +%H%M)"

case "$NOW" in
  "0700" | "0701") "$ROOT/scripts/notify.sh" morning ;;
  "0800" | "0801") "$ROOT/scripts/notify.sh" commute_am ;;
  "1900" | "1901") "$ROOT/scripts/notify.sh" commute_pm ;;
  "2120" | "2121") "$ROOT/scripts/notify.sh" wind_down ;;
  "2145" | "2146") "$ROOT/scripts/notify.sh" sleep ;;
  *) : ;; # 非目标时间点，静默
esac
