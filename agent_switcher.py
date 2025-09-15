#!/usr/bin/env python3
"""
Trae IDE Agent切換管理器
展示如何手動選擇和切換不同的專業Agent
"""

import os
import json
import subprocess
from typing import Dict, List
from pathlib import Path

class TraeAgentManager:
    """Trae IDE Agent管理器 - 手動切換不同專業Agent"""
    
    def __init__(self):
        self.agents_dir = Path("/Users/jianjunneng/0912test/auto_setup_ai_agents")
        self.installed_agents = self._discover_agents()
    
    def _discover_agents(self) -> Dict[str, Dict]:
        """發現已安裝的Agent"""
        agents = {}
        
        # 標準Agent列表
        agent_configs = {
            "root_cause": {
                "name": "根因分析Agent",
                "description": "專業系統問題診斷和根本原因分析",
                "script": "root_cause_agent.py",
                "icon": "🔍",
                "specialty": ["系統故障", "性能問題", "架構分析"]
            },
            "security": {
                "name": "安全審計Agent", 
                "description": "代碼安全漏洞掃描和分析",
                "script": "security_scan_agent.py",
                "icon": "🔒",
                "specialty": ["安全漏洞", "代碼審計", "威脅分析"]
            },
            "performance": {
                "name": "性能優化Agent",
                "description": "系統性能分析和優化建議",
                "script": "performance_agent.py", 
                "icon": "⚡",
                "specialty": ["性能瓶頸", "資源優化", "負載分析"]
            },
            "database": {
                "name": "數據庫診斷Agent",
                "description": "數據庫問題診斷和查詢優化",
                "script": "database_agent.py",
                "icon": "🗄️",
                "specialty": ["SQL優化", "數據備份", "連接問題"]
            }
        }
        
        # 檢查實際存在的Agent
        for agent_id, config in agent_configs.items():
            script_path = self.agents_dir / config["script"]
            if script_path.exists():
                agents[agent_id] = config
                agents[agent_id]["status"] = "已安裝"
            else:
                agents[agent_id] = config
                agents[agent_id]["status"] = "待安裝"
        
        return agents
    
    def list_agents(self) -> None:
        """列出所有可用Agent"""
        print("📋 Trae IDE 已安裝Agent列表:")
        print("=" * 50)
        
        for agent_id, info in self.installed_agents.items():
            status_icon = "✅" if info["status"] == "已安裝" else "❌"
            print(f"{info['icon']} {info['name']} {status_icon}")
            print(f"   ID: {agent_id}")
            print(f"   描述: {info['description']}")
            print(f"   專長: {', '.join(info['specialty'])}")
            print(f"   狀態: {info['status']}")
            print()
    
    def switch_agent(self, agent_id: str, mode: str = "interactive") -> None:
        """手動切換到指定Agent"""
        if agent_id not in self.installed_agents:
            print(f"❌ 未知的Agent: {agent_id}")
            return
            
        agent = self.installed_agents[agent_id]
        if agent["status"] != "已安裝":
            print(f"❌ Agent未安裝: {agent['name']}")
            return
        
        script_path = self.agents_dir / agent["script"]
        
        print(f"🔄 切換到 {agent['icon']} {agent['name']}")
        print(f"📁 執行: {script_path}")
        
        try:
            if mode == "interactive":
                print(f"🎯 啟動 {agent['name']} 交互模式...")
                subprocess.run(["python3", str(script_path)], cwd=self.agents_dir)
            elif mode == "demo":
                print(f"📊 運行 {agent['name']} 演示...")
                subprocess.run(["python3", str(script_path), "demo"], cwd=self.agents_dir)
        except KeyboardInterrupt:
            print("\n⏹️  Agent已停止")
        except Exception as e:
            print(f"❌ 執行錯誤: {e}")
    
    def create_switch_config(self) -> None:
        """創建Trae IDE的Agent切換配置"""
        config = {
            "version": "2.0.0",
            "tasks": [
                {
                    "label": "切換到根因分析Agent",
                    "type": "shell",
                    "command": "python3",
                    "args": ["${workspaceFolder}/root_cause_agent.py"],
                    "group": "build",
                    "presentation": {
                        "echo": True,
                        "reveal": "always",
                        "focus": False,
                        "panel": "shared"
                    }
                },
                {
                    "label": "切換到性能分析Agent",
                    "type": "shell", 
                    "command": "python3",
                    "args": ["${workspaceFolder}/performance_agent.py"],
                    "group": "build"
                }
            ],
            "launch": {
                "configurations": [
                    {
                        "name": "Python: 當前Agent",
                        "type": "python",
                        "request": "launch",
                        "program": "${file}",
                        "console": "integratedTerminal"
                    }
                ]
            }
        }
        
        config_path = self.agents_dir / ".vscode" / "tasks.json"
        config_path.parent.mkdir(exist_ok=True)
        
        with open(config_path, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Trae IDE配置已創建: {config_path}")
    
    def show_usage_guide(self) -> None:
        """顯示使用指南"""
        print("""
🎯 Trae IDE Agent切換使用指南

❌ 誤解: IDE會自動切換Agent
✅ 實際: 需要手動選擇和觸發

## 切換方式:

### 1. 命令面板切換 (Ctrl+Shift+P)
- 輸入 "Tasks: 運行任務"
- 選擇對應的Agent任務

### 2. 快捷鍵切換
- Ctrl+Shift+B: 構建任務選擇器
- F1: 命令面板

### 3. 終端手動切換
```bash
# 列出所有Agent
python3 agent_switcher.py --list

# 切換到指定Agent
python3 agent_switcher.py --switch root_cause

# 運行指定Agent的演示
python3 agent_switcher.py --switch root_cause --mode demo
```

### 4. 文件總管右鍵
- 右鍵點擊Agent文件
- 選擇 "在終端中運行"

## 當前狀態:
""")
        self.list_agents()

def main():
    manager = TraeAgentManager()
    
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == "--list":
            manager.list_agents()
        elif sys.argv[1] == "--switch" and len(sys.argv) > 2:
            mode = "demo" if "--mode" in sys.argv and "demo" in sys.argv else "interactive"
            manager.switch_agent(sys.argv[2], mode)
        elif sys.argv[1] == "--setup":
            manager.create_switch_config()
            manager.show_usage_guide()
    else:
        manager.show_usage_guide()

if __name__ == "__main__":
    main()