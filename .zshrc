# ========== [ Hermes Agent: RTK + Caveman 别名 ] ==========
alias cgs='~/bin/caveman_wrapper.sh git-status'
alias cgl='~/bin/caveman_wrapper.sh git-log'
alias clint='~/bin/caveman_wrapper.sh lint'
alias ctest='~/bin/caveman_wrapper.sh test-results'
alias gs='rtk git status'
alias gl='rtk git log --oneline -10'
alias gd='rtk git diff'
alias verify-hermes='~/bin/verify_caveman_setup.sh'
# ========== [ Oh My Zsh 启用段 ] ==========
export ZSH="$HOME/.oh-my-zsh"
# 最小默认配置: 仅启用 OMZ 框架本身, 不额外加载插件以保持资源占用基准纯净
ZSH_THEME=""
plugins=(git z sudo extract)
source "$ZSH/oh-my-zsh.sh"
# (启用后用户自定义 alias/function 在此段之后仍完全生效)

# ========== [ M4 视觉审计系统 (NUSUN 终极完美版) ] ==========
source "$HOME/dotfiles/.secrets.env"
export SYSTEM_NAME="NUSUN"
export BRAIN_DIR="$HOME/brain"

# 路径一体化整合 (M4 视觉审计系统)
# 1. 设置基础路径：优先系统和 Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

export CF_API_TOKEN="redacted-old-cf-token"


# 将 Cargo 路径加入系统 PATH
export PATH="$HOME/.cargo/bin:$PATH"


export NBLM_PROJECT_NUMBER="635392071609"
export NBLM_LOCATION="global"
export NBLM_ENDPOINT_LOCATION="global"

# 统一入口配置
# 清掉 OMZ git 插件占用的同名 alias, 避免与下面的 brain 系列函数冲突(parse error)
unalias gbm gbd gbl 2>/dev/null
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
alias ql='cleanup-daily.sh'
alias reset="~/scripts/reset.sh"
alias ghostty="/Applications/Ghostty.app/Contents/MacOS/ghostty"
alias litellm="litellm --model anthropic/qwen-35b-local --api_base http://127.0.0.1:8080 --port 4000"



alias csm="crex save MacMiniM4"
alias crsm="crex restore MacMiniM4"

# ========== CliBrain 知识库快捷入口 ==========
# 关 banghist: 让 ! 变普通字符, capture 整句无引号可直接敲(含中文感叹号)
unsetopt banghist
alias kc='kb capture '
alias ks='kb search '
alias kn='kb new '
alias kd='kb doctor'
alias ki='kb index '
alias ka='kb ask '
alias kg='kb grep '
# kp: 剪贴板内容一键入库(⌘C 后 kp 即可)
alias kp='pbpaste | kb capture '
# sou: 重新加载 zshrc 配置(用函数, 避免 global alias 选项坑)
sou() { source ~/dotfiles/.zshrc }
# 子命令补全: kb <Tab> 列出 new/capture/search...
_kb() {
  local -a subcmds
  subcmds=(
    'new:新建笔记(带 frontmatter 模板)'
    'capture:随手记进 inbox(最高频)'
    'grep:ripgrep 直通(精确串/报错)'
    'doctor:健康检查'
    'index:建/更新索引(--full 推倒重建)'
    'ask:语义+RAG 问答(需起 embedding/LLM 服务)'
    'search:BM25 检索(主题, --phrase 短语, --fzf 预览)'
    'notes-pull:Apple Notes 单向汇入(手动)'
  )
  _describe 'subcommand' subcmds
}
compdef _kb kb


# youtube-auto-dub 统一配音入口 (V1/V2/V3 体验一致)
# cd 进任一版本目录后, 三命令等价: py/dub/python <URL> 均一键配音
# python 非URL参数会透传给真 python3, 不影响日常用途
alias py="noglob $HOME/bin/dub-dispatch py"
alias dub="noglob $HOME/bin/dub-dispatch dub"
python() { "$HOME/bin/dub-dispatch" python "$@"; }

# dinotty MCP 用(从密钥节点注入, 不写明文)
export DINOTTY_TOKEN="$(secret get dinotty-token)"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# >>> Claude Code Haha PATH >>>
export PATH="$HOME/.local/bin:$PATH"
# <<< Claude Code Haha PATH <<<
# Obsidian REST API 密钥: 从本地 Keychain(login) 注入, 不落盘明文
# 条目: secret:obsidian-rest-key (secret set obsidian-rest-key '<值>')
export OBSIDIAN_API_SECRET="$(secret get obsidian-rest-key 2>/dev/null || true)"

# 通用长音视频转写/知识提炼流水线 — 实例化与跳转
# 模板真身: ~/Documents/Project/youtube-auto-dub/youtube_auto_dub-prompt/media-pipeline-template
# 用法: np <主题> <音视频路径>  例: np ai-lecture /Volumes/ORICO/raw/lec.mkv
#      dp                        跳到统一管理目录(模板+样例)
np() {
  local base="$HOME/Documents/Project/youtube-auto-dub/youtube_auto_dub-prompt"
  local tpl="$base/media-pipeline-template/new_project.sh"
  [ -f "$tpl" ] || { echo "❌ 模板脚本缺失: $tpl" >&2; return 1 }
  "$tpl" "$@"
}
# newproj: np 的兼容别名(主用 np, 老习惯也能用)
newproj() { np "$@"; }
# dp: cd 进流水线统一管理目录(模板+样例都在这), 极短导航替代 dubproj
dp() { cd "$HOME/Documents/Project/youtube-auto-dub/youtube_auto_dub-prompt" || return 1; }

 

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# ========== [ tmux 一键接入 (配合 Ghostty super+t) ] ==========
# 不在 tmux 会话内 -> 进 main(没有就新建); 已在 tmux 内 -> 提示防嵌套
tta() {
  if [ -n "$TMUX" ]; then
    echo "已在 tmux 会话内 (${TMUX##*/})，勿嵌套。先 Ctrl+B d 脱离再 attach。"
    return 0
  fi
  if tmux has-session -t main 2>/dev/null; then
    tmux attach -t main
  else
    tmux new -s main
  fi
}

# ========== [ Starship 提示符 ] =========
eval "$(starship init zsh)"

# ========== [ NotebookLM CLI ] =========
# notebooklm-py 工具链配置
# 安装: uv tool install notebooklm-py
# 用法: notebooklm login | notebooklm list | notebooklm ask "问题"
alias notebooklm='~/.local/share/uv/tools/notebooklm-py/bin/notebooklm'
# 快速笔记本工作流函数
nb() {
  case "$1" in
    "sync")
      # 同步本地文档到 NotebookLM
      local nb_name="${2:-$HOME/brain}"
      notebooklm use "$nb_name" 2>/dev/null || notebooklm create "$nb_name"
      notebooklm source add . "$HOME/brain"/*.md 2>/dev/null
      echo "✅ 已同步 $HOME/brain 到 NotebookLM"
      ;;
    "ask")
      notebooklm ask "$2"
      ;;
    "list")
      notebooklm list
      ;;
    *)
      echo "用法: nb {sync|ask|list} [参数]"
      echo "  nb sync <笔记本名>  - 同步本地文档"
      echo "  nb ask <问题>       - 提问 NotebookLM"
      echo "  nb list             - 列出所有笔记本"
      ;;
  esac
}

# Claude 成本监控别名

# Claude 对话隔离与使用量管理别名
alias claude-new='~/.claude/conversation-isolation.sh new'
alias claude-conversations='~/.claude/conversation-isolation.sh list'
export PATH="$HOME/.local/bin:$PATH"

# pi (pi-coding-agent) — global npm bin on PATH
export PATH="$HOME/.npm-global/bin:$PATH"
