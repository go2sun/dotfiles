import ollama
import subprocess
import sys
import os

# 路径修复
venv_packages = os.path.expanduser("~/.venv/lib/python3.14/site-packages")
if venv_packages not in sys.path:
    sys.path.insert(0, venv_packages)

def get_mem_info():
    """仅在需要时抓取排名前5的内存大户"""
    try:
        # 获取 top 统计快照
        res = subprocess.check_output("top -l 1 -o mem -n 5 | tail -n 6", shell=True).decode('utf-8')
        return res
    except:
        return "暂时无法获取内存数据。"

def chat():
    print("\033[1;36m M4 实验室 - 智能网关 (已修复死循环)\033[0m")
    print("提示：询问 '内存' 或 '进程' 触发系统分析，输入 'quit' 退出。")
    
    while True:
        try:
            user_input = input("\n\033[1;32m用户 >> \033[0m")
            if user_input.lower() in ['quit', 'exit']: break
            if not user_input.strip(): continue

            # 智能判断是否需要抓取系统数据
            sys_context = ""
            if any(k in user_input for k in ["内存", "进程", "谁最占"]):
                print("\033[1;30m(正在调取 M4 硬件监控数据...)\033[0m")
                sys_context = f"\n当前系统内存数据：\n{get_mem_info()}"

            print("\033[1;34mLuna >> \033[0m", end='', flush=True)
            
            stream = ollama.chat(
                model='llama3.2:3b',
                messages=[
                    {'role': 'system', 'content': f'你是 Luna。{sys_context}\n请基于数据简洁回答。如果数据里有 WebKit 或 WindowServer，那是 Mac 的正常开销。'},
                    {'role': 'user', 'content': user_input}
                ],
                stream=True,
            )
            for chunk in stream:
                print(chunk['message']['content'], end='', flush=True)
            print()
            
        except KeyboardInterrupt:
            print("\n已退出。")
            break
        except Exception as e:
            print(f"\n发生错误: {e}")

if __name__ == "__main__":
    chat()
