#!/usr/bin/env bash
# 一键安装：检查依赖 → 赋权 → 生成配置 → 初始化 Git。
# 幂等：重复执行不会覆盖你已填好的 config.env，也不会重复初始化仓库。

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

echo "==> 1/4 检查依赖"
MISSING=0
for cmd in git curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "  ✗ 缺少 $cmd"
    MISSING=1
  else
    echo "  ✓ $cmd"
  fi
done
command -v npx >/dev/null 2>&1 \
  && echo "  ✓ npx（可接入 MCP）" \
  || echo "  ! 未检测到 npx —— 接入 AI 助理前需安装 Node.js"
[[ "$MISSING" -eq 0 ]] || { echo "请先安装缺失依赖后重试。"; exit 1; }

echo "==> 2/4 赋可执行权限"
chmod +x "$ROOT"/scripts/*.sh "$ROOT/install.sh"
echo "  ✓ scripts/*.sh"

echo "==> 3/4 生成配置"
if [[ -f "$ROOT/scripts/config.env" ]]; then
  echo "  · scripts/config.env 已存在，保留不动"
else
  cp "$ROOT/scripts/config.env.example" "$ROOT/scripts/config.env"
  chmod 600 "$ROOT/scripts/config.env"
  echo "  ✓ 已生成 scripts/config.env（请填写钉钉 webhook）"
fi

# 把占位路径替换成真实的 vault 绝对路径
if grep -q '/ABSOLUTE/PATH/TO' "$ROOT/scripts/config.env" 2>/dev/null; then
  if sed --version >/dev/null 2>&1; then
    sed -i "s|/ABSOLUTE/PATH/TO/my-assistant/vault|$ROOT/vault|" "$ROOT/scripts/config.env"
  else
    sed -i '' "s|/ABSOLUTE/PATH/TO/my-assistant/vault|$ROOT/vault|" "$ROOT/scripts/config.env"
  fi
  echo "  ✓ VAULT_ROOT 已设为 $ROOT/vault"
fi

echo "==> 4/4 初始化 Git"
if [[ -d "$ROOT/.git" ]]; then
  echo "  · 已是 Git 仓库，跳过"
else
  git init -q
  git add -A
  git commit -q -m "chore: 从 personal-ai-assistant-starter 初始化"
  echo "  ✓ 已初始化并完成首次提交"
fi

cat <<NEXT

安装完成。接下来三步：

  1. 用 Obsidian 打开：  $ROOT/vault
  2. 改助理守则：        $ROOT/AGENTS.md（换成你的名字、作息、目录偏好）
  3. 接 AI 与提醒：
       - MCP 接入见   docs/02-接入-AI-助理.md
       - 定时提醒见   docs/03-定时提醒.md
       - 踩坑清单见   docs/99-常见坑.md

自测推送（填好 webhook 后）：  $ROOT/scripts/notify.sh test
NEXT
