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
	"strings" // 确保这里导入了
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
	activeModelKey := "Mistral-Nemo"

	for i, arg := range os.Args {
		if arg == "-snap" { isSnap = true }
		if arg == "-all" { isAll = true }
		if arg == "-m" && i+1 < len(os.Args) {
			activeModelKey = os.Args[i+1]
		}
	}

	if isSnap {
		if isAll {
			runConcurrentRaceWithStance()
		} else {
			if _, ok := ModelList[activeModelKey]; ok {
				triggerSingleWithStance(activeModelKey, ModelList[activeModelKey])
			} else {
				fmt.Printf("⚠️ 模型 %s 不存在，使用 Mistral-Nemo\n", activeModelKey)
				triggerSingleWithStance("Mistral-Nemo", ModelList["Mistral-Nemo"])
			}
		}
		return
	}
	fmt.Println("🏗️  M4 并发专家审计守护进程 (架构师立场) 已就绪...")
	daemonLoop()
}

func runConcurrentRaceWithStance() {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	
	fmt.Println("📸 [并发竞技] 捕捉瞬间画面...")
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	fmt.Println("👁️  Moondream 正在提取视觉底稿...")
	vDesc := callOllama(VisionModel, "Extract layout, code, and active processes accurately.", imgBase64)

	var wg sync.WaitGroup
	fmt.Println("🔥 信号下达！三模并发专家判定中...")

	// 顶级架构师立场：Jobs 的美学、Musk 的效率、Tesla 的频率
	stancePrompt := "你现在是一位跨越时空的顶级架构师，融合了 Steve Jobs 对极简的偏执、Elon Musk 对效率的狂热、以及 Tesla 对物理本质的洞察。请以‘星际节点’的高度俯瞰此屏幕状态。"

	for label, model := range ModelList {
		wg.Add(1)
		go func(l, m, s string) {
			defer wg.Done()
			start := time.Now()
			
			prompt := fmt.Sprintf("%s 视觉底稿：'%s'。请直接以顶级架构师的立场输出中文审计报告，禁止废话。格式：\n\n### 🚀 星际节点审计 (%s)\n- **底层第一性原理**: [从本质逻辑透视系统运行]\n- **冗余清除计划**: [指出屏幕中任何不符合极简与高效的垃圾信息]\n- **进化建议**: [给出只有专家能看懂的跨代优化方案]", s, vDesc, l)
			report := callOllama(m, prompt, "")
			
			elapsed := time.Since(start).Seconds()
			fmt.Printf("✅ %s 完成报告 (耗时: %.2fs)\n", l, elapsed)
			
			fileName := fmt.Sprintf("AR_Audit_%s_%s.md", ts, l)
			mdContent := fmt.Sprintf("# 🔬 并发对比审计 [%s]\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n> 💡 推理耗时: %.2fs | 引擎: %s\n\n%s", l, ts, elapsed, m, report)
			os.WriteFile(filepath.Join(GitRepoPath, fileName), []byte(mdContent), 0644)
		}(label, model, stancePrompt)
	}

	wg.Wait()
	fmt.Println("📤 所有大脑已交卷，正在同步看板...")
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
	exec.Command("say", "Bingo, 并发竞技完成").Run()
}

func triggerSingleWithStance(l, m string) { /* 逻辑同上但仅针对单个模型 */ }

func callOllama(model, prompt, img string) string {
	payload := map[string]interface{}{
		"model": model, "prompt": prompt, "stream": false,
		"options": map[string]interface{}{"temperature": 0.4},
	}
	if img != "" { payload["images"] = []string{img} }
	b, _ := json.Marshal(payload)
	resp, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "引擎离线" }
	defer resp.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(resp.Body).Decode(&res)
	return res.Response
}

func daemonLoop() {
	for {
		out, _ := exec.Command("pbpaste").Output()
		sig := strings.TrimSpace(string(out)) // 确保这里使用了 strings 包
		if sig == "snap" {
			// 这里根据需要决定是 runAll 还是 triggerSingle
			runConcurrentRaceWithStance() 
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		} else if sig == "clear_all_logs" {
			exec.Command("sh", "-c", "cd /Users/nusun/Documents/Project/m4-audit-logs && rm -f AR_Audit_*.md screenshots/*.jpg && git add . && git commit -m '🧹 重置记录' && git push").Run()
			exec.Command("say", "Bingo, 清空").Run()
			exec.Command("sh", "-c", "echo '' | pbcopy").Run()
		}
		time.Sleep(1 * time.Second)
	}
}
