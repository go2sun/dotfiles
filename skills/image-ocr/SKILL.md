---
name: image-ocr
description: 离线 OCR 提取图片文字(Vision 视觉的兜底方案)
---

# image-ocr — 离线图片文字识别

用 macOS Vision 框架对图片做 OCR,纯本地、无需网络/API。
作为 `see-image`(Gemini 视觉)的离线兜底:断网或无 API key 时使用。
仅提取文字,不含布局/图标等语义——优先用 see-image。

## 首次使用需编译

```bash
cd ~/.hermes/skills/image-ocr && swiftc -O img-ocr.swift -o img-ocr
```

## 用法

```bash
~/.hermes/skills/image-ocr/img-ocr <图片路径> [语言...]
```

示例:

```bash
~/.hermes/skills/image-ocr/img-ocr /tmp/shot.png zh-Hans en-US
```

## 说明

- 纯本地、毫秒级(编译后);未编译时用 `swift img-ocr.swift ...` 直跑但较慢。
- 默认识别中英文(zh-Hans, en-US)。
- 依赖:macOS(Vision.framework)、swift/swiftc(Xagsu CLT)。
