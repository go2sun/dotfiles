# ========== [ M4 视觉审计系统 (NUSUN 终极完美版) ] ==========
source "$HOME/dotfiles/.secrets.env"
export SYSTEM_NAME="NUSUN"

# 1. 路径一体化
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.lmstudio/bin:$HOME/.local/bin:$(npm prefix -g)/bin:/Users/nusun/.opencode/bin:/Users/nusun/.npm-global/bin:$PATH"

# 2. VLC 核心环境
export PYTHON_VLC_LIB_PATH="/Applications/VLC.app/Contents/MacOS/lib/libvlc.dylib"
export VLC_PLUGIN_PATH="/Applications/VLC.app/Contents/MacOS/plugins"

# 3. 核心知识库与 AI API
export OBSIDIAN_API_URL="http://127.0.0.1:27123"
export QWEN_MODEL_PATH="/Users/nusun/models/llm/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ2_M.gguf"
export DISABLE_UVLOOP=True

# --- [审计与推理链路] ---
call-claude() {
    curl -s http://127.0.0.1:9090/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{ \"model\": \"Claude\", \"messages\": [{\"role\": \"user\", \"content\": \"$1\"}], \"stream\": false }" \
    | jq -r '.choices[0].message.content'
}

call-claude-stream() {
    curl -sN http://127.0.0.1:9090/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{ \"model\": \"Claude\", \"messages\": [{\"role\": \"user\", \"content\": \"$1\"}], \"stream\": true }" \
    | while read -r line; do
        content=$(echo "$line" | sed 's/^data: //' | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
        echo -ne "$content"
    done
    echo ""
}

# --- [系统清理与防御] ---
cleanm4() {
    echo "🚀 正在执行 M4 深度清理..."
    sudo killall -9 idleassetsd 2>/dev/null
    rm -rf ~/Library/Caches/* ~/.cache/huggingface/hub/* 2>/dev/null
    brew cleanup --prune=all
    echo "✨ 清理完成。"
}

# --- [最终审计同步流程] ---
q() {
  echo -ne "\033]0;M4 LLM Service\007"
  /Users/nusun/llama.cpp/build/bin/llama-server \
    -m "/Users/nusun/models/llm/Qwythos-9B-Claude-Mythos-5-1M-MTP-Q6_K.gguf" \
    --chat-template chatml -ngl 99 -c 4096 -np 1 --cache-type-k q8_0 --cache-type-v q8_0 --temp 0.7 --port 9090
}

syncm4() {
    local COMMIT_MSG="M4 视觉审计系统 (最终版) - 自动同步: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🛡️ [M4 审计] 启动全量同步..."

    # 定义审计目录列表
    local sync_dirs=("$HOME/M4_Repo" "$HOME/dotfiles" "$HOME/brain")

    for dir in "${sync_dirs[@]}"; do
        if [ -d "$dir/.git" ]; then
            echo "📂 同步仓库: $dir"
            cd "$dir" && git add . && git commit -m "$COMMIT_MSG" > /dev/null 2>&1
            git push origin main
            
            # 敏感信息检查 (已优化：跳过 .zshrc 本身及 Git 历史文件对象，消除自检误报)
            if grep -rE --exclude=".zshrc" --exclude-dir=".git" "AIza|ghp_" . > /dev/null 2>&1; then
               echo "⚠️ 警告：检测到疑似敏感凭证泄露 (在 $dir 中)！"
            else
               echo "✅ $dir 扫描安全。"
            fi
        else
            echo "⚠️ 跳过: $dir (非 Git 仓库或路径不存在)"
        fi
    done

    # 更新 Obsidian 审计日志
    curl -X POST "$OBSIDIAN_API_URL/append/" \
         -H "Authorization: Bearer $OBSIDIAN_API_KEY" \
         -d "- [x] **M4 视觉审计系统同步完成**: $(date '+%Y-%m-%d %H:%M:%S')" --silent --output /dev/null

    echo "✨ 所有模块同步完成，日志已更新。"
}

# --- [配置初始化] ---
autoload -Uz compinit
compinit -i

# 4. 别名汇总
alias cc='call-claude'
alias ccs='call-claude-stream'
alias cs="cleanm4 && syncm4"
alias reset='~/scripts/reset.sh'
alias ghostty="/Applications/Ghostty.app/Contents/MacOS/ghostty"
alias litellm="litellm --model anthropic/qwen-35b-local --api_base http://127.0.0.1:8080 --port 4000"
alias stopq='pkill -f llama-server && echo "✅ 模型服务已彻底停止"'