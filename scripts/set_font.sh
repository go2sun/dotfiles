#!/bin/bash
# ---------- M4 审计系统：全局字体适配最终修复版 (V1.2) ----------

echo -e "\033[36m[M4 Font]\033[0m 正在为 macOS 14+ 强制应用视觉环境..."

# 1. 自动执行 iTerm2 字体切换 (硬编码名称避开 AppleScript 变量解析错误)
osascript <<EOT
tell application "iTerm2"
    tell current session of current window
        try
            set text font to "Sarasa Term SC"
            set font size to 14
        on error
            log "字体应用失败"
        end try
    end tell
end tell
EOT

echo -e "\033[32m[OK]\033[0m 已尝试下发字体切换指令。"
echo -e "\033[33m[手动确认]\033[0m 若未生效，请在 iTerm2 设置中手动选择 'Sarasa Term SC'。"
