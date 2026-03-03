# M4 视觉审计系统 (最终版) 优化配置
alias cleanm4="pkill -9 ollama; pkill -9 openclaw; rm -rf ~/.ollama/sessions >/dev/null 2>&1; mkdir -p ~/.ollama/sessions; sleep 1; echo 'M4 系统暴力重置成功'"

# 核心 qwen 指令：强制 verbose 统计 + 抑制 Thinking 输出
alias qwen="cleanm4 && stty sane && ollama run qwen-audit --verbose"

# 仪表盘 checkqwen 指令：专门用于提取那一行数据
alias checkqwen="cleanm4 && (ollama run qwen-audit '系统自检' --verbose 2>&1 | tail -n 5 | tr '\n' ' | ' | sed 's/ | $//' | tee -a ~/dotfiles/audit_performance.log; echo '')"

alias avgm4="grep -oE 'rate: [0-9.]+' ~/dotfiles/audit_performance.log | awk '{sum+=\$2; count++} END {if (count > 0) print \"M4 平均审计速率: \", sum/count, \" tokens/s\"; else print \"尚无记录\"}'"
alias updatereadme="echo '# M4 视觉审计系统 性能看板\n\n### 最近审计记录 (Latest 5)\n\n\`\`\`text' > ~/dotfiles/README.md; tail -n 5 ~/dotfiles/audit_performance.log >> ~/dotfiles/README.md; echo '\`\`\`\n\n> 自动同步时间: \$(date)' >> ~/dotfiles/README.md"
alias syncm4="updatereadme; cp ~/.zshrc ~/dotfiles/; cd ~/dotfiles && git add . && git commit -m 'M4 Audit: Dashboard Fix' && git push"

echo "M4 视觉审计系统 (最终版) 优化已就绪。"
