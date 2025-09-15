#!/bin/bash

# 🔍 環境檢測器
# 自動識別用戶環境並提供修復建議

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 輸出函數
info() {
    echo -e "${CYAN}[檢測]${NC} $1"
}

success() {
    echo -e "${GREEN}[通過]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

fail() {
    echo -e "${RED}[錯誤]${NC} $1"
}

# 系統資訊收集
collect_system_info() {
    echo "========================================"
    echo "🔍 AI Agents 環境檢測報告"
    echo "========================================"
    echo ""
    
    # 操作系統詳細資訊
    info "操作系統資訊"
    echo "  系統: $(uname -s)"
    echo "  內核: $(uname -r)"
    echo "  架構: $(uname -m)"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "  發行版: $PRETTY_NAME"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS版本: $(sw_vers -productVersion)"
    fi
    echo ""
    
    # 包管理器檢測
    info "包管理器檢測"
    local pms=()
    command -v apt-get &> /dev/null && pms+=("apt")
    command -v yum &> /dev/null && pms+=("yum")
    command -v dnf &> /dev/null && pms+=("dnf")
    command -v pacman &> /dev/null && pms+=("pacman")
    command -v brew &> /dev/null && pms+=("brew")
    command -v choco &> /dev/null && pms+=("choco")
    
    if [ ${#pms[@]} -gt 0 ]; then
        echo "  可用包管理器: ${pms[*]}"
    else
        warn "  未檢測到包管理器"
    fi
    echo ""
}

# 依賴檢查表
check_dependencies_table() {
    info "依賴檢查表"
    echo "  ┌─────────────┬─────────────┬─────────────┬─────────────────┐"
    echo "  │ 工具        │ 狀態        │ 版本        │ 建議            │"
    echo "  ├─────────────┼─────────────┼─────────────┼─────────────────┤"
    
    # 檢查每個工具
    local tools=("node" "npm" "python3" "pip3" "git" "curl")
    local statuses=()
    local versions=()
    local suggestions=()
    
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -n1 | cut -d' ' -f2)
            statuses+=("✅ 已安裝")
            versions+=("$version")
            suggestions+=("-")
        else
            statuses+=("❌ 缺失")
            versions+=("-")
            suggestions+=("需要安裝")
        fi
    done
    
    for i in "${!tools[@]}"; do
        printf "  │ %-11s │ %-11s │ %-11s │ %-15s │\n" "${tools[$i]}" "${statuses[$i]}" "${versions[$i]}" "${suggestions[$i]}"
    done
    echo "  └─────────────┴─────────────┴─────────────┴─────────────────┘"
    echo ""
}

# 網路連線測試
test_network() {
    info "網路連線測試"
    
    local sites=("github.com" "registry.npmjs.org" "pypi.org")
    local results=()
    
    for site in "${sites[@]}"; do
        if curl -s --max-time 5 "https://$site" > /dev/null; then
            results+=("✅ $site")
        else
            results+=("❌ $site")
        fi
    done
    
    echo "  網站連線狀態:"
    for result in "${results[@]}"; do
        echo "    $result"
    done
    echo ""
}

# 權限檢查
check_permissions() {
    info "權限檢查"
    
    local test_dirs=("/usr/local" "/opt" "$HOME")
    local results=()
    
    for dir in "${test_dirs[@]}"; do
        if [ -w "$dir" ]; then
            results+=("✅ $dir")
        else
            results+=("❌ $dir")
        fi
    done
    
    echo "  目錄寫入權限:"
    for result in "${results[@]}"; do
        echo "    $result"
    done
    echo ""
}

# 磁碟空間檢查
check_disk_space() {
    info "磁碟空間檢查"
    
    local disk_info=$(df -h / | awk 'NR==2{print $4 " 可用, " $5 " 已用"}')
    echo "  根目錄: $disk_info"
    
    # 檢查是否有足夠空間（至少2GB）
    local available=$(df / | awk 'NR==2{print $4}')
    if [ $available -lt 2000000 ]; then
        warn "  磁碟空間可能不足（建議至少2GB）"
    else
        success "  磁碟空間充足"
    fi
    echo ""
}

# 生成修復建議
generate_fix_suggestions() {
    info "修復建議"
    
    local os=$(uname -s)
    local missing_deps=()
    
    # 收集缺失的依賴
    for tool in node npm python3 pip3 git curl; do
        if ! command -v $tool &> /dev/null; then
            missing_deps+=($tool)
        fi
    done
    
    echo "  📋 快速修復命令:"
    echo ""
    
    # 根據操作系統提供建議
    case $os in
        "Darwin")
            echo "  🍎 macOS 修復:"
            echo "    curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/macos_fix.sh | bash"
            ;;
        "Linux")
            if command -v apt-get &> /dev/null; then
                echo "  🐧 Ubuntu/Debian 修復:"
                echo "    curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/ubuntu_fix.sh | bash"
            elif command -v yum &> /dev/null; then
                echo "  🐧 CentOS/RHEL 修復:"
                echo "    curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/centos_fix.sh | bash"
            elif command -v pacman &> /dev/null; then
                echo "  🐧 Arch Linux 修復:"
                echo "    curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/arch_fix.sh | bash"
            fi
            ;;
        "MINGW32_NT"*|"MINGW64_NT"*|"MSYS_NT"*)
            echo "  🪟 Windows 修復:"
            echo "    iwr -useb https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/windows_fix.ps1 | iex"
            ;;
    esac
    
    echo ""
    
    # 通用修復
    echo "  🔄 通用修復:"
    echo "    ./universal_fix.sh"
    echo ""
    
    # 如果有缺失依賴，提供手動安裝命令
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "  🛠️ 手動安裝缺失依賴:"
        case $os in
            "Darwin")
                echo "    brew install ${missing_deps[*]}"
                ;;
            "Linux")
                if command -v apt-get &> /dev/null; then
                    echo "    sudo apt-get install -y ${missing_deps[*]}"
                elif command -v yum &> /dev/null; then
                    echo "    sudo yum install -y ${missing_deps[*]}"
                elif command -v pacman &> /dev/null; then
                    echo "    sudo pacman -S ${missing_deps[*]}"
                fi
                ;;
        esac
        echo ""
    fi
}

# 生成環境報告
generate_report() {
    local report_file="environment_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "AI Agents 環境檢測報告"
        echo "生成時間: $(date)"
        echo "================================"
        echo ""
        
        # 系統資訊
        echo "系統資訊:"
        echo "  操作系統: $(uname -s)"
        echo "  內核: $(uname -r)"
        echo "  架構: $(uname -m)"
        
        if [[ "$OSTYPE" == "linux-gnu"* ]] && [ -f /etc/os-release ]; then
            . /etc/os-release
            echo "  發行版: $PRETTY_NAME"
        fi
        echo ""
        
        # 依賴狀態
        echo "依賴狀態:"
        for tool in node npm python3 pip3 git curl; do
            if command -v $tool &> /dev/null; then
                echo "  $tool: ✅ $(echo $($tool --version 2>/dev/null | head -n1))"
            else
                echo "  $tool: ❌ 未安裝"
            fi
        done
        echo ""
        
        # 網路狀態
        echo "網路狀態:"
        for site in github.com registry.npmjs.org pypi.org; do
            if curl -s --max-time 5 "https://$site" > /dev/null; then
                echo "  $site: ✅ 可訪問"
            else
                echo "  $site: ❌ 無法訪問"
            fi
        done
        
    } > "$report_file"
    
    echo "環境報告已保存至: $report_file"
}

# 主程序
main() {
    collect_system_info
    check_dependencies_table
    test_network
    check_permissions
    check_disk_space
    generate_fix_suggestions
    
    # 詢問是否生成報告
    echo "是否要生成詳細的環境報告？(y/n)"
    read -r response
    if [[ $response =~ ^[Yy]$ ]]; then
        generate_report
    fi
    
    echo ""
    echo "🎯 下一步:"
    echo "  1. 執行快速修復: ./universal_fix.sh"
    echo "  2. 或根據上方建議執行對應修復命令"
    echo "  3. 如需幫助，請查看: ./QUICK_RECOVERY_STARTER.md"
}

# 執行主程序
main "$@"