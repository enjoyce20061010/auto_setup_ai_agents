# VS Code Trae Extension 使用指南

## 🔧 安裝確認
- **擴展名稱**: Trae AI Assistant
- **安裝方式**: VS Code Extension
- **版本**: 確保為最新版本

## 🎯 使用方法 (VS Code Extension)

### 方法1: 命令面板
1. `Ctrl+Shift+P` (Windows/Linux) 或 `Cmd+Shift+P` (Mac)
2. 輸入 "Trae Agent"
3. 選擇 "運行根因分析Agent"

### 方法2: 右鍵菜單
1. 在文件或編輯器中右鍵
2. 選擇 "Trae Agent" → "運行根因分析Agent"

### 方法3: 快捷鍵
- `Ctrl+Shift+R`: 快速啟動根因分析Agent

### 方法4: 調試面板
1. 打開調試面板 (`Ctrl+Shift+D`)
2. 選擇 "啟動根因分析Agent"

## 📋 可用命令
- **運行根因分析Agent**: 啟動交互式分析
- **運行Agent演示**: 查看演示案例

## 🚀 立即測試
```bash
# 在終端中測試
python3 root_cause_agent.py demo
```

## 🔍 問題排查
如果看不到選項：
1. 檢查Trae Extension是否啟用
2. 重新加載窗口 (`Ctrl+Shift+P` → "Developer: Reload Window")
3. 檢查輸出面板是否有錯誤信息
