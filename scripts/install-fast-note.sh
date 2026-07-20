#!/usr/bin/env bash
# ============================================================
#  install-fast-note.sh — Fast Note Sync Service 用户级安装 (macOS)
#  用法: bash ~/dotfiles/scripts/install-fast-note.sh
#  幂等: 可重复运行, 不破坏已有 ~/fast-note 数据
#  设计: 用户级 (~/fast-note + ~/Library/LaunchAgents), 零 sudo,
#        以当前用户身份开机自启, 监听 127.0.0.1:9000 (仅本机回环)
#  配合: 见 docs/services/fast-note.md
# ============================================================
set -uo pipefail

INSTALL_DIR="$HOME/fast-note"
PLIST_SRC="$HOME/dotfiles/LaunchAgents/com.haierkeys.fast-note.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.haierkeys.fast-note.plist"
LOG_DIR="$INSTALL_DIR/storage/log"
G='\033[0;32m'; B='\033[0;34m'; Y='\033[0;33m'; R='\033[0;31m'; N='\033[0m'
info() { echo -e "${B}▸ $*${N}"; }
ok()   { echo -e "${G}✓ $*${N}"; }
warn() { echo -e "${Y}! $*${N}"; }

# 已装且二进制存在 => 只确保 LaunchAgent 链接, 不重下
if [ -x "$INSTALL_DIR/fast-note-sync-service" ]; then
  ok "已安装, 跳过下载: $INSTALL_DIR/fast-note-sync-service"
else
  info "下载 darwin-arm64 二进制 (GitHub Releases, 最新)"
  mkdir -p "$INSTALL_DIR"
  # 取最新 tag
  VER="$(curl -fsSL https://api.github.com/repos/haierkeys/fast-note-sync-service/releases/latest 2>/dev/null \
        | sed -nE 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' || echo "latest")"
  VER="${VER#v}"
  [ -z "$VER" ] && VER=latest
  URL="https://github.com/haierkeys/fast-note-sync-service/releases/download/${VER}/fast-note-sync-service-${VER}-darwin-arm64.tar.gz"
  TMP="$(mktemp -d)"
  info "版本=$VER 下载=$URL"
  curl -fsSL -o "$TMP/fns.tar.gz" "$URL" || { echo -e "${R}下载失败${N}"; rm -rf "$TMP"; exit 1; }
  tar -tzf "$TMP/fns.tar.gz" >/dev/null 2>&1 || { echo -e "${R}压缩包损坏${N}"; rm -rf "$TMP"; exit 1; }
  tar -xzf "$TMP/fns.tar.gz" -C "$INSTALL_DIR"
  rm -rf "$TMP"
  chmod +x "$INSTALL_DIR/fast-note-sync-service"
  ok "二进制就绪: $(file "$INSTALL_DIR/fast-note-sync-service" | cut -d: -f2)"
fi

# 配置: 若用户没有自定义 config, 用仓库带的已绑 127.0.0.1 的版本
mkdir -p "$INSTALL_DIR/config"
if [ -f "$HOME/dotfiles/config/fast-note/config.yaml" ] && [ ! -f "$INSTALL_DIR/config/config.yaml" ]; then
  cp "$HOME/dotfiles/config/fast-note/config.yaml" "$INSTALL_DIR/config/config.yaml"
  ok "已写入 config (监听 127.0.0.1:9000)"
elif [ -f "$INSTALL_DIR/config/config.yaml" ]; then
  # 已存在: 确保监听是本机回环 (避免误绑 0.0.0.0 暴露局域网)
  if grep -q 'http-port: ":9000"' "$INSTALL_DIR/config/config.yaml"; then
    sed -i.bak 's|http-port: ":9000"|http-port: "127.0.0.1:9000"|' "$INSTALL_DIR/config/config.yaml"
    warn "已将 http-port 从 :9000 收紧为 127.0.0.1:9000 (仅本机)"
  fi
  ok "config 已存在, 保留用户修改"
else
  warn "无 config 模板, 用服务自带默认 (会监听 :9000, 建议手动收紧)"
fi

mkdir -p "$LOG_DIR"

# LaunchAgent: 软链 dotfiles 里的 plist 到用户 LaunchAgents
mkdir -p "$(dirname "$PLIST_DST")"
if [ -L "$PLIST_DST" ] && [ "$(readlink "$PLIST_DST")" = "$PLIST_SRC" ]; then
  ok "LaunchAgent 已链接"
else
  [ -e "$PLIST_DST" ] && mv "$PLIST_DST" "$PLIST_DST.bak.$(date +%s)"
  ln -s "$PLIST_SRC" "$PLIST_DST"
  ok "LaunchAgent 软链: $PLIST_DST -> $PLIST_SRC"
fi

# 加载 (若已在跑则先 unload 再 load, 幂等)
launchctl unload -w "$PLIST_DST" 2>/dev/null || true
launchctl load -w "$PLIST_DST" 2>/dev/null || { warn "launchctl load 失败(可能需登录会话)"; }
sleep 2
if lsof -nP -iTCP:9000 -sTCP:LISTEN >/dev/null 2>&1; then
  ok "服务已在 127.0.0.1:9000 监听 (HTTP $(curl -sS -m5 -o /dev/null -w '%{http_code}' http://127.0.0.1:9000/ 2>/dev/null))"
else
  warn "端口未监听, 请检查日志: $LOG_DIR/launchd.err.log"
fi

echo -e "${G}================================================${N}"
ok "Fast Note Sync 安装完成 (用户级, 开机自启)"
echo "  1. 浏览器开 http://127.0.0.1:9000 注册账号"
echo "  2. 后台 -> 笔记库 -> 复制 API 配置"
echo "  3. Obsidian 装 Fast Note Sync 插件, 粘贴配置"
echo "  详见: ~/dotfiles/docs/services/fast-note.md"
