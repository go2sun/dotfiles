# 🛠️ M4 Mac Mini 逻辑工厂 (Dotfiles)

本项目是针对 Apple M4 芯片优化的个人开发环境配置。通过一套精简的脚本，实现从裸机到生产力的快速迁移。

## 🧠 核心调优经验 (Distilled)

### 1. 分支架构：All-in-Main
* **教训**：弃用 `master`，全面拥抱 `main`。
* **操作**：通过 `git checkout --orphan` 彻底清理历史冗余，确保 `dotfiles` 仓库轻量化。
* **避坑**：删除远程默认分支前，必须先在 GitHub Settings 中手动切换 Default Branch。

### 2. M4 硬件适配
* **统一内存优化**：在 `.zshrc` 中针对 M4 统一内存分配 Ollama 资源。
* **自动化部署**：使用自定义 `./deploy.sh` 逻辑，通过 `ln -sf` 实现配置文件的原子级同步。

### 3. 环境快照
* **Brewfile**：记录了所有原生适配 M4 的常用工具。
* **清理幽灵引用**：定期运行 `git fetch --prune` 保持远程追踪的绝对纯净。

## 🛠️ 快速部署

```bash
git clone https://github.com/go2sun/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x deploy.sh
./deploy.sh
```

## 🧹 常用维护命令
* **同步软件列表**：`brew bundle dump --force && git add Brewfile && git commit -m "update: brew list" && git push`
* **重载配置**：`source ~/.zshrc`
- Font: JetBrainsMono Nerd Font (Manual Install via releases)
