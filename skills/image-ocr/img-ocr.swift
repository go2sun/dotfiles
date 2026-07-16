#!/usr/bin/env swift
// img-ocr.swift — 用 macOS Vision 框架对图片文件做 OCR
// 用法: swift img-ocr.swift <图片路径> [语言...]
// 例:   swift img-ocr.swift shot.png zh-Hans en-US
import Foundation
import Vision
import AppKit

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("用法: img-ocr.swift <图片路径> [语言 zh-Hans en-US ...]\n".data(using: .utf8)!)
    exit(2)
}
let path = args[1]
let langs = args.count > 2 ? Array(args[2...]) : ["zh-Hans", "en-US"]

guard let img = NSImage(contentsOfFile: path),
      let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("无法读取图片: \(path)\n".data(using: .utf8)!)
    exit(1)
}

let req = VNRecognizeTextRequest { request, error in
    guard let obs = request.results as? [VNRecognizedTextObservation] else { return }
    for o in obs {
        if let top = o.topCandidates(1).first { print(top.string) }
    }
}
req.recognitionLevel = .accurate
req.usesLanguageCorrection = true
req.recognitionLanguages = langs

let handler = VNImageRequestHandler(cgImage: cg, options: [:])
do { try handler.perform([req]) }
catch { FileHandle.standardError.write("OCR失败: \(error)\n".data(using: .utf8)!); exit(1) }
