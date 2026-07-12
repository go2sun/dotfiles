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
	VisionModel = "moondream:latest"
	ChatModel   = "qwen2.5-coder:7b"
)

func main() {
	isSnap := false
	for _, arg := range os.Args {
		if arg == "-snap" { isSnap = true; break }
	}

	if isSnap {
		fmt.Println("🚀 [M4 最终版] 启动双引擎深度审计...")
		trigger()
		return
	}

	fmt.Println("🏗️  启动 nanoclaw (双引擎版)...")
	fmt.Println("👁️  [守护模式] 正在监听中文审计信号...")
	
	for {
		out, _ := exec.Command("pbpaste").Output()
		curr := strings.TrimSpace(string(out))
		if curr == "snap" {
			trigger()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if curr == "clear_all_logs" {
			clearCmd := fmt.Sprintf("cd %s && rm -f AR_Audit_*.md screenshots/*.jpg && git add . && git commit -m '🧹 一键清空' && git push", GitRepoPath)
			exec.Command("sh", "-c", clearCmd).Run()
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

	// Step 1: Moondream 提取视觉特征
	fmt.Println("📸 Moondream 正在解析图像...")
	vDesc := callOllama(VisionModel, "Describe the content of this screenshot in detail, focusing on active windows and text.", imgBase64)

	// Step 2: Qwen2.5 翻译并扩写为专业中文
	fmt.Println("🧠 Qwen2.5 正在生成中文报告...")
	qPrompt := fmt.Sprintf("你是一个审计专家。根据描述：'%s'，写一份中文报告。格式：\n审计结论：[详细描述]\n发现故障：[异常或无]\n核心重点：[关键点]", vDesc)
	finalReport := callOllama(ChatModel, qPrompt, "")

	// 写入 Markdown
	md := fmt.Sprintf("# 👁️ M4 专家级审计\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, finalReport)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 报告已同步并播报。")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}

func callOllama(model, prompt, img string) string {
	m := map[string]interface{}{"model": model, "prompt": prompt, "stream": false}
	if img != "" { m["images"] = []string{img} }
	b, _ := json.Marshal(m)
	r, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "AI 连接失败" }
	defer r.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(r.Body).Decode(&res)
	return res.Response
}
