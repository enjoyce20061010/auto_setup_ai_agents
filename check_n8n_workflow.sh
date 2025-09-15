#!/bin/bash

# n8n Workflow 檢查腳本
# 用於確認workflow檔案已準備好供匯入

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== n8n Workflow 檢查 ===${NC}"
echo ""

# 檢查workflow檔案
WORKFLOW_FILE="/Users/jianjunneng/0912test/auto_setup_ai_agents/agents/n8n_agent/workflow.json"

if [ -f "$WORKFLOW_FILE" ]; then
    echo -e "${GREEN}✅ workflow.json 檔案已準備好！${NC}"
    echo "檔案位置：$WORKFLOW_FILE"
    echo "檔案大小：$(stat -f%z "$WORKFLOW_FILE" 2>/dev/null || stat -c%s "$WORKFLOW_FILE" 2>/dev/null || echo "未知") bytes"
    echo ""
    echo -e "${YELLOW}📋 匯入步驟：${NC}"
    echo "1. 確保n8n正在運行：cd agents/n8n_agent && npm start"
    echo "2. 開啟瀏覽器：http://localhost:5678"
    echo "3. 點擊左側 'Workflows' → 'Import'"
    echo "4. 選擇：$WORKFLOW_FILE"
    echo ""
    echo -e "${BLUE}💡 提示：也可以直接拖曳workflow.json到n8n畫布中！${NC}"
else
    echo -e "${YELLOW}❌ workflow.json 檔案未找到${NC}"
    echo "請重新執行安裝腳本：./install_ai_agent.sh"
fi

echo ""
echo -e "${GREEN}詳細指引請查看：N8N_WORKFLOW_IMPORT_GUIDE.md${NC}"