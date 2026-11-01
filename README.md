# 个人 AI 助理 · 起步套件（Starter Kit）

把「一个每天真的在用的个人知识库 + 会主动提醒你的 AI 助理」压成一套可以复制的骨架：Obsidian 目录体系、助理守则、钉钉定时提醒、自动版本管理。

> 来源：一个真实运行中的个人系统（PARA 目录 + MCP 接入 + 钉钉定时提醒 + 每天自动 git 提交）。所有个人数据已剥离，只留可复用骨架。

## 5 分钟上手

```bash
git clone <本仓库地址> my-assistant
cd my-assistant
./install.sh
```

装完做三件事：

1. 用 Obsidian 打开 `vault/` 目录（**Open folder as vault**）；
2. 改 `AGENTS.md`：把助理名字、你的作息、你的目录偏好换成你自己的；
3. 接入与定时：按 `docs/02-接入-AI-助理.md` 接 MCP，按 `docs/03-定时提醒.md` 开钉钉提醒。

## 目录结构

```
my-assistant/
├── README.md                      # 本文件
├── AGENTS.md                       # 助理守则（这套系统的灵魂，先改它）
├── GLOSSARY.md                     # 领域术语表
├── install.sh                      # 一键安装：检查依赖、生成配置、初始化 git
├── vault/                          # 用 Obsidian 打开这个目录
│   ├── 00-日记/                    # 每日记录与复盘
│   ├── 01-收件箱(Inbox)/           # 临时灵感，待分拣
│   ├── 02-项目(Projects)/          # 有截止期的任务
│   ├── 03-领域(Areas)/             # 长期责任领域（健康、财务、职业…）
│   ├── 04-资源(Resources)/Templates/ # 笔记模板
│   ├── 05-归档(Archives)/
│   ├── assets/                     # 图片附件
│   ├── raw/                        # 原始素材（只读）
│   └── wiki/                       # 结构化知识沉淀 + 索引 + 日志
├── scripts/
│   ├── config.env.example          # 复制成 config.env 后填写（不提交）
│   ├── notify.sh                   # 钉钉推送（自带消息模板）
│   ├── dispatch.sh                 # 工作日判定 + 时间点分发
│   ├── auto-commit.sh              # 每日自动 git 快照
│   └── install-launchd.sh          # 生成并加载 macOS LaunchAgent
├── config/
│   ├── mcp-obsidian.example.yml    # MCP（obsidian-mcp）接入示例
│   └── com.example.assistant.notify.plist # 定时任务模板
└── docs/
    ├── 01-安装.md
    ├── 02-接入-AI-助理.md
    ├── 03-定时提醒.md
    └── 99-常见坑.md                 # 最值钱的一页
```

## 这套东西解决四个问题

1. **记忆外置**：知识、画像、决策落在文件里，不靠脑子记，也不锁在某个 App 里；
2. **主动提醒**：到点推送「现在该做什么」，把作息 SOP 从意志力问题变成环境问题；
3. **自动沉淀**：AI 助理按守则把对话里的高价值信息实时写进对应档案，并每天自动提交 Git；
4. **数字分身（灵魂注入）**：内置《个人数字分身基准卡》模板，把你的核心价值观、家庭背景、行为底线结构化注入 AI，让助理真正懂你。

## 你需要什么

| 依赖 | 用途 | 必须？ |
| :--- | :--- | :---: |
| macOS 或 Linux | 定时任务（LaunchAgent / cron） | 是 |
| [Obsidian](https://obsidian.md/) | 笔记编辑、双链、模板 | 是 |
| Git | 版本管理与备份 | 是 |
| 支持 MCP 的 AI 客户端 | 让助理读写笔记 | 推荐 |
| 钉钉群自定义机器人 | 定时提醒推送 | 可选 |
| Node.js（npx） | 运行 obsidian-mcp | 接 MCP 时需要 |

## 许可证与免责

示例代码可直接复制修改用于你自己的系统。定时提醒、自动提交属于本地自动化，请自行确认路径与凭据安全；`config.env` 内含 webhook 凭据，**永远不要提交到公开仓库**。
