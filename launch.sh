#!/bin/bash

# WhatsApp MCP Server - Easy Launcher
# This script provides a simple menu to start the WhatsApp MCP services

set -e

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

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

# Function to start WhatsApp Bridge
start_bridge() {
    if is_running "main"; then
        print_warning "WhatsApp Bridge is already running"
        return 0
    fi
    
    print_status "Starting WhatsApp Bridge..."
    cd whatsapp-bridge
    nohup ./main > ../bridge.log 2>&1 &
    cd ..
    
    sleep 2
    if is_running "main"; then
        print_success "WhatsApp Bridge started successfully"
        print_status "Check bridge.log for QR code and status"
    else
        print_error "Failed to start WhatsApp Bridge"
        return 1
    fi
}

# Function to start MCP Server
start_mcp() {
    if is_running "main.py"; then
        print_warning "MCP Server is already running"
        return 0
    fi
    
    print_status "Starting MCP Server..."
    cd whatsapp-mcp-server
    nohup uv run main.py > ../mcp.log 2>&1 &
    cd ..
    
    sleep 2
    if is_running "main.py"; then
        print_success "MCP Server started successfully"
        print_status "Check mcp.log for status"
    else
        print_error "Failed to start MCP Server"
        return 1
    fi
}

# Function to stop all services
stop_all() {
    print_status "Stopping all services..."
    
    if is_running "main"; then
        pkill -f "main" && print_success "WhatsApp Bridge stopped"
    fi
    
    if is_running "main.py"; then
        pkill -f "main.py" && print_success "MCP Server stopped"
    fi
    
    print_success "All services stopped"
}

# Function to show status
show_status() {
    echo "=========================================="
    echo "WhatsApp MCP Server Status"
    echo "=========================================="
    
    if is_running "main"; then
        print_success "WhatsApp Bridge: RUNNING"
    else
        print_error "WhatsApp Bridge: NOT RUNNING"
    fi
    
    if is_running "main.py"; then
        print_success "MCP Server: RUNNING"
    else
        print_error "MCP Server: NOT RUNNING"
    fi
    
    echo ""
    echo "Log files:"
    echo "- Bridge: bridge.log"
    echo "- MCP Server: mcp.log"
    echo ""
}

# Function to show logs
show_logs() {
    echo "=========================================="
    echo "WhatsApp MCP Server Logs"
    echo "=========================================="
    
    if [[ -f "bridge.log" ]]; then
        echo "--- WhatsApp Bridge Log ---"
        tail -20 bridge.log
        echo ""
    fi
    
    if [[ -f "mcp.log" ]]; then
        echo "--- MCP Server Log ---"
        tail -20 mcp.log
        echo ""
    fi
}

# Function to show menu
show_menu() {
    echo "=========================================="
    echo "WhatsApp MCP Server - Easy Launcher"
    echo "=========================================="
    echo ""
    echo "1. Start WhatsApp Bridge"
    echo "2. Start MCP Server"
    echo "3. Start Both Services"
    echo "4. Stop All Services"
    echo "5. Show Status"
    echo "6. Show Logs"
    echo "7. Install/Update Dependencies"
    echo "8. Exit"
    echo ""
}

# Main menu loop
main() {
    while true; do
        show_menu
        read -p "Choose an option (1-8): " choice
        
        case $choice in
            1)
                start_bridge
                ;;
            2)
                start_mcp
                ;;
            3)
                start_bridge
                start_mcp
                ;;
            4)
                stop_all
                ;;
            5)
                show_status
                ;;
            6)
                show_logs
                ;;
            7)
                print_status "Running installation script..."
                ./install.sh
                ;;
            8)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-8."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Check if we're in the right directory
if [[ ! -f "whatsapp-bridge/main.go" ]] || [[ ! -f "whatsapp-mcp-server/main.py" ]]; then
    print_error "Please run this script from the WhatsApp MCP project root directory"
    exit 1
fi

# Run main function
main
