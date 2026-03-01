package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"flag"
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
	snap := flag.Bool("snap", false, "触发单次审计")
	flag.Parse()

	if *snap {
		fmt.Println("🚀 [M4 最终版] 启动单次快照审计...")
		trigger()
	} else {
		fmt.Println("👁️ [守护模式] 监听剪贴板信号...")
		for {
			out, _ := exec.Command("pbpaste").Output()
			if strings.TrimSpace(string(out)) == "snap" {
				trigger()
				exec.Command("sh", "-c", "echo '' | pbcopy").Run()
			}
			time.Sleep(1 * time.Second)
		}
	}
}

func trigger() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	
	fmt.Println("📸 捕捉中...")
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)
	
	fmt.Println("🧠 AI 中文审计中...")
	payload, _ := json.Marshal(map[string]interface{}{
		"model":  VisionModel,
		"prompt": "请分析此屏幕。识别任何技术故障(BUG)、核心重点(FOCUS)和关键词(KEYWORDS)。必须使用中文输出。格式：BUG: [描述或无], FOCUS: [描述], KEYWORDS: [关键词列表]",
		"stream": false,
		"images": []string{imgBase64},
	})
	
	resp, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(payload))
	if err != nil {
		fmt.Println("❌ AI 连接失败")
		return
	}
	defer resp.Body.Close()

	var res struct{ Response string }
	json.NewDecoder(resp.Body).Decode(&res)

	md := fmt.Sprintf("# 👁️ M4 审计\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n%s", ts, res.Response)
	os.WriteFile(filepath.Join(GitRepoPath, fmt.Sprintf("AR_Audit_%s.md", ts)), []byte(md), 0644)
	
	fmt.Println("📤 同步云端并播报...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
}
