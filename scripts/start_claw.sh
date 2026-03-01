#!/bin/zsh

echo "🚀 正在为 M4 Mac 优化启动环境..."

# 1. 检查 Ollama 是否在运行
if ! pgrep -x "ollama" > /dev/null; then
    echo "📦 正在后台启动 Ollama..."
    open -a Ollama
    sleep 2
fi

# 2. 尝试修复并手动拉起 Gateway (解决 EPERM 报错)
echo "🌐 正在激活 Clawdbot Gateway..."
clawdbot gateway start > /dev/null 2>&1 &
sleep 2

# 3. 启动 OpenClaw
echo "🦞 正在加载 GLM-4.7-Flash (tinyer) 并启动 OpenClaw..."
ollama launch openclaw --model sparksammy/glm-4.7-flash-unsloth:tinyer-hotfixed

