#!/bin/bash

# 强制设置 PATH，确保能找到 git, rm, ls 和 say
export PATH=/usr/bin:/bin:/usr/local/bin:/opt/homebrew/bin:$PATH

# 1. 自动清理，保留最新 50 条
ls -t AR_Audit_*.md 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null
ls -t screenshots/snap_*.jpg 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null

# 2. 静默推送到 GitHub
git add . >/dev/null 2>&1
git commit -m "📊 审计更新：$(date +'%H:%M:%S')" >/dev/null 2>&1
git push origin master >/dev/null 2>&1

# 3. 提取中文结论并播报
LATEST=$(ls -t AR_Audit_*.md 2>/dev/null | head -n 1)

if [ -z "$LATEST" ]; then
    # 如果没有文件，说明清理过度，播报错误
    /usr/bin/say -v "Meijia" "审计文件丢失。"
    exit 1
fi

# 智能识别 BUG (排除“无”或“None”的情况)
BUG_DETAIL=$(grep "BUG:" "$LATEST" | grep -ivE "无|None" | sed 's/BUG://g' | xargs)

# 4. 终极播报 (使用绝对路径)
if [ -n "$BUG_DETAIL" ]; then
    # 发现故障：播报具体中文内容
    /usr/bin/say -v "Meijia" "发现故障。详情：$BUG_DETAIL"
else
    # 一切正常：清脆的 BINGO
    /usr/bin/say "BINGO"
fi
