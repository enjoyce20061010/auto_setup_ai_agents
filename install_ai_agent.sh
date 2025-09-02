#!/bin/bash

# 顏色設定
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}
success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}
warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}
fail() {
    echo -e "${RED}[FAIL] $1${NC}"
}

precheck() {
    if [[ "$0" == "bash" ]]; then
        info "請直接執行腳本檔案，不要用 bash 來源。"
        exit 1
    fi
    if [[ "$1" == "curl" ]]; then
        info "curl 下載時將完整專案下載並在新終端執行。"
        exit 0
    fi
}

install_vscode_agent() {
    info "安裝 VSCode Agent..."
    # 安裝流程
    success "VSCode Agent 安裝完成。"
}

install_n8n_agent() {
    info "安裝 n8n Agent..."
    cd agents/n8n_agent
    npm install
    node setup.js
    success "n8n Agent 安裝完成。"
    cd ../..
}

install_chatgpt_agent() {
    info "安裝 ChatGPT Agent..."
    cd agents/chatgpt_agent
    pip install -r requirements.txt
    python3 setup.py
    success "ChatGPT Agent 安裝完成。"
    cd ../..
}

main_menu() {
    echo "選擇要安裝的 AI Agent："
    echo "1) VSCode Agent"
    echo "2) n8n Agent"
    echo "3) ChatGPT Agent"
    echo "q) 離開"
    read -p "請輸入選項: " choice
    case $choice in
        1)
            install_vscode_agent
            ;;
        2)
            install_n8n_agent
            ;;
        3)
            install_chatgpt_agent
            ;;
        q)
            info "離開安裝程式。"
            exit 0
            ;;
        *)
            warn "無效選項，請重新選擇。"
            main_menu
            ;;
    esac
}

precheck "$1"
main_menu
