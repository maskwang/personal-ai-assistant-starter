#!/usr/bin/env bash
# 生成并加载 macOS LaunchAgent：每分钟调用 dispatch.sh（由它自己判断时间点）。
# 用法：./scripts/install-launchd.sh [label]
#   默认 label: com.example.assistant.notify —— 建议换成你自己的反域名，例如 com.你的名字.assistant.notify

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="${1:-com.example.assistant.notify}"
TARGET="$HOME/Library/LaunchAgents/$LABEL.plist"

mkdir -p "$HOME/Library/LaunchAgents"

cat > "$TARGET" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$ROOT/scripts/dispatch.sh</string>
    </array>
    <!-- 每分钟唤醒一次，具体是否推送由 dispatch.sh 判断 -->
    <key>StartInterval</key>
    <integer>60</integer>
    <key>StandardOutPath</key>
    <string>$ROOT/scripts/launchd.log</string>
    <key>StandardErrorPath</key>
    <string>$ROOT/scripts/launchd.err</string>
</dict>
</plist>
PLIST

launchctl unload "$TARGET" 2>/dev/null || true
launchctl load "$TARGET"

echo "已安装并加载：$TARGET"
echo "自测：  $ROOT/scripts/notify.sh test"
echo "卸载：  launchctl unload $TARGET && rm $TARGET"
