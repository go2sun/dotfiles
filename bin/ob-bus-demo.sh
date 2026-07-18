#!/bin/bash
# ob-bus-demo.sh — 最小总线闭环(路3: ob 面板 -> 本地 shell 执行 -> 回写 ob 笔记)
# 用法: ob-bus-demo.sh "<要执行的命令>"
# 机制: 执行命令 -> 捕获 stdout/stderr/exit_code -> 以"追加一条执行记录"的方式回写 ob 笔记
#        笔记始终只保留一个 H1 标题 + info 框 + 多条"## 最近一次执行"历史(最新在最上)
# 安全: key 从 secret 节点取, 不落盘不打印
set -uo pipefail
export PATH="/Users/nusun/bin:$PATH"

CMD="${1:-hostname && date}"
OBS_KEY=$(secret get obsidian-rest-key)
[ -z "$OBS_KEY" ] && { echo "❌ 取不到 obsidian-rest-key" >&2; exit 1; }

NOTE="控制台/总线回写验证.md"
TS=$(date '+%Y-%m-%d %H:%M:%S')
OUT=$(eval "$CMD" 2>&1)
RC=$?

# 构造一条新的执行记录(markdown)
NEW_REC=$(printf '## 最近一次执行 (%s)\n\n- 命令: `%s`\n- exit_code: %s\n- 输出:\n\n```\n%s\n```\n' "$TS" "$CMD" "$RC" "$OUT")

# 若笔记已存在: 保留原有历史记录(去掉旧的 H1/info, 仅拼接历史), 新记录放最上
EXIST=$(curl -s -m5 -k -H "Authorization: Bearer $OBS_KEY" "https://127.0.0.1:27124/vault/$NOTE" 2>/dev/null)
if [ -n "$EXIST" ]; then
  # 去掉已有 H1 标题行 + info 框, 提取 ## 历史段
  HIST=$(printf '%s\n' "$EXIST" | sed -n '/^## /,$p')
  BODY=$(printf '# 总线回写验证\n\n> [!info] 总线闭环验证笔记。命令经本地 shell 执行, 结果自动回写本节。\n\n%s\n\n%s\n' "$NEW_REC" "$HIST")
else
  BODY=$(printf '# 总线回写验证\n\n> [!info] 总线闭环验证笔记。命令经本地 shell 执行, 结果自动回写本节。\n\n%s\n' "$NEW_REC")
fi

code=$(curl -s -m6 -o /dev/null -w "%{http_code}" -X PUT -k \
  -H "Authorization: Bearer $OBS_KEY" -H "Content-Type: text/markdown" \
  --data-binary "$BODY" "https://127.0.0.1:27124/vault/$NOTE")

if [ "$code" = "204" ] || [ "$code" = "200" ]; then
  echo "✅ 已执行并回写 ob 笔记: $NOTE (HTTP $code)"
  echo "   命令: $CMD | exit=$RC"
else
  echo "❌ 回写失败 HTTP $code"
fi
