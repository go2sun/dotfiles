#!/bin/bash
mkdir -p ~/models/minicpm-o
cd ~/models/minicpm-o
echo "M4 系统正在从 HuggingFace 镜像下载权重 (需保持网络畅通)..."

# 使用 ModelScope 镜像 (国内速度更快) 或 HuggingFace
# 这里以常用的链接为例，如果失败请手动前往 OpenBMB 仓库
curl -L -O https://huggingface.co/openbmb/MiniCPM-o-2_6-gguf/resolve/main/MiniCPM-o-2_6-Q4_K_M.gguf
