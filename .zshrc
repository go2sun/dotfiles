# --- M4 视觉审计系统 核心配置 ---

# 基础路径
export DOTFILES="$HOME/dotfiles"
mkdir -p $DOTFILES

# 暴力重置与清理
alias cleanm4="pkill -9 ollama; pkill -9 openclaw; sleep 1; stty sane; echo 'M4 系统重置成功'"

# 核心指令：使用 qwen3.5-nothink 模型并开启 verbose 统计

# 自动同步与 README 更新逻辑
alias syncm4="echo '# M4 性能看板\n\n> 同步时间: \$(date)\n' > \$DOTFILES/README.md; cp ~/.zshrc \$DOTFILES/; cd \$DOTFILES && git add . && git commit -m 'M4: Shell Env Fix' && git push"

# 极速自检指令
alias fastcheck="ollama run qwen3.5-nothink '执行系统性能自检' --verbose"

echo 'M4 视觉审计系统 (最终版) 极速引擎已就绪。'
alias qwen="ollama run qwen-m4-final --verbose && sleep 0.5 && stty sane"
