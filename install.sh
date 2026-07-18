#!/usr/bin/env bash
# ============================================================
#  dotfiles install.sh — 新机一键还原 (go2sun / macOS)
#  用法: git clone git@github.com:go2sun/dotfiles.git ~/personal/dotfiles \
#        && cd ~/personal/dotfiles && ./install.sh
#  幂等: 可重复运行,不会破坏已有配置 (自动备份被覆盖的文件)
# ============================================================
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[0;33m'; R='\033[0;31m'; N='\033[0m'
info() { echo -e "${B}▸ $*${N}"; }
ok()   { echo -e "${G}✓ $*${N}"; }
warn() { echo -e "${Y}! $*${N}"; }

# 安全软链: 目标已存在且非本仓库链接时,先备份再链
link() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { warn "源不存在,跳过: $src"; return; }
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "已链接: $dst"; return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP$(dirname "${dst#$HOME}")"
    mv "$dst" "$BACKUP${dst#$HOME}"
    warn "已备份旧文件 → $BACKUP${dst#$HOME}"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  ok "软链: $dst → $src"
}

echo -e "${B}================ dotfiles install ================${N}"
info "dotfiles 目录: $DOTFILES"

# ---------- 1. Homebrew ----------
info "[1/5] Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Apple Silicon 路径
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew 已安装"
else
  ok "Homebrew 已存在"
fi

# ---------- 2. Brewfile ----------
info "[2/5] 安装软件 (brew bundle)"
if [ -f "$DOTFILES/Brewfile" ]; then
  brew bundle install --file="$DOTFILES/Brewfile" || warn "部分包安装失败,可稍后重试"
  ok "Brewfile 处理完成"
else
  warn "无 Brewfile,跳过"
fi

# ---------- 3. 配置文件软链 ----------
info "[3/5] 软链配置文件"
link "$DOTFILES/.zshrc"              "$HOME/.zshrc"
link "$DOTFILES/config/gitconfig"      "$HOME/.gitconfig"
link "$DOTFILES/config/gitconfig-work" "$HOME/.gitconfig-work"
# .config 下的应用配置
for app in ghostty aerospace cmux; do
  [ -d "$DOTFILES/config/$app" ] && link "$DOTFILES/config/$app" "$HOME/.config/$app"
done
# 注: raycast 用其自带云同步,不纳入 dotfiles

# SSH config (私钥不在仓库,单独处理)
if [ -f "$DOTFILES/config/ssh_config" ]; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  link "$DOTFILES/config/ssh_config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config" 2>/dev/null || true
fi

# Hermes 外挂 skills (视觉能力等)
if [ -d "$DOTFILES/skills" ]; then
  for s in "$DOTFILES/skills"/*/; do
    [ -d "$s" ] && link "${s%/}" "$HOME/.hermes/skills/$(basename "$s")"
  done
  # 编译 image-ocr 二进制(离线兜底)
  if [ -f "$HOME/.hermes/skills/image-ocr/img-ocr.swift" ] && command -v swiftc &>/dev/null; then
    ( cd "$HOME/.hermes/skills/image-ocr" && swiftc -O img-ocr.swift -o img-ocr 2>/dev/null ) \
      && ok "image-ocr 已编译" || warn "image-ocr 编译跳过(需 Xcode CLT)"
  fi
fi

# ---------- 3.5 个人 bin 脚本 ----------
info "[3.5] 同步个人 bin 脚本 ($HOME/bin)"
mkdir -p "$HOME/bin"
if [ -d "$DOTFILES/bin" ]; then
  for s in "$DOTFILES/bin"/*; do
    name="$(basename "$s")"
    if [ -e "$HOME/bin/$name" ]; then
      ok "已存在,跳过: $name"
    else
      cp "$s" "$HOME/bin/$name" && chmod +x "$HOME/bin/$name" \
        && ok "已部署: $name" || warn "部署失败: $name"
    fi
  done
  ok "个人 bin 脚本就绪 ($HOME/bin 已在 .zshrc 的 PATH 中)"
fi

# ---------- 4. 私密文件提醒 ----------
info "[4/5] 私密文件检查 (不在 git 仓库中)"
[ -f "$HOME/.secrets.env" ] || [ -f "$DOTFILES/.secrets.env" ] \
  && ok ".secrets.env 已就位" \
  || warn ".secrets.env 缺失! 需手动创建 (含 API keys),.zshrc 依赖它"
[ -f "$HOME/.ssh/id_rsa" ]           || warn "个人私钥 ~/.ssh/id_rsa 缺失 (go2sun)"
[ -f "$HOME/.ssh/id_ed25519_work" ]  || warn "工作私钥 ~/.ssh/id_ed25519_work 缺失 (sunusun-me)"

# ---------- 5. 系统设置 ----------
info "[5/5] macOS 系统设置"
if [ -f "$DOTFILES/macos.sh" ]; then
  bash "$DOTFILES/macos.sh" && ok "系统设置已应用"
else
  warn "无 macos.sh,跳过 (可选)"
fi

# ---------- 目录骨架 ----------
mkdir -p "$HOME/personal" "$HOME/work"

echo -e "${G}================================================${N}"
ok "完成! 建议:"
echo "  1. 缺失的私钥/.secrets.env 请手动补齐 (见上方 ! 提示)"
echo "  2. 重启终端或 source ~/.zshrc"
echo "  3. 验证双账号: ssh -T git@github.com && ssh -T git@github-work"
[ -d "$BACKUP" ] && echo -e "  ${Y}被覆盖的旧文件已备份至: $BACKUP${N}"
