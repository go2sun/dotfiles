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
		fmt.Println("🚀 [M4 终极版] 正在调用 Mistral-Nemo 执行专家审计...")
		trigger()
		return
	}

	fmt.Println("🏗️  M4 视觉审计系统 (最优解模式) 已就绪...")
	daemonLoop()
}

func trigger() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	// Step 1: 视觉识别
	vDesc := callOllama(VisionModel, "Detailed list of windows and text on screen.", imgBase64)

	// Step 2: 专家级指令注入 (针对 Mistral-Nemo 优化)
	fmt.Println("🧠 Mistral-Nemo 正在进行专家级判定...")
	qPrompt := fmt.Sprintf("你是一个资深系统审计官。请直接分析以下视觉信息：'%s'。禁止废话，禁止重复我的指令。请直接按此格式输出中文：\n\n### 📜 审计报告\n- **核心状态**: [一句话总结当前系统最主要的操作]\n- **细节发现**: [描述具体的窗口、代码或网页内容]\n- **风险评估**: [识别潜在BUG或风险，若无则写：系统运行稳健]", vDesc)
	
	finalReport := callOllama(ChatModel, qPrompt, "")

	md := fmt.Sprintf("# 👁️ M4 深度审计记录\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, finalReport)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 专家报告已归档并播报。")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}

func callOllama(model, prompt, img string) string {
	m := map[string]interface{}{"model": model, "prompt": prompt, "stream": false, "options": map[string]interface{}{"temperature": 0.3}} // 降低随机性，增加严谨度
	if img != "" { m["images"] = []string{img} }
	b, _ := json.Marshal(m)
	r, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "AI 引擎离线" }
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
