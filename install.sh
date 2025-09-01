#!/bin/bash

# AI Agent Installer - One-Line Bootstrapper
# This script downloads the full installer package and starts the interactive setup.
# It does not require Git.

# --- Configuration ---
REPO_OWNER="enjoyce20061010"
REPO_NAME="auto_agent_package_tool"
ZIP_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.zip"
# The directory name created by unzipping the GitHub main branch zip
EXTRACTED_DIR_NAME="${REPO_NAME}-main" 

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

fail() {
    echo -e "${C_RED}ERROR:${C_RESET} $1"
    exit 1
}

# --- Main Execution ---
clear
echo "================================================"
echo "  Welcome to the AI Agent Installer"
echo "================================================"
echo

# 1. Pre-flight Checks
info "Checking for required tools (curl, unzip)..."
if ! command -v curl &> /dev/null; then
    fail "'curl' is not installed. Please install it to continue."
fi
if ! command -v unzip &> /dev/null; then
    fail "'unzip' is not installed. Please install it to continue."
fi
success "Required tools are present."
echo

# 2. Create a directory for the download
INSTALL_PARENT_DIR="$HOME/Downloads"
INSTALL_BASE_DIR="${INSTALL_PARENT_DIR}/${REPO_NAME}_installer_pkg"
rm -rf "$INSTALL_BASE_DIR" # Clean up previous attempts
mkdir -p "$INSTALL_BASE_DIR" || fail "Could not create installation directory at ${INSTALL_BASE_DIR}"
cd "$INSTALL_BASE_DIR" || fail "Could not navigate to installation directory."
info "Installer package will be downloaded to ${INSTALL_BASE_DIR}"
echo

# 3. Download the repository zip file
info "Downloading AI Agent Installer package from GitHub..."
curl -# -L -o "installer.zip" "$ZIP_URL"
if [ $? -ne 0 ]; then
    fail "Failed to download repository from ${ZIP_URL}"
fi
success "Download complete."
echo

# 4. Unzip the file
info "Extracting files..."
unzip -q "installer.zip"
if [ $? -ne 0 ]; then
    fail "Failed to unzip the downloaded file."
fi
rm "installer.zip" # Clean up the zip file
success "Extraction complete."
echo

# 5. Navigate into the extracted directory
cd "$EXTRACTED_DIR_NAME" || fail "Could not find the extracted directory: $EXTRACTED_DIR_NAME"

# 6. Make the main installer executable and run it
info "Handing over to the interactive installer..."
echo "------------------------------------------------"
chmod +x install_ai_agent.sh
./install_ai_agent.sh

# The interactive script will handle the rest.
echo "------------------------------------------------"
success "The interactive installer has finished."
info "You can find the installation package at: ${INSTALL_BASE_DIR}/${EXTRACTED_DIR_NAME}"