#!/bin/bash
# 自动创建 2x2 的工况墙
tmux new-session -d -s M4_AUDIT
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux split-window -v

# 窗格 0: 实时监控 nanoclaw 日志
tmux send-keys -t 0 "nanoclaw" C-m
# 窗格 1: 监控 git 提交流
tmux send-keys -t 1 "cd ~/Documents/Project/m4-audit-logs && watch -n 2 'git log --oneline -n 5'" C-m
# 窗格 2: 监控 Ollama 模型加载 (M4 性能实时情况)
tmux send-keys -t 2 "ollama list | grep 'latest'" C-m
# 窗格 3: 系统 top (查看 M4 核心占用)
tmux send-keys -t 3 "top -u" C-m

tmux attach-session -t M4_AUDIT
