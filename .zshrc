export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/nusun/bin"
alias syncm4="cd /Users/nusun/dotfiles && git add . && git commit -m "M4_Final_Sync" && git push origin main"
alias cddot="cd /Users/nusun/dotfiles"
alias m4v="code /Users/nusun/dotfiles"
eval "$(/opt/homebrew/bin/brew shellenv)"
alias syncbrew='brew bundle dump --force --file=~/dotfiles/Brewfile && syncm4'
alias syncm4='cd ~/dotfiles && git add . && git commit -m "M4 Audit System Final Sync 2026-03-01" && git push origin main'

# M4 视觉审计系统 - AI 引擎快捷键
alias visionm4='ollama run minicpm-v'
# --- M4 视觉审计系统 核心别名 ---
# 快捷共享会话
alias sharem4='tmux -S /tmp/shared-session new -A -s M4_Audit'
# 快速启动视觉审计 (Ollama版)
# 将 cmake 路径加入 PATH (如果 brew 路径异常)
export PATH="/opt/homebrew/bin:$PATH"
# --- M4 视觉审计系统 自动化别名 ---
# 一键同步 dotfiles 到 GitHub
alias syncm4='cd ~/dotfiles && git add . && git commit -m "Sync M4 Config $(date +%Y-%m-%d)" && git push'
# 全双工审计快速启动 (等下载完即可用)
alias audit-start='cd ~/dotfiles/scripts/llama.cpp-omni/build && ./bin/llama-omni-cli -m ~/models/minicpm-o/MiniCPM-o-2_6-Q4_K_M.gguf --mmproj ../../models/MiniCPM-o-2_6-vision-F16.gguf -ngl 99 -t 8'
# 一键同步所有配置到 GitHub 并更新 dotfiles
alias syncm4='cd ~/dotfiles && git add . && git commit -m "M4 系统配置同步 $(date +%Y-%m-%d)" && git push'
# 快速启动视觉审计大脑 (已适配 16GB M4 金属引擎)
alias audit-start='/Users/nusun/dotfiles/scripts/llama.cpp-omni/build/bin/llama-omni-cli -m ~/models/minicpm-o/MiniCPM-o-2_6-Q4_K_M.gguf --mmproj /Users/nusun/dotfiles/scripts/llama.cpp-omni/models/MiniCPM-o-2_6-vision-F16.gguf -ngl 99 -t 8'
alias m4-audit='/Users/nusun/dotfiles/scripts/llama.cpp-omni/build/bin/llama-mtmd-cli -m ~/models/minicpm-o/Model-7.6B-Q4_K_M.gguf --mmproj ~/models/minicpm-o/mmproj-model-f16.gguf -ngl 99 -c 4096 --temp 0.1'
alias m4b='/Users/nusun/dotfiles/scripts/llama.cpp-omni/build/bin/llama-mtmd-cli -m ~/models/minicpm-o/Model-7.6B-Q4_K_M.gguf --mmproj ~/models/minicpm-o/mmproj-model-f16.gguf -ngl 99 -c 4096 --temp 0.1'
export LANG="zh_CN.UTF-8"
export LC_ALL="zh_CN.UTF-8"
alias m4-brain='/Users/nusun/dotfiles/scripts/llama.cpp-omni/build/bin/llama-mtmd-cli -m ~/models/minicpm-o/Model-7.6B-Q4_K_M.gguf --mmproj ~/models/minicpm-o/mmproj-model-f16.gguf -ngl 99 -c 4096 --temp 0.1'
# OpenFang
export PATH=/Users/nusun/.openfang/bin:$PATH
alias cleanm4="killall ollama; killall openclaw; lsof -ti:18789 | xargs kill -9 2>/dev/null; echo \"M4 系统已重置\""
alias syncm4="cp ~/.zshrc ~/dotfiles/ && cd ~/dotfiles && git add . && git commit -m \"Update M4 Audit Config\" && git push"
export OLLAMA_VERBOSE=1
alias syncm4="perl -i -ne \"print unless \$seen{\$_}++\" ~/.zshrc; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m \"M4 Audit System: Updated Config with Token Monitoring\" && git push"
alias syncm4="perl -i -ne \"print unless \$seen{\$_}++\" ~/.zshrc; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m \"M4 Audit System: Updated Config with Token Monitoring\" && git push"
alias cleanm4="killall ollama; killall openclaw; lsof -ti:18789 | xargs kill -9 2>/dev/null; echo \"M4 系统已重置\""
alias glm="cleanm4 && ollama run glm-4.7-flash:8b"
alias qwen="cleanm4 && ollama run qwen3.5:9b"
alias syncm4="perl -i -ne \"print unless \$seen{\$_}++\" ~/.zshrc; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m \"M4 Audit System: Integrated Optimized Aliases\" && git push"
alias cleanm4="killall ollama; killall openclaw; lsof -ti:18789 | xargs kill -9 2>/dev/null; echo \"M4 系统已重置\""
alias glm="cleanm4 && ollama run glm-4.7-flash:8b"
alias qwen="cleanm4 && ollama run qwen3.5:9b"
alias syncm4="perl -i -ne \"print unless \$seen{\$_}++\" ~/.zshrc; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m \"M4 Audit System: Final Clean Config\" && git push"
alias qwen="cleanm4 && ollama run qwen3.5:9b"
alias cleanm4="killall ollama; killall openclaw; lsof -ti:18789 | xargs kill -9 2>/dev/null; sleep 0.5; echo \"M4 系统已重置\""
alias cleanm4="killall ollama; killall openclaw; lsof -ti:18789 | xargs kill -9 2>/dev/null; printf \"\033c\"; sleep 0.8; echo \"M4 系统已重置\""
alias qwen="cleanm4 && stty sane && ollama run qwen3.5:9b"
