# =================================================================
# 1. 核心路径与环境 (Path & Shell)
# =================================================================
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
autoload -Uz compinit && compinit

# =================================================================
# 2. M4 顶级性能调优 (Apple Silicon Dedicated)
# =================================================================
export OLLAMA_MAX_LOADED_MODELS=3
export OLLAMA_NUM_PARALLEL=4
# 针对 M4 内核优化的编译参数
export CFLAGS="-march=apple-m4 -O3"
export CXXFLAGS="-march=apple-m4 -O3"
# 提升大规模文件处理速度
ulimit -n 4096

# =================================================================
# 3. 生产力别名 (Factory & General Aliases)
# =================================================================
alias dot='cd ~/dotfiles'
alias syncfactory='git fetch --prune && git pull origin main'
alias syncbrew="(cd ~/dotfiles && brew bundle dump --force && git add Brewfile && git commit -m 'update: brew list' && git push)"

alias python="python3"
alias pip="pip3"
alias clean='sudo m4-clean'
alias code='/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code'
alias m4top='sudo powermetrics --samplers gpu_power,cpu_power -i 500'

# =================================================================
# 4. AI 审计与项目工作流 (Dual-Claw Orchestrator)
# =================================================================
alias gonano='cd ~/Documents/Project/nanoclaw'
alias goclaw='cd ~/Developer/OpenClaw'

# 【核心修复】删除了旧函数，直接映射到我们编译好的二进制文件
# 现在输入 nanoclaw -snap 会直接调用 /usr/local/bin/nanoclaw
alias nanoclaw='/usr/local/bin/nanoclaw'

# OpenClaw 启动器 (保持 Node.js 逻辑)
claw() {
    if ! lsof -i :11434 > /dev/null; then
        echo "⚡️ 唤醒 M4 GPU 推理引擎..."
        (fastollama > /dev/null 2>&1 &)
        sleep 2
    fi
    local TARGET_DIR="/Users/nusun/Developer/OpenClaw"
    if [ -d "$TARGET_DIR" ]; then
        cd "$TARGET_DIR"
        echo "🦀 启动 OpenClaw (Node.js)..."
        node --watch core.js
    else
        echo "❌ 路径错误：找不到 OpenClaw 目录"
    fi
}

# =================================================================
# 5. Gemini AI & Obsidian Brain Sync
# =================================================================
alias save_ai='/Users/nusun/Documents/Project/MacMiniM4/Inbox/automator.sh'
alias AI_Inbox='cd /Users/nusun/Documents/Project/MacMiniM4/Inbox && ls -la'

look_ai() {
    local VAULT_NAME="MacMiniM4"
    local TARGET_DIR="/Users/nusun/Documents/Project/MacMiniM4/Inbox"
    local LATEST_FILE=$(ls -t "$TARGET_DIR"/Chat_* 2>/dev/null | head -1 | xargs basename)
    if [ -z "$LATEST_FILE" ]; then
        echo "❌ 还没发现任何 Chat 节点"
        return
    fi
    echo "🔍 正在对焦最新大脑模型: $LATEST_FILE"
    open "obsidian://open?vault=$VAULT_NAME&file=Inbox/$LATEST_FILE"
}

# =================================================================
# 6. 多模式 Ollama 引擎控制
# =================================================================
# 快速模式：使用内置存储
alias fastollama="killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve"
# 重量级模式：使用外置 ORICO 硬盘中的模型
alias bigollama="killall ollama 2>/dev/null; export OLLAMA_MODELS='/Volumes/ORICO/Models/ollama_models'; OLLAMA_HOST=127.0.0.1:11434 ollama serve"

# =================================================================
# 7. 自动补全与收尾
# =================================================================
[[ -f "/Users/nusun/.openclaw/completions/openclaw.zsh" ]] && source "/Users/nusun/.openclaw/completions/openclaw.zsh"

# 最后同步时刻: 2026-02-28alias nanoclaw='/usr/local/bin/nanoclaw'
