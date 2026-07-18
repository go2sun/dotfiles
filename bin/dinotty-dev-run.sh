#!/bin/bash
# dinotty-dev-run.sh — 启动 dev 分支编译版 dinotty(独立端口, 不碰运行中的 0.16.1)
# 用法: dinotty-dev-run.sh [端口, 默认 18999]
# 安全: 不替换 /Applications/Dinotty.app, 不复用其端口; 独立进程
#       复用现有设置目录(已开 open_api + token), 仅端口不同
set -uo pipefail
PORT="${1:-18999}"
BIN=~/dinotty/target/debug/dinotty-server
[ -x "$BIN" ] || { echo "❌ 编译产物不存在: $BIN (先 cargo build -p dinotty-server)"; exit 1; }
echo "启动 dev dinotty @ http://127.0.0.1:$PORT (独立进程, 不碰 8999)"
"$BIN" --port "$PORT"
