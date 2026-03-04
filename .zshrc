# --- M4 视觉审计系统 核心配置 ---

# 基础路径
export DOTFILES="$HOME/dotfiles"
mkdir -p $DOTFILES

# 暴力重置与清理

# 核心指令：使用 qwen3.5-nothink 模型并开启 verbose 统计

# 自动同步与 README 更新逻辑
alias syncm4="echo '# M4 性能看板\n\n> 同步时间: \$(date)\n' > \$DOTFILES/README.md; cp ~/.zshrc \$DOTFILES/; cd \$DOTFILES && git add . && git commit -m 'M4: Shell Env Fix' && git push"

# 极速自检指令
alias fastcheck="ollama run qwen3.5-nothink '执行系统性能自检' --verbose"

echo 'M4 视觉审计系统 (最终版) 极速引擎已就绪。'
alias qwen="ollama run qwen-m4-final --verbose && sleep 0.5 && stty sane"
  if [ $# -eq 0 ]; then
    # 无参数时，尝试打开 UI（虽然目前 Docker 未运行，这作为占位符）
    open http://localhost:3000
  else
    # 有参数时，直接调用 M4 巅峰引擎并修复终端乱码
    ollama run qwen-m4-final "$@" --verbose && stty sane
  fi
  if [ $# -eq 0 ]; then
    open http://localhost:3000
  else
    ollama run qwen-m4-final "$@" --verbose && stty sane
  fi
  if [ "$1" = "gateway" ]; then
    # 如果指令包含 gateway，则尝试真正拉起服务
  elif [ $# -eq 0 ]; then
    open http://localhost:3000
  else
    ollama run qwen-m4-final "$@" --verbose && stty sane
  fi
openclaw() {
    if [ $# -eq 0 ]; then
        # 无参数时，打开 Ollama 状态页确认内核在线
        open http://localhost:11434
    else
        # 有参数时，保持 267 tokens/s 的极速审计输出
        ollama run qwen-m4-final "$@" --verbose && stty sane
    fi
}
# Last Sync: Tue Mar  3 20:38:20 EST 2026

# M4 视觉审计系统 - 自动修复网关逻辑
openclaw () {
    if ! pgrep -f "clawdbot gateway serve" > /dev/null; then
    fi

    if [ "$1" = "gateway" ]; then
        ollama launch openclaw --model qwen-m4-final:latest
    elif [ $# -eq 0 ]; then
        open http://localhost:3000
    else
        ollama run qwen-m4-final "$@" --verbose && stty sane
    fi
}
