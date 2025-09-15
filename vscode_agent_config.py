#!/usr/bin/env python3
"""
VS Code Extension Trae UI Agent配置工具
專為VS Code Extension版本的Trae UI對話框設計
"""

import json
import os
from pathlib import Path

class VSCodeTraeConfig:
    """VS Code Trae Extension配置器"""
    
    def __init__(self):
        self.workspace = Path("/Users/jianjunneng/0912test/auto_setup_ai_agents")
        self.vscode_config = self.workspace / ".vscode"
        
    def create_vscode_settings(self):
        """創建VS Code專用配置"""
        settings = {
            "trae.customAgents": [
                {
                    "id": "root_cause_agent",
                    "name": "根因分析專家",
                    "description": "專業的系統問題診斷和根本原因分析工具",
                    "command": "python3",
                    "args": ["${workspaceFolder}/root_cause_agent.py"],
                    "icon": "🔍",
                    "when": "resourceExtname == .py || resourceExtname == .log",
                    "category": "分析工具",
                    "prompt": "請描述您遇到的問題，我將為您進行根因分析"
                }
            ],
            "trae.agentShortcuts": [
                {
                    "key": "ctrl+shift+r",
                    "command": "trae.runAgent",
                    "args": "root_cause_agent",
                    "when": "editorTextFocus"
                }
            ]
        }
        
        settings_file = self.vscode_config / "settings.json"
        
        # 如果settings.json已存在，則合併配置
        if settings_file.exists():
            with open(settings_file, 'r') as f:
                existing = json.load(f)
            existing.update(settings)
        else:
            existing = settings
            
        with open(settings_file, 'w') as f:
            json.dump(existing, f, indent=2, ensure_ascii=False)
        
        print(f"✅ VS Code配置已更新: {settings_file}")
        
    def create_agent_launcher(self):
        """創建Agent啟動器"""
        launcher = {
            "version": "0.2.0",
            "configurations": [
                {
                    "name": "啟動根因分析Agent",
                    "type": "python",
                    "request": "launch",
                    "program": "${workspaceFolder}/root_cause_agent.py",
                    "args": ["--interactive"],
                    "console": "integratedTerminal",
                    "cwd": "${workspaceFolder}",
                    "presentation": {
                        "group": "Agent",
                        "order": 1
                    }
                },
                {
                    "name": "運行Agent演示",
                    "type": "python",
                    "request": "launch",
                    "program": "${workspaceFolder}/root_cause_agent.py",
                    "args": ["demo"],
                    "console": "integratedTerminal",
                    "cwd": "${workspaceFolder}",
                    "presentation": {
                        "group": "Agent",
                        "order": 2
                    }
                }
            ]
        }
        
        launch_file = self.vscode_config / "launch.json"
        with open(launch_file, 'w') as f:
            json.dump(launcher, f, indent=2, ensure_ascii=False)
        
        print(f"✅ VS Code啟動配置已創建: {launch_file}")
        
    def create_extension_commands(self):
        """創建Extension命令"""
        commands = {
            "contributes": {
                "commands": [
                    {
                        "command": "trae.runRootCauseAgent",
                        "title": "運行根因分析Agent",
                        "category": "Trae Agent"
                    },
                    {
                        "command": "trae.runAgentDemo",
                        "title": "運行Agent演示",
                        "category": "Trae Agent"
                    }
                ],
                "menus": {
                    "explorer/context": [
                        {
                            "command": "trae.runRootCauseAgent",
                            "when": "resourceExtname == .py || resourceExtname == .log",
                            "group": "Agent"
                        }
                    ],
                    "editor/context": [
                        {
                            "command": "trae.runRootCauseAgent",
                            "when": "editorTextFocus",
                            "group": "Agent"
                        }
                    ]
                }
            }
        }
        
        # 創建VS Code Extension的package.json片段
        ext_file = self.workspace / ".vscode" / "extension.json"
        with open(ext_file, 'w') as f:
            json.dump(commands, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Extension命令配置已創建: {ext_file}")
        
    def create_quick_guide(self):
        """創建快速使用指南"""
        guide = """# VS Code Trae Extension 使用指南

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
"""
        
        guide_file = self.workspace / "VS_CODE_TRAE_GUIDE.md"
        with open(guide_file, 'w', encoding='utf-8') as f:
            f.write(guide)
        
        print(f"✅ VS Code使用指南已創建: {guide_file}")
        
    def setup_vscode_extension(self):
        """設置VS Code Extension環境"""
        print("🎯 設置VS Code Trae Extension環境...")
        
        # 確保.vscode目錄存在
        self.vscode_config.mkdir(exist_ok=True)
        
        # 創建所有配置
        self.create_vscode_settings()
        self.create_agent_launcher()
        self.create_extension_commands()
        self.create_quick_guide()
        
        print("\n✅ VS Code Trae Extension配置完成！")
        print("\n📋 使用步驟：")
        print("1. 重新加載VS Code窗口")
        print("2. 使用 Ctrl+Shift+P → 'Trae Agent'")
        print("3. 或在編輯器中右鍵 → 'Trae Agent'")
        print("4. 或使用快捷鍵 Ctrl+Shift+R")

if __name__ == "__main__":
    config = VSCodeTraeConfig()
    config.setup_vscode_extension()