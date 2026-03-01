#!/bin/bash
SESSION="M4_COMMAND_CENTER"

tmux new-session -d -s $SESSION

# 1. 顶部：全量日志与指令输入 (占 30% 高度)
tmux split-window -v -p 70
# 2. 中部：btop 核心脉搏 (占 40% 高度)
tmux select-pane -t 1
tmux split-window -v -p 50

# 3. 底部：左右对开 (状态灯 vs 同步脉搏)
tmux select-pane -t 2
tmux split-window -h

# --- 注入灵魂指令 ---
# 顶部：后端运行
tmux send-keys -t 0 "nanoclaw" C-m
# 中部：btop 图形墙 (线与点云)
tmux send-keys -t 1 "btop" C-m
# 左下：AI 大脑状态流
tmux send-keys -t 2 "watch -n 1 'echo \"🧠 AI ACTIVE STATUS\"; echo \"------------------\"; curl -s http://localhost:11434/api/tags | jq -r \".models[].name\" | sed \"s/^/🔥 /\"'" C-m
# 右下：Git 脉搏
tmux send-keys -t 3 "cd ~/Documents/Project/m4-audit-logs && watch -n 2 'git log --oneline --graph --all -n 8'" C-m

tmux select-pane -t 0
tmux attach-session -t $SESSION
