#!/usr/bin/env python3
"""
Trae IDE 智能助手整合演示
展示如何手動觸發Agent進行系統分析
"""

import subprocess
import json
import sys
from typing import Dict, Any

class TraeAIDuo:
    """Trae AI助手整合器 - 展示如何協調使用"""
    
    def __init__(self):
        self.agent_path = "/Users/jianjunneng/0912test/auto_setup_ai_agents/root_cause_agent.py"
    
    def general_assist(self, query: str) -> str:
        """通用AI助手回答（我）"""
        return f"🤖 通用助手回應：我來幫你整體規劃 {query} 的解決方案"
    
    def trigger_agent_analysis(self, problem: Dict[str, Any]) -> Dict[str, Any]:
        """手動觸發Agent進行深度分析"""
        try:
            # 創建臨時問題文件
            with open('/tmp/agent_input.json', 'w', encoding='utf-8') as f:
                json.dump(problem, f, ensure_ascii=False, indent=2)
            
            # 執行Agent分析
            result = subprocess.run([
                sys.executable, self.agent_path, 
                'analyze', '--file', '/tmp/agent_input.json'
            ], capture_output=True, text=True, cwd="/Users/jianjunneng/0912test/auto_setup_ai_agents")
            
            if result.returncode == 0:
                return {
                    "status": "success",
                    "output": result.stdout,
                    "agent_triggered": True
                }
            else:
                return {
                    "status": "error", 
                    "error": result.stderr,
                    "agent_triggered": False
                }
                
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "agent_triggered": False
            }
    
    def demonstrate_usage(self):
        """演示實際使用流程"""
        
        print("=== Trae AI助手協作演示 ===\n")
        
        # 場景1：MySQL備份失敗問題
        mysql_problem = {
            "title": "MySQL備份失敗",
            "description": "每日自動備份任務失敗，錯誤代碼1064，備份文件大小為0KB",
            "symptoms": [
                "備份腳本執行報錯",
                "備份文件為空",
                "MySQL連接超時",
                "磁碟空間充足"
            ],
            "environment": {
                "mysql_version": "8.0.35",
                "backup_time": "2024-01-15 02:00:00",
                "script_type": "mysqldump",
                "server_load": "中等"
            }
        }
        
        print("🔍 場景：MySQL備份失敗分析")
        print("-" * 40)
        
        # 步驟1：通用助手初步回應
        print("1️⃣ 通用助手（我）初步建議：")
        print(self.general_assist("MySQL備份失敗"))
        print()
        
        # 步驟2：手動觸發Agent深度分析
        print("2️⃣ 手動觸發Agent深度分析：")
        print("   💡 使用快捷鍵：Ctrl+Shift+P → '執行Agent分析'")
        print("   💡 或使用命令：python root_cause_agent.py analyze --interactive")
        print()
        
        result = self.trigger_agent_analysis(mysql_problem)
        if result["agent_triggered"]:
            print("✅ Agent分析結果：")
            print(result["output"])
        else:
            print("❌ Agent啟動失敗：")
            print(result["error"])
        
        print("\n" + "="*50)
        print("🎯 正確使用方式總結：")
        print("❌ 不是：關鍵字自動切換")
        print("✅ 而是：明確手動觸發")
        print("\n📝 快捷操作：")
        print("   • F5：啟動Agent分析")
        print("   • Ctrl+Shift+A：分析當前文件")
        print("   • 右鍵菜單：選擇代碼→分析")

if __name__ == "__main__":
    demo = TraeAIDuo()
    demo.demonstrate_usage()