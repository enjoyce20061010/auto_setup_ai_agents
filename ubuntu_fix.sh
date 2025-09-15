#!/bin/bash

# 🐧 Ubuntu/Debian 專用修復腳本
# 針對Ubuntu/Debian環境的完整修復方案

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

# 檢查是否在Ubuntu/Debian上運行
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        fail "無法檢測操作系統版本"
        exit 1
    fi
    
    . /etc/os-release
    
    if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
        fail "此腳本僅適用於Ubuntu或Debian"
        exit 1
    fi
    
    success "檢測到 $PRETTY_NAME"
}

# 更新系統包列表
update_system() {
    info "更新系統包列表..."
    
    sudo apt-get update
    
    # 升級已安裝的包
    sudo apt-get upgrade -y
    
    success "系統更新完成"
}

# 安裝基本依賴
install_basic_deps() {
    info "安裝基本系統依賴..."
    
    local packages=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "python3"
        "python3-pip"
        "python3-dev"
        "python3-venv"
    )
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            info "安裝 $pkg..."
            sudo apt-get install -y $pkg
        else
            success "$pkg 已安裝"
        fi
    done
}

# 安裝Node.js和npm
install_nodejs() {
    info "安裝Node.js和npm..."
    
    # 使用NodeSource存儲庫獲取最新版本
    if ! command -v node &> /dev/null; then
        info "添加NodeSource存儲庫..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        
        info "安裝Node.js..."
        sudo apt-get install -y nodejs
    else
        success "Node.js 已安裝"
    fi
    
    # 升級npm
    sudo npm install -g npm@latest
    
    success "Node.js和npm安裝完成"
}

# 修復npm權限
fix_npm_permissions() {
    info "修復npm權限..."
    
    # 創建全局npm目錄
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    
    # 添加到PATH
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
    
    # 立即生效
    export PATH=~/.npm-global/bin:$PATH
    
    success "npm權限已修復"
}

# 配置Python環境
setup_python_env() {
    info "配置Python環境..."
    
    # 升級pip
    pip3 install --upgrade pip setuptools wheel --user
    
    # 創建虛擬環境目錄
    mkdir -p ~/.virtualenvs
    
    # 安裝virtualenv
    pip3 install --user virtualenv
    
    success "Python環境配置完成"
}

# 安裝常用開發工具
install_dev_tools() {
    info "安裝開發工具..."
    
    # 安裝額外的開發工具
    local dev_packages=(
        "tree"
        "jq"
        "htop"
        "vim"
        "nano"
    )
    
    for pkg in "${dev_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            info "安裝 $pkg..."
            sudo apt-get install -y $pkg
        else
            success "$pkg 已安裝"
        fi
    done
    
    # 安裝npm全局包
    local npm_packages=(
        "n"
        "nodemon"
        "pm2"
    )
    
    for pkg in "${npm_packages[@]}"; do
        if ! npm list -g $pkg &> /dev/null; then
            info "安裝npm全局包 $pkg..."
            npm install -g $pkg
        fi
    done
}

# 配置網路優化
setup_network_optimization() {
    info "配置網路優化..."
    
    # 設置國內鏡像（如果檢測到中國IP）
    if curl -s ipinfo.io/country | grep -q "CN"; then
        info "檢測到中國IP，配置國內鏡像..."
        
        # npm國內鏡像
        npm config set registry https://registry.npmmirror.com
        
        # pip國內鏡像
        mkdir -p ~/.pip
        cat > ~/.pip/pip.conf << 'EOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
        
        success "已配置國內鏡像"
    else
        info "使用默認鏡像"
    fi
}

# 清理系統
cleanup_system() {
    info "清理系統..."
    
    # 清理apt緩存
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    
    # 清理npm緩存
    npm cache clean --force
    
    # 清理pip緩存
    pip3 cache purge 2>/dev/null || true
    
    success "系統清理完成"
}

# 驗證安裝
verify_installation() {
    info "驗證Ubuntu環境安裝..."
    
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
    
    # 檢查版本要求
    local node_version=$(node --version 2>/dev/null | sed 's/v//')
    local python_version=$(python3 --version 2>/dev/null | cut -d' ' -f2)
    
    if [[ "$node_version" < "16.0.0" ]]; then
        warn "Node.js版本過低，建議升級到16.x或更高版本"
    fi
    
    if [[ "$python_version" < "3.8.0" ]]; then
        warn "Python版本過低，建議升級到3.8或更高版本"
    fi
    
    if [ "$all_good" = true ]; then
        success "🎉 Ubuntu環境驗證通過！"
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
    mkdir -p ~/.local/bin
    cat > ~/.local/bin/ubuntu-ai-fix << 'EOF'
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/enjoyce20061010/auto_setup_ai_agents/main/ubuntu_fix.sh | bash
EOF
    chmod +x ~/.local/bin/ubuntu-ai-fix
    
    # 添加到PATH（如果不存在）
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
    
    success "快速啟動腳本已創建"
}

# 主程序
main() {
    echo "🐧 Ubuntu/Debian AI Agents 修復器"
    echo "================================="
    
    # 檢查是否在Ubuntu/Debian上運行
    check_os
    
    # 執行修復步驟
    update_system
    install_basic_deps
    install_nodejs
    fix_npm_permissions
    setup_python_env
    install_dev_tools
    setup_network_optimization
    cleanup_system
    verify_installation
    create_quick_scripts
    
    echo ""
    echo "🎉 Ubuntu環境修復完成！"
    echo ""
    echo "下一步:"
    echo "  1. 執行: ./install_ai_agent_linux.sh"
    echo "  2. 或使用快速命令: ubuntu-ai-fix"
    echo ""
    echo "提示: 執行 'source ~/.bashrc' 以確保所有變更生效"
}

# 執行主程序
main "$@"