# tmux 操作手册

> 真源：`dotfiles/tmux/tmux.conf` → `~/.tmux.conf`（软链）
> 前缀键：`Ctrl+A`（统一，非默认 `Ctrl+B`）
> 终端：Ghostty + tmux 3.7b + macOS 剪贴板集成

---

## 1. 会话（Session）操作

| 命令 | 快捷键 | 说明 |
|------|--------|------|
| `tmux new -s <名>` | — | 新建会话 |
| `tmux attach -t <名>` | — | 接入已有会话 |
| `tmux ls` | — | 列出所有会话 |
| `tmux kill-session -t <名>` | — | 销毁会话 |
| `tmux kill-server` | — | 销毁全部会话 |
| detach（分离，不杀） | `Ctrl+A` `d` | 退出 tmux 但会话后台保留 |

### 常用流程
```bash
# 新建并命名
tmux new -s work

# 中途 detach 去干别的
Ctrl+A d

# 回来
tmux attach -t work

# 查看哪些在跑
tmux ls
```

---

## 2. 窗口（Window）操作

| 命令 | 快捷键 | 说明 |
|------|--------|------|
| 新建窗口 | `Ctrl+A` `c` | 保留当前 pane 路径 |
| 关闭窗口 | `Ctrl+A` `&` | 关闭前确认 |
| 上一个窗口 | `Ctrl+A` `p` | |
| 下一个窗口 | `Ctrl+A` `n` | |
| 选择窗口 | `Ctrl+A` `0~9` | 按编号跳 |
| 重命名窗口 | `Ctrl+A` `,` | |
| 全屏当前 pane | `Ctrl+A` `z` | 再按一次恢复 |

---

## 3. 窗格（Pane）操作

### 分割
| 命令 | 快捷键 | 说明 |
|------|--------|------|
| 水平分割 | `Ctrl+A` `|` | 左右分 |
| 垂直分割 | `Ctrl+A` `-` | 上下分 |
| 关闭当前 pane | `Ctrl+A` `x` | 确认后关闭 |

### vi 风格导航（核心手感）
| 命令 | 快捷键 | 说明 |
|------|--------|------|
| 左移 | `Ctrl+A` `h` | vi `h` |
| 下移 | `Ctrl+A` `j` | vi `j` |
| 上移 | `Ctrl+A` `k` | vi `k` |
| 右移 | `Ctrl+A` `l` | vi `l` |

### 调整大小
先按 `Ctrl+A` 进入前缀，再按方向键：
- `Ctrl+A` `←` / `→` / `↑` / `↓`：以 1 格调整
- `Ctrl+A` `M+←` 等：以 5 格快速调整

---

## 4. 复制 / 粘贴（macOS 剪贴板）

### 进入复制模式
- `Ctrl+A` `[`   进入复制模式（vi 键位）
- `Space`        开始标记选区
- `Enter`        复制并退出（自动写入系统剪贴板）
- `q` / `Esc`    放弃复制

### 复制模式导航
| 键 | 动作 |
|----|------|
| `h/j/k/l` | 光标移动 |
| `w` / `b` | 下一个/上一个单词 |
| `0` / `$` | 行首/行尾 |
| `Ctrl+u` / `Ctrl+d` | 上/下半屏滚动 |

### 鼠标复制
- 鼠标拖选松开后**自动写入系统剪贴板**（`reattach-to-user-namespace` 集成）
- 可直接 `Cmd+V` 到其他 App

---

## 5. 同步窗格（多 pane 同时输入）

| 命令 | 快捷键 | 说明 |
|------|--------|------|
| 开启同步 | `Ctrl+A` `s` | 所有 pane 同步输入 |
| 关闭同步 | `Ctrl+A` `s` | 再按一次关闭 |

**视觉反馈**：开启后左侧状态栏显示红底白字 `SYNC`，关闭恢复 `#S` 蓝色。

---

## 6. 会话持久化（TPM + resurrect + continuum）

### 安装插件
- `Ctrl+A` `I`（大写 i）自动安装/更新所有插件

### 手动保存
- `Ctrl+A` `Ctrl+s` 立即保存当前会话布局

### 自动恢复
- 每 **15 分钟**自动保存（continuum）
- `tmux` 重启后自动恢复上次会话

### 恢复后注意事项
- `main` 会话名默认恢复，若冲突可 `tmux rename-session`

---

## 7. 配置热重载

```bash
Ctrl+A r
```
状态栏会显示 `config reloaded`。改完 `tmux.conf` 直接生效，不用杀会话。

---

## 8. 状态栏速读

```
 #[fg=#7aa2f7] #S #[default]                       ← 会话名（蓝色）
 #[fg=#565f89] %H:%M #[fg=#7aa2f7] #h #[default]  ← 时间 + 主机名（暗蓝/蓝）
 #I #W                                               ← 窗口编号 + 名称（当前窗口高亮青色 bold）
```

- `#S` = 会话名
- `#h` = 主机名（短名）
- `#I #W` = 窗口编号 + 窗口名
- 同步开启时 `#S` 被替换为 `SYNC`（红底白字）

---

## 9. 快速参考卡片（常忘的贴屏幕）

```
前缀键   Ctrl+A
hjkl     pane 导航
| -      水平/垂直分割
" !      close pane/window
c        新建窗口
d        detach（后台保留）
[        复制模式（vi 键位）
s        同步输入开关
r        重载配置
Ctrl+s   手动保存会话
```

---

## 10. 故障排查

| 症状 | 解决 |
|------|------|
| prefix 没反应 | 确认实际按的不是 `Ctrl+B`，必须是 `Ctrl+A` |
| 复制后系统剪贴板没内容 | `reattach-to-user-namespace` 是否装了 |
| 插件缺失 | `Ctrl+A I` 重装；若失败检查 `~/.tmux/plugins/tpm` 是否存在 |
| 旧配置残留 | 已确认无备份文件；若怀疑，`tmux source-file ~/.tmux.conf` |
| 会话起不来 | `tmux kill-server` 清掉残留 daemon 再 `tmux new` |

---

## 11. 真源路径

```
~/.tmux.conf                 → 软链 →  dotfiles/tmux/tmux.conf（唯一真源）
~/.tmux/plugins/             → TPM + 插件（tpm / resurrect / continuum / sensible）
dotfiles/tmux/tmux.conf      ← 改配置只改这一个文件
```

*不建议直接写 `~/.tmux.conf` 内容，改动必须在 `dotfiles/tmux/tmux.conf` 提交。*

---

*最后更新：2026-07-29 · M4/Ghostty 合并版*
