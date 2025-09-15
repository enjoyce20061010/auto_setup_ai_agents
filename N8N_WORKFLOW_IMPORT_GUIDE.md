# n8n Workflow 匯入指引

## ✅ 已完成部署
您的n8n系統已成功部署並正在運行！

## 📁 Workflow檔案位置
**workflow.json** 檔案已準備好在以下位置：
```
/Users/jianjunneng/0912test/auto_setup_ai_agents/agents/n8n_agent/workflow.json
```

## 🎯 匯入步驟

### 方法1：透過n8n UI匯入
1. 開啟瀏覽器訪問：http://localhost:5678
2. 登入n8n（如果需要的話）
3. 點擊左側選單的 **"Workflows"**
4. 點擊 **"Import"** 按鈕
5. 選擇檔案：`/Users/jianjunneng/0912test/auto_setup_ai_agents/agents/n8n_agent/workflow.json`
6. 點擊 **"Import"** 完成匯入

### 方法2：拖曳匯入
1. 開啟 http://localhost:5678
2. 直接將workflow.json檔案拖曳到n8n畫布中
3. 系統會自動匯入workflow

## 📋 匯入後檢查
匯入成功後，您應該會看到：
- 一個名為 **"My workflow"** 的workflow
- 包含一個 **"When chat message received"** 節點
- 可以點擊 **"Chat"** 按鈕開始測試

## 🚀 快速開始
匯入完成後，點擊workflow畫布右上角的 **"Test workflow"** 即可開始使用！