#!/bin/bash
# ---------- M4 监控脚本修复版 (V2.2) ----------
LOG_PATH="$HOME/dotfiles/logs"
if [ -n "$TMUX" ]; then
    # 修复 macOS 专用的 top 命令参数
    tmux send-keys -t 0 "top -o cpu -n 10" C-m
    # 确保 tail 命令正常运行
    tmux send-keys -t 1 "tail -f $LOG_PATH/claw_audit.log" C-m
    tmux select-pane -t 0
fi
