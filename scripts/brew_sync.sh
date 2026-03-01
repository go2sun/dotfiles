#!/bin/bash
# M4 系统：依赖基因导出
DOTFILES="$HOME/dotfiles/core/config"
mkdir -p "$DOTFILES"

echo "📦 正在导出 Brew 依赖基因..."
# 导出当前系统的所有 brew 软件列表
brew bundle dump --force --file="$DOTFILES/Brewfile"

echo "✅ 依赖基因已存至 $DOTFILES/Brewfile"