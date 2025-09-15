#!/bin/bash
#
# AI Agent Installer - Linux 版本
# 適用於一般 Linux 環境的一鍵安裝腳本
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
    echo ""
    echo "安裝失敗！請執行以下命令進行診斷："
    echo "  ./linux_install_diagnostic.sh --diagnostic"
    echo ""
    exit 1
}

# --- 系統檢查 ---
check_system() {
    info "檢查系統環境..."
    
    # 檢查是否為Linux
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        warn "此腳本專為Linux設計，當前系統: $OSTYPE"
    fi
    
    # 檢查必要工具
    local tools=("curl" "tar" "git" "python3" "pip3" "node" "npm")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        fail "缺少必要工具: ${missing_tools[*]}"
    fi
    
    success "系統檢查通過"
}

# --- 下載專案 ---
download_project() {
    info "下載 AI Agent 專案..."
    
    local REPO_OWNER="enjoyce20061010"
    local REPO_NAME="auto_setup_ai_agents"
    local INSTALL_DIR="$HOME/${REPO_NAME}"
    local TEMP_TARBALL="/tmp/${REPO_NAME}.tar.gz"
    local TARBALL_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
    
    # 清理舊目錄
    if [ -d "$INSTALL_DIR" ]; then
        warn "發現舊的安裝目錄，正在清理..."
        rm -rf "$INSTALL_DIR" || fail "無法刪除舊目錄"
    fi
    
    # 下載
    if ! curl -L "$TARBALL_URL" -o "$TEMP_TARBALL"; then
        fail "下載失敗，請檢查網路連線"
    fi
    
    # 解壓縮
    mkdir -p "$INSTALL_DIR"
    if ! tar -xzf "$TEMP_TARBALL" -C "$INSTALL_DIR" --strip-components=1; then
        fail "解壓縮失敗"
    fi
    
    rm "$TEMP_TARBALL"
    
    # 切換到安裝目錄
    cd "$INSTALL_DIR" || fail "無法進入安裝目錄"
    
    success "專案下載完成"
}

# --- 1. VSCode Agent 安裝 ---
install_vscode_agent() {
    info "安裝 VSCode Agent..."
    
    local AGENT_DIR="agents/vscode_agent"
    
    if [ ! -d "$AGENT_DIR" ]; then
        warn "VSCode Agent 目錄不存在，跳過"
        return 0
    fi
    
    cd "$AGENT_DIR" || fail "無法進入 VSCode Agent 目錄"
    
    info "安裝 Node.js 依賴..."
    npm install || fail "npm install 失敗"
    
    if [ -f "package.json" ] && npm run setup &> /dev/null; then
        npm run setup || warn "setup 腳本執行失敗"
    fi
    
    cd - > /dev/null
    success "VSCode Agent 安裝完成"
}

# --- 2. n8n Agent 安裝 ---
install_n8n_agent() {
    info "安裝 n8n Agent..."
    
    local AGENT_DIR="agents/n8n_agent"
    
    if [ ! -d "$AGENT_DIR" ]; then
        warn "n8n Agent 目錄不存在，跳過"
        return 0
    fi
    
    cd "$AGENT_DIR" || fail "無法進入 n8n Agent 目錄"
    
    info "安裝 Node.js 依賴..."
    npm install || fail "npm install 失敗"
    
    if [ -f "package.json" ] && npm run setup &> /dev/null; then
        npm run setup || warn "setup 腳本執行失敗"
    fi
    
    # 設置 n8n 工作目錄
    local N8N_USER_DIR="$HOME/.n8n"
    local N8N_CUSTOM_DIR="$N8N_USER_DIR/custom"
    mkdir -p "$N8N_CUSTOM_DIR"
    
    if [ -f "workflow.json" ]; then
        cp -f "workflow.json" "$N8N_CUSTOM_DIR/workflow.json"
        info "工作流文件已複製"
    fi
    
    cd - > /dev/null
    success "n8n Agent 安裝完成"
}

# --- 3. ChatGPT Agent 安裝 ---
install_chatgpt_agent() {
    info "安裝 ChatGPT Agent..."
    
    local AGENT_DIR="agents/chatgpt_agent"
    local VENV_DIR="$AGENT_DIR/venv"
    
    if [ ! -d "$AGENT_DIR" ]; then
        warn "ChatGPT Agent 目錄不存在，跳過"
        return 0
    fi
    
    cd "$AGENT_DIR" || fail "無法進入 ChatGPT Agent 目錄"
    
    # 創建虛擬環境
    if [ ! -d "$VENV_DIR" ]; then
        info "創建 Python 虛擬環境..."
        python3 -m venv "$VENV_DIR" || fail "無法創建虛擬環境"
    fi
    
    # 安裝依賴
    source "$VENV_DIR/bin/activate"
    
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt || fail "pip install 失敗"
    fi
    
    # 處理 pydantic-settings 兼容性問題
    pip3 install pydantic-settings || warn "pydantic-settings 安裝失敗"
    
    # 提示輸入 API Key
    echo ""
    read -p "請輸入 OpenAI API Key: " OPENAI_API_KEY
    if [ -n "$OPENAI_API_KEY" ]; then
        sed -i.bak "s/YOUR_OPENAI_API_KEY/$OPENAI_API_KEY/g" "chatgpt_agent.py"
        rm -f "chatgpt_agent.py.bak"
        success "API Key 已配置"
    else
        warn "未提供 API Key，需要手動配置"
    fi
    
    deactivate
    cd - > /dev/null
    success "ChatGPT Agent 安裝完成"
}

# --- 根因分析工具安裝 ---
install_diagnostic_tools() {
    info "安裝診斷工具..."
    
    # 設置診斷腳本可執行權限
    chmod +x linux_install_diagnostic.sh || warn "無法設置診斷腳本權限"
    
    # 創建快速診斷命令
    cat > diagnose.sh << 'EOF'
#!/bin/bash
echo "執行安裝診斷..."
./linux_install_diagnostic.sh --diagnostic
EOF
    
    chmod +x diagnose.sh
    success "診斷工具已準備就緒"
}

# --- 主選單 ---
main_menu() {
    clear
    echo "========================================"
    echo "    AI Agent Installer - Linux 版本"
    echo "========================================"
    echo "此腳本專為 Linux 環境設計"
    echo ""
    echo "選擇要安裝的 Agent:"
    
    PS3="請輸入選項: "
    options=("VSCode Agent" "n8n Agent" "ChatGPT Agent" "安裝全部" "執行診斷" "退出")
    
    select opt in "${options[@]}"
    do
        case $opt in
            "VSCode Agent")
                install_vscode_agent
                break
                ;;
            "n8n Agent")
                install_n8n_agent
                break
                ;;
            "ChatGPT Agent")
                install_chatgpt_agent
                break
                ;;
            "安裝全部")
                info "開始安裝所有 Agent..."
                install_vscode_agent
                install_n8n_agent
                install_chatgpt_agent
                success "所有 Agent 安裝完成！"
                break
                ;;
            "執行診斷")
                ./linux_install_diagnostic.sh --diagnostic
                break
                ;;
            "退出")
                break
                ;;
            *) echo "無效選項 $REPLY";;
        esac
    done
}

# --- 主程式 ---
main() {
    info "啟動 AI Agent Linux 安裝程式..."
    
    # 檢查系統
    check_system
    
    # 如果透過 curl 執行，先下載專案
    if [ "$(basename "$0")" != "install_ai_agent_linux.sh" ]; then
        info "透過 curl 執行，正在下載專案..."
        download_project
    fi
    
    # 安裝診斷工具
    install_diagnostic_tools
    
    # 顯示主選單
    main_menu
    
    success "安裝程式執行完成！"
    echo ""
    echo "使用說明:"
    echo "1. 如果安裝失敗，執行: ./diagnose.sh"
    echo "2. 手動診斷: ./linux_install_diagnostic.sh --diagnostic"
    echo "3. 查看日誌: tail -f /tmp/install_*.log"
}

# 執行主程式
main "$@"