#!/bin/bash
# VS Code Trae Extension 測試腳本

echo "🎯 VS Code Trae Extension 測試"
echo "============================"
echo ""

# 檢查當前目錄
echo "📍 當前工作目錄: $(pwd)"
echo ""

# 檢查配置文件
echo "🔍 檢查配置文件:"
if [ -f ".vscode/settings.json" ]; then
    echo "✅ .vscode/settings.json 存在"
    echo "   包含Agent配置: $(grep -c 'trae.customAgents' .vscode/settings.json || echo '0')"
else
    echo "❌ .vscode/settings.json 不存在"
fi

if [ -f ".vscode/launch.json" ]; then
    echo "✅ .vscode/launch.json 存在"
else
    echo "❌ .vscode/launch.json 不存在"
fi

if [ -f ".vscode/extension.json" ]; then
    echo "✅ .vscode/extension.json 存在"
else
    echo "❌ .vscode/extension.json 不存在"
fi

echo ""
echo "🔧 測試Agent啟動:"
python3 root_cause_agent.py --help

echo ""
echo "📋 VS Code 使用提示:"
echo "1. 重新加載窗口: Ctrl+Shift+P → 'Developer: Reload Window'"
echo "2. 命令面板: Ctrl+Shift+P → 'Trae Agent'"
echo "3. 右鍵菜單: 在文件上右鍵 → 'Trae Agent'"
echo "4. 快捷鍵: Ctrl+Shift+R"
