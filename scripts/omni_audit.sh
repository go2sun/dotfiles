#!/bin/bash
# 路径请根据你的实际 llama.cpp-omni 存放位置修改
MODEL_PATH="$HOME/models/minicpm-o-4.5-q4_k_m.gguf"

echo -e "\033[35m[M4 Omni Engine]\033[0m 启动全双工流式审计..."

./llama-cpp-omni/main -m $MODEL_PATH \
  --threads 8 \
  --n-gpu-layers 99 \
  --color \
  --alias-free \
  --ctx-size 4096 \
  --interactive-first
