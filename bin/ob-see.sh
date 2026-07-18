#!/bin/bash
# ob-see.sh — 让 Agent 直接读取 Obsidian 笔记内容(无需截图)
# 用法: ob-see.sh "<笔记路径, 如 控制台/总线回写验证>"
# 机制: 经 ob REST API GET /vault/<path> 读回笔记 markdown
# 安全: key 从 secret 节点取, 不落盘不打印
set -uo pipefail
export PATH="/Users/nusun/bin:$PATH"
NOTE="${1:?用法: ob-see.sh <笔记路径>}"
OBS_KEY=$(secret get obsidian-rest-key)
[ -z "$OBS_KEY" ] && { echo "❌ 取不到 obsidian-rest-key" >&2; exit 1; }
curl -s -m5 -k -H "Authorization: Bearer $OBS_KEY" "https://127.0.0.1:27124/vault/$NOTE"
echo
