#!/bin/bash

# 1. 环境初始化
open -a "AeroSpace"
open -a "Sunshine"

# 2. Workspace 1: 工作 (核心 5K 屏)
open -a "MetaTrader 5"
sleep 1
aerospace move-node-to-workspace 1 --window-id $(pgrep -x "MetaTrader 5")
aerospace focus --window-id $(pgrep -x "MetaTrader 5") && aerospace fullscreen on

# 3. Workspace 2: 学习 (三分屏联动)
# 核心：Chrome
open -a "Google Chrome" && sleep 0.5 && aerospace move-node-to-workspace 2
# 左屏：Terminal
open -a "Terminal" && sleep 0.5 && aerospace move-node-to-workspace 2
# 右屏：Gemini
open -a "Gemini" && sleep 0.5 && aerospace move-node-to-workspace 2

# 4. Workspace 3: 生活
open -a "WeChat" && sleep 0.5 && aerospace move-node-to-workspace 3

# 强制切回默认状态
aerospace workspace 1
say "Triple screen command center ready."
EOF

chmod +x ~/.config/aerospace/init-m4.sh