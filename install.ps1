# WhatsApp MCP Server - Automated Installation Script for Windows PowerShell
# This script automates the installation of all dependencies and sets up the WhatsApp MCP server

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Function to check if command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install Go
function Install-Go {
    if (Test-Command "go") {
        $goVersion = (go version).Split(' ')[2]
        Write-Success "Go is already installed (version: $goVersion)"
        return
    }

    Write-Status "Installing Go..."
    Write-Error "Please download and install Go from https://golang.org/dl/"
    Write-Error "Make sure to add Go to your PATH during installation"
    Write-Error "After installing Go, run this script again"
    exit 1
}

# Function to install Python
function Install-Python {
    if (Test-Command "python") {
        $pythonVersion = (python --version).Split(' ')[1]
        # Check if version is 3.11 or higher
        $version = [Version]$pythonVersion
        if ($version -ge [Version]"3.11.0") {
            Write-Success "Python is already installed (version: $pythonVersion)"
            return
        } else {
            Write-Warning "Python version $pythonVersion is too old. Need Python 3.11+"
        }
    }

    Write-Status "Installing Python 3.11+..."
    Write-Error "Please download and install Python 3.11+ from https://www.python.org/downloads/"
    Write-Error "Make sure to check 'Add Python to PATH' during installation"
    Write-Error "After installing Python, run this script again"
    exit 1
}

# Function to install Git
function Install-Git {
    if (Test-Command "git") {
        $gitVersion = (git --version).Split(' ')[2]
        Write-Success "Git is already installed (version: $gitVersion)"
        return
    }

    Write-Status "Installing Git..."
    Write-Error "Please download and install Git from https://git-scm.com/downloads"
    Write-Error "After installing Git, run this script again"
    exit 1
}

# Function to install UV
function Install-UV {
    if (Test-Command "uv") {
        $uvVersion = (uv --version).Split(' ')[1]
        Write-Success "UV is already installed (version: $uvVersion)"
        return
    }

    Write-Status "Installing UV package manager..."
    try {
        Invoke-WebRequest -Uri "https://astral.sh/uv/install.ps1" -OutFile "install_uv.ps1"
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        .\install_uv.ps1
        Remove-Item "install_uv.ps1" -Force
        Write-Success "UV installed successfully"
    }
    catch {
        Write-Error "Failed to install UV. Please install manually from https://docs.astral.sh/uv/getting-started/installation/"
        exit 1
    }
}

# Function to install FFmpeg
function Install-FFmpeg {
    if (Test-Command "ffmpeg") {
        $ffmpegVersion = (ffmpeg -version).Split(' ')[2]
        Write-Success "FFmpeg is already installed (version: $ffmpegVersion)"
        return
    }

    Write-Status "Installing FFmpeg (optional, for audio conversion)..."
    Write-Warning "FFmpeg not found. This is optional but recommended for audio conversion."
    Write-Warning "Please install FFmpeg from https://ffmpeg.org/download.html if you want audio support"
}

# Function to setup the project
function Setup-Project {
    Write-Status "Setting up WhatsApp MCP project..."
    
    # Get the directory where this script is located
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    # Install Go dependencies
    Write-Status "Installing Go dependencies..."
    Set-Location "$scriptDir\whatsapp-bridge"
    go mod tidy
    go build -o main.exe main.go
    Set-Location $scriptDir
    
    # Install Python dependencies
    Write-Status "Installing Python dependencies..."
    Set-Location "$scriptDir\whatsapp-mcp-server"
    uv sync
    Set-Location $scriptDir
    
    Write-Success "Project setup completed"
}

# Function to create configuration files
function New-ConfigFiles {
    Write-Status "Creating configuration files..."
    
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    # Find UV executable
    $uvPath = (Get-Command uv).Source
    
    # Create Claude Desktop configuration
    $claudeConfigDir = "$env:APPDATA\Claude"
    if (!(Test-Path $claudeConfigDir)) {
        New-Item -ItemType Directory -Path $claudeConfigDir -Force | Out-Null
    }
    
    $claudeConfig = @{
        mcpServers = @{
            whatsapp = @{
                command = $uvPath
                args = @(
                    "--directory",
                    "$scriptDir\whatsapp-mcp-server",
                    "run",
                    "main.py"
                )
            }
        }
    } | ConvertTo-Json -Depth 4
    
    $claudeConfig | Out-File -FilePath "$claudeConfigDir\claude_desktop_config.json" -Encoding UTF8
    
    # Create Cursor configuration
    $cursorConfigDir = "$env:APPDATA\Cursor"
    if (!(Test-Path $cursorConfigDir)) {
        New-Item -ItemType Directory -Path $cursorConfigDir -Force | Out-Null
    }
    
    $cursorConfig = @{
        mcpServers = @{
            whatsapp = @{
                command = $uvPath
                args = @(
                    "--directory",
                    "$scriptDir\whatsapp-mcp-server",
                    "run",
                    "main.py"
                )
            }
        }
    } | ConvertTo-Json -Depth 4
    
    $cursorConfig | Out-File -FilePath "$cursorConfigDir\mcp.json" -Encoding UTF8
    
    Write-Success "Configuration files created"
    Write-Status "Claude Desktop config: $claudeConfigDir\claude_desktop_config.json"
    Write-Status "Cursor config: $cursorConfigDir\mcp.json"
}

# Function to create startup scripts
function New-StartupScripts {
    Write-Status "Creating startup scripts..."
    
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    
    # Create start script for WhatsApp Bridge
    $bridgeScript = @"
@echo off
cd /d "$scriptDir\whatsapp-bridge"
echo Starting WhatsApp Bridge...
echo Scan the QR code with your WhatsApp mobile app to authenticate.
echo Press Ctrl+C to stop the bridge.
echo.
main.exe
pause
"@
    
    $bridgeScript | Out-File -FilePath "$scriptDir\start_whatsapp_bridge.bat" -Encoding ASCII
    
    # Create start script for MCP Server
    $mcpScript = @"
@echo off
cd /d "$scriptDir\whatsapp-mcp-server"
echo Starting WhatsApp MCP Server...
echo Make sure the WhatsApp Bridge is running first!
echo.
uv run main.py
pause
"@
    
    $mcpScript | Out-File -FilePath "$scriptDir\start_mcp_server.bat" -Encoding ASCII
    
    Write-Success "Startup scripts created"
    Write-Status "Start WhatsApp Bridge: start_whatsapp_bridge.bat"
    Write-Status "Start MCP Server: start_mcp_server.bat"
}

# Main installation function
function Main {
    Write-Host "=========================================="
    Write-Host "WhatsApp MCP Server - Automated Installer"
    Write-Host "=========================================="
    Write-Host ""
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if ($isAdmin) {
        Write-Error "This script should not be run as administrator"
        exit 1
    }
    
    # Install dependencies
    Install-Git
    Install-Go
    Install-Python
    Install-UV
    Install-FFmpeg
    
    # Setup project
    Setup-Project
    
    # Create configuration files
    New-ConfigFiles
    
    # Create startup scripts
    New-StartupScripts
    
    Write-Host ""
    Write-Host "=========================================="
    Write-Success "Installation completed successfully!"
    Write-Host "=========================================="
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Start the WhatsApp Bridge: start_whatsapp_bridge.bat"
    Write-Host "2. Scan the QR code with your WhatsApp mobile app"
    Write-Host "3. Start the MCP Server: start_mcp_server.bat"
    Write-Host "4. Restart Claude Desktop or Cursor"
    Write-Host "5. You should now see WhatsApp as an available integration"
    Write-Host ""
    Write-Host "For troubleshooting, see the README.md file"
    Write-Host ""
    Read-Host "Press Enter to continue"
}

# Run main function
Main
