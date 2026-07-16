#!/usr/bin/env bash
# see-image.sh — 用 Gemini 视觉模型分析图片(外挂视觉能力)
# 让不支持视觉的主模型(如 hy3:free)也能"看懂"图片
# 用法: see-image.sh <图片路径> [自定义提问]
set -euo pipefail

IMG="${1:?用法: see-image.sh <图片路径> [提问]}"
PROMPT="${2:-用中文详细描述这张图:界面结构、关键元素、图标、文字、状态、任何报错或重要信息。简洁但不遗漏要点。}"
MODEL="${GEMINI_VISION_MODEL:-gemini-2.5-flash}"

[ -f "$IMG" ] || { echo "图片不存在: $IMG" >&2; exit 1; }
# 载入 key
[ -z "${GOOGLE_AI_STUDIO_API_KEY:-}" ] && source "$HOME/dotfiles/.secrets.env" 2>/dev/null || true
[ -n "${GOOGLE_AI_STUDIO_API_KEY:-}" ] || { echo "缺 GOOGLE_AI_STUDIO_API_KEY" >&2; exit 1; }

# MIME 类型
case "${IMG##*.}" in
  png) MIME=image/png ;; jpg|jpeg) MIME=image/jpeg ;;
  gif) MIME=image/gif ;; webp) MIME=image/webp ;; *) MIME=image/png ;;
esac

REQ=$(mktemp); RESP=$(mktemp)
trap 'rm -f "$REQ" "$RESP"' EXIT
python3 - "$IMG" "$MIME" "$PROMPT" > "$REQ" <<'PY'
import sys, json, base64
img, mime, prompt = sys.argv[1], sys.argv[2], sys.argv[3]
data = base64.b64encode(open(img,'rb').read()).decode()
print(json.dumps({"contents":[{"parts":[{"text":prompt},{"inline_data":{"mime_type":mime,"data":data}}]}]}))
PY

curl -s "https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=${GOOGLE_AI_STUDIO_API_KEY}" \
  -H "Content-Type: application/json" -d @"$REQ" > "$RESP"

python3 - "$RESP" <<'PY'
import sys, json
d = json.load(open(sys.argv[1]))
try:
    print(d['candidates'][0]['content']['parts'][0]['text'])
except (KeyError, IndexError):
    print("视觉分析失败:", json.dumps(d.get('error', d), ensure_ascii=False))
    sys.exit(1)
PY
