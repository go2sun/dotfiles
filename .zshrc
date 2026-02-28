# --- Path & Completions ---
autoload -Uz compinit && compinit

# --- General Aliases ---
alias clean='sudo m4-clean'
alias go-claw='cd ~/Developer/OpenClaw'

# --- Project Aliases ---
alias aia='python3 ~/aia.py'
alias sum='python3 /Users/nusun/Documents/Project/MacMiniM4/Obsidian_QuickAction.py'
alias claw='PATH="/Users/nusun/Documents/Project/nanoclaw/fake_bin:$PATH" node run.js'

# --- Gemini AI Automation ---
alias save_ai='/Users/nusun/Documents/Project/MacMiniM4/Inbox/automator.sh'

# 快速跳转到 AI 仓库
alias AI_Inbox='cd /Users/nusun/Documents/Project/MacMiniM4/Inbox && ls -la'

# --- AI 可视化回溯指令 ---
look_ai() {
    VAULT_NAME="MacMiniM4"
    TARGET_DIR="/Users/nusun/Documents/Project/MacMiniM4/Inbox"
    
    # 获取最近修改的一个 Chat 文件（排除索引文件）
    LATEST_FILE=$(ls -t "$TARGET_DIR"/Chat_* | head -1 | xargs basename)
    
    if [ -z "$LATEST_FILE" ]; then
        echo "❌ 还没发现任何 Chat 节点，先用 save_ai 存一个吧！"
        return
    fi

    echo "🔍 正在对焦最新大脑模型: $LATEST_FILE"
    
    # 优雅跳转：打开最新笔记，并尝试触发 Obsidian 的关系图谱或反向链接
    open "obsidian://open?vault=$VAULT_NAME&file=Inbox/$LATEST_FILE"
    
    # 可选：如果你安装了 Advanced URI 插件，甚至可以自动打开右侧边栏
    # open "obsidian://advanced-uri?vault=$VAULT_NAME&filepath=Inbox/$LATEST_FILE&viewmode=live&openmode=true"
}
alias python="python3"
alias pip="pip3"
alias sf='~/Desktop/M4_Shifu/start_sf.sh'
alias sf='~/Desktop/M4_Shifu/start_sf.sh'
alias ytd="yt-dlp -o '~/Desktop/zip/%(title)s.%(ext)s'"
# 针对 VS Code - Insiders 的绝对路径别名
alias code='/Applications/Visual\ Studio\ Code\ -\ Insiders.app/Contents/Resources/app/bin/code'
# Ollama 极速版 (内置 SSD)
alias fastollama="killall ollama; unset OLLAMA_MODELS; OLLAMA_HOST=127.0.0.1:11434 ollama serve"

# Ollama 实验版 (ORICO 移动硬盘)
alias bigollama="killall ollama; export OLLAMA_MODELS='/Volumes/ORICO/Models/ollama_models'; OLLAMA_HOST=127.0.0.1:11434 ollama serve"

# OpenClaw Completion
source "/Users/nusun/.openclaw/completions/openclaw.zsh"
# Sync Test Sat Feb 28 11:50:24 EST 2026
