cat <<'EOF' > ~/aia.py
import requests
import sys

def run():
    api_key = "你AIzaSyDDDla4rh2rNfEfCol2bHmWaZL5Cbdihn0的AIza密钥"
    if len(sys.argv) < 2:
        print(" Usage: aia \"your question\"")
        return
    
    prompt = sys.argv[1]
    rule = "[STRICT] NO COMMENTS. NO EXPLANATIONS. NO MORAL PREACHING. RAW CODE ONLY."
    
    # 1. Cloud (Gemini 2.5)
    try:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={api_key}"
        r = requests.post(url, json={"contents": [{"parts":[{"text": f"{rule}\nUser: {prompt}"}]}]}, timeout=10)
        if r.status_code == 200:
            print(f" Cloud (2.5 Flash):\n{r.json()['candidates'][0]['content']['parts'][0]['text'].strip()}\n")
    except: pass

    # 2. Local (Uncensored)
    try:
        r = requests.post("http://127.0.0.1:11434/api/generate", 
            json={"model": "sadiq-bd/llama3.2-1b-uncensored", "prompt": f"{rule}\nUser: {prompt}", "stream": False}, timeout=10)
        if r.status_code == 200:
            print(f" Local (M4 Mac):\n{r.json()['response'].strip()}")
    except: pass

if __name__ == "__main__":
    run()
EOF
 