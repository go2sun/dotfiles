# M4 视觉审计系统 (最终版) 极速引擎配置
alias cleanm4="pkill -9 ollama; pkill -9 openclaw; rm -rf ~/.ollama/sessions >/dev/null 2>&1; mkdir -p ~/.ollama/sessions; sleep 0.5; echo 'M4 系统重置成功'"

# 使用 4b 引擎，彻底消除 Thinking 延迟

# 仪表盘指令
alias checkqwen="cleanm4 && (ollama run qwen3.5:4b '系统自检' --verbose 2>&1 | tail -n 5 | tr '\n' ' | ' | sed 's/ | $//' | tee -a ~/dotfiles/audit_performance.log; echo '')"

alias avgm4="grep -oE 'rate: [0-9.]+' ~/dotfiles/audit_performance.log | awk '{sum+=\$2; count++} END {if (count > 0) print \"M4 平均审计速率: \", sum/count, \" tokens/s\"; else print \"尚无记录\"}'"
alias updatereadme="echo '# M4 视觉审计系统 性能看板\n\n### 最近审计记录 (Latest 5)\n\n\`\`\`text' > ~/dotfiles/README.md; tail -n 5 ~/dotfiles/audit_performance.log >> ~/dotfiles/README.md; echo '\`\`\`\n\n> 自动同步时间: \$(date)' >> ~/dotfiles/README.md"
alias syncm4="updatereadme; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m 'M4 Audit: Switch to 4B High Speed Engine' && git push"

echo "M4 视觉审计系统 (最终版) 极速引擎已就绪。"
alias qwen="cleanm4 && stty sane && ollama run qwen-m4-final --verbose"
