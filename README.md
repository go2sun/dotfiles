# dotfiles

个人 macOS 环境配置 —— 新机一行命令还原软件、配置与开发环境。

## 🚀 新机还原

```bash
git clone git@github.com:go2sun/dotfiles.git ~/personal/dotfiles \
  && cd ~/personal/dotfiles && ./install.sh
```

`install.sh` 幂等、可重复运行，自动完成：

1. 安装 Homebrew
2. `brew bundle` 装齐所有软件（见 `Brewfile`）
3. 软链配置文件（`.zshrc`、git、ghostty、aerospace、cmux）
4. 部署双 GitHub 账号 SSH/git 配置
5. 运行 `macos.sh` 应用系统偏好
6. 创建 `~/personal`、`~/work` 目录并检查机密文件

被覆盖的旧文件自动备份到 `~/.dotfiles-backup/<时间戳>/`。

## 🔑 需手动带到新机的机密（不在 git 中）

install.sh 会检测并提醒补齐：

| 文件 | 用途 |
|------|------|
| `~/.ssh/id_rsa` | 个人账号 go2sun 私钥 |
| `~/.ssh/id_ed25519_work` | 工作账号 sunusun-me 私钥 |
| `~/.secrets.env` | API keys（`.zshrc` 依赖） |

建议存 1Password 或加密 U 盘。**切勿提交进仓库。**

## 👥 双 GitHub 账号

| | 个人 | 工作 |
|---|------|------|
| 账号 | go2sun | sunusun-me |
| SSH host | `github.com` | `github-work` |
| 私钥 | id_rsa | id_ed25519_work |
| 目录 | `~/personal/` | `~/work/` |

git 身份按目录自动切换（`~/work/` 下自动用工作身份）。克隆时：

```bash
# 个人
git clone git@github.com:go2sun/仓库.git ~/personal/仓库
# 工作（注意 host 是 github-work）
git clone git@github-work:sunusun-me/仓库.git ~/work/仓库
```

新增工作私钥后，把公钥加到对应 GitHub，验证：

```bash
ssh -T git@github.com      # → Hi go2sun!
ssh -T git@github-work     # → Hi sunusun-me!
```

## 📁 结构

```
.zshrc              # shell 配置（source .secrets.env）
Brewfile            # 软件清单（brew bundle）
install.sh          # 一键还原入口
macos.sh            # 系统偏好（键盘/触控板/Finder/Dock/截图）
config/
  ssh_config        # 双账号 SSH 模板
  gitconfig         # 默认身份 + 目录级 includeIf
  gitconfig-work    # 工作身份
  ghostty/ aerospace/ cmux/   # 应用配置
tmux/               # tmux 配置
scripts/            # 自用脚本
```

## 🔧 维护

```bash
# 更新软件清单
brew bundle dump --force --file=Brewfile

# 应用最新配置（重跑 install，安全幂等）
./install.sh
```

## ⚠️ 安全约定

- `.env` / `*.key` / 私钥 / `.secrets.env` 已在 `.gitignore`，永不提交。
- 若不慎提交密钥：立即在源头吊销，再用 `git filter-repo --replace-text` 清理历史。
