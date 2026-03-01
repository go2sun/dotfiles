# 🖥️ M4 视觉审计系统 (M4 Visual Audit System)
> 最终稳定版 V2.4 - 基于 Apple MacMini M4 构建

## 📊 系统核心视觉逻辑
系统通过 `tmux` 状态栏提供直观的实时审计反馈：

* **常规模式**：左下角显示黄底红字编号，保持视觉清爽。
* **同步模式 (`Ctrl-a + s`)**：左下角立即翻转为 **红底白字 ⚠️ SYNC**，强制提醒多面板操作，杜绝误触。

## ⌨️ 快捷指令集
* **前缀键 (Prefix)**: `Ctrl + a` (已解决 macOS 系统蜂鸣冲突)。
* **面板同步**: `Prefix` + `s` (带状态栏颜色强制刷新)。
* **配置重载**: `Prefix` + `r` (应用 `~/dotfiles/tmux/tmux.conf` 的更改)。
* **云端同步**: 输入 `syncm4` 自动推送本地审计脚本与配置。

## 📁 目录结构梳理
* `/tmux/tmux.conf`: 核心逻辑定义，已消除 `bold] 0` 乱码。
* `/scripts/`: 包含 `watch_m4.sh`, `start_claw.sh` 等自动化审计脚本。
