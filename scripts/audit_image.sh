#!/bin/bash
# 使用示例: ./audit_image.sh test.jpg "这张图片里有什么异常?"
IMAGE_PATH=$1
PROMPT=$2

echo -e "\033[36m[M4 AI Audit]\033[0m 正在分析: $IMAGE_PATH..."

curl -X POST http://localhost:11434/api/generate -d '{
  "model": "minicpm-v",
  "prompt": "'"$PROMPT"'",
  "images": ["'"$(base64 -i "$IMAGE_PATH")"'"],
  "stream": false
}' | jq '.response'
