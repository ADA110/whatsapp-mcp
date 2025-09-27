#!/bin/bash

# WhatsApp MCP Server - Automated Installation Script
# This script automates the installation of all dependencies and sets up the WhatsApp MCP server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to install Homebrew
install_homebrew() {
    if command_exists brew; then
        BREW_VERSION=$(brew --version | head -n1 | cut -d' ' -f2)
        print_success "Homebrew is already installed (version: $BREW_VERSION)"
        return 0
    fi

    print_status "Installing Homebrew..."
    
    # Install Homebrew using the official installer
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    # Add Homebrew to PATH permanently
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    elif [[ -f "/usr/local/bin/brew" ]]; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
    fi
    
    # Verify installation
    if command_exists brew; then
        print_success "Homebrew installed successfully"
    else
        print_error "Homebrew installation failed. Please install manually: https://brew.sh/"
        exit 1
    fi
}

# Function to install Go
install_go() {
    if command_exists go; then
        GO_VERSION=$(go version | cut -d' ' -f3 | sed 's/go//')
        print_success "Go is already installed (version: $GO_VERSION)"
        return 0
    fi

    print_status "Installing Go..."
    
    OS=$(detect_os)
    case $OS in
        "linux")
            # Install Go for Linux
            GO_VERSION="1.24.1"
            wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
            sudo rm -rf /usr/local/go
            sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
            rm go${GO_VERSION}.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            export PATH=$PATH:/usr/local/go/bin
            ;;
        "macos")
            # Install Go for macOS using Homebrew
            if ! command_exists brew; then
                install_homebrew
            fi
            brew install go
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
    
    print_success "Go installed successfully"
}

# Function to install Python
install_python() {
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        # Check if version is 3.11 or higher
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
            print_success "Python is already installed (version: $PYTHON_VERSION)"
            return 0
        else
            print_warning "Python version $PYTHON_VERSION is too old. Need Python 3.11+"
        fi
    fi

    print_status "Installing Python 3.11+..."
    
    OS=$(detect_os)
    case $OS in
        "linux")
            # Install Python 3.11+ for Linux
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo add-apt-repository -y ppa:deadsnakes/ppa
            sudo apt-get update
            sudo apt-get install -y python3.11 python3.11-venv python3.11-pip
            ;;
        "macos")
            # Install Python for macOS using Homebrew
            if ! command_exists brew; then
                install_homebrew
            fi
            brew install python@3.11
            ;;
        *)
            print_error "Unsupported operating system: $OSTYPE"
            exit 1
            ;;
    esac
    
    print_success "Python installed successfully"
}

# Function to install UV
install_uv() {
    if command_exists uv; then
        UV_VERSION=$(uv --version | cut -d' ' -f2)
        print_success "UV is already installed (version: $UV_VERSION)"
        return 0
    fi

    print_status "Installing UV package manager..."
    
    # Install UV using the official installer
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add UV to PATH
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
    
    # Verify installation
    if command_exists uv; then
        print_success "UV installed successfully"
    else
        print_error "UV installation failed. Please install manually: https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    fi
}


# Function to install Git
install_git() {
    if command_exists git; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git is already installed (version: $GIT_VERSION)"
        return 0
    fi

    print_status "Installing Git..."
    
    OS=$(detect_os)
    case $OS in
        "linux")
            sudo apt-get update
            sudo apt-get install -y git
            ;;
        "macos")
            if ! command_exists brew; then
                install_homebrew
            fi
            brew install git
            ;;
        *)
            print_error "Please install Git manually for your operating system"
            exit 1
            ;;
    esac
    
    print_success "Git installed successfully"
}

# Function to setup the project
setup_project() {
    print_status "Setting up WhatsApp MCP project..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Navigate to the project directory
    cd "$SCRIPT_DIR"
    
    # Install Go dependencies
    print_status "Installing Go dependencies..."
    cd whatsapp-bridge
    go mod tidy
    go build -o main main.go
    cd ..
    
    # Install Python dependencies
    print_status "Installing Python dependencies..."
    cd whatsapp-mcp-server
    uv sync
    cd ..
    
    print_success "Project setup completed"
}

# Function to create configuration files
create_config_files() {
    print_status "Creating configuration files..."
    
    # Get the directory where this script is located
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Find UV executable
    UV_PATH=$(which uv)
    if [[ -z "$UV_PATH" ]]; then
        UV_PATH="$HOME/.cargo/bin/uv"
    fi
    
    # Create Claude Desktop configuration
    CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        mkdir -p "$CLAUDE_CONFIG_DIR"
    fi
    
    cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "whatsapp": {
      "command": "$UV_PATH",
      "args": [
        "--directory",
        "$SCRIPT_DIR/whatsapp-mcp-server",
        "run",
        "main.py"
      ]
    }
  }
}
EOF
    
    # Create Cursor configuration
    CURSOR_CONFIG_DIR="$HOME/.cursor"
    if [[ ! -d "$CURSOR_CONFIG_DIR" ]]; then
        mkdir -p "$CURSOR_CONFIG_DIR"
    fi
    
    cat > "$CURSOR_CONFIG_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "whatsapp": {
      "command": "$UV_PATH",
      "args": [
        "--directory",
        "$SCRIPT_DIR/whatsapp-mcp-server",
        "run",
        "main.py"
      ]
    }
  }
}
EOF
    
    print_success "Configuration files created"
    print_status "Claude Desktop config: $CLAUDE_CONFIG_DIR/claude_desktop_config.json"
    print_status "Cursor config: $CURSOR_CONFIG_DIR/mcp.json"
}

# Function to create startup scripts
create_startup_scripts() {
    print_status "Creating startup scripts..."
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create start script
    cat > "$SCRIPT_DIR/start_whatsapp_bridge.sh" << 'EOF'
#!/bin/bash
# Start WhatsApp Bridge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/whatsapp-bridge"

echo "Starting WhatsApp Bridge..."
echo "Scan the QR code with your WhatsApp mobile app to authenticate."
echo "Press Ctrl+C to stop the bridge."

./main
EOF
    
    chmod +x "$SCRIPT_DIR/start_whatsapp_bridge.sh"
    
    # Create start MCP server script
    cat > "$SCRIPT_DIR/start_mcp_server.sh" << 'EOF'
#!/bin/bash
# Start MCP Server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/whatsapp-mcp-server"

echo "Starting WhatsApp MCP Server..."
echo "Make sure the WhatsApp Bridge is running first!"

uv run main.py
EOF
    
    chmod +x "$SCRIPT_DIR/start_mcp_server.sh"
    
    print_success "Startup scripts created"
    print_status "Start WhatsApp Bridge: ./start_whatsapp_bridge.sh"
    print_status "Start MCP Server: ./start_mcp_server.sh"
}

# Main installation function
main() {
    echo "=========================================="
    echo "WhatsApp MCP Server - Automated Installer"
    echo "=========================================="
    echo ""
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Install dependencies
    install_git
    install_go
    install_python
    install_uv
    
    # Setup project
    setup_project
    
    # Create configuration files
    create_config_files
    
    # Create startup scripts
    create_startup_scripts
    
    echo ""
    echo "=========================================="
    print_success "Installation completed successfully!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Start the WhatsApp Bridge: ./start_whatsapp_bridge.sh"
    echo "2. Scan the QR code with your WhatsApp mobile app"
    echo "3. Start the MCP Server: ./start_mcp_server.sh"
    echo "4. Restart Claude Desktop or Cursor"
    echo "5. You should now see WhatsApp as an available integration"
    echo ""
    echo "For troubleshooting, see the README.md file"
}

# Run main function
main "$@"
