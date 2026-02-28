# 🚀 M4 Mac Mini Logic Studio (Dotfiles)

这是基于 Apple M4 芯片深度优化的开发环境配置仓库。集成了双 Workspace 算力管理、自动化部署及逻辑解构工具。

## 🧠 核心架构：双大脑存储 (Ollama)
针对 16GB 统一内存进行的“冷热数据分离”设计。

- **Fast Mode (内置 SSD)**: 
  - 指令: `fastollama`
  - 路径: `~/.ollama`
  - 优势: 极速预填充 (Prefill)，适合 7B-14B 常用模型。
- **Big Mode (外置 ORICO)**: 
  - 指令: `bigollama`
  - 路径: `/Volumes/ORICO/Models/ollama_models`
  - 优势: 海量存储，适合 32B+ 巨型模型测试。



## 🛠️ 常用快捷指令 (Aliases)

| 指令 | 功能 |
| :--- | :--- |
| `code` | 唤起 VS Code - Insiders 快速编辑配置 |
| `fastollama` | 切换至内置 SSD 运行 Ollama (极速模式) |
| `bigollama` | 切换至外置硬盘运行 Ollama (海量模式) |
| `stow .` | 重新同步 dotfiles 到系统目录 |

## 🛰️ 异地恢复与一键部署
在新机器上，只需执行以下流程即可 100% 还原环境：

1. **克隆仓库**: `git clone <repo_url> ~/dotfiles`
2. **运行脚本**: `cd ~/dotfiles && sh deploy.sh`
3. **恢复软件**: `brew bundle` (基于仓库内的 Brewfile)

## 🩺 逻辑手术刀 (OpenClaw)
本项目配置了专用的 Telegram Bot 接口，后端挂载本地 `Qwen2.5-Coder`。
- **配置路径**: `~/.openclaw/openclaw.json`
- **环境变量**: 已集成在 `.zshrc` 中自动加载。