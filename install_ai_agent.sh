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
pre_flight_check() {
    # The install.sh now passes 'curl' as an argument
    if [ "$1" == "curl" ]; then
        info "Running via curl. The script will now open a new terminal to continue."

        if ! command -v osascript &> /dev/null; then
            fail "This installer requires 'osascript' (AppleScript) on macOS to run correctly when installed via curl. Please run the script directly."
        fi

        # Get the absolute path to the current directory
        local CURRENT_DIR
        CURRENT_DIR=$(pwd)

        # Use osascript to open a new Terminal window, cd to the correct directory,
        # and re-run the installer script without the 'curl' argument.
        osascript -e "tell application \"Terminal\" to do script \"cd '${CURRENT_DIR}' && ./install_ai_agent.sh\""

        # The curl | bash script has done its job. Now it must exit.
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
    info "Installing the n8n Agent..."
    
    AGENT_DIR="agents/n8n_agent"
    info "Changing to $AGENT_DIR directory..."
    cd "$AGENT_DIR" || fail "Could not change to directory $AGENT_DIR"
    
    info "Installing n8n as a dependency..."
    if ! npm install n8n@1.109.1; then
        fail "npm install n8n failed. Please check for errors."
    fi

    info "Installing other Node.js dependencies..."
    if ! npm install; then
        fail "npm install failed. Please check for errors."
    fi
    
    info "Running agent setup..."
    if ! node setup.js; then
        fail "Agent setup failed. Please check for errors."
    fi
    
    success "n8n Agent installed successfully."
    info "Starting the n8n server with a tunnel..."
    info "You will see the URL for your n8n instance in the output below."
    npx n8n start --tunnel
    info "Returning to the root directory..."
    cd ../..
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
pre_flight_check "$1"
main_menu
info "Installation script finished."
