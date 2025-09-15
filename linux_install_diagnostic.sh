#!/bin/bash
#
# Linux 安裝診斷腳本 - 當一鍵安裝失敗時使用
# 提供詳細的根因分析和修復建議
#

# --- Colors for output ---
C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'

# --- Helper Functions ---
info() {
    echo -e "${C_BLUE}INFO:${C_RESET} $1"
}

success() {
    echo -e "${C_GREEN}SUCCESS:${C_RESET} $1"
}

warn() {
    echo -e "${C_YELLOW}WARNING:${C_RESET} $1"
}

fail() {
    echo -e "${C_RED}ERROR:${C_RESET} $1"
}

# --- 系統檢查函數 ---
check_os_compatibility() {
    info "檢查作業系統相容性..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        success "檢測到 Linux 系統"
        
        # 檢查發行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            info "發行版: $NAME $VERSION"
        fi
        
        # 檢查是否有必要的Linux工具
        local missing_tools=()
        
        if ! command -v curl &> /dev/null; then
            missing_tools+=("curl")
        fi
        
        if ! command -v tar &> /dev/null; then
            missing_tools+=("tar")
        fi
        
        if ! command -v git &> /dev/null; then
            missing_tools+=("git")
        fi
        
        if [ ${#missing_tools[@]} -gt 0 ]; then
            fail "缺少必要工具: ${missing_tools[*]}"
            info "請使用以下命令安裝:"
            info "Ubuntu/Debian: sudo apt-get install ${missing_tools[*]}"
            info "CentOS/RHEL: sudo yum install ${missing_tools[*]}"
            info "Arch: sudo pacman -S ${missing_tools[*]}"
            exit 1
        fi
        
    else
        warn "非Linux系統，部分檢查可能不適用"
    fi
}

# --- 依賴檢查 ---
check_dependencies() {
    info "檢查系統依賴..."
    
    local missing_deps=()
    
    # 檢查 Node.js
    if ! command -v node &> /dev/null; then
        missing_deps+=("nodejs")
    else
        local node_version=$(node --version)
        info "Node.js 版本: $node_version"
    fi
    
    # 檢查 npm
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    else
        local npm_version=$(npm --version)
        info "npm 版本: $npm_version"
    fi
    
    # 檢查 Python
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    else
        local python_version=$(python3 --version)
        info "Python 版本: $python_version"
    fi
    
    # 檢查 pip
    if ! command -v pip3 &> /dev/null; then
        missing_deps+=("pip3")
    else
        local pip_version=$(pip3 --version)
        info "pip 版本: $pip_version"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        warn "發現缺失的依賴: ${missing_deps[*]}"
        info "安裝建議:"
        info "Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        info "CentOS/RHEL: sudo yum install ${missing_deps[*]}"
        info "使用套件管理器安裝缺失的依賴"
        return 1
    fi
    
    success "所有依賴檢查通過"
    return 0
}

# --- 網路檢查 ---
check_network() {
    info "檢查網路連線..."
    
    # 檢查 GitHub 連線
    if curl -s --head --max-time 5 https://github.com > /dev/null; then
        success "GitHub 連線正常"
    else
        warn "無法連接 GitHub，可能影響下載"
    fi
    
    # 檢查 npm registry
    if curl -s --head --max-time 5 https://registry.npmjs.org > /dev/null; then
        success "npm registry 連線正常"
    else
        warn "無法連接 npm registry"
    fi
    
    # 檢查 PyPI
    if curl -s --head --max-time 5 https://pypi.org > /dev/null; then
        success "PyPI 連線正常"
    else
        warn "無法連接 PyPI"
    fi
}

# --- 權限檢查 ---
check_permissions() {
    info "檢查檔案權限..."
    
    local current_dir=$(pwd)
    
    if [ -w "$current_dir" ]; then
        success "當前目錄可寫入"
    else
        fail "當前目錄無寫入權限: $current_dir"
    fi
    
    # 檢查家目錄權限
    if [ -w "$HOME" ]; then
        success "家目錄可寫入"
    else
        warn "家目錄無寫入權限: $HOME"
    fi
}

# --- 磁碟空間檢查 ---
check_disk_space() {
    info "檢查磁碟空間..."
    
    local available=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [ "$available" -lt 1 ]; then
        fail "磁碟空間不足，至少需要 1GB 可用空間"
    else
        success "磁碟空間充足: ${available}GB 可用"
    fi
}

# --- 執行完整診斷 ---
run_full_diagnostic() {
    info "開始執行 Linux 安裝診斷..."
    echo "================================"
    
    check_os_compatibility
    check_dependencies
    check_network
    check_permissions
    check_disk_space
    
    echo "================================"
    success "診斷完成！"
    
    # 提供修復建議
    info "如果安裝失敗，請嘗試以下步驟:"
    echo "1. 手動安裝缺失的依賴"
    echo "2. 使用 sudo 提升權限"
    echo "3. 檢查網路連線"
    echo "4. 清理 npm 快取: npm cache clean --force"
    echo "5. 使用國內鏡像源加速下載"
    
    # 提供替代安裝方法
    info "替代安裝方法:"
    echo "git clone https://github.com/enjoyce20061010/auto_setup_ai_agents.git"
    echo "cd auto_setup_ai_agents"
    echo "chmod +x linux_install_diagnostic.sh"
    echo "./linux_install_diagnostic.sh"
}

# --- 主程式 ---
main() {
    if [[ "$1" == "--diagnostic" ]]; then
        run_full_diagnostic
    else
        info "Linux 安裝診斷腳本"
        info "使用方法: $0 --diagnostic"
        info "當一鍵安裝失敗時，執行此腳本進行診斷"
    fi
}

main "$@"