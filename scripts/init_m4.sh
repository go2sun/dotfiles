#!/bin/bash
echo -e "\033[36m[M4 Init]\033[0m 正在清理旧环境并检查配置链接..."
rm -f ~/.tmux0.conf ~/.tmux1.conf
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
SESSION_NAME="M4_Audit"
if ! tmux has-session -t $SESSION_NAME 2>/dev/null; then
    tmux new-session -d -s $SESSION_NAME -n "Main"
    echo -e "\033[32m[M4 Init]\033[0m 正在部署双面板审计监控..."
    tmux send-keys -t $SESSION_NAME:Main "~/dotfiles/scripts/start_claw.sh" C-m
    sleep 1
    tmux send-keys -t $SESSION_NAME:Main "~/dotfiles/scripts/watch_m4.sh" C-m
fi
echo -e "\033[33m[M4 Init]\033[0m 引导完成。系统已就绪。"
tmux attach-session -t $SESSION_NAME
