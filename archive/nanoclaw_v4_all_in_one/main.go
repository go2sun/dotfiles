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
)

// 模型池定义
var Models = map[string]string{
	"nemo":       "mistral-nemo:latest",
	"qwen":       "qwen2.5-coder:7b",
	"abliterate": "huihui_ai/qwen2.5-coder-abliterate:latest",
}

func main() {
	// 默认使用 Mistral-Nemo 最优解
	activeModel := Models["nemo"]

	// 参数解析
	isSnap := false
	for i, arg := range os.Args {
		if arg == "-snap" { isSnap = true }
		if arg == "-m" && i+1 < len(os.Args) {
			if val, ok := Models[os.Args[i+1]]; ok {
				activeModel = val
			}
		}
	}

	if isSnap {
		fmt.Printf("🚀 [M4 整合版] 启动审计 (大脑: %s)...\n", activeModel)
		trigger(activeModel)
		return
	}

	fmt.Printf("🏗️  M4 指挥中心已就绪 (默认大脑: %s)\n", activeModel)
	fmt.Println("👁️  正在监听: [snap] 拍照审计 / [clear_all_logs] Bingo清空...")
	daemonLoop(activeModel)
}

func trigger(modelName string) {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	
	// 1. 拍照
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	// 2. 视觉预处理
	fmt.Println("📸 视觉解析中...")
	vDesc := callOllama(VisionModel, "Analyze this screenshot precisely.", imgBase64)
	
	// 3. 核心审计 (使用当前激活模型)
	fmt.Printf("🧠 正在使用 %s 进行专家判定...\n", modelName)
	prompt := fmt.Sprintf("你是一个审计专家。根据视觉描述：'%s'。请直接输出中文报告，严禁废话。格式：\n### 📜 审计报告 (%s)\n- **核心状态**: [一句话总结]\n- **细节发现**: [描述]\n- **风险评估**: [评估或无]", vDesc, modelName)
	report := callOllama(modelName, prompt, "")

	// 4. 保存 Markdown
	md := fmt.Sprintf("# 👁️ M4 深度审计\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, report)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	// 5. 同步
	fmt.Println("📤 正在同步至云端看板...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}

func clearAll() {
	fmt.Println("🧹 收到清空指令...")
	cmd := fmt.Sprintf("cd %s && rm -f AR_Audit_*.md screenshots/*.jpg && git add . && git commit -m '🧹 重置记录' && git push", GitRepoPath)
	exec.Command("sh", "-c", cmd).Run()
	
	// 🎯 Bingo 语音反馈
	exec.Command("say", "Bingo, 清空").Run()
	fmt.Println("✅ 记录已物理清除。")
}

func callOllama(model, prompt, img string) string {
	payload := map[string]interface{}{
		"model": model, "prompt": prompt, "stream": false,
		"options": map[string]interface{}{"temperature": 0.2},
	}
	if img != "" { payload["images"] = []string{img} }
	b, _ := json.Marshal(payload)
	resp, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "AI 离线" }
	defer resp.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(resp.Body).Decode(&res)
	return res.Response
}

func daemonLoop(model string) {
	for {
		out, _ := exec.Command("pbpaste").Output()
		sig := strings.TrimSpace(string(out))
		if sig == "snap" {
			trigger(model)
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if sig == "clear_all_logs" {
			clearAll()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}
