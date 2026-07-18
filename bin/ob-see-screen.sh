#!/bin/bash
# ob-see-screen.sh — 让我(agent)看你的屏幕: 截全屏 -> OCR 出文字 -> 回显
# 用法: ob-see-screen.sh
# 依赖: screencapture(已授权 cmux) + ~/.hermes/skills/image-ocr/img-ocr
# 说明: OCR 只能提取屏幕上的文字(笔记/终端/设置/按钮标签), 非通用视觉
set -uo pipefail
export PATH="/Users/nusun/bin:$PATH"
IMG="/tmp/see_screen.png"
OCR=/Users/nusun/.hermes/skills/image-ocr/img-ocr
screencapture -x "$IMG" 2>/dev/null || { echo "❌ 截屏失败" >&2; exit 1; }
echo "截屏: $IMG ($(wc -c < "$IMG") 字节)"
echo "--- OCR 文字 ---"
"$OCR" "$IMG" 2>&1 | head -60
