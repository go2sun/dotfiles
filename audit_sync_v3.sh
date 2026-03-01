#!/bin/bash
# 1. 自动清理，保留最新 50 条
ls -t AR_Audit_*.md | tail -n +51 | xargs rm -f 2>/dev/null
ls -t screenshots/snap_*.jpg | tail -n +51 | xargs rm -f 2>/dev/null

# 2. 推送到 GitHub
git add . >/dev/null 2>&1
git commit -m "📊 审计更新" >/dev/null 2>&1
git push origin master >/dev/null 2>&1

# 3. 提取中文结论并播报
LATEST=$(ls -t AR_Audit_*.md | head -n 1)
BUG_DETAIL=$(grep "BUG:" "$LATEST" | grep -ivE "无|None" | sed 's/BUG://g' | xargs)

if [ -n "$BUG_DETAIL" ]; then
    say -v "Meijia" "发现故障。详情：$BUG_DETAIL"
else
    # 只要运行成功，就清脆地 BINGO
    say "BINGO"
fi
