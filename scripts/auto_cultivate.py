import os, requests, subprocess, whisper

# 宿主机 Ollama 地址
OLLAMA_URL = "http://192.168.64.1:11434/v1/chat/completions"
MODEL = "huihui_ai/qwen2.5-coder-abliterate:latest" # 你的 Ollama 模型名

def process_video(file_path):
    print(f"📦 发现视频: {file_path}")
    # 1. 提取音频
    audio_file = "temp_voice.mp3"
    subprocess.run(["ffmpeg", "-y", "-i", file_path, "-q:a", "0", "-map", "a", audio_file], stderr=subprocess.DEVNULL)
    
    # 2. 语音转文字 (Whisper 这里的算力消耗在虚拟机，若慢可调小模型)
    print("👂 正在听取功法内容...")
    model = whisper.load_model("base")
    result = model.transcribe(audio_file)
    text = result["text"]
    
    # 3. 发送给 M4 芯片的 Qwen 整理
    print("🧠 正在请求 M4 宗师整理心法...")
    prompt = f"你是一个修真功法专家。请将以下转录文本整理成Markdown笔记，包含【核心心法】、【运行路径】、【避坑指南】。文本内容：{text}"
    response = requests.post(OLLAMA_URL, json={
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}]
    })
    
    # 4. 保存结果
    note_name = file_path.rsplit('.', 1)[0] + "_心法笔记.md"
    with open(note_name, "w") as f:
        f.write(response.json()['choices'][0]['message']['content'])
    print(f"✨ 整理完成: {note_name}\n")
    os.remove(audio_file)

if __name__ == "__main__":
    videos = [f for f in os.listdir('.') if f.endswith('.mp4')]
    if not videos:
        print("❌ 当前目录下没找到 MP4 视频，请丢一个进去再试！")
    for v in videos:
        process_video(v)
