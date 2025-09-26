#!/bin/bash

# WhatsApp MCP Server - Installation Test Script
# This script tests if all dependencies are properly installed

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check version
check_version() {
    local cmd="$1"
    local min_version="$2"
    local version_cmd="$3"
    
    if command_exists "$cmd"; then
        local version
        if [[ -n "$version_cmd" ]]; then
            version=$($version_cmd)
        else
            version=$($cmd --version 2>/dev/null | head -n1 | cut -d' ' -f2)
        fi
        
        print_success "$cmd is installed (version: $version)"
        return 0
    else
        print_error "$cmd is not installed"
        return 1
    fi
}

# Function to test Go installation
test_go() {
    print_status "Testing Go installation..."
    
    if ! check_version "go" "1.20" "go version | cut -d' ' -f3 | sed 's/go//'"; then
        return 1
    fi
    
    # Test Go build
    cd whatsapp-bridge
    if go build -o /tmp/test_build main.go 2>/dev/null; then
        print_success "Go can build the WhatsApp bridge"
        rm -f /tmp/test_build
        cd ..
    else
        print_error "Go cannot build the WhatsApp bridge"
        cd ..
        return 1
    fi
}

# Function to test Python installation
test_python() {
    print_status "Testing Python installation..."
    
    if ! check_version "python3" "3.11" "python3 --version | cut -d' ' -f2"; then
        return 1
    fi
    
    # Test Python version compatibility
    if python3 -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>/dev/null; then
        print_success "Python version is compatible"
    else
        print_error "Python version is too old (need 3.11+)"
        return 1
    fi
}

# Function to test UV installation
test_uv() {
    print_status "Testing UV installation..."
    
    if ! check_version "uv" "0.1"; then
        return 1
    fi
    
    # Test UV sync
    cd whatsapp-mcp-server
    if uv sync --dry-run 2>/dev/null; then
        print_success "UV can manage Python dependencies"
        cd ..
    else
        print_error "UV cannot manage Python dependencies"
        cd ..
        return 1
    fi
}

# Function to test FFmpeg installation
test_ffmpeg() {
    print_status "Testing FFmpeg installation..."
    
    if command_exists "ffmpeg"; then
        local version=$(ffmpeg -version 2>/dev/null | head -n1 | cut -d' ' -f3)
        print_success "FFmpeg is installed (version: $version)"
        return 0
    else
        print_warning "FFmpeg is not installed (optional for audio conversion)"
        return 0
    fi
}

# Function to test Git installation
test_git() {
    print_status "Testing Git installation..."
    
    if ! check_version "git" "2.0"; then
        return 1
    fi
}

# Function to test project structure
test_project_structure() {
    print_status "Testing project structure..."
    
    local required_files=(
        "whatsapp-bridge/main.go"
        "whatsapp-bridge/go.mod"
        "whatsapp-mcp-server/main.py"
        "whatsapp-mcp-server/pyproject.toml"
        "install.sh"
        "launch.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            print_success "Found $file"
        else
            print_error "Missing $file"
            return 1
        fi
    done
}

# Function to test configuration files
test_config_files() {
    print_status "Testing configuration files..."
    
    local config_files=(
        "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
        "$HOME/.cursor/mcp.json"
    )
    
    local found_configs=0
    for config in "${config_files[@]}"; do
        if [[ -f "$config" ]]; then
            print_success "Found $config"
            ((found_configs++))
        else
            print_warning "Missing $config (will be created on first run)"
        fi
    done
    
    if [[ $found_configs -eq 0 ]]; then
        print_warning "No configuration files found. Run the installer to create them."
    fi
}

# Main test function
main() {
    echo "=========================================="
    echo "WhatsApp MCP Server - Installation Test"
    echo "=========================================="
    echo ""
    
    local tests_passed=0
    local total_tests=0
    
    # Run tests
    ((total_tests++))
    if test_git; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_go; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_python; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_uv; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_ffmpeg; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_project_structure; then
        ((tests_passed++))
    fi
    
    ((total_tests++))
    if test_config_files; then
        ((tests_passed++))
    fi
    
    echo ""
    echo "=========================================="
    echo "Test Results: $tests_passed/$total_tests tests passed"
    echo "=========================================="
    
    if [[ $tests_passed -eq $total_tests ]]; then
        print_success "All tests passed! Installation is ready."
        echo ""
        echo "Next steps:"
        echo "1. Run: ./launch.sh"
        echo "2. Start the WhatsApp Bridge"
        echo "3. Scan the QR code with your WhatsApp mobile app"
        echo "4. Start the MCP Server"
        echo "5. Restart Claude Desktop or Cursor"
    else
        print_error "Some tests failed. Please check the errors above."
        echo ""
        echo "To fix issues:"
        echo "1. Run: ./install.sh (to install missing dependencies)"
        echo "2. Run: ./test_installation.sh (to test again)"
    fi
}

# Run main function
main "$@"
