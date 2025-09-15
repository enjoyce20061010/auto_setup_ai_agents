# ChatGPT Agent

一個使用最新OpenAI 1.0+ API的中文對話助手

## 功能特點

- ✅ 支持中文對話
- ✅ 保留對話歷史
- ✅ 交互式命令行界面
- ✅ 環境變量配置
- ✅ 錯誤處理和提示

## 安裝步驟

### 1. 安裝依賴

```bash
cd /Users/jianjunneng/0912test/auto_setup_ai_agents/agents/chatgpt_agent
pip3 install -r requirements.txt
```

### 2. 配置API密鑰

#### 方法一：使用環境變量
```bash
export OPENAI_API_KEY="您的_openai_api密鑰"
```

#### 方法二：使用.env文件
```bash
cp .env.example .env
# 編輯 .env 文件，填入您的API密鑰
```

### 3. 運行程序

```bash
python3 chatgpt_agent.py
```

## 使用方法

### 基本對話
```
🤖 ChatGPT Agent 已啟動
==================================================
輸入 'quit' 或 'exit' 退出
輸入 'clear' 清除對話歷史
==================================================

👤 您: 你好
🤖 AI: 你好！我是ChatGPT，很高興為您服務。
```

### 命令
- `quit`/`exit`/`退出`：退出程序
- `clear`：清除對話歷史
- `Ctrl+C`：強制退出

### 代碼示例

```python
from chatgpt_agent import ChatGPTEngine

# 創建引擎實例
engine = ChatGPTEngine()

# 單次對話
response = engine.get_response("你好，請介紹一下自己")
print(response)

# 清除歷史
engine.clear_history()
```

## 故障排除

### 常見錯誤

1. **ModuleNotFoundError: No module named 'openai'**
   ```bash
   pip3 install openai>=1.0.0
   ```

2. **ValueError: 請設置 OPENAI_API_KEY 環境變量**
   - 確保已設置環境變量或創建了.env文件
   - 檢查API密鑰是否正確

3. **API錯誤: 401 Unauthorized**
   - 檢查API密鑰是否有效
   - 確保賬戶有足夠的API額度

## 技術細節

- **Python版本**: 3.7+
- **OpenAI API版本**: 1.0+
- **支持模型**: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview

## 更新日誌

- v2.0.0: 升級到OpenAI 1.0+ API，支持對話歷史
- v1.0.0: 初始版本，基礎對話功能