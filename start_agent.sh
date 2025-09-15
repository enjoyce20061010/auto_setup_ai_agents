#!/bin/bash
# Trae Agent快速啟動腳本

echo "🎯 Trae IDE Agent快速啟動"
echo "=========================="
echo ""
echo "選項:"
echo "1. 啟動根因分析Agent"
echo "2. 運行演示"
echo "3. 分析當前目錄問題"
echo "4. 檢查環境"
echo ""
read -p "請選擇 (1-4): " choice

case $choice in
    1)
        echo "🔄 啟動根因分析Agent..."
        python3 root_cause_agent.py
        ;;
    2)
        echo "📊 運行演示..."
        python3 root_cause_agent.py demo
        ;;
    3)
        echo "🔍 分析當前目錄..."
        python3 root_cause_agent.py analyze --interactive
        ;;
    4)
        echo "🔍 檢查環境..."
        python3 check_environment.py
        ;;
    *)
        echo "❌ 無效選擇"
        ;;
esac
