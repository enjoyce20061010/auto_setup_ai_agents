#!/usr/bin/env python3
"""
Trae IDE 內建Agent整合配置
根據官方文檔 https://docs.trae.ai/ide/agent 創建標準配置
"""

import json
import os
from pathlib import Path

class TraeAgentIntegration:
    """Trae IDE Agent標準整合"""
    
    def __init__(self):
        self.workspace_root = Path("/Users/jianjunneng/0912test/auto_setup_ai_agents")
        self.agent_config = {
            "id": "root_cause_agent",
            "name": "根因分析專家",
            "version": "1.0.0",
            "description": "專業的系統問題診斷和根本原因分析工具",
            "type": "external",
            "runtime": {
                "type": "python",
                "command": "python3",
                "args": ["root_cause_agent.py"],
                "env": {
                    "PYTHONPATH": "/Users/jianjunneng/0912test/auto_setup_ai_agents"
                }
            },
            "capabilities": {
                "analysis": {
                    "types": ["system_issues", "performance", "architecture"],
                    "formats": ["json", "text", "interactive"]
                },
                "diagnostics": {
                    "scope": ["system", "application", "infrastructure"],
                    "depth": "comprehensive"
                }
            },
            "interaction": {
                "modes": ["cli", "file", "interactive"],
                "input_types": ["problem_description", "log_files", "metrics"],
                "output_types": ["report", "suggestions", "action_items"]
            },
            "activation": {
                "manual_trigger": True,
                "auto_trigger": False,
                "context_menu": True,
                "keyboard_shortcut": "Ctrl+Shift+A"
            }
        }
    
    def setup_trae_integration(self):
        """設置Trae IDE標準整合"""
        
        # 1. 創建Agent描述文件
        agent_desc_path = self.workspace_root / ".trae" / "agents" / "root_cause.json"
        agent_desc_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(agent_desc_path, 'w', encoding='utf-8') as f:
            json.dump(self.agent_config, f, indent=2, ensure_ascii=False)
        
        # 2. 創建VS Code配置（Trae兼容）
        vscode_config = {
            "version": "2.0.0",
            "tasks": [
                {
                    "label": "🔄 切換到根因分析Agent",
                    "type": "shell",
                    "command": "python3",
                    "args": ["${workspaceFolder}/root_cause_agent.py"],
                    "group": "build",
                    "presentation": {
                        "echo": True,
                        "reveal": "always",
                        "focus": True,
                        "panel": "shared"
                    },
                    "problemMatcher": []
                },
                {
                    "label": "🎯 分析當前文件",
                    "type": "shell",
                    "command": "python3",
                    "args": ["${workspaceFolder}/root_cause_agent.py", "analyze", "--file", "${file}"],
                    "group": "test"
                },
                {
                    "label": "📊 運行演示",
                    "type": "shell",
                    "command": "python3",
                    "args": ["${workspaceFolder}/root_cause_agent.py", "demo"],
                    "group": "test"
                }
            ]
        }
        
        vscode_path = self.workspace_root / ".vscode" / "tasks.json"
        vscode_path.parent.mkdir(exist_ok=True)
        
        with open(vscode_path, 'w', encoding='utf-8') as f:
            json.dump(vscode_config, f, indent=2, ensure_ascii=False)
        
        # 3. 創建快捷鍵配置
        keybindings = [
            {
                "key": "ctrl+shift+a",
                "command": "workbench.action.tasks.runTask",
                "args": "🔄 切換到根因分析Agent",
                "when": "editorTextFocus"
            },
            {
                "key": "ctrl+shift+d",
                "command": "workbench.action.tasks.runTask", 
                "args": "📊 運行演示"
            }
        ]
        
        keybindings_path = self.workspace_root / ".vscode" / "keybindings.json"
        with open(keybindings_path, 'w', encoding='utf-8') as f:
            json.dump(keybindings, f, indent=2, ensure_ascii=False)
        
        # 4. 創建使用指南
        self.create_usage_guide()
        
        print("✅ Trae IDE Agent整合配置完成！")
        print("📁 配置文件已創建:")
        print(f"   - {agent_desc_path}")
        print(f"   - {vscode_path}")
        print(f"   - {keybindings_path}")
    
    def create_usage_guide(self):
        """創建使用指南"""
        guide_content = """# Trae IDE Agent使用指南

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
"""
        
        guide_path = self.workspace_root / "TRAE_AGENT_GUIDE.md"
        with open(guide_path, 'w', encoding='utf-8') as f:
            f.write(guide_content)
        
        print(f"📖 詳細指南: {guide_path}")

if __name__ == "__main__":
    integration = TraeAgentIntegration()
    integration.setup_trae_integration()
    
    print("\n" + "="*50)
    print("🎉 Trae IDE Agent整合完成！")
    print("重啟Trae IDE後即可使用標準Agent切換功能")
    print("="*50)