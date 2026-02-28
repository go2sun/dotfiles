# --- 1. Path & Shell Environment ---
export PATH="/opt/homebrew/bin:$PATH"
autoload -Uz compinit && compinit

# --- 2. M4 Performance Tuning (Apple Silicon) ---
# 针对 M4 统一内存优化 Ollama 运行效率
export OLLAMA_MAX_LOADED_MODELS=3
export OLLAMA_NUM_PARALLEL=4
export CFLAGS="-march=apple-m4"
export CXXFLAGS="-march=apple-m4"

# --- 3. Distilled Factory Aliases (逻辑工厂自动化) ---
alias dot='cd ~/dotfiles'
alias syncfactory='git fetch --prune && git pull origin main'
alias syncbrew="(cd ~/dotfiles && brew bundle dump --force && git add Brewfile && git commit -m 'update: brew list' && git push)"

# --- 4. General & Python Aliases ---
alias python="python3"
alias pip="pip3"
alias clean='sudo m4-clean'
alias ytd="yt-dlp -o '~/Desktop/zip/%(title)s.%(ext)s'"
alias code='/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code'

# --- 5. Project Aliases (Claw 双子星整合) ---

# 进入目录的快捷键
alias goclaw='cd ~/Developer/OpenClaw'
alias gonano='cd ~/Documents/Project/nanoclaw'

# 核心函数：OpenClaw (Node.js 版本)
claw() {
    # 唤醒后台 AI (共享逻辑)
    if ! lsof -i :11434 > /dev/null; then
        echo "⚡️ 检测到 Ollama 未启动，正在为你唤醒 M4 GPU..."
        (killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve > /dev/null 2>&1 &)
        sleep 2
    fi
    
    local TARGET_DIR="/Users/nusun/Developer/OpenClaw"
    if [ -d "$TARGET_DIR" ]; then
        cd "$TARGET_DIR"
        echo "🦀 启动 OpenClaw (Node.js)..."
        # 如果是开发模式用 npm run dev，如果是脚本用 node run.js
        npm run dev 2>/dev/null || node run.js
    else
        echo "❌ 路径错误：找不到 OpenClaw 目录"
    fi
}

# 核心函数：nanoclaw (Go 版本)
nanoclaw() {
    # 唤醒后台 AI (共享逻辑)
    if ! lsof -i :11434 > /dev/null; then
        echo "⚡️ 检测到 Ollama 未启动，正在为你唤醒 M4 GPU..."
        (killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve > /dev/null 2>&1 &)
        sleep 2
    fi
    
    local TARGET_DIR="/Users/nusun/Documents/Project/nanoclaw"
    if [ -d "$TARGET_DIR" ]; then
        cd "$TARGET_DIR"
        echo "🏗️ 启动 nanoclaw (Go 引擎)..."
        # 注入 fake_bin 并运行 Go 主程序
        PATH="$TARGET_DIR/fake_bin:$PATH" go run main.go
    else
        echo "❌ 路径错误：找不到 nanoclaw 目录"
    fi
}

# --- 6. Gemini AI & Obsidian Workflow ---
alias save_ai='/Users/nusun/Documents/Project/MacMiniM4/Inbox/automator.sh'
alias AI_Inbox='cd /Users/nusun/Documents/Project/MacMiniM4/Inbox && ls -la'

claw() {
    # 1. 唤醒后台 AI
    if ! lsof -i :11434 > /dev/null; then
        echo "⚡️ 检测到 Ollama 未启动，正在为你唤醒 M4 GPU..."
        (killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve > /dev/null 2>&1 &)
        sleep 2
    fi
    
    # 2. 精准降落并执行
    local TARGET_DIR="/Users/nusun/Documents/Project/nanoclaw"
    if [ -d "$TARGET_DIR" ]; then
        cd "$TARGET_DIR"
        echo "🦀 进入 nanoclaw 基地..."
        PATH="$TARGET_DIR/fake_bin:$PATH" node run.js
    else
        echo "❌ 路径错误：找不到 $TARGET_DIR"
    fi
}

look_ai() {
    VAULT_NAME="MacMiniM4"
    TARGET_DIR="/Users/nusun/Documents/Project/MacMiniM4/Inbox"
    LATEST_FILE=$(ls -t "$TARGET_DIR"/Chat_* 2>/dev/null | head -1 | xargs basename)
    
    if [ -z "$LATEST_FILE" ]; then
        echo "❌ 还没发现任何 Chat 节点，先用 save_ai 存一个吧！"
        return
    fi
    echo "🔍 正在对焦最新大脑模型: $LATEST_FILE"
    open "obsidian://open?vault=$VAULT_NAME&file=Inbox/$LATEST_FILE"
}
# --- 7. Dual-Mode Ollama (内置 SSD vs 外置硬盘) ---
alias fastollama="killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve"
alias bigollama="killall ollama 2>/dev/null; export OLLAMA_MODELS='/Volumes/ORICO/Models/ollama_models'; OLLAMA_HOST=127.0.0.1:11434 ollama serve"

# --- 8. Completions ---
[[ -f "/Users/nusun/.openclaw/completions/openclaw.zsh" ]] && source "/Users/nusun/.openclaw/completions/openclaw.zsh"

# Sync Last Refreshed: $(date)

