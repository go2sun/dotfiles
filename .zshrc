# --- 1. Path & Shell Environment ---
export PATH="/opt/homebrew/bin:$PATH"
autoload -Uz compinit && compinit

# --- 2. M4 Performance Tuning (Apple Silicon) ---
export OLLAMA_MAX_LOADED_MODELS=3
export OLLAMA_NUM_PARALLEL=4
export CFLAGS="-march=apple-m4"
export CXXFLAGS="-march=apple-m4"

# --- 3. Distilled Factory Aliases ---
alias dot='cd ~/dotfiles'
alias syncfactory='git fetch --prune && git pull origin main'
alias syncbrew="(cd ~/dotfiles && brew bundle dump --force && git add Brewfile && git commit -m 'update: brew list' && git push)"

# --- 4. General & Python Aliases ---
alias python="python3"
alias pip="pip3"
alias clean='sudo m4-clean'
alias ytd="yt-dlp -o '~/Desktop/zip/%(title)s.%(ext)s'"
alias code='/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code'

# --- 5. Project Aliases (Dual-Claw Orchestrator) ---
alias goclaw='cd ~/Developer/OpenClaw'
alias gonano='cd ~/Documents/Project/nanoclaw'

# OpenClaw (Node.js 完整版)
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
        # 尝试开发模式，失败则回退到运行脚本
        npm run dev 2>/dev/null || node run.js
    else
        echo "❌ 路径错误：找不到 OpenClaw 目录"
    fi
}

# nanoclaw (Go 极简版)
nanoclaw() {
    if ! lsof -i :11434 > /dev/null; then
        echo "⚡️ 唤醒 M4 GPU 推理引擎..."
        (fastollama > /dev/null 2>&1 &)
        sleep 2
    fi
    local TARGET_DIR="/Users/nusun/Documents/Project/nanoclaw"
    if [ -d "$TARGET_DIR" ]; then
        cd "$TARGET_DIR"
        echo "🏗️ 启动 nanoclaw (Go 引擎)..."
        PATH="$TARGET_DIR/fake_bin:$PATH" go run main.go
    else
        echo "❌ 路径错误：找不到 nanoclaw 目录"
    fi
}

# --- 6. Gemini AI & Obsidian Workflow ---
alias save_ai='/Users/nusun/Documents/Project/MacMiniM4/Inbox/automator.sh'
alias AI_Inbox='cd /Users/nusun/Documents/Project/MacMiniM4/Inbox && ls -la'

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

# --- 7. Dual-Mode Ollama ---
alias fastollama="killall ollama 2>/dev/null; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve"
alias bigollama="killall ollama 2>/dev/null; export OLLAMA_MODELS='/Volumes/ORICO/Models/ollama_models'; OLLAMA_HOST=127.0.0.1:11434 ollama serve"

# --- 8. Completions & Final Sync ---
[[ -f "/Users/nusun/.openclaw/completions/openclaw.zsh" ]] && source "/Users/nusun/.openclaw/completions/openclaw.zsh"
# Last Integrated Sync: 2026-02-28