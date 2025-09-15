# Trae IDE 思考根因分析Agent安裝指南

## 🎯 快速安裝步驟

### 步驟1：創建Trae工作區

1. **打開Trae IDE**
2. **創建新工作區**：
   - 點擊 `File → New Workspace`
   - 選擇或創建文件夾：`~/trae-workspace/root-cause-agent`

3. **在Trae終端中執行**：
   ```bash
   mkdir -p ~/trae-workspace/root-cause-agent
   cd ~/trae-workspace/root-cause-agent
   ```

### 步驟2：複製Agent文件

#### 方法一：從現有項目複製
```bash
# 在Trae終端中執行
cp ~/0912test/auto_setup_ai_agents/root_cause_agent.py .
cp ~/0912test/auto_setup_ai_agents/requirements_root_cause.txt .
cp ~/0912test/auto_setup_ai_agents/demo_problem.json .
```

#### 方法二：直接創建新文件
在Trae中創建以下文件：

1. **創建 `root_cause_agent.py`**
2. **創建 `requirements.txt`** 內容：
   ```
   click>=8.0.0
   rich>=13.0.0
   ```

### 步驟3：配置Python環境

#### 3.1 創建虛擬環境
在Trae終端中：
```bash
python3 -m venv venv
source venv/bin/activate  # macOS
# Windows: venv\Scripts\activate
```

#### 3.2 安裝依賴
```bash
pip install -r requirements_root_cause.txt
```

### 步驟4：Trae IDE配置

#### 4.1 創建啟動配置
創建 `.vscode/launch.json`：
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "根因分析Agent",
      "type": "python",
      "request": "launch",
      "program": "${workspaceFolder}/root_cause_agent.py",
      "console": "integratedTerminal",
      "args": ["analyze", "--interactive"],
      "env": {
        "PYTHONPATH": "${workspaceFolder}"
      }
    },
    {
      "name": "演示模式",
      "type": "python", 
      "request": "launch",
      "program": "${workspaceFolder}/root_cause_agent.py",
      "console": "integratedTerminal",
      "args": ["demo"]
    }
  ]
}
```

#### 4.2 創建任務配置
創建 `.vscode/tasks.json`：
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "運行根因分析",
      "type": "shell",
      "command": "python",
      "args": ["root_cause_agent.py", "analyze", "--interactive"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true
      }
    },
    {
      "label": "運行演示",
      "type": "shell",
      "command": "python",
      "args": ["root_cause_agent.py", "demo"],
      "group": "test"
    }
  ]
}
```

## 🎮 使用方法

### 方法一：快捷鍵啟動
- **F5**：直接啟動交互式分析
- **Ctrl+Shift+P** → `Tasks: Run Task` → 選擇「運行根因分析」

### 方法二：終端命令
在Trae終端中：
```bash
# 激活虛擬環境
source venv/bin/activate

# 交互式分析
python root_cause_agent.py analyze --interactive

# 分析演示文件
python root_cause_agent.py analyze --file demo_problem.json

# 查看演示案例
python root_cause_agent.py demo
```

### 方法三：右鍵菜單集成
在 `.vscode/settings.json` 中添加：
```json
{
  "python.defaultInterpreterPath": "./venv/bin/python",
  "terminal.integrated.env.osx": {
    "PYTHONPATH": "${workspaceFolder}"
  }
}
```

## 📁 項目結構

```
root-cause-agent/
├── root_cause_agent.py      # 主程序
├── demo_problem.json        # 演示案例
├── requirements_root_cause.txt  # 依賴列表
├── .vscode/
│   ├── launch.json          # 調試配置
│   └── tasks.json           # 任務配置
├── venv/                    # 虛擬環境
└── README.md               # 使用說明
```

## 🔧 進階配置

### 自定義分析模式
創建 `custom_patterns.yaml`：
```yaml
patterns:
  custom_category:
    symptoms:
      symptom_type:
        - keyword1
        - keyword2
    root_causes:
      - cause1
      - cause2
```

### 集成到Trae AI助手
在 `.trae/settings.json` 中添加：
```json
{
  "customCommands": [
    {
      "name": "analyzeSelected",
      "description": "分析選中的問題描述",
      "command": "python root_cause_agent.py analyze --file ${selectedText}",
      "when": "editorTextFocus"
    }
  ]
}
```

## 🚀 快速測試

### 1. 立即測試
在Trae終端中執行：
```bash
# 確保在正確目錄
cd ~/trae-workspace/root-cause-agent

# 激活環境
source venv/bin/activate

# 運行演示
python root_cause_agent.py demo
```

### 2. 交互式測試
```bash
python root_cause_agent.py analyze --interactive

# 輸入示例：
# 問題標題：網站訪問緩慢
# 詳細描述：用戶反映網站加載時間超過10秒
# 症狀：頁面加載慢,超時錯誤,用戶投訴增加
```

## 📊 使用示例輸出

運行後您將看到：
```
根因分析報告
問題: 網站訪問緩慢問題
分析耗時: 2.5秒
總體置信度: 82%

根本原因:
┌─────────────────┬──────────┬─────────┐
│ 原因            │ 置信度   │ 影響級別│
├─────────────────┼──────────┼─────────┤
│ 數據庫查詢優化  │ 85%      │ high    │
│ 服務器資源瓶頸  │ 78%      │ medium  │
└─────────────────┴──────────┴─────────┘

改進建議:
1. 立即審查和更新相關配置
2. 優化業務流程並建立監控機制
3. 進行技術架構評估和優化
```

## 🛠️ 故障排除

### 常見問題

1. **找不到Python解釋器**
   - 解決：在Trae中按 `Ctrl+Shift+P` → `Python: Select Interpreter` → 選擇 `./venv/bin/python`

2. **依賴安裝失敗**
   - 解決：確保網絡連接，或使用：
   ```bash
   pip install --upgrade pip
   pip install click rich
   ```

3. **權限問題**
   - 解決：
   ```bash
   chmod +x root_cause_agent.py
   ```

## 🎯 下一步

1. **立即使用**：按F5啟動交互式分析
2. **自定義配置**：根據需要修改分析模式
3. **集成工作流**：添加到您的日常問題分析流程
4. **擴展功能**：創建自定義分析規則

---

**準備就緒！** 現在您可以在Trae IDE中直接使用這個獨立的思考根因分析Agent了。