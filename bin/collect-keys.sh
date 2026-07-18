#!/bin/bash
# collect-keys.sh — 第一层:清点 + 入库(Keychain) + 收紧原文件权限
# 安全约定: 不打印任何密钥值; 仅显示文件/长度/结果
set -uo pipefail
SECRET=/Users/nusun/bin/secret
BAK=/tmp/key-collect-bak
mkdir -p "$BAK"
LOG=/tmp/key-collect.log
: > "$LOG"

# 平行数组(下标配对), 避免关联数组解析坑
FILES=(
  "/Users/nusun/.gemini_key"
  "/Users/nusun/dotfiles/.secrets.env"
  "/Users/nusun/.hermes/.env"
  "/Users/nusun/.gemini/.env"
  "/Users/nusun/.gemini/gemini-credentials.json"
  "/Users/nusun/.config/gws/client_secret.json"
  "/Users/nusun/.msgvault/tokens"
  "/Users/nusun/.msgvault/config.toml"
  "/Users/nusun/.openclaw/service-env/ai.openclaw.gateway.env"
  "/Users/nusun/.workbuddy-key-fallback/connector-keys/1bcc8799bcc81558e7d56f788c37c351.key"
  "/Users/nusun/.config/sunshine/credentials"
  "/Users/nusun/.docker/.token_seed"
)
NAMES=(
  "gemini_key"
  "dotfiles_secrets_env"
  "hermes_env"
  "gemini_env"
  "gemini_credentials_json"
  "gws_client_secret_json"
  "msgvault_tokens"
  "msgvault_config_toml"
  "openclaw_gateway_env"
  "workbuddy_connector_key"
  "sunshine_credentials"
  "docker_token_seed"
)

n=${#FILES[@]}
for ((i=0; i<n; i++)); do
  f="${FILES[$i]}"
  name="${NAMES[$i]}"
  if [ ! -f "$f" ]; then echo "SKIP(不存在): $f" | tee -a "$LOG"; continue; fi
  sz=$(wc -c < "$f")
  if [ "$sz" -eq 0 ]; then echo "SKIP(空文件): $f" | tee -a "$LOG"; continue; fi
  val=$(cat "$f")
  "$SECRET" set "$name" "$val" >/dev/null 2>&1 && st="入库OK" || st="入库FAIL"
  cp -f "$f" "$BAK/$(basename "$f").bak" 2>/dev/null
  chmod 600 "$f" 2>/dev/null && pm="权限600" || pm="权限不变"
  printf "%-28s | %-52s | %sB | %s | %s\n" "$name" "$f" "$sz" "$st" "$pm" | tee -a "$LOG"
done
echo "--- 完成. 日志: $LOG ---"
echo "统一节点现有密钥名:"
"$SECRET" ls 2>/dev/null | sed 's/^/  /'