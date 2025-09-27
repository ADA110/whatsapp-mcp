#!/bin/bash

# WhatsApp MCP Server - Kill All Processes Script
# This script forcefully kills all WhatsApp MCP related processes

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

# Function to force kill all processes
force_kill_all() {
    print_status "Force killing all WhatsApp MCP processes..."
    
    killed_any=false
    
    # Kill WhatsApp Bridge processes
    if pgrep -f "whatsapp-bridge.*main" > /dev/null; then
        pkill -9 -f "whatsapp-bridge.*main" && print_success "WhatsApp Bridge force killed"
        killed_any=true
    fi
    
    # Kill MCP Server processes
    if pgrep -f "whatsapp-mcp-server.*main.py" > /dev/null; then
        pkill -9 -f "whatsapp-mcp-server.*main.py" && print_success "MCP Server force killed"
        killed_any=true
    fi
    
    # Kill any remaining main processes
    if pgrep -f "./main" > /dev/null; then
        pkill -9 -f "./main" && print_success "Remaining main processes killed"
        killed_any=true
    fi
    
    # Kill any remaining main.py processes
    if pgrep -f "main.py" > /dev/null; then
        pkill -9 -f "main.py" && print_success "Remaining main.py processes killed"
        killed_any=true
    fi
    
    if [ "$killed_any" = true ]; then
        print_success "All processes force killed"
    else
        print_warning "No WhatsApp MCP processes found running"
    fi
}

# Function to show running processes
show_running_processes() {
    echo "=========================================="
    echo "WhatsApp MCP Running Processes"
    echo "=========================================="
    
    if pgrep -f "whatsapp-bridge.*main" > /dev/null; then
        print_success "WhatsApp Bridge: RUNNING"
        ps aux | grep "whatsapp-bridge.*main" | grep -v grep
    else
        print_warning "WhatsApp Bridge: NOT RUNNING"
    fi
    
    echo ""
    
    if pgrep -f "whatsapp-mcp-server.*main.py" > /dev/null; then
        print_success "MCP Server: RUNNING"
        ps aux | grep "whatsapp-mcp-server.*main.py" | grep -v grep
    else
        print_warning "MCP Server: NOT RUNNING"
    fi
    
    echo ""
}

# Main function
main() {
    echo "=========================================="
    echo "WhatsApp MCP Server - Process Killer"
    echo "=========================================="
    echo ""
    
    # Show what's currently running
    show_running_processes
    
    # Ask for confirmation
    read -p "Do you want to kill all WhatsApp MCP processes? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        force_kill_all
        echo ""
        print_status "Processes killed. You can now restart the services."
    else
        print_status "Operation cancelled."
    fi
}

# Check if we're in the right directory
if [[ ! -f "whatsapp-bridge/main.go" ]] || [[ ! -f "whatsapp-mcp-server/main.py" ]]; then
    print_error "Please run this script from the WhatsApp MCP project root directory"
    exit 1
fi

# Run main function
main
