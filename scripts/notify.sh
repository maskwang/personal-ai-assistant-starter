#!/usr/bin/env bash
# 钉钉推送：把「提醒内容」发到群机器人。
# 用法：./notify.sh morning | commute_am | commute_pm | wind_down | sleep | test | <自定义 key>
# 消息文案改下面的 case 分支即可 —— 这是你每天真正会看的内容，值得写得具体、可执行。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$ROOT/scripts/config.env"

if [[ ! -f "$CONFIG" ]]; then
  echo "缺少 $CONFIG，请先：cp scripts/config.env.example scripts/config.env 并填写。" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG"

MSG_KEY="${1:-default}"

case "$MSG_KEY" in
  morning)
    CONTENT="【${DINGTALK_KEYWORD}提醒 · 晨间唤醒】
1. 喝一杯温白开水；
2. 微运动：俯卧撑 15~20 个 + 卷腹 20 个（做完再洗漱）；
3. 顺手记一行今天的焦点任务。"
    ;;
  commute_am)
    CONTENT="【${DINGTALK_KEYWORD}提醒 · 早通勤】
1. 前 15 分钟闭目养神：耳机戴好，手机放回口袋；
2. 之后专注听一期播客，手机保持黑屏；
3. 到站前 5 分钟，想清楚今天最关键的一件事。"
    ;;
  commute_pm)
    CONTENT="【${DINGTALK_KEYWORD}提醒 · 晚通勤】
1. 前 20 分钟彻底断电：手机勿扰，闭目打盹；
2. 后半程只放轻音乐或漫谈，不看蓝光短视频；
3. 把状态平稳地带回家。"
    ;;
  wind_down)
    CONTENT="【${DINGTALK_KEYWORD}提醒 · 睡前静心】
1. 安静 15~20 分钟：练字 / 阅读 / 拉伸，任选其一；
2. 手机放在够不着的地方；
3. 给明天留一句交代，然后收工。"
    ;;
  sleep)
    CONTENT="【${DINGTALK_KEYWORD}提醒 · 准时就寝】
1. 洗漱完毕，手机开勿扰并远离床头；
2. 准时熄灯，锁定 8~9 小时睡眠。"
    ;;
  test)
    CONTENT="【${DINGTALK_KEYWORD}测试】钉钉定时提醒部署成功，工作日将按计划推送。"
    ;;
  *)
    CONTENT="【${DINGTALK_KEYWORD}提醒】按计划保持节奏。"
    ;;
esac

# 兜底：确保消息一定包含安全关键词，避免因关键词校验被拒收
if [[ "$CONTENT" != *"$DINGTALK_KEYWORD"* ]]; then
  CONTENT="${DINGTALK_KEYWORD}｜${CONTENT}"
fi

# 纯 bash 的 JSON 转义，避免依赖 jq / python
escape_json() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

PAYLOAD="{\"msgtype\":\"text\",\"text\":{\"content\":\"$(escape_json "$CONTENT")\"}}"

# launchd 不继承登录 shell 的 PATH，这里显式补上常见路径
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

RESP="$(curl -sS -X POST -H 'Content-Type: application/json' -d "$PAYLOAD" "$DINGTALK_WEBHOOK" || true)"
echo "$(date '+%F %T') [$MSG_KEY] $RESP" >> "$ROOT/scripts/notify.log"
