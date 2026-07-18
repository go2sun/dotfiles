# ========== [ M4 视觉审计系统 (NUSUN 终极完美版) ] ==========
source "$HOME/dotfiles/.secrets.env"
export SYSTEM_NAME="NUSUN"
export BRAIN_DIR="$HOME/brain"

# 路径一体化整合 (M4 视觉审计系统)
# 1. 设置基础路径：优先系统和 Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export CF_API_TOKEN="«redacted-old-cf-token»"



# 统一入口配置
gbt() { ~/scripts/brain-think.sh "$1" }
gbm() { ~/scripts/brain-memory.sh }
gbd() { ~/scripts/brain-dream.sh }
gbl() { ~/scripts/brain-loop.sh }


USER_PATHS=(
    "$HOME/.local/bin"
    "$(npm prefix -g)/bin"
    "$HOME/.lmstudio/bin"
    "$HOME/.opencode/bin"
    "$HOME/.npm-global/bin"
    "$HOME/llama.cpp/build/bin" # 添加这一行，让你在任何位置都能直接执行 llama-server
    "$HOME/bin" # 统一密文节点 / 密钥收拢脚本
)

export PATH="$(IFS=:; echo "${USER_PATHS[*]}"):$PATH"

# 2. VLC 核心环境
export PYTHON_VLC_LIB_PATH="/Applications/VLC.app/Contents/MacOS/lib/libvlc.dylib"
export VLC_PLUGIN_PATH="/Applications/VLC.app/Contents/MacOS/plugins"

# 3. 核心知识库与 AI API
export OBSIDIAN_API_URL="http://127.0.0.1:27123"
export QWEN_MODEL_PATH="/Users/nusun/models/llm/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-IQ2_M.gguf"
export DISABLE_UVLOOP=True

# --- [审计与推理链路] ---

# 极速非流式版本
cc() {
    local prompt="$1"
    # 直接发送请求，不再调用 /v1/models 浪费时间
    curl -s http://127.0.0.1:9090/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"default\", \"messages\": [{\"role\": \"user\", \"content\": \"${prompt}\"}], \"stream\": false}" \
    | jq -r '.choices[0].message.content'
}

# 极速流式版本（带实时思考渲染）
ccs() {
    local prompt="$1"
    local in_think=0

    curl -sN http://127.0.0.1:9090/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"default\", \"messages\": [{\"role\": \"user\", \"content\": \"${prompt}\"}], \"stream\": true}" \
    | while read -r line; do
        [[ "$line" == "data: [DONE]" ]] && break
        
        # 提取当前 Token
        local content=$(echo "$line" | sed 's/^data: //' | jq -r '.choices[0].delta.content // empty' 2>/dev/null)
        [[ -z "$content" ]] && continue

        # 处理思考标签的颜色切换（让终端动起来）
        if [[ "$content" == *"<think>"* ]]; then
            in_think=1
            echo -ne "\033[90m[思考中] " # 灰色显示思考
            content=${content//"<think>"/}
        fi

        echo -ne "$content"

        if [[ "$content" == *"</think>"* ]]; then
            in_think=0
            echo -ne "\033[0m\n" # 恢复颜色并换行
        fi
    done
    echo -ne "\033[0m\n" # 确保颜色重置
}

# --- [系统清理与防御] ---
cleanm4() {
    echo "🚀 正在执行 M4 深度清理..."
    sudo killall -9 idleassetsd 2>/dev/null
    rm -rf ~/Library/Caches/* ~/.cache/huggingface/hub/* 2>/dev/null
    brew cleanup --prune=all
    echo "✨ 清理完成。"
}

# ==========================================================
# M4 视觉审计系统 (NUSUN 终极优化版)
# ==========================================================

# 1. 核心 AI 服务启动器 (q)
# 静默后台启动器
q() {
    # 1. 检查端口是否占用
    if lsof -i:9090 > /dev/null; then
        echo "⚠️ M4 审计服务已经在运行 (PID: $(lsof -ti:9090))"
        return
    fi

    # 2. 使用 nohup 将其彻底甩到后台，并忽略所有输出
    echo "🚀 M4 视觉审计系统正在后台静默启动..."
    nohup /Users/nusun/llama.cpp/build/bin/llama-server \
        -m "/Users/nusun/models/llm/Qwythos-9B-Claude-Mythos-5-1M-MTP-Q4_K_M.gguf" \
        --mmproj "/Users/nusun/models/llm/mmproj-Qwythos-9B-Claude-Mythos-5-1M-F16.gguf" \
        -ngl 99 -c 32768 -np 1 --cache-ram 4096 \
        -fa on --temp 0.7 --port 9090 > /dev/null 2>&1 &
    
    echo "✨ 启动成功！你可以直接执行 audit 命令了。"
}

# 2. 审计函数 (audit) - 优化了流处理与错误屏蔽
audit() {
    local task="$1"
    local sys_prompt="你现在是M4审计系统。要求：1.用中文输出。2.输出结构严谨，包含：【分析目标】、【审计发现】、【风险等级】、【整改建议】。"
    
    curl -sN -X POST http://127.0.0.1:9090/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d "{\"model\": \"default\", \"messages\": [{\"role\": \"system\", \"content\": \"$sys_prompt\"}, {\"role\": \"user\", \"content\": \"$task\"}], \"stream\": true}" \
    2>/dev/null | while read -r line; do
        [[ "$line" == "data: [DONE]" ]] && break
        # 通过 sed 快速提取内容，tr -d '\\n' 保持流式美观
        echo "$line" | sed -n 's/.*"content":"\([^"]*\)".*/\1/p' | tr -d '\n'
    done
    echo ""
}

# 3. 同步与清理逻辑 (syncm4) - 保持了你原有的闭环逻辑
syncm4() {
    local COMMIT_MSG="M4 审计同步: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🛡️ [M4 审计] 启动全量同步..."
    
    # 代码仓库同步
    local sync_dirs=("$HOME/M4_Repo" "$HOME/dotfiles" "$HOME/brain")
    for dir in "${sync_dirs[@]}"; do
        if [ -d "$dir/.git" ]; then
            cd "$dir" || continue
            # 仅扫描敏感信息
            local leaked=$(grep -rIEl "AIza|ghp_" . --exclude-dir=.git --exclude=*.log 2>/dev/null)
            [ -n "$leaked" ] && echo "⚠️ 审计警告: $dir 发现敏感文件。" || echo "✅ $dir 扫描安全。"
            git add . && git commit -m "$COMMIT_MSG" >/dev/null 2>&1
            git push origin main >/dev/null 2>&1
        fi
    done
    curl -X POST "$OBSIDIAN_API_URL/append/" -d "- [x] **M4 同步完成**: $(date)" --silent --output /dev/null
    echo "✨ 审计链路闭环。"
}

# 4. 别名汇总
alias cs="cleanm4 && syncm4"
alias reset="~/scripts/reset.sh"
# 确保不再有 alias cc 或 alias ccs 冲突，直接删除旧定义

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
# 1. 大脑连接器函数 (确保已删除对应的 alias)
m4-connect() {
    python3 "/Users/nusun/M4_Repo/scripts/maintenance/m4_mcp_connect.py" "$1" --token "$2" --name "${3:-m4-remote-brain}"
}

# --- [配置初始化] ---
autoload -Uz compinit
compinit -i

gb-think() {
    local query="$1"
    local brain_dir="$HOME/brain"
    
    # 1. READ: 预扫描相关上下文 (Context Injection)
    local context=$(grep -rh "$query" "$brain_dir/concepts/" | head -n 10)
    
    # 2. THINK: 审计并合成
    local result=$(audit "基于以下背景知识：$context，审计问题：$query")
    
    # 3. WRITE: 自动写入归档
    echo -e "\n## $(date)\n$result" >> "$brain_dir/timeline/recent.md"
    echo "$result"
}

# --- M4 视觉审计系统 (最终版) 自动化工作流 ---

function csm() {
  echo ">>> [M4 系统] 正在同步代码并封存当前工作台..."
  
  # 1. 执行原有的同步逻辑 (syncm4)
  # 确保代码已推送到 GitHub 并同步 dotfiles
  syncm4
  
  # 检查 syncm4 是否执行成功
  if [ $? -eq 0 ]; then
    echo ">>> [M4 系统] 代码同步完成，开始保存快照..."
    crex save MacMiniM4
    echo ">>> [M4 系统] 快照 'MacMiniM4' 已封存。"
  else
    echo ">>> [!] 警告：syncm4 同步失败，快照保存已中止，以防状态不一致。"
  fi
}

function crsm() {
  echo ">>> [M4 系统] 正在还原工作台..."
  crex restore MacMiniM4
  echo ">>> [M4 系统] 还原完成，欢迎回来。"
}


# 4. 别名汇总

alias cs="cleanm4 && syncm4"
alias reset="~/scripts/reset.sh"
alias ghostty="/Applications/Ghostty.app/Contents/MacOS/ghostty"
alias litellm="litellm --model anthropic/qwen-35b-local --api_base http://127.0.0.1:8080 --port 4000"



alias csm="crex save MacMiniM4"
alias crsm="crex restore MacMiniM4"

alias py="noglob $HOME/youtube-auto-dub-v2/py"
alias dub="noglob $HOME/youtube-auto-dub-v2/py"
