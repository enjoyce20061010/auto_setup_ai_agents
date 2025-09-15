#!/usr/bin/env python3
"""
Trae IDE Agent環境診斷工具
檢查當前環境的切換與啟動狀態
"""

import os
import json
import subprocess
from pathlib import Path

class EnvironmentChecker:
    """環境檢查器"""
    
    def __init__(self):
        self.workspace = Path("/Users/jianjunneng/0912test/auto_setup_ai_agents")
        self.check_results = {}
    
    def check_trae_config(self):
        """檢查Trae配置"""
        print("🔍 檢查Trae IDE配置...")
        
        # 檢查Agent描述文件
        agent_config = self.workspace / ".trae" / "agents" / "root_cause.json"
        if agent_config.exists():
            print(f"  ✅ Agent配置: {agent_config}")
            with open(agent_config) as f:
                config = json.load(f)
                print(f"  📋 Agent名稱: {config.get('name', 'N/A')}")
                print(f"  🎯 類型: {config.get('type', 'N/A')}")
        else:
            print(f"  ❌ 缺少Agent配置: {agent_config}")
        
        # 檢查VS Code任務配置
        tasks_config = self.workspace / ".vscode" / "tasks.json"
        if tasks_config.exists():
            print(f"  ✅ 任務配置: {tasks_config}")
            with open(tasks_config) as f:
                tasks = json.load(f)
                print(f"  📝 任務數量: {len(tasks.get('tasks', []))}")
        else:
            print(f"  ❌ 缺少任務配置: {tasks_config}")
        
        # 檢查快捷鍵配置
        keybindings = self.workspace / ".vscode" / "keybindings.json"
        if keybindings.exists():
            print(f"  ⌨️ 快捷鍵配置: {keybindings}")
        else:
            print(f"  ❌ 缺少快捷鍵配置: {keybindings}")
    
    def check_agent_functionality(self):
        """檢查Agent功能"""
        print("\n🚀 檢查Agent功能...")
        
        # 檢查Agent腳本
        agent_script = self.workspace / "root_cause_agent.py"
        if agent_script.exists():
            print(f"  ✅ Agent腳本: {agent_script}")
        else:
            print(f"  ❌ 缺少Agent腳本: {agent_script}")
            return False
        
        # 測試Agent啟動
        try:
            result = subprocess.run([
                "python3", str(agent_script), "--help"
            ], capture_output=True, text=True, cwd=self.workspace)
            
            if result.returncode == 0:
                print("  ✅ Agent可正常啟動")
                print("  📋 可用命令:")
                for line in result.stdout.strip().split('\n'):
                    if 'Commands:' in line or line.strip().startswith('-'):
                        print(f"     {line.strip()}")
            else:
                print(f"  ❌ Agent啟動失敗: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"  ❌ 測試錯誤: {e}")
            return False
        
        return True
    
    def check_python_environment(self):
        """檢查Python環境"""
        print("\n🐍 檢查Python環境...")
        
        # 檢查Python版本
        try:
            result = subprocess.run([
                "python3", "--version"
            ], capture_output=True, text=True)
            print(f"  ✅ Python版本: {result.stdout.strip()}")
        except:
            print("  ❌ Python3不可用")
        
        # 檢查依賴
        try:
            result = subprocess.run([
                "python3", "-c", "import rich; print('rich:', rich.__version__)"
            ], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"  ✅ 依賴檢查: {result.stdout.strip()}")
            else:
                print(f"  ⚠️  依賴問題: {result.stderr}")
        except:
            print("  ⚠️  無法檢查依賴")
    
    def create_quick_start_script(self):
        """創建快速啟動腳本"""
        script_content = """#!/bin/bash
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
"""
        
        quick_script = self.workspace / "start_agent.sh"
        with open(quick_script, 'w') as f:
            f.write(script_content)
        
        os.chmod(quick_script, 0o755)
        print(f"  ✅ 快速啟動腳本: {quick_script}")
    
    def run_full_check(self):
        """執行完整檢查"""
        print("🔍 Trae IDE Agent環境診斷報告")
        print("=" * 50)
        
        self.check_trae_config()
        agent_ok = self.check_agent_functionality()
        self.check_python_environment()
        self.create_quick_start_script()
        
        print("\n" + "=" * 50)
        print("📊 診斷結果摘要:")
        
        if agent_ok:
            print("✅ Agent系統完整，可正常使用")
            print("🎯 使用方法:")
            print("   Ctrl+Shift+P → 輸入 'agent' 或 'tasks'")
            print("   ./start_agent.sh (快速啟動)")
        else:
            print("❌ 需要修復Agent系統")
        
        print("=" * 50)

if __name__ == "__main__":
    checker = EnvironmentChecker()
    checker.run_full_check()