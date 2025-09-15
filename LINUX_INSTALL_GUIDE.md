# Linux 環境 AI Agent 安裝指南

## 問題概述

當使用者在一般 Linux 環境執行一鍵安裝腳本時，可能會遇到以下問題：

1. **macOS 專屬命令不相容** - 原腳本使用 `osascript` 命令
2. **缺少系統依賴** - Node.js、Python3、pip3 等未安裝
3. **權限問題** - 無法寫入特定目錄
4. **網路連線問題** - 無法下載依賴套件
5. **版本相容性** - pydantic-settings 等套件版本問題

## 解決方案

### 方案一：使用 Linux 專用安裝腳本

#### 快速安裝（推薦）
```bash
# 下載並執行 Linux 專用安裝腳本
curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/install_ai_agent_linux.sh | bash

# 或手動下載執行
git clone https://github.com/enjoyce20061010/auto_setup_ai_agents.git
cd auto_setup_ai_agents
chmod +x install_ai_agent_linux.sh
./install_ai_agent_linux.sh
```

#### 單獨安裝特定 Agent
```bash
# 只安裝需要的 Agent
./install_ai_agent_linux.sh  # 選擇特定選項
```

### 方案二：使用根因分析工具自助診斷

當安裝失敗時，使用者可以**獨立執行根因分析**，無需外部協助：

#### 步驟 1：執行系統診斷
```bash
# 方法一：使用診斷腳本
./linux_install_diagnostic.sh --diagnostic

# 方法二：如果診斷腳本不存在，手動檢查
python3 root_cause_agent.py --diagnostic --mode=install
```

#### 步驟 2：根據診斷結果修復

診斷工具會提供具體的修復建議：

**案例 1：缺少系統依賴**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl tar git nodejs npm python3 python3-pip

# CentOS/RHEL
sudo yum install curl tar git nodejs npm python3 python3-pip

# Arch Linux
sudo pacman -S curl tar git nodejs npm python python-pip
```

**案例 2：權限問題**
```bash
# 使用 sudo 或更改目錄權限
sudo chown -R $USER:$USER /path/to/install/directory
```

**案例 3：網路問題**
```bash
# 使用國內鏡像源
npm config set registry https://registry.npmmirror.com
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

**案例 4：版本兼容性**
```bash
# 修復 pydantic 兼容性
pip3 install pydantic-settings
```

### 方案三：手動逐步安裝

如果自動安裝仍然失敗，可以手動執行：

```bash
# 1. 檢查系統環境
./linux_install_diagnostic.sh --diagnostic

# 2. 修復發現的問題
# （根據診斷結果執行相應修復）

# 3. 手動安裝各個 Agent
# VSCode Agent
cd agents/vscode_agent
npm install
npm start

# n8n Agent
cd agents/n8n_agent
npm install
npm start

# ChatGPT Agent
cd agents/chatgpt_agent
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
pip3 install pydantic-settings
python3 chatgpt_agent.py
```

## 根因分析工具使用說明

### root_cause_agent.py 的獨立使用

該工具**完全獨立**，可以在沒有任何協助的情況下使用：

#### 基本用法
```bash
# 全面診斷
python3 root_cause_agent.py --diagnostic --mode=install

# 針對特定問題
python3 root_cause_agent.py --diagnostic --component=nodejs
python3 root_cause_agent.py --diagnostic --component=python

# 生成詳細報告
python3 root_cause_agent.py --diagnostic --output=report.json
```

#### 輸出示例
```json
{
  "status": "failed",
  "component": "nodejs",
  "error": "npm install failed",
  "root_cause": "網路連線超時",
  "solution": "使用國內 npm 鏡像源",
  "commands": [
    "npm config set registry https://registry.npmmirror.com",
    "npm install"
  ]
}
```

## 故障排除流程圖

```
安裝失敗
    ↓
執行診斷腳本
    ↓
┌─────────────────┬─────────────────┐
│   系統依賴缺失   │   網路連線問題   │
│   ↓            │   ↓            │
│ 安裝缺失工具    │ 更換鏡像源     │
└─────────────────┴─────────────────┘
    ↓                    ↓
重新執行安裝 ←─────────┘
    ↓
成功安裝
```

## 常見問題解答

### Q: 為什麼原腳本在 Linux 會失敗？
A: 原腳本使用 `osascript` 命令，這是 macOS 專屬命令，Linux 不支援。

### Q: 如何確認我的 Linux 系統是否支援？
A: 執行 `./linux_install_diagnostic.sh --diagnostic` 會自動檢查系統相容性。

### Q: 如果所有方法都失敗怎麼辦？
A: 執行完整診斷並保存報告：
```bash
./linux_install_diagnostic.sh --diagnostic > diagnostic.log 2>&1
```
然後可以將 `diagnostic.log` 提供給技術支援。

### Q: 需要管理員權限嗎？
A: 通常不需要，但如果遇到權限問題，可以使用 `sudo`。

## 快速修復命令匯總

```bash
# 一鍵診斷
./linux_install_diagnostic.sh --diagnostic

# 一鍵安裝（Linux 專用）
./install_ai_agent_linux.sh

# 手動診斷
python3 root_cause_agent.py --diagnostic

# 清理並重新安裝
rm -rf ~/auto_setup_ai_agents
./install_ai_agent_linux.sh
```

## 支援的 Linux 發行版

- **Ubuntu** 18.04+
- **Debian** 10+
- **CentOS** 7+
- **RHEL** 7+
- **Fedora** 30+
- **Arch Linux**
- **openSUSE**

所有發行版都可以使用相同的診斷和修復流程。