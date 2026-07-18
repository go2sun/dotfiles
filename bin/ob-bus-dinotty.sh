#!/bin/bash
# ob-bus-dinotty.sh — 总线闭环(dinotty 介入版, dev 编译版 @18999)
# 精准提取法: 命令前后各打印唯一 marker, 读 screen 取两 marker 之间内容
# 不依赖 OSC133 / 不依赖文件重定向(已验证 dinotty 终端 > 重定向不稳)
# 安全: key 从 secret 节点取, 不落盘不打印
set -uo pipefail
export PATH="/Users/nusun/bin:$PATH"

DINOTTY_PORT="${DINOTTY_PORT:-18999}"
NOTE="${NOTE_PATH:-控制台/总线回写验证.md}"
CMD="${1:-hostname && date}"
DT=$(secret get dinotty-token)
OBS_KEY=$(secret get obsidian-rest-key)
[ -z "$DT" ] && { echo "❌ 取不到 dinotty-token" >&2; exit 1; }
[ -z "$OBS_KEY" ] && { echo "❌ 取不到 obsidian-rest-key" >&2; exit 1; }

TS=$(date '+%Y-%m-%d %H:%M:%S')
PANE=$(curl -s -m5 -H "Authorization: Bearer $DT" "http://127.0.0.1:$DINOTTY_PORT/api/tabs" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('active_pane_id',''))" 2>/dev/null)
[ -z "$PANE" ] && { echo "❌ 无活跃终端"; exit 1; }

MARK="BUS${RANDOM}$(date +%s)"
# 构造远程命令: 打印开始标记 -> 执行命令 -> 打印结束标记
# 用 python 生成完整字符串(单引号包裹命令, 内部单引号转义为 '\'')
REMOTE_CMD=$(python3 <<PY
cmd = '''$CMD'''
m = '''$MARK'''
# 命令里的单引号转义
safe = cmd.replace("'", "'\\''")
remote = "printf 'BUS_START_{0}\\n'; {1}; printf 'BUS_END_{0}\\n'".format(m, safe)
print(remote)
PY
)
curl -s -m5 -X POST -H "Authorization: Bearer $DT" -H "Content-Type: application/json" \
 -d "$(python3 -c "import json,sys; print(json.dumps({'data': sys.argv[1]+'\n'}))" "$REMOTE_CMD")" \
 "http://127.0.0.1:$DINOTTY_PORT/api/sessions/$PANE/input" 2>/dev/null >/dev/null
sleep 2

# 读 screen, 提取 BUS_START_<MARK> 和 BUS_END_<MARK> 之间内容
SCREEN=$(curl -s -m5 -H "Authorization: Bearer $DT" "http://127.0.0.1:$DINOTTY_PORT/api/sessions/$PANE/screen" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('content',''))" 2>/dev/null)
OUT=$(printf '%s' "$SCREEN" | python3 -c "
import sys
m='$MARK'
lines=sys.stdin.read().split('\n')
start=None;end=None
for i,l in enumerate(lines):
    if 'BUS_START_'+m in l: start=i
    if 'BUS_END_'+m in l: end=i; break
if start is not None and end is not None and end>start:
    print('\n'.join(lines[start+1:end]).rstrip())
else:
    print('(提取失败)')
")
echo "dinotty 执行完成, 输出行数: $(echo "$OUT" | wc -l)"

# 回写 ob 笔记
NEW_REC=$(printf '## 最近一次执行 (dinotty %s)\n\n- 命令: `%s`\n- 总线: dinotty 终端(18999)\n- 输出:\n\n```\n%s\n```\n' "$TS" "$CMD" "$OUT")
EXIST=$(curl -s -m5 -k -H "Authorization: Bearer $OBS_KEY" "https://127.0.0.1:27124/vault/$NOTE" 2>/dev/null)
if [ -n "$EXIST" ]; then
  HIST=$(printf '%s\n' "$EXIST" | sed -n '/^## /,$p')
  BODY=$(printf '# 总线回写验证\n\n> [!info] 总线闭环验证笔记(dinotty 总线版)。命令经 dinotty 终端执行, 结果自动回写本节。\n\n%s\n\n%s\n' "$NEW_REC" "$HIST")
else
  BODY=$(printf '# 总线回写验证\n\n> [!info] 总线闭环验证笔记(dinotty 总线版)。\n\n%s\n' "$NEW_REC")
fi
code=$(curl -s -m6 -o /dev/null -w "%{http_code}" -X PUT -k \
  -H "Authorization: Bearer $OBS_KEY" -H "Content-Type: text/markdown" \
  --data-binary "$BODY" "https://127.0.0.1:27124/vault/$NOTE")
echo "回写 ob 笔记: HTTP $code"