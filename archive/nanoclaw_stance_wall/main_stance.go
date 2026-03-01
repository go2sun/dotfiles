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
		runRaceWithStance(isAll)
		return
	}
	daemonLoop()
}

func runRaceWithStance(isAll bool) {
	ts := time.Now().Format("20060102_150405")
	repoImg := filepath.Join(GitRepoPath, "screenshots", fmt.Sprintf("snap_%s.jpg", ts))
	exec.Command("screencapture", "-x", "-t", "jpg", repoImg).Run()
	imgData, _ := os.ReadFile(repoImg)
	imgBase64 := base64.StdEncoding.EncodeToString(imgData)

	vDesc := callOllama(VisionModel, "Extract layout, code, and active processes.", imgBase64)

	var wg sync.WaitGroup
	// 顶级架构师立场：Jobs 的美学、Musk 的效率、Tesla 的频率
	stance := "你现在是一位跨越时空的顶级架构师，融合了 Steve Jobs 对极简的偏执、Elon Musk 对效率的狂热、以及 Tesla 对物理本质的洞察。请以‘星际节点’的高度俯瞰此屏幕状态。"

	for label, model := range ModelList {
		wg.Add(1)
		go func(l, m string) {
			defer wg.Done()
			start := time.Now()
			
			prompt := fmt.Sprintf("%s 视觉输入：'%s'。请直接输出中文审计，禁止废话。格式：\n\n### 🚀 星际节点审计 (%s)\n- **底层第一性原理**: [透视系统运行的最本质逻辑]\n- **冗余清除计划**: [指出屏幕中任何不符合极简与高效的垃圾信息]\n- **进化建议**: [基于 M4 算力的跨代优化方案]", stance, vDesc, l)
			report := callOllama(m, prompt, "")
			
			elapsed := time.Since(start).Seconds()
			fileName := fmt.Sprintf("AR_Audit_%s_%s.md", ts, l)
			mdContent := fmt.Sprintf("# 🔬 架构师立场对比 [%s]\n\n![Screenshot](./screenshots/snap_%s.jpg)\n\n> 💡 响应耗时: %.2fs\n\n%s", l, ts, elapsed, report)
			os.WriteFile(filepath.Join(GitRepoPath, fileName), []byte(mdContent), 0644)
		}(label, model)
		if !isAll { break } // 非 -all 模式只跑第一个
	}
	wg.Wait()
	exec.Command("sh", "-c", fmt.Sprintf("cd %s && ./sync.sh", GitRepoPath)).Run()
	exec.Command("say", "Bingo, 架构师已入驻").Run()
}

func callOllama(model, prompt, img string) string {
	m := map[string]interface{}{"model": model, "prompt": prompt, "stream": false, "options": map[string]interface{}{"temperature": 0.4}}
	if img != "" { m["images"] = []string{img} }
	b, _ := json.Marshal(m)
	r, err := http.Post(OllamaURL, "application/json", bytes.NewBuffer(b))
	if err != nil { return "离线" }
	defer r.Body.Close()
	var res struct{ Response string }
	json.NewDecoder(r.Body).Decode(&res)
	return res.Response
}

func daemonLoop() { /* 保持原有逻辑 */ }
