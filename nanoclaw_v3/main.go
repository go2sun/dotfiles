package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const (
	GitRepoPath = "/Users/nusun/Documents/Project/m4-audit-logs"
	OllamaURL   = "http://localhost:11434/api/generate"
	VisionModel = "moondream"
)

func main() {
	isSnap := false
	for _, arg := range os.Args {
		if arg == "-snap" { isSnap = true; break }
	}

	if isSnap {
		fmt.Println("🚀 [M4 最终版] 启动中文快照审计...")
		trigger()
		return
	}

	fmt.Println("🏗️ 启动 nanoclaw (Go 引擎)...")
	fmt.Println("👁️ [守护模式] 正在监听中文审计信号...")
	for {
		out, _ := exec.Command("pbpaste").Output()
		curr := strings.TrimSpace(string(out))
		if curr == "snap" {
			trigger()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if curr == "clear_all_logs" {
			exec.Command("sh", "-c", fmt.Sprintf("cd %s && rm -f AR_Audit_*.md screenshots/*.jpg && git add . && git commit -m '🧹 一键清空' && git push", GitRepoPath)).Run()
			exec.Command("say", "审计记录已清空").Run()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}

func trigger() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	
	fmt.Println("📸 捕捉画面...")
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)
	
	fmt.Println("🧠 AI 中文深度审计中 (Moondream)...")
	// 这里是核心：强制要求中文输出
	prompt := "你是一个专业的视觉审计专家。请分析这张屏幕截图，识别任何明显的错误、异常或核心关注点。必须使用中文回答，禁止使用英文。格式：[审计结论]: xxx，[发现故障]: xxx，[关键词]: xxx"
	
	payload, _ := json.Marshal(map[string]interface{}{
		"model": VisionModel, "prompt": prompt, "stream": false, "images": []string{imgBase64},
	})
	
	resp, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(payload))
	if err != nil { fmt.Println("❌ AI 连接失败"); return }
	defer resp.Body.Close()

	var res struct{ Response string }
	json.NewDecoder(resp.Body).Decode(&res)

	// 写入 Markdown
	md := fmt.Sprintf("# 👁️ M4 中文审计报告\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, res.Response)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 同步并播报 Bingo...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}
