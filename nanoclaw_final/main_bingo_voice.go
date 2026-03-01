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
	ChatModel   = "mistral-nemo"
)

func main() {
	isSnap := false
	for _, arg := range os.Args {
		if arg == "-snap" { isSnap = true; break }
	}

	if isSnap {
		fmt.Println("🚀 [M4 终极版] 正在执行专家审计...")
		trigger()
		return
	}

	fmt.Println("🏗️  M4 视觉审计系统 (Mistral-Nemo) 守护进程已启动...")
	fmt.Println("👁️  正在监听信号: [snap] 拍照审计 / [clear_all_logs] 一键清空...")
	daemonLoop()
}

func trigger() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	vDesc := callOllama(VisionModel, "Detailed list of windows and text on screen.", imgBase64)
	qPrompt := fmt.Sprintf("你是一个资深系统审计官。请直接分析以下视觉信息：'%s'。直接按此格式输出中文：\n\n### 📜 审计报告\n- **核心状态**: [总结]\n- **细节发现**: [描述]\n- **风险评估**: [评估]", vDesc)
	finalReport := callOllama(ChatModel, qPrompt, "")

	md := fmt.Sprintf("# 👁️ M4 深度审计记录\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, finalReport)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 报告归档中...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}

func clearLogs() {
	fmt.Println("🧹 收到清空指令：正在物理删除所有历史审计记录...")
	clearCmd := fmt.Sprintf("cd %s && rm -f AR_Audit_*.md screenshots/*.jpg && git add . && git commit -m '🧹 系统重置：一键清空记录' && git push", GitRepoPath)
	exec.Command("sh", "-c", clearCmd).Run()
	
	// 🎯 核心修改：升级语音反馈
	exec.Command("say", "Bingo, 清空").Run()
	fmt.Println("✅ 数据库已重置，Bingo 语音已播报。")
}

func callOllama(model, prompt, img string) string {
	m := map[string]interface{}{"model": model, "prompt": prompt, "stream": false, "options": map[string]interface{}{"temperature": 0.2}}
	if img != "" { m["images"] = []string{img} }
	b, _ := json.Marshal(m)
	r, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "AI 引擎未响应" }
	defer r.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(r.Body).Decode(&res)
	return res.Response
}

func daemonLoop() {
	for {
		out, _ := exec.Command("pbpaste").Output()
		sig := strings.TrimSpace(string(out))
		if sig == "snap" {
			trigger()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if sig == "clear_all_logs" {
			clearLogs()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}
