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
	"sync"
	"time"
)

const (
	GitRepoPath = "/Users/nusun/Documents/Project/m4-audit-logs"
	OllamaURL   = "http://localhost:11434/api/generate"
	VisionModel = "moondream:latest"
)

var ModelList = map[string]string{
	"Mistral-Nemo": "mistral-nemo:latest",
	"Qwen-Coder":   "qwen2.5-coder:7b",
	"Abliterate":   "huihui_ai/qwen2.5-coder-abliterate:latest",
}

func main() {
	isSnap := false
	isAll := false
	for _, arg := range os.Args {
		if arg == "-snap" { isSnap = true }
		if arg == "-all" { isAll = true }
	}

	if isSnap {
		if isAll {
			runConcurrentRace()
		} else {
			// 默认单模运行
			triggerSingle("Mistral-Nemo", ModelList["Mistral-Nemo"])
		}
		return
	}
	fmt.Println("🏗️  M4 并发审计守护进程已就绪...")
	daemonLoop()
}

func runConcurrentRace() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	
	fmt.Println("📸 [并发竞技] 捕捉瞬间画面...")
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	// 统一视觉输入
	fmt.Println("👁️  Moondream 正在提取视觉底稿...")
	vDesc := callOllama(VisionModel, "Identify active windows and text content precisely.", imgBase64)

	var wg sync.WaitGroup
	fmt.Println("🔥 信号下达！三个大脑并发判定中...")

	for label, model := range ModelList {
		wg.Add(1)
		go func(l, m string) {
			defer wg.Done()
			startTime := time.Now()
			
			prompt := fmt.Sprintf("你是一个专业的系统审计官。根据底稿：'%s'。请直接输出中文审计报告。格式：\n### 🏆 审计报告 (%s)\n- **核心状态**: [总结]\n- **技术细节**: [描述]\n- **深度评估**: [见解]", vDesc, l)
			report := callOllama(m, prompt, "")
			
			duration := time.Since(startTime).Seconds()
			fmt.Printf("✅ %s 提交报告 (耗时: %.2fs)\n", l, duration)
			
			fileName := fmt.Sprintf("AR_Audit_%s_%s.md", ts, l)
			mdContent := fmt.Sprintf("# 🔬 并发对比审计 [%s]\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n> 💡 推理耗时: %.2fs | 引擎: %s\n\n%s", l, ts, duration, m, report)
			os.WriteFile(filepath.Join(GitRepoPath, fileName), []byte(mdContent), 0644)
		}(label, model)
	}

	wg.Wait() // 同步点：等待所有协程完成
	
	fmt.Println("📤 所有大脑已交卷，正在同步看板...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
	exec.Command("say", "Bingo, 并发竞技完成").Run()
}

func callOllama(model, prompt, img string) string {
	m := map[string]interface{}{"model": model, "prompt": prompt, "stream": false, "options": map[string]interface{}{"temperature": 0.2}}
	if img != "" { m["images"] = []string{img} }
	b, _ := json.Marshal(m)
	r, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "AI 离线" }
	defer r.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(r.Body).Decode(&res)
	return res.Response
}

func triggerSingle(l, m string) { /* 逻辑同上但仅针对单个模型 */ }

func daemonLoop() {
	for {
		out, _ := exec.Command("pbpaste").Output()
		sig := strings.TrimSpace(string(out))
		if sig == "snap" {
			runConcurrentRace()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if sig == "clear_all_logs" {
			// 执行 Bingo 清空逻辑
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}
