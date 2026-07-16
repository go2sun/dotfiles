---
name: see-image
description: 用 Gemini 视觉分析图片,让无视觉主模型也能看懂图
---

# see-image — 外挂视觉能力

主模型(如 hy3:free)不支持图像输入时,用本 skill 调 Gemini 视觉模型
"看懂"图片,返回富语义描述(布局/图标/文字/状态/报错),而非仅 OCR 文字。

## 何时使用

用户发来图片路径(截图、照片、UI、报错等),或消息里出现
`[User attached image: ...]` / `clipboard-*.png` 之类路径时。

## 用法

```bash
bash ~/.hermes/skills/see-image/see-image.sh <图片路径> ["自定义提问"]
```

- 第一个参数:图片绝对路径(png/jpg/gif/webp)。
- 第二个参数(可选):具体想问什么。省略则给出全面描述。

示例:

```bash
# 全面描述
bash ~/.hermes/skills/see-image/see-image.sh /tmp/clipboard-xxx.png

# 定向提问
bash ~/.hermes/skills/see-image/see-image.sh /tmp/shot.png "只告诉我报错信息是什么"
```

## 说明

- 走 `GOOGLE_AI_STUDIO_API_KEY`(在 ~/dotfiles/.secrets.env),Gemini 免费额度。
- 默认模型 `gemini-2.5-flash`;可用 `GEMINI_VISION_MODEL` 环境变量覆盖。
- 主模型仍是 hy3:free,不产生额外主模型费用——视觉走 Gemini 免费档。
- 拿到返回后,把结果当作"我看到的内容"向用户复述/分析。

## 依赖

- curl、python3(系统自带)
- 有效的 Gemini API key
