#!/bin/bash
# sync_user_md.sh — 把通用 USER 铁律(单一事实源)分发到所有项目（symlink,零漂移）
#
# 用法:
#   ~/.dotfiles/skills/sync_user_md.sh           # 重建所有链接 + 提交 dotfiles git
#   ~/.dotfiles/skills/sync_user_md.sh --no-commit
#
# 机制:
#   真源: ~/.dotfiles/skills/_USER_RULES.md  (带 git remote, 跨机同步)
#   每个项目里的 USER.md = symlink -> 真源  (改一处, 处处同步, 无副本漂移)
#   项目专属补充: 各项目内部的 USER.local.md (不进通用源, 不污染真源)

set -u
SRC="$HOME/.dotfiles/skills/_USER_RULES.md"
NO_COMMIT=0
[[ "${1:-}" == "--no-commit" ]] && NO_COMMIT=1

# 要分发到的项目根目录(如有新增项目, 在此追加)
PROJECTS=(
  "$HOME/Documents/Project/v3-dub"
  "$HOME/Documents/Project/AI_Hub"
  "$HOME/Documents/Project/GBrain"
  "$HOME/Documents/Project/MacMiniM4"
  "$HOME/Documents/Project/SB"
  "$HOME/Documents/Project/Cli"
  "$HOME/youtube-auto-dub-v2"
)

# 真源必须存在
if [[ ! -f "$SRC" ]]; then
  echo "✗ 真源不存在: $SRC" >&2
  exit 1
fi

echo "==> 真源: $SRC"
count=0
for p in "${PROJECTS[@]}"; do
  if [[ ! -d "$p" ]]; then
    echo "  - 跳过(不存在): $p"
    continue
  fi
  target="$p/USER.md"
  # 若已是正确 symlink, 跳过
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$SRC" ]]; then
    echo "  ✓ 已链接: $target"
    ((count++)); continue
  fi
  # 若已是普通文件(旧副本), 备份为 USER.local.md(仅首次), 再替换为链接
  if [[ -f "$target" && ! -L "$target" ]]; then
    bak="$p/USER.local.md"
    if [[ ! -f "$bak" ]]; then
      cp "$target" "$bak"
      echo "  ↳ 旧副本已备份为 USER.local.md: $bak"
    fi
    rm -f "$target"
  fi
  ln -s "$SRC" "$target"
  echo "  + 已链接: $target -> $SRC"
  ((count++))
done

echo "==> 已分发到 $count 个项目"

# 提交 dotfiles(真源本身有 git remote, 跨机同步)
if [[ $NO_COMMIT -eq 0 ]]; then
  d=$(cd "$(dirname "$SRC")" && git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$d" ]]; then
    cd "$d"
    git add -A
    if git diff --cached --quiet; then
      echo "==> dotfiles 无变更, 跳过提交"
    else
      git commit -m "chore: sync USER rules ($(date +%Y-%m-%d))" >/dev/null 2>&1 && \
        echo "==> 已提交 dotfiles (git push 以跨机同步)" || \
        echo "==> 提交失败(可能无改动或需手动 push)"
    fi
  fi
fi
echo "==> 完成。跨机同步: cd ~/.dotfiles && git push"
