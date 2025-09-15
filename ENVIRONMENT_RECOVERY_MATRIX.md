# 跨平台安裝卡關修復矩陣

## 環境分類與修復策略總覽

| 環境類型 | 主要問題 | 自動修復 | 手動修復 | 診斷工具 | 備份方案 |
|----------|----------|----------|----------|----------|----------|
| **macOS** | 權限/路徑 | ✅ 原生支援 | ✅ 終端修復 | ✅ osascript | ✅ 手動安裝 |
| **Linux Ubuntu** | 依賴缺失 | ✅ apt修復 | ✅ 套件安裝 | ✅ 系統檢測 | ✅ Docker |
| **Linux CentOS** | 版本相容 | ✅ yum修復 | ✅ 編譯安裝 | ✅ 環境檢查 | ✅ 容器化 |
| **Linux Arch** | 滾動更新 | ✅ pacman | ✅ AUR輔助 | ✅ 版本鎖定 | ✅ 虛擬環境 |
| **Windows WSL** | 路徑轉換 | ✅ WSL檢測 | ✅ 路徑修復 | ✅ 雙系統檢查 | ✅ 原生Windows |
| **Docker** | 容器限制 | ✅ 映像修復 | ✅ 手動建置 | ✅ 容器診斷 | ✅ 主機安裝 |
| **CI/CD** | 環境變數 | ✅ 配置檢測 | ✅ 變數注入 | ✅ 流水線診斷 | ✅ 本地驗證 |

---

## 1. macOS 環境修復策略

### 1.1 原生macOS (Intel/Apple Silicon)

#### 自動修復流程
```bash
# 執行原生安裝腳本
./install_ai_agent.sh

# 如果失敗，執行macOS專用診斷
./macos_diagnostic.sh --comprehensive
```

#### 常見問題與修復
| 問題症狀 | 根因分析 | 修復命令 | 預防措施 |
|----------|----------|----------|----------|
| `osascript` 失敗 | 終端權限問題 | `tccutil reset All` | 授予終端完整磁碟存取 |
| Node.js 版本過舊 | Homebrew未更新 | `brew upgrade node` | 定期更新brew |
| Python 路徑錯誤 | 多版本衝突 | `which python3` | 使用pyenv管理版本 |
| 權限被拒絕 | SIP限制 | `sudo` 前置命令 | 檢查目錄權限 |

#### Apple Silicon 特殊處理
```bash
# ARM64架構檢測
if [[ $(uname -m) == "arm64" ]]; then
    info "檢測到Apple Silicon，使用ARM64優化..."
    export PATH="/opt/homebrew/bin:$PATH"
fi
```

### 1.2 macOS + Homebrew 環境

#### 依賴修復腳本
```bash
#!/bin/bash
# macos_homebrew_fix.sh

# Homebrew診斷
brew doctor

# 修復缺失依賴
MISSING_DEPS=$(brew missing)
if [[ -n "$MISSING_DEPS" ]]; then
    brew install $MISSING_DEPS
fi

# Node.js版本修復
if ! command -v node &> /dev/null; then
    brew install node
fi

# Python環境修復
if ! command -v python3 &> /dev/null; then
    brew install python@3.9
fi
```

---

## 2. Linux 環境修復策略

### 2.1 Ubuntu/Debian 系列

#### 系統依賴修復矩陣
```bash
#!/bin/bash
# ubuntu_fix.sh

# 更新套件列表
sudo apt-get update

# 基礎依賴檢查與修復
DEPS=(
    "curl:curl"
    "wget:wget"
    "git:git"
    "build-essential:build-essential"
    "python3:python3"
    "python3-pip:python3-pip"
    "nodejs:nodejs"
    "npm:npm"
)

for dep in "${DEPS[@]}"; do
    IFS=':' read -r cmd pkg <<< "$dep"
    if ! command -v "$cmd" &> /dev/null; then
        echo "安裝缺失套件: $pkg"
        sudo apt-get install -y "$pkg"
    fi
done

# 特定版本修復
if [[ $(lsb_release -rs) == "20.04" ]]; then
    # Ubuntu 20.04 特殊處理
    sudo apt-get install -y python3.8-venv
fi
```

#### Snap 套件修復
```bash
# Snap版本Node.js修復
if snap list node &> /dev/null; then
    sudo snap refresh node --classic
else
    sudo snap install node --classic
fi
```

### 2.2 CentOS/RHEL 系列

#### YUM/DNF 修復策略
```bash
#!/bin/bash
# centos_fix.sh

# CentOS版本檢測
if [[ -f /etc/centos-release ]]; then
    CENTOS_VERSION=$(grep -oE '[0-9]+' /etc/centos-release | head -1)
    
    if [[ $CENTOS_VERSION -eq 7 ]]; then
        # CentOS 7 特殊處理
        sudo yum install -y epel-release
        sudo yum install -y curl git python3 python3-pip nodejs npm
    elif [[ $CENTOS_VERSION -ge 8 ]]; then
        # CentOS 8+ 使用DNF
        sudo dnf install -y curl git python3 python3-pip nodejs npm
    fi
fi

# Node.js版本修復（使用NodeSource）
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo yum install -y nodejs
```

### 2.3 Arch Linux 系列

#### Pacman 修復策略
```bash
#!/bin/bash
# arch_fix.sh

# 同步套件資料庫
sudo pacman -Sy

# 安裝基礎依賴
sudo pacman -S --needed curl git python python-pip nodejs npm base-devel

# AUR輔助工具（可選）
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si
    cd .. && rm -rf yay
fi

# 使用yay安裝最新版本
yay -S nodejs-lts python-pip
```

---

## 3. Windows 環境修復策略

### 3.1 Windows Subsystem for Linux (WSL)

#### WSL 環境檢測與修復
```bash
#!/bin/bash
# wsl_fix.sh

# WSL環境檢測
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    info "檢測到WSL環境: $WSL_DISTRO_NAME"
    
    # WSL路徑修復
    export PATH="$PATH:/mnt/c/Windows/System32"
    
    # Windows檔案系統存取修復
    sudo mkdir -p /mnt/c/temp
    sudo mount -t drvfs C: /mnt/c
fi

# WSL2特定修復
if [[ $(uname -r) == *microsoft* ]]; then
    # WSL2網路修復
    sudo bash -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
fi
```

#### Windows 原生環境
```powershell
# Windows PowerShell 修復腳本
# windows_fix.ps1

# 檢查Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# 安裝依賴
choco install nodejs python git curl -y

# 檢查Python pip
python -m pip install --upgrade pip
```

### 3.2 Windows + Git Bash

#### Git Bash 相容性修復
```bash
#!/bin/bash
# gitbash_fix.sh

# Git Bash環境檢測
if [[ "$OSTYPE" == "msys" ]]; then
    # 路徑轉換修復
    export PATH="$PATH:/c/Program Files/nodejs"
    export PATH="$PATH:/c/Users/$USERNAME/AppData/Local/Programs/Python/Python39"
    
    # 使用Windows版Node.js
    if command -v node.exe &> /dev/null; then
        alias node="node.exe"
        alias npm="npm.cmd"
    fi
fi
```

---

## 4. Docker 環境修復策略

### 4.1 容器化安裝修復

#### Dockerfile 修復模板
```dockerfile
# Multi-stage Dockerfile 修復版本
FROM node:18-alpine AS node_base
FROM python:3.9-alpine AS python_base

# 系統依賴修復
RUN apk add --no-cache \
    curl \
    git \
    build-base \
    python3-dev \
    py3-pip

# Node.js環境修復
WORKDIR /app/agents/vscode_agent
COPY agents/vscode_agent/package*.json ./
RUN npm ci --only=production

# Python環境修復
WORKDIR /app/agents/chatgpt_agent
COPY agents/chatgpt_agent/requirements*.txt ./
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install pydantic-settings

# 環境變數修復
ENV NODE_ENV=production
ENV PYTHONPATH=/app
```

#### Docker Compose 修復
```yaml
version: '3.8'
services:
  ai-agents:
    build: .
    environment:
      - NODE_ENV=production
      - PYTHONPATH=/app
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    ports:
      - "3000:3000"
      - "5678:5678"
    restart: unless-stopped
```

### 4.2 容器診斷工具
```bash
#!/bin/bash
# docker_diagnostic.sh

docker run --rm -it \
  -v $(pwd):/workspace \
  -w /workspace \
  node:18-alpine \
  sh -c "
    echo '=== Docker環境診斷 ==='
    node --version
    npm --version
    python3 --version
    pip3 --version
    echo '=== 網路測試 ==='
    curl -I https://registry.npmjs.org
    curl -I https://pypi.org
  "
```

---

## 5. CI/CD 環境修復策略

### 5.1 GitHub Actions 修復

#### 工作流程修復
```yaml
name: AI Agent CI Fix
on: [push, pull_request]

jobs:
  test-matrix:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node: [16, 18, 20]
        python: [3.8, 3.9, 3.10]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ matrix.node }}
        cache: 'npm'
    
    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python }}
        cache: 'pip'
    
    - name: Run Environment Diagnostic
      run: |
        chmod +x linux_install_diagnostic.sh
        ./linux_install_diagnostic.sh --diagnostic
```

### 5.2 Jenkins 修復

#### Jenkinsfile 修復模板
```groovy
pipeline {
    agent any
    
    stages {
        stage('Environment Check') {
            steps {
                script {
                    if (isUnix()) {
                        sh './linux_install_diagnostic.sh --diagnostic'
                    } else {
                        bat 'powershell -File windows_fix.ps1'
                    }
                }
            }
        }
        
        stage('Fix Dependencies') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'sudo apt-get update && sudo apt-get install -y curl git nodejs npm python3 python3-pip'
                    }
                }
            }
        }
    }
}
```

---

## 6. Agent 特定修復策略

### 6.1 VSCode Agent 修復

#### 跨平台 Node.js 修復
```bash
#!/bin/bash
# vscode_agent_fix.sh

# 檢測平台
PLATFORM=$(uname -s)

case $PLATFORM in
    "Darwin")
        # macOS 修復
        if ! command -v code &> /dev/null; then
            echo "VSCode CLI 未安裝，請安裝 VSCode"
            exit 1
        fi
        ;;
    "Linux")
        # Linux 修復
        if ! command -v code &> /dev/null; then
            echo "VSCode CLI 未找到，使用code-server替代"
            npm install -g code-server
        fi
        ;;
    "MINGW"*)
        # Windows Git Bash 修復
        if ! command -v code.exe &> /dev/null; then
            echo "VSCode 未安裝，請從官網下載"
            exit 1
        fi
        ;;
esac

# 通用修復
cd agents/vscode_agent
npm install || npm ci
npm audit fix
```

### 6.2 n8n Agent 修復

#### 資料庫修復策略
```bash
#!/bin/bash
# n8n_agent_fix.sh

# 檢測並修復n8n資料庫
N8N_DIR="$HOME/.n8n"

if [ ! -d "$N8N_DIR" ]; then
    mkdir -p "$N8N_DIR"
fi

# 修復SQLite資料庫
if [ -f "$N8N_DIR/database.sqlite" ]; then
    echo "檢測到n8n資料庫，執行修復..."
    sqlite3 "$N8N_DIR/database.sqlite" ".backup '$N8N_DIR/database_backup.sqlite'"
fi

# 重置n8n配置
if [ -f "$N8N_DIR/config" ]; then
    mv "$N8N_DIR/config" "$N8N_DIR/config.backup"
fi

echo "n8n配置已重置，請重新配置"
```

### 6.3 ChatGPT Agent 修復

#### Python 環境修復
```bash
#!/bin/bash
# chatgpt_agent_fix.sh

# Python版本檢測
PYTHON_MIN_VERSION="3.8"
CURRENT_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)

if [[ $(echo "$CURRENT_VERSION < $PYTHON_MIN_VERSION" | bc -l) -eq 1 ]]; then
    echo "Python版本過低，需要升級到 $PYTHON_MIN_VERSION+"
    exit 1
fi

# 虛擬環境修復
VENV_DIR="agents/chatgpt_agent/venv"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

# 依賴修復
pip install --upgrade pip
pip install -r agents/chatgpt_agent/requirements.txt
pip install pydantic-settings

# OpenAI API Key修復
if [ -z "$OPENAI_API_KEY" ]; then
    read -p "請輸入OpenAI API Key: " OPENAI_API_KEY
    export OPENAI_API_KEY="$OPENAI_API_KEY"
    sed -i "s/YOUR_OPENAI_API_KEY/$OPENAI_API_KEY/g" agents/chatgpt_agent/chatgpt_agent.py
fi

deactivate
```

---

## 7. 環境檢測腳本整合

### 7.1 統一檢測腳本
```bash
#!/bin/bash
# universal_environment_check.sh

# 跨平台環境檢測與修復
set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 平台檢測
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos";;
        Linux*)     echo "linux";;
        CYGWIN*)    echo "windows_cygwin";;
        MINGW*)     echo "windows_mingw";;
        *)          echo "unknown";;
    esac
}

# 依賴檢測
check_dependencies() {
    local platform=$1
    local missing_deps=()
    
    case $platform in
        "macos")
            if ! command -v brew &> /dev/null; then
                missing_deps+=("homebrew")
            fi
            ;;
        "linux")
            if ! command -v apt-get &> /dev/null && ! command -v yum &> /dev/null && ! command -v pacman &> /dev/null; then
                missing_deps+=("package_manager")
            fi
            ;;
        "windows"*)
            if ! command -v choco &> /dev/null && ! command -v winget &> /dev/null; then
                missing_deps+=("windows_package_manager")
            fi
            ;;
    esac
    
    echo "${missing_deps[@]}"
}

# 自動修復
auto_fix() {
    local platform=$1
    
    case $platform in
        "macos")
            if [[ "$(check_dependencies macos)" == *"homebrew"* ]]; then
                echo "安裝Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
        "linux")
            # 自動檢測並使用適當的套件管理器
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y curl git nodejs npm python3 python3-pip
            elif command -v yum &> /dev/null; then
                sudo yum install -y curl git nodejs npm python3 python3-pip
            elif command -v pacman &> /dev/null; then
                sudo pacman -S --needed curl git nodejs npm python python-pip
            fi
            ;;
    esac
}

# 主程式
main() {
    local platform=$(detect_platform)
    echo "檢測到平台: $platform"
    
    local missing=$(check_dependencies $platform)
    if [[ -n "$missing" ]]; then
        echo "發現缺失依賴: $missing"
        read -p "是否執行自動修復？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            auto_fix $platform
        fi
    else
        echo "所有依賴已就緒"
    fi
}

main "$@"
```

### 7.2 快速修復命令彙總

#### 一鍵修復命令
```bash
# 跨平台快速修復
./universal_environment_check.sh && ./install_ai_agent_$(uname -s | tr '[:upper:]' '[:lower:]').sh

# 平台特定修復
./macos_fix.sh          # macOS
./ubuntu_fix.sh         # Ubuntu/Debian
./centos_fix.sh         # CentOS/RHEL
./arch_fix.sh           # Arch Linux
./windows_fix.ps1       # Windows PowerShell
./wsl_fix.sh            # WSL環境
./docker_diagnostic.sh  # Docker環境
```

#### 環境切換腳本
```bash
#!/bin/bash
# environment_switcher.sh

# 根據環境自動選擇修復方案
case "$(uname -s)" in
    Darwin*)
        echo "使用macOS修復方案"
        ./macos_fix.sh
        ;;
    Linux*)
        if [[ -n "$WSL_DISTRO_NAME" ]]; then
            echo "使用WSL修復方案"
            ./wsl_fix.sh
        else
            echo "使用Linux修復方案"
            ./linux_install_diagnostic.sh --diagnostic
        fi
        ;;
    *)
        echo "不支援的環境，請手動修復"
        exit 1
        ;;
esac
```

---

## 8. 緊急修復方案

### 8.1 完全離線修復
```bash
# 預先下載所有依賴
./offline_prepare.sh

# 離線安裝
./offline_install.sh
```

### 8.2 最小可用版本
```bash
# 最小功能版本
./minimal_install.sh --agent=chatgpt

# 逐步擴展
./expand_install.sh --add=n8n
./expand_install.sh --add=vscode
```

### 8.3 災難恢復
```bash
# 完整備份
./backup_environment.sh

# 災難恢復
./restore_environment.sh --from-backup
```

這個修復矩陣涵蓋了從開發環境到生產環境的所有可能場景，每個環境都有對應的自動和手動修復方案。