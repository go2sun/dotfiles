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
	ChatModel   = "mistral-nemo" // 切换至 OpenClaw 官方推荐的最优解
)

func main() {
	isSnap := false
	for _, arg := range os.Args {
		if arg == "-snap" { isSnap = true; break }
	}

	if isSnap {
		fmt.Println("🚀 [OpenClaw x M4] 启动最优解审计模式...")
		trigger()
		return
	}

	fmt.Println("🏗️  启动 OpenClaw 控制台...")
	daemonLoop()
}

func trigger() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	// Step 1: Moondream 快速视觉扫描
	vDesc := callOllama(VisionModel, "Detailed visual analysis of this screenshot.", imgBase64)

	// Step 2: Mistral-Nemo 专家级中文审计
	fmt.Println("🧠 Mistral-Nemo (12B) 深度审计中...")
	qPrompt := fmt.Sprintf("你现在是 OpenClaw 审计专家。请根据以下视觉数据，用专业、严谨的中文写一份审计报告。原始数据：'%s'。必须包含：\n审计结论：[深度分析]\n故障排查：[具体风险或无]\n系统建议：[操作建议]", vDesc)
	finalReport := callOllama(ChatModel, qPrompt, "")

	md := fmt.Sprintf("# 👁️ M4 视觉审计报告 (Mistral-Nemo)\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, finalReport)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 报告已同步至看板。")
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

func daemonLoop() {
	for {
		out, _ := exec.Command("pbpaste").Output()
		if strings.TrimSpace(string(out)) == "snap" {
			trigger()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}
