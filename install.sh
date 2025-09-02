#!/bin/bash

# GitHub 仓库信息
OWNER="enjoyce20061010"
REPO="auto_setup_ai_agents"

# 下载并解压项目
curl -L "https://github.com/$OWNER/$REPO/archive/refs/heads/main.zip" -o "$REPO-main.zip"
unzip "$REPO-main.zip"

# 进入项目目录并执行安装脚本
cd "$REPO-main"
./install_ai_agent.sh
