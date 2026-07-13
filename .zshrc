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

q() {
  stopq
  /Users/nusun/llama.cpp/build/bin/llama-server \
    -m "/Users/nusun/models/llm/Qwythos-9B-Claude-Mythos-5-1M-MTP-Q6_K.gguf" \
    --jinja --port 9090 \
    --mcp "/Users/nusun/bin/m4-mcp-lite.sh" \
    --ctx-size 32768 \
    --log-disable \
    -ngl 99 \
    --temp 0.2 &
}

# MCP Chat Command (mcc) - 增加推理模式选择
mcc() {
    # 强制重新注入环境变量并执行，确保 MCP 代理正确响应
    export FIRECRAWL_API_KEY=$(grep FIRECRAWL_API_KEY ~/.dotfiles/.secrets.env | cut -d '=' -f2)
    echo "--- M4 MCP 审计模式启动 ---"
    curl -s http://127.0.0.1:9090/completion \
    -H "Content-Type: application/json" \
    -d "{\"prompt\": \"$1\", \"n_predict\": 1024}" | jq -r .content
}

# --- [扩展：M4 视觉审计系统 MCP 大脑连接器] ---
# 用于将外部 MCP 节点动态挂载至 Claude Desktop 或本地审计环境
m4-connect() {
    local url=$1
    local token=$2
    local name=${3:-"m4-remote-brain"}
    
    python3 "/Users/nusun/M4_Repo/scripts/maintenance/m4_mcp_connect.py" "$url" --token "$token" --name "$name"
}

# 2. 强化后的 syncm4 (加入自动化审计配置)
syncm4() {
    local COMMIT_MSG="M4 审计同步: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🛡️ [M4 审计] 启动全量同步..."

    # 预先同步 MCP 配置(如果存在于环境)
    if [ -f "$HOME/dotfiles/.mcp_config" ]; then
        echo "🔗 正在根据 dotfiles 映射远程大脑..."
        xargs -a "$HOME/dotfiles/.mcp_config" m4-connect
    fi

    local sync_dirs=("$HOME/M4_Repo" "$HOME/dotfiles" "$HOME/brain")
    for dir in "${sync_dirs[@]}"; do
        if [ -d "$dir/.git" ]; then
            cd "$dir" || continue
            git add . && git commit -m "$COMMIT_MSG" > /dev/null 2>&1
            git push origin main > /dev/null 2>&1
            
            if git grep -IqE "AIza|ghp_" -- . ':!*.git*' ':!.zshrc'; then
               echo "⚠️ 审计警告：$dir 包含未过滤敏感信息！"
            else
               echo "✅ $dir 扫描安全。"
            fi
        fi
    done
    
    # Obsidian 同步与闭环
    curl -X POST "$OBSIDIAN_API_URL/append/" -d "- [x] **M4 同步完成**: $(date)" --silent --output /dev/null
    echo "✨ 审计链路闭环。"
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

# 增加一键重启所有服务的功能
alias relm4="stopq && source ~/.zshrc && q"alias m4-connect="python3 /Users/nusun/M4_Repo/scripts/maintenance/m4_mcp_connect.py"
