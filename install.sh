#!/bin/bash

# GitHub 仓库信息
OWNER="enjoyce20061010"
REPO="auto_setup_ai_agents"
BRANCH="fix/n8n-and-chatgpt-setup"

# 下载并解压项目
curl -L "https://github.com/$OWNER/$REPO/archive/refs/heads/fix/n8n-and-chatgpt-setup.zip" -o "$REPO-fix.zip"
unzip -o "$REPO-fix.zip"

# GitHub replaces '/' with '-' in the directory name
EXTRACTED_DIR_NAME="$REPO-fix-n8n-and-chatgpt-setup"

# 进入项目目录并执行安装脚本
cd "$EXTRACTED_DIR_NAME"

# Add execute permission to the installer script
chmod +x install_ai_agent.sh

./install_ai_agent.sh curl
