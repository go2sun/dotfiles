#!/bin/bash

# 定义颜色，让输出更具美感
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE} 正在初始化极简部署环境...${NC}"

# 1. 创建必要的物理目录
mkdir -p ~/ollama_models
mkdir -p ~/.openclaw

# 2. 获取脚本所在的绝对路径
DOTFILES_DIR=$(cd "$(dirname "$0")"; pwd)

echo "正在同步配置文件..."

# 3. 强制建立符号链接 (Symbolic Links)
# 这样无论你以后怎么改 .dotfiles 里的内容，系统调用的都是最新版
ln -sf "$DOTFILES_DIR/openclaw/openclaw.Modelfile" ~/ollama_models/openclaw.Modelfile
# 预留给 OpenClaw 的配置文件链接
if [ -f "$DOTFILES_DIR/openclaw/openclaw.json" ]; then
    ln -sf "$DOTFILES_DIR/openclaw/openclaw.json" ~/.openclaw/openclaw.json
ln -sf "$DOTFILES_DIR/openclaw/stress_test.py" ~/stress_test.py
fi

# 4. 通知 Ollama 重新加载/创建模型
if command -v ollama &> /dev/null; then
    echo -e "${BLUE}正在注册本地越狱模型: openclaw-nemo...${NC}"
    ollama create openclaw-nemo -f "$DOTFILES_DIR/openclaw/openclaw.Modelfile"
else
    echo "提示: 未检测到 Ollama，请稍后手动安装并运行此脚本。"
fi

echo -e "${GREEN}✓ 部署成功。Everything just works.${NC}"
