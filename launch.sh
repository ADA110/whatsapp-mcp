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

# Function to check if WhatsApp Bridge is running
is_bridge_running() {
    pgrep -f "whatsapp-bridge.*main" > /dev/null 2>&1 || pgrep -f "./main" > /dev/null 2>&1
}

# Function to check if MCP Server is running
is_mcp_running() {
    pgrep -f "whatsapp-mcp-server.*main.py" > /dev/null 2>&1 || pgrep -f "uv run main.py" > /dev/null 2>&1
}

# Function to start WhatsApp Bridge
start_bridge() {
    if is_bridge_running; then
        print_warning "WhatsApp Bridge is already running"
        return 0
    fi
    
    print_status "Starting WhatsApp Bridge..."
    cd whatsapp-bridge
    nohup ./main > ../bridge.log 2>&1 &
    cd ..
    
    sleep 2
    if is_bridge_running; then
        print_success "WhatsApp Bridge started successfully"
        print_status "Waiting for QR code..."
        
        # Wait a bit more for QR code to be generated
        sleep 3
        
        # Show QR code from log file
        if [[ -f "bridge.log" ]]; then
            echo ""
            echo "=========================================="
            echo "WHATSAPP QR CODE - SCAN WITH YOUR PHONE"
            echo "=========================================="
            echo ""
            # Extract QR code from log file
            awk '/Scan this QR code with your WhatsApp app:/{flag=1; next} /^$/{if(flag) exit} flag' bridge.log
            echo ""
            echo "=========================================="
            echo "If QR code doesn't appear above, check: cat bridge.log"
            echo "=========================================="
        else
            print_warning "Log file not found, check bridge.log manually"
        fi
    else
        print_error "Failed to start WhatsApp Bridge"
        return 1
    fi
}

# Function to start MCP Server
start_mcp() {
    if is_mcp_running; then
        print_warning "MCP Server is already running"
        return 0
    fi
    
    print_status "Starting MCP Server..."
    cd whatsapp-mcp-server
    nohup uv run main.py > ../mcp.log 2>&1 &
    cd ..
    
    sleep 2
    if is_mcp_running; then
        print_success "MCP Server started successfully"
        print_status "Check mcp.log for status"
    else
        print_error "Failed to start MCP Server"
        return 1
    fi
}


# Function to force kill all processes
force_kill_all() {
    print_status "Force killing all WhatsApp MCP processes..."
    
    # Kill WhatsApp Bridge processes
    if pgrep -f "whatsapp-bridge.*main" > /dev/null; then
        pkill -9 -f "whatsapp-bridge.*main" && print_success "WhatsApp Bridge force killed"
    fi
    
    # Kill MCP Server processes
    if pgrep -f "whatsapp-mcp-server.*main.py" > /dev/null; then
        pkill -9 -f "whatsapp-mcp-server.*main.py" && print_success "MCP Server force killed"
    fi
    
    # Kill any remaining main processes
    if pgrep -f "./main" > /dev/null; then
        pkill -9 -f "./main" && print_success "Remaining main processes killed"
    fi
    
    # Kill any remaining main.py processes
    if pgrep -f "main.py" > /dev/null; then
        pkill -9 -f "main.py" && print_success "Remaining main.py processes killed"
    fi
    
    print_success "All processes force killed"
}

# Function to show status
show_status() {
    echo "=========================================="
    echo "WhatsApp MCP Server Status"
    echo "=========================================="
    
    if is_bridge_running; then
        print_success "WhatsApp Bridge: RUNNING"
    else
        print_error "WhatsApp Bridge: NOT RUNNING"
    fi
    
    if is_mcp_running; then
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

# Function to show QR code
show_qr_code() {
    echo "=========================================="
    echo "WhatsApp QR Code"
    echo "=========================================="
    
    if [[ -f "bridge.log" ]]; then
        # Look for QR code in the log
        if grep -q "Scan this QR code" bridge.log; then
            echo ""
            echo "WHATSAPP QR CODE - SCAN WITH YOUR PHONE"
            echo ""
            # Extract QR code from log file
            awk '/Scan this QR code with your WhatsApp app:/{flag=1; next} /^$/{if(flag) exit} flag' bridge.log
            echo ""
            echo "=========================================="
        else
            print_warning "QR code not found in log. Bridge may still be starting..."
            print_status "Showing recent bridge log:"
            tail -10 bridge.log
        fi
    else
        print_error "Bridge log not found. Start the bridge first."
    fi
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
    echo "4. Force Kill All Processes"
    echo "5. Show Status"
    echo "6. Show QR Code"
    echo "7. Show Logs"
    echo "8. Install/Update Dependencies"
    echo "9. Exit"
    echo ""
}

# Main menu loop
main() {
    while true; do
        show_menu
        read -p "Choose an option (1-10): " choice
        
        case $choice in
            1)
                start_bridge
                ;;
            2)
                start_mcp
                ;;
            3)
                start_both
                ;;
            4)
                force_kill_all
                ;;
            5)
                show_status
                ;;
            6)
                show_qr_code
                ;;
            7)
                show_logs
                ;;
            8)
                print_status "Running installation script..."
                ./install.sh
                ;;
            9)
                print_status "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-9."
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

# Check for command line arguments
if [[ "$1" == "kill" ]]; then
    force_kill_all
    exit 0
elif [[ "$1" == "status" ]]; then
    show_status
    exit 0
elif [[ "$1" == "qr" ]]; then
    show_qr_code
    exit 0
fi

# Run main function
main
