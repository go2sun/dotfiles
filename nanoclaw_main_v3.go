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

type OllamaReq struct {
	Model  string   `json:"model"`
	Prompt string   `json:"prompt"`
	Stream bool     `json:"stream"`
	Images []string `json:"images,omitempty"`
}

func main() {
	// 1. 参数定义与第一时间解析
	snapMode := flag.Bool("snap", false, "触发单次快照审计")
	flag.Parse()

	// 2. 目录初始化
	os.MkdirAll(filepath.Join(GitRepoPath, "screenshots"), 0755)

	if *snapMode {
		fmt.Println("🚀 [快照模式] 启动单次审计...")
		triggerScreenAudit()
		return
	}

	fmt.Println("👁️ [守护模式] 正在监听剪贴板信号 'snap'...")
	daemonLoop()
}

func daemonLoop() {
	var lastClipboard = ""
	for {
		out, _ := exec.Command("pbpaste").Output()
		curr := strings.TrimSpace(string(out))
		if curr == "snap" && curr != lastClipboard {
			fmt.Println("🔔 检测到信号，执行自动审计...")
			triggerScreenAudit()
			// 清空剪贴板防止循环
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		lastClipboard = curr
		time.Sleep(1 * time.Second)
	}
}

func triggerScreenAudit() {
	timestamp := time.Now().Format("20060102_150405")
	snapName := fmt.Sprintf("snap_%s.jpg", timestamp)
	localSnapPath := filepath.Join(os.TempDir(), "claw_snap.jpg")
	repoSnapPath := filepath.Join(GitRepoPath, "screenshots", snapName)

	fmt.Printf("📸 [捕捉屏幕]: %s\n", snapName)
	exec.Command("screencapture", "-x", "-t", "jpg", localSnapPath).Run()

	if _, err := os.Stat(localSnapPath); err == nil {
		// 复制到仓库
		exec.Command("cp", localSnapPath, repoSnapPath).Run()

		imgData, _ := os.ReadFile(localSnapPath)
		imgBase64 := base64.StdEncoding.EncodeToString(imgData)

		fmt.Println("🧠 [AI 蒸馏]: 正在进行中文深度分析...")

		// 【整合点】专家级中文提示词注入
		prompt := "请分析此屏幕。识别任何技术故障(BUG)、核心重点(FOCUS)和关键词(KEYWORDS)。必须使用中文输出。格式：BUG: [描述或无], FOCUS: [描述], KEYWORDS: [关键词列表]"

		res := callMoondream(prompt, imgBase64)

		// 生成中文 Markdown
		mdFileName := fmt.Sprintf("AR_Audit_%s.md", timestamp)
		mdContent := fmt.Sprintf("# 👁️ AR 视觉审计报告\n\n![屏幕快照](./screenshots/%s)\n\n%s", snapName, res)
		os.WriteFile(filepath.Join(GitRepoPath, mdFileName), []byte(mdContent), 0644)

		fmt.Printf("✨ [结晶成功]: %s\n", mdFileName)

		// 触发同步脚本
		fmt.Println("☁️  [同步]: 正在推送至云端看板...")
		exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
	} else {
		fmt.Println("❌ 失败: 无法捕获屏幕，请检查系统录屏权限！")
	}
}

func callMoondream(prompt, imgBase64 string) string {
	payload := OllamaReq{Model: VisionModel, Prompt: prompt, Stream: false, Images: []string{imgBase64}}
	jsonData, _ := json.Marshal(payload)
	resp, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(jsonData))
	if err != nil || resp == nil {
		return "BUG: AI 引擎离线, FOCUS: 检查 Ollama 服务, KEYWORDS: 离线, 错误"
	}
	defer resp.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(resp.Body).Decode(&res)
	return res.Response
}
