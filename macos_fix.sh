#!/bin/bash

# 🍎 macOS 專用修復腳本
# 針對macOS環境的完整修復方案

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# 檢查和安裝Homebrew
check_homebrew() {
    info "檢查Homebrew..."
    
    if command -v brew &> /dev/null; then
        success "Homebrew已安裝"
        brew --version
    else
        warn "Homebrew未安裝，正在安裝..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加Homebrew到PATH
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# 安裝系統依賴
install_system_deps() {
    info "安裝macOS系統依賴..."
    
    # 更新Homebrew
    brew update
    
    # 安裝基本工具
    local packages=(
        "node"
        "python3"
        "git"
        "curl"
        "wget"
        "tree"
        "jq"
    )
    
    for pkg in "${packages[@]}"; do
        if ! brew list $pkg &> /dev/null; then
            info "安裝 $pkg..."
            brew install $pkg
        else
            success "$pkg 已安裝"
        fi
    done
    
    # 升級已安裝的包
    brew upgrade node python3 git curl wget tree jq
}

# 修復npm權限
fix_npm_permissions() {
    info "修復npm權限..."
    
    # 創建全局npm目錄
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    
    # 添加到PATH
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bash_profile
    
    # 立即生效
    export PATH=~/.npm-global/bin:$PATH
    
    success "npm權限已修復"
}

# 修復Python環境
fix_python_env() {
    info "修復Python環境..."
    
    # 創建Python虛擬環境目錄
    mkdir -p ~/.virtualenvs
    
    # 安裝pip
    if ! command -v pip3 &> /dev/null; then
        warn "pip3未找到，正在安裝..."
        curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
        python3 get-pip.py --user
        rm get-pip.py
    fi
    
    # 升級pip
    pip3 install --upgrade pip setuptools wheel --user
    
    success "Python環境已修復"
}

# 修復Node.js環境
fix_nodejs_env() {
    info "修復Node.js環境..."
    
    # 安裝最新穩定版Node.js
    brew upgrade node
    
    # 安裝npm
    npm install -g npm@latest
    
    # 安裝常用全局包
    local global_packages=(
        "n"
        "nodemon"
        "pm2"
    )
    
    for pkg in "${global_packages[@]}"; do
        if ! npm list -g $pkg &> /dev/null; then
            info "安裝全局包 $pkg..."
            npm install -g $pkg
        fi
    done
    
    success "Node.js環境已修復"
}

# 修復開發者工具
fix_dev_tools() {
    info "檢查開發者工具..."
    
    # 檢查Xcode命令行工具
    if ! xcode-select -p &> /dev/null; then
        warn "Xcode命令行工具未安裝，正在安裝..."
        xcode-select --install
        
        # 等待安裝完成
        warn "請在彈出的對話框中點擊'安裝'..."
        read -p "安裝完成後按Enter繼續..."
    else
        success "Xcode命令行工具已安裝"
    fi
}

# 清理舊版本和緩存
cleanup() {
    info "清理舊版本和緩存..."
    
    # 清理Homebrew緩存
    brew cleanup
    
    # 清理npm緩存
    npm cache clean --force
    
    # 清理pip緩存
    pip3 cache purge 2>/dev/null || true
    
    success "清理完成"
}

# 驗證安裝
verify_installation() {
    info "驗證macOS環境安裝..."
    
    local all_good=true
    
    # 檢查工具
    local tools=("node" "npm" "python3" "pip3" "git" "curl")
    for tool in "${tools[@]}"; do
        if command -v $tool &> /dev/null; then
            local version=$($tool --version 2>/dev/null | head -n1)
            success "$tool: $version"
        else
            fail "$tool: 未安裝"
            all_good=false
        fi
    done
    
    # 檢查目錄權限
    local dirs=("~/.npm-global" "/usr/local/lib/node_modules")
    for dir in "${dirs[@]}"; do
        if [ -w "$dir" ]; then
            success "$dir: 可寫入"
        else
            warn "$dir: 可能需要權限修復"
        fi
    done
    
    if [ "$all_good" = true ]; then
        success "🎉 macOS環境驗證通過！"
        return 0
    else
        fail "❌ 部分工具未正確安裝"
        return 1
    fi
}

# 創建快速啟動腳本
create_quick_scripts() {
    info "創建快速啟動腳本..."
    
    # 創建修復腳本快捷方式
    cat > ~/.local/bin/macos-ai-fix << 'EOF'
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/macos_fix.sh | bash
EOF
    chmod +x ~/.local/bin/macos-ai-fix
    
    # 添加到PATH
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    
    success "快速啟動腳本已創建"
}

# 主程序
main() {
    echo "🍎 macOS AI Agents 修復器"
    echo "=========================="
    
    # 檢查是否在macOS上運行
    if [[ "$OSTYPE" != "darwin"* ]]; then
        fail "此腳本僅適用於macOS"
        exit 1
    fi
    
    # 執行修復步驟
    check_homebrew
    install_system_deps
    fix_npm_permissions
    fix_python_env
    fix_nodejs_env
    fix_dev_tools
    cleanup
    verify_installation
    create_quick_scripts
    
    echo ""
    echo "🎉 macOS環境修復完成！"
    echo ""
    echo "下一步:"
    echo "  1. 執行: ./install_ai_agent.sh"
    echo "  2. 或使用快速命令: macos-ai-fix"
    echo ""
    echo "提示: 重新啟動終端以確保所有變更生效"
}

# 執行主程序
main "$@"