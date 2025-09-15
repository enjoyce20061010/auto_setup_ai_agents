#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ChatGPT Agent - 中文對話助手
使用最新的OpenAI 1.0+ API
"""

import os
import sys
from openai import OpenAI

def clear_screen():
    """清除終端屏幕"""
    os.system('clear' if os.name == 'posix' else 'cls')

class ChatGPTEngine:
    def __init__(self, api_key=None):
        """初始化ChatGPT引擎"""
        self.api_key = api_key or os.getenv('OPENAI_API_KEY')
        
        if not self.api_key:
            # 嘗試從.env文件讀取
            env_file = os.path.join(os.path.dirname(__file__), '.env')
            if os.path.exists(env_file):
                with open(env_file, 'r', encoding='utf-8') as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('OPENAI_API_KEY='):
                            self.api_key = line.split('=', 1)[1].strip('"\'')
                            break
        
        if not self.api_key:
            raise ValueError("請設置 OPENAI_API_KEY 環境變量或在.env文件中配置")
        
        self.client = OpenAI(api_key=self.api_key)
        self.conversation_history = []

    def get_response(self, prompt, model="gpt-3.5-turbo"):
        """發送消息到ChatGPT並獲取回應"""
        try:
            # 添加用戶消息到對話歷史
            self.conversation_history.append({"role": "user", "content": prompt})
            
            # 調用OpenAI API
            response = self.client.chat.completions.create(
                model=model,
                messages=self.conversation_history,
                max_tokens=1000,
                temperature=0.7,
                top_p=1.0,
                frequency_penalty=0.0,
                presence_penalty=0.0
            )
            
            # 獲取AI回應
            ai_message = response.choices[0].message.content.strip()
            
            # 添加AI回應到對話歷史
            self.conversation_history.append({"role": "assistant", "content": ai_message})
            
            return ai_message
            
        except Exception as e:
            return f"API錯誤: {str(e)}"

    def clear_history(self):
        """清除對話歷史"""
        self.conversation_history = []
        print("對話歷史已清除！")

    def interactive_chat(self):
        """啟動交互式聊天"""
        clear_screen()
        print("🤖 ChatGPT Agent 已啟動")
        print("=" * 50)
        print("輸入 'quit' 或 'exit' 退出")
        print("輸入 'clear' 清除對話歷史")
        print("=" * 50)
        
        while True:
            try:
                user_input = input("\n👤 您: ").strip()
                
                if not user_input:
                    continue
                
                if user_input.lower() in ['quit', 'exit', '退出']:
                    print("👋 再見！")
                    break
                
                if user_input.lower() == 'clear':
                    self.clear_history()
                    continue
                
                # 獲取AI回應
                print("🤖 AI: ", end="", flush=True)
                response = self.get_response(user_input)
                print(response)
                
            except KeyboardInterrupt:
                print("\n\n👋 再見！")
                break
            except Exception as e:
                print(f"\n❌ 錯誤: {e}")

if __name__ == "__main__":
    try:
        # 創建ChatGPT引擎實例
        engine = ChatGPTEngine()
        
        # 啟動交互式聊天
        engine.interactive_chat()
        
    except ValueError as e:
        print(f"❌ 配置錯誤: {e}")
        print("\n請按照以下步驟操作：")
        print("1. 創建 .env 文件: touch .env")
        print("2. 添加API密鑰: echo 'OPENAI_API_KEY=您的API密鑰' > .env")
        print("3. 重新運行程序")
    except Exception as e:
        print(f"❌ 運行錯誤: {e}")
        sys.exit(1)