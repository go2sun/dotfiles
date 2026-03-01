#!/bin/bash

# =================================================================
# OpenClaw & Ollama 自动化部署脚本 (Steve Jobs Minimalist Edition)
# =================================================================

# 定义颜色
GREEN='\033[0;32m'
NC='\033[0m' # 无颜色

echo -e "${GREEN} 正在启动极简主义部署程序...${NC}"

# 1. 确保目标目录存在
mkdir -p ~/ollama_models
mkdir -p ~/.openclaw

# 2. 定义配置文件路径 (基于你的 .dotfiles 仓库结构)
DOTFILES_DIR=$(pwd)
MODES_DIR="$DOTFILES_DIR/openclaw"

# 3. 创建符号链接 (Symbolic Links)
# 如果文件已存在，使用 -f 强制覆盖，确保指向最新仓库
echo "正在建立符号链接..."

# Ollama Modelfile
ln -sf "$MODES_DIR/openclaw.Modelfile" ~/ollama_models/openclaw.Modelfile

# OpenClaw JSON 配置
ln -sf "$MODES_DIR/openclaw.json" ~/.openclaw/openclaw.json

# 4. 自动注册 Ollama 模型
if command -v ollama &> /dev/null
then
    echo "正在根据 Modelfile 更新本地模型: openclaw-nemo..."
    ollama create openclaw-nemo -f "$MODES_DIR/openclaw.Modelfile"
else
    echo "警告: 未检测到 Ollama，请先安装。"
fi

echo -e "${GREEN}✓ 部署完成。Everything just works.${NC}"
# 检查 8787 端口，如果没启动则尝试启动
if ! lsof -i:8787 > /dev/null; then
    echo "检测到 Gemini 中转未启动，正在尝试拉起..."
    cd "$DOTFILES_DIR/gemini-cli-openai" && nohup npx wrangler dev --ip 127.0.0.1 --port 8787 > wrangler.log 2>&1 &
    echo "Gemini 中转已在后台启动。"
else
    echo "Gemini 中转已在线。"
fi