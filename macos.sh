#!/usr/bin/env bash
# ============================================================
#  macos.sh — macOS 系统设置 (保守通用版, 由 dotfiles 管理)
#  被 install.sh 调用; 也可单独运行: bash macos.sh
#  仅含安全、可逆、无破坏性的偏好设置 (不碰电源/休眠/系统文件)
#  参考: mathiasbynens/dotfiles
# ============================================================
set -uo pipefail

G='\033[0;32m'; B='\033[0;34m'; N='\033[0m'
info() { echo -e "${B}▸ $*${N}"; }

# 关闭"系统设置"以免覆盖将写入的值
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

###############################################################################
info "键盘"
###############################################################################
# 关闭长按弹出重音候选,改为按键重复
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# 按键重复速度拉快 (KeyRepeat 越小越快, InitialKeyRepeat 首次触发延迟)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# 全键盘控制: Tab 可聚焦所有控件(含弹窗按钮)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# 关闭自动大写/智能引号/智能破折号/自动纠错(写代码友好)
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
info "触控板 / 鼠标"
###############################################################################
# 轻点即点击
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
info "外观 / UI"
###############################################################################
# 深色模式
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
# 存储位置默认本地磁盘(非 iCloud)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# 保存/打印面板默认展开
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

###############################################################################
info "Finder"
###############################################################################
# 显示所有文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 显示状态栏 / 路径栏
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
# 默认按名称排序
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# 搜索默认在当前文件夹
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 改扩展名不弹警告
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# 不在网络/U盘生成 .DS_Store
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
info "Dock"
###############################################################################
# 自动隐藏 + 加快显示动画
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.4

###############################################################################
info "截图"
###############################################################################
# 截图存到 ~/Screenshots (自动创建), PNG 格式, 不要窗口阴影
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
info "应用重启使设置生效"
###############################################################################
for app in Finder Dock SystemUIServer; do killall "$app" 2>/dev/null || true; done

echo -e "${G}✓ macOS 设置已应用${N} (部分需注销/重启后完全生效)"
