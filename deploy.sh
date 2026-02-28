#!/bin/bash

# --- 1. 软链接自动化 (Stow) ---
echo "🔗 正在同步本地 dotfiles 软链接..."
cd ~/dotfiles
stow .

# --- 2. Git 环境纯净维护 ---
echo "🧹 正在清理 Git 远程 master 幻影..."
# 设置远程 HEAD 指向 main
git remote set-head origin main 2>/dev/null
# 清理本地不存在的远程分支引用
git remote prune origin

# --- 3. 自动找回核心模型 (Fast 模式) ---
# 只有在运行 fastollama 时，才拉取 SSD 模型
if [ "$OLLAMA_MODELS" = "/Users/nusun/.ollama/models" ]; then
    echo "🚀 检测到 Fast 模式，确保核心模型就位..."
    ollama pull qwen2.5-coder:7b
fi

echo "✨ M4 Mac Mini 逻辑工厂配置部署完成！"