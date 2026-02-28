# 🚀 nusun's M4 Mac Mini Logic Factory

这是 M4 Mac Mini 的核心配置仓库，采用 `GNU Stow` 进行管理。

## 📦 包含组件
- **.zshrc**: 核心环境变量、别名（Alias）以及 Ollama 切换逻辑。
- **Brewfile**: 软件包清单。
- **deploy.sh**: 自动化部署与维护脚本。

## 🤖 Ollama 双模切换
- `fastollama`: 使用内置 SSD 路径，极致响应。
- `bigollama`: 使用 ORICO 外部存储路径，存放大型模型。

## 🚀 快速部署
```bash
git clone https://github.com/go2sun/dotfiles.git ~/dotfiles
cd ~/dotfiles
./deploy.sh
```
