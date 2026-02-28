#!/bin/bash
# M4 Mac 环境一键恢复脚本

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 开始恢复环境...${NC}"

# 1. 检查 Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. 安装核心工具
brew install git stow ollama

# 3. 强制重连配置文件
cd ~/dotfiles
rm -f ~/.zshrc
stow .

# 4. 批量恢复软件 (如果有 Brewfile)
if [ -f "Brewfile" ]; then
    brew bundle
fi

echo -e "${GREEN}✅ 环境恢复完成！请执行 'source ~/.zshrc'${NC}"