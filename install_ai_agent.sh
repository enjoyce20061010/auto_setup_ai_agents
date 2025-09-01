#!/bin/bash

#
# AI Agent Installer - An interactive installer for various AI agents
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
    exit 1
}

# --- Pre-flight check for curl-based execution ---
# This block ensures that if the script is run via curl, it first
# downloads the full repository, unpacks it, and then opens a new
# terminal window to run the interactive installer, solving all shell conflicts.
pre_flight_check() {
    # Heuristic to check if we are running from a file or a pipe.
    # If the script's name is not 'install_ai_agent.sh' (e.g., 'bash'),
    # we assume it's piped from curl and needs to download the full project.
    if [ "$(basename "$0")" != "install_ai_agent.sh" ]; then
        info "Running via curl. Preparing to download the full project..."

        # Check for required tools
        if ! command -v curl &> /dev/null; then
            fail "curl is not installed. Please install curl to continue."
        fi
        if ! command -v tar &> /dev/null; then
            fail "tar is not installed. Please install tar to continue."
        fi
        if ! command -v osascript &> /dev/null; then
            fail "osascript (AppleScript) is not available. This installer requires it on macOS."
        fi

        local REPO_OWNER="enjoyce20061010"
        local REPO_NAME="auto_setup_ai_agents"
        local TARBALL_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/main.tar.gz"
        local INSTALL_DIR="$HOME/${REPO_NAME}"
        local TEMP_TARBALL="/tmp/${REPO_NAME}.tar.gz"

        # For a curl-based install, always start fresh.
        if [ -d "$INSTALL_DIR" ]; then
            info "Removing existing installation directory at $INSTALL_DIR..."
            rm -rf "$INSTALL_DIR" || fail "Could not remove existing directory. Please check permissions."
        fi

        info "Downloading project from ${TARBALL_URL}..."
        if ! curl -L "$TARBALL_URL" -o "$TEMP_TARBALL"; then
            fail "Failed to download the project tarball. Please check the URL and your connection."
        fi

        info "Unpacking project into $INSTALL_DIR..."
        mkdir -p "$INSTALL_DIR" || fail "Could not create installation directory."
        if ! tar -xzf "$TEMP_TARBALL" -C "$INSTALL_DIR" --strip-components=1; then
            fail "Failed to unpack the project tarball."
        fi
        rm "$TEMP_TARBALL"

        info "Download complete. Opening a new terminal window to start the installation..."

        # Use osascript to open a new Terminal window and run the installer.
        # This is the most robust way to create a new, interactive session
        # and avoid all shell conflicts (zsh vs bash) from the curl pipe.
        osascript -e "tell application \"Terminal\" to do script \"cd '${INSTALL_DIR}' && ./install_ai_agent.sh\""
        
        # The curl | bash script has done its job (downloading). Now it must exit.
        success "A new terminal window has been opened to continue the installation. Please check your open windows."
        exit 0
    fi
}

# --- Agent Installation Functions ---

# 1. VSCode Agent
install_vscode_agent() {
    info "Installing the VSCode Agent (Standalone)..."

    # Check for Node.js and npm
    if ! command -v node &> /dev/null; then
        fail "Node.js is not installed. Please install Node.js to continue."
    fi
    if ! command -v npm &> /dev/null; then
        fail "npm is not installed. Please install npm to continue."
    fi

    AGENT_DIR="agents/vscode_agent"

    info "Changing to $AGENT_DIR directory..."
    cd "$AGENT_DIR" || fail "Could not change to directory $AGENT_DIR"

    info "Installing Node.js dependencies via npm..."
    if ! npm install; then
        fail "npm install failed. Please check for errors."
    fi

    info "Configuring the agent..."
    if ! npm run setup; then
        fail "Agent setup failed. Please check for errors."
    fi

    info "Returning to the root directory..."
    cd - > /dev/null # Go back to the previous directory silently

    success "VSCode Agent installed successfully!"
    info "To run the agent, use the following commands:"
    echo "  cd $AGENT_DIR"
    echo "  npm start"
}

# 2. n8n Agent
install_n8n_agent() {
    info "Installing the n8n Agent with a dedicated environment..."

    # Check for Node.js and npm
    if ! command -v node &> /dev/null; then
        fail "Node.js is not installed. Please install Node.js to continue."
    fi
    if ! command -v npm &> /dev/null; then
        fail "npm is not installed. Please install npm to continue."
    fi

    AGENT_DIR="agents/n8n_agent"

    info "Changing to $AGENT_DIR directory..."
    cd "$AGENT_DIR" || fail "Could not change to directory $AGENT_DIR"

    info "Installing Node.js dependencies (including n8n itself)..."
    if ! npm install; then
        fail "npm install failed. Please check for errors."
    fi

    info "Configuring the n8n environment..."
    if ! npm run setup; then
        fail "Agent setup failed. Please check for errors."
    fi

    # n8n looks for a .n8n directory in the user's home directory by default for user data.
    # We will create it and a specific subdirectory for our workflows.
    N8N_USER_DIR="$HOME/.n8n"
    N8N_CUSTOM_DIR="$N8N_USER_DIR/custom"
    info "Ensuring n8n custom workflow directory exists at $N8N_CUSTOM_DIR..."
    mkdir -p "$N8N_CUSTOM_DIR"

    info "Copying workflow.json to the n8n custom directory..."
    cp -f workflow.json "$N8N_CUSTOM_DIR/workflow.json"

    info "Returning to the root directory..."
    cd - > /dev/null # Go back to the previous directory silently

    success "n8n Agent installed successfully!"
    info "All data will be stored in the local '$AGENT_DIR/database' folder."
    info "To run the agent, use the following commands:"
    echo "  cd $AGENT_DIR"
    echo "  npm start"
}

# 3. ChatGPT Agent
install_chatgpt_agent() {
    info "Installing the ChatGPT Agent..."

    # Check for Python
    if ! command -v python3 &> /dev/null; then
        fail "Python 3 is not installed. Please install Python 3 to continue."
    fi

    # Check for pip
    if ! command -v pip3 &> /dev/null; then
        fail "pip3 is not installed. Please install pip3 to continue."
    fi

    AGENT_DIR="agents/chatgpt_agent"
    VENV_DIR="$AGENT_DIR/venv"

    # Create virtual environment
    info "Creating Python virtual environment in $VENV_DIR..."
    python3 -m venv "$VENV_DIR"

    # Activate virtual environment and install dependencies
    info "Installing dependencies from requirements.txt..."
    source "$VENV_DIR/bin/activate"
    pip3 install -r "$AGENT_DIR/requirements.txt"
    deactivate

    # Prompt for API Key
    read -p "Please enter your OpenAI API Key: " OPENAI_API_KEY
    if [ -z "$OPENAI_API_KEY" ]; then
        fail "OpenAI API Key cannot be empty. Installation cancelled."
    fi

    # Replace placeholder in the script
    # Note: Using a temporary file for sed to work on both macOS and Linux
    sed -i.bak "s/YOUR_OPENAI_API_KEY/$OPENAI_API_KEY/g" "$AGENT_DIR/chatgpt_agent.py"
    rm "$AGENT_DIR/chatgpt_agent.py.bak"

    success "ChatGPT Agent installed successfully!"
    info "To run the agent, use the following commands:"
    echo "  cd $AGENT_DIR"
    echo "  source venv/bin/activate"
    echo "  python3 chatgpt_agent.py"
}


# --- Main Menu ---
main_menu() {
    clear
    echo "========================================"
    echo "       AI Agent Installer"
    echo "========================================"
    echo "This script will help you install various AI agents."
    echo
    echo "Select an agent to install:"
    
    PS3="Please enter your choice: "
    options=("VSCode Agent" "n8n Agent" "ChatGPT Agent" "Install All" "Exit")
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
            "Install All")
                info "Installing all agents..."
                install_vscode_agent
                install_n8n_agent
                install_chatgpt_agent
                success "All agents have been processed."
                break
                ;;
            "Exit")
                break
                ;;
            *) echo "Invalid option $REPLY";;
        esac
    done
}

# --- Script Entry Point ---
pre_flight_check
main_menu
info "Installation script finished."
