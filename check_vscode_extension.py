#!/usr/bin/env python3
"""
VS Code Trae Extension 環境檢查工具
專門檢查VS Code Extension中的Trae Agent功能
"""

import json
import os
from pathlib import Path

class VSCodeExtensionChecker:
    """VS Code Extension檢查器"""
    
    def __init__(self):
        self.workspace = Path("/Users/jianjunneng/0912test/auto_setup_ai_agents")
        self.vscode_dir = self.workspace / ".vscode"
        
    def check_vscode_config(self):
        """檢查VS Code配置"""
        print("🔍 檢查VS Code Extension配置...")
        
        # 檢查settings.json
        settings_file = self.vscode_dir / "settings.json"
        if settings_file.exists():
            print(f"✅ 找到settings.json: {settings_file}")
            with open(settings_file) as f:
                settings = json.load(f)
                
            if "trae.customAgents" in settings:
                agents = settings["trae.customAgents"]
                print(f"📋 找到 {len(agents)} 個自定義Agent:")
                for agent in agents:
                    print(f"   🎯 {agent['name']} ({agent['id']})")
            else:
                print("⚠️  settings.json中未找到trae.customAgents配置")
        else:
            print(f"❌ 未找到settings.json: {settings_file}")
            
        # 檢查launch.json
        launch_file = self.vscode_dir / "launch.json"
        if launch_file.exists():
            print(f"✅ 找到launch.json: {launch_file}")
            with open(launch_file) as f:
                launch = json.load(f)
                configs = launch.get('configurations', [])
                print(f"📋 找到 {len(configs)} 個調試配置")
                for config in configs:
                    print(f"   🚀 {config['name']}")
        else:
            print(f"❌ 未找到launch.json: {launch_file}")
            
        # 檢查extension.json
        ext_file = self.vscode_dir / "extension.json"
        if ext_file.exists():
            print(f"✅ 找到extension.json: {ext_file}")
        else:
            print(f"❌ 未找到extension.json: {ext_file}")
            
    def create_test_script(self):
        """創建測試腳本"""
        test_script = """#!/bin/bash
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
"""
        
        script_path = self.workspace / "test_vscode_extension.sh"
        with open(script_path, 'w') as f:
            f.write(test_script)
        
        os.chmod(script_path, 0o755)
        print(f"✅ 測試腳本已創建: {script_path}")
        
    def show_troubleshooting_guide(self):
        """顯示問題排查指南"""
        print("\n🔍 VS Code Trae Extension 問題排查")
        print("=" * 50)
        print("")
        print("如果看不到Agent選項，請按以下步驟檢查：")
        print("")
        print("1. 🔍 檢查Trae Extension是否安裝")
        print("   - 打開擴展面板 (Ctrl+Shift+X)")
        print("   - 搜索 'Trae AI Assistant'")
        print("   - 確保已啟用")
        print("")
        print("2. 🔄 重新加載窗口")
        print("   - Ctrl+Shift+P → 'Developer: Reload Window'")
        print("")
        print("3. 📁 檢查工作區")
        print("   - 確保打開的是正確的工作目錄")
        print("   - 路徑應包含: /Users/jianjunneng/0912test/auto_setup_ai_agents")
        print("")
        print("4. ⚙️ 檢查配置")
        print("   - 查看 .vscode/settings.json 是否存在")
        print("   - 檢查是否有 trae.customAgents 配置")
        print("")
        print("5. 🐛 查看輸出")
        print("   - Ctrl+Shift+P → 'Toggle Developer Tools'")
        print("   - 查看控制台是否有錯誤")
        print("")
        print("6. 📞 聯繫支持")
        print("   - 如果問題持續，請檢查Trae Extension文檔")
        print("=" * 50)
        
    def run_full_check(self):
        """執行完整檢查"""
        print("🔍 VS Code Trae Extension 完整檢查")
        print("=" * 50)
        
        self.check_vscode_config()
        self.create_test_script()
        self.show_troubleshooting_guide()
        
        print("\n✅ 檢查完成！")
        print("\n🎯 下一步：")
        print("1. 在終端執行: ./test_vscode_extension.sh")
        print("2. 重新加載VS Code窗口")
        print("3. 使用 Ctrl+Shift+P → 'Trae Agent'")

if __name__ == "__main__":
    checker = VSCodeExtensionChecker()
    checker.run_full_check()