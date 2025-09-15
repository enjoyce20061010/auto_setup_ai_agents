# Trae IDE Agent使用指南

## 🎯 如何在當前IDE切換Agent

### 方法1: 命令面板 (推薦)
1. 按 `Ctrl+Shift+P` 打開命令面板
2. 輸入 "Tasks: 運行任務"
3. 選擇對應的Agent任務:
   - 🔄 切換到根因分析Agent
   - 🎯 分析當前文件
   - 📊 運行演示

### 方法2: 快捷鍵
- `Ctrl+Shift+A`: 快速啟動根因分析Agent
- `Ctrl+Shift+D`: 運行演示模式

### 方法3: 終端命令
```bash
# 在終端中手動切換
python3 root_cause_agent.py
python3 root_cause_agent.py demo
python3 root_cause_agent.py analyze --file your_file.json
```

### 方法4: 文件右鍵菜單
1. 在文件總管中選擇文件
2. 右鍵點擊
3. 選擇 "分析當前文件"

## 🔍 關鍵澄清
- **不是自動切換**: 需要手動選擇和觸發
- **標準整合**: 遵循Trae官方Agent規範
- **多模式支持**: CLI、文件、交互模式
- **即時可用**: 配置已完成，可直接使用

## 🚀 立即開始
重啟Trae IDE後，使用 `Ctrl+Shift+P` → "Tasks: 運行任務" 即可看到所有Agent選項。
