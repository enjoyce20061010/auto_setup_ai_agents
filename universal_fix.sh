#!/bin/bash

# 🚀 萬能快速修復器
# 自動檢測環境並執行對應修復

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 輸出函數
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# 檢測操作系統
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$NAME
        elif [ -f /etc/redhat-release ]; then
            OS="CentOS"
        elif [ -f /etc/debian_version ]; then
            OS="Debian"
        else
            OS="Linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="Windows"
    else
        OS="Unknown"
    fi
    echo $OS
}

# 檢測包管理器
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v choco &> /dev/null; then
        echo "choco"
    else
        echo "unknown"
    fi
}

# 檢測依賴
check_dependencies() {
    local missing_deps=()
    
    # 檢查基本工具
    for tool in curl git node npm python3 pip3; do
        if ! command -v $tool &> /dev/null; then
            missing_deps+=($tool)
        fi
    done
    
    echo "${missing_deps[@]}"
}

# 安裝依賴
install_dependencies() {
    local pm=$(detect_package_manager)
    local missing_deps=($@)
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        success "所有依賴已安裝"
        return 0
    fi
    
    info "安裝缺失的依賴: ${missing_deps[*]}"
    
    case $pm in
        "apt")
            sudo apt-get update
            sudo apt-get install -y curl git nodejs npm python3 python3-pip
            ;;
        "yum"|"dnf")
            sudo $pm install -y curl git nodejs npm python3 python3-pip
            ;;
        "pacman")
            sudo pacman -S curl git nodejs npm python3 python-pip
            ;;
        "brew")
            brew install curl git node python3
            ;;
        "choco")
            choco install curl git nodejs python -y
            ;;
        *)
            warn "未知的包管理器，請手動安裝: ${missing_deps[*]}"
            return 1
            ;;
    esac
}

# 修復npm權限
fix_npm_permissions() {
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        info "修復npm權限..."
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        export PATH=~/.npm-global/bin:$PATH
        echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    fi
}

# 檢測並修復網路問題
fix_network_issues() {
    info "檢測網路連線..."
    
    # 測試github連線
    if curl -s https://api.github.com > /dev/null; then
        success "網路連線正常"
    else
        warn "網路連線異常，嘗試使用鏡像..."
        
        # 根據地理位置選擇鏡像
        if ping -c 1 8.8.8.8 &> /dev/null; then
            info "使用國內鏡像..."
            export NPM_CONFIG_REGISTRY=https://registry.npmmirror.com
            export PYPI_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
        else
            fail "網路問題無法自動修復，請檢查網路設定"
            return 1
        fi
    fi
}

# 執行環境特定修復
run_environment_fix() {
    local os=$(detect_os)
    
    case $os in
        "macOS")
            info "執行macOS專用修復..."
            if [ -f "macos_fix.sh" ]; then
                ./macos_fix.sh
            else
                # 創建臨時macOS修復腳本
                cat > /tmp/macos_temp_fix.sh << 'EOF'
#!/bin/bash
# macOS臨時修復
brew install node python3 git curl
sudo chown -R $(whoami) /usr/local/lib/node_modules
EOF
                chmod +x /tmp/macos_temp_fix.sh
                /tmp/macos_temp_fix.sh
            fi
            ;;
        "Ubuntu"|"Debian")
            info "執行Ubuntu/Debian專用修復..."
            if [ -f "ubuntu_fix.sh" ]; then
                ./ubuntu_fix.sh
            else
                sudo apt-get update
                sudo apt-get install -y curl git nodejs npm python3 python3-pip
            fi
            ;;
        "CentOS"|"Red Hat")
            info "執行CentOS專用修復..."
            if [ -f "centos_fix.sh" ]; then
                ./centos_fix.sh
            else
                sudo yum install -y curl git nodejs npm python3 python3-pip
            fi
            ;;
        "Arch Linux")
            info "執行Arch Linux專用修復..."
            if [ -f "arch_fix.sh" ]; then
                ./arch_fix.sh
            else
                sudo pacman -S curl git nodejs npm python3 python-pip
            fi
            ;;
        *)
            warn "未識別的操作系統: $os"
            info "嘗試通用修復..."
            ;;
    esac
}

# 驗證安裝
verify_installation() {
    info "驗證安裝結果..."
    
    local all_good=true
    
    # 檢查基本工具
    for tool in node npm python3 git curl; do
        if ! command -v $tool &> /dev/null; then
            fail "缺少工具: $tool"
            all_good=false
        fi
    done
    
    # 檢查版本
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        info "Node.js版本: $node_version"
    fi
    
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version)
        info "Python版本: $python_version"
    fi
    
    if [ "$all_good" = true ]; then
        success "所有依賴安裝成功！"
        return 0
    else
        fail "部分依賴安裝失敗"
        return 1
    fi
}

# 主程序
main() {
    echo "🚀 AI Agents 快速修復器 v1.0"
    echo "================================"
    
    # 檢測環境
    local os=$(detect_os)
    local pm=$(detect_package_manager)
    
    info "檢測到操作系統: $os"
    info "檢測到包管理器: $pm"
    
    # 檢查依賴
    local missing_deps=($(check_dependencies))
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warn "發現缺失依賴: ${missing_deps[*]}"
        install_dependencies "${missing_deps[@]}"
    fi
    
    # 修復網路問題
    fix_network_issues
    
    # 修復權限
    fix_npm_permissions
    
    # 執行環境特定修復
    run_environment_fix
    
    # 驗證安裝
    verify_installation
    
    if [ $? -eq 0 ]; then
        success "🎉 修復完成！現在可以執行安裝腳本了"
        echo ""
        echo "下一步:"
        echo "  1. 執行: ./install_ai_agent.sh"
        echo "  2. 或執行: ./install_ai_agent_linux.sh"
    else
        fail "❌ 修復過程中出現問題"
        echo ""
        echo "請嘗試:"
        echo "  1. 查看詳細日誌: cat /tmp/fix_log.txt"
        echo "  2. 手動安裝缺失的依賴"
        echo "  3. 聯繫技術支援"
    fi
}

# 執行主程序
main "$@"