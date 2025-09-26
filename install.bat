@echo off
setlocal enabledelayedexpansion

REM WhatsApp MCP Server - Automated Installation Script for Windows
REM This script automates the installation of all dependencies and sets up the WhatsApp MCP server

echo ==========================================
echo WhatsApp MCP Server - Automated Installer
echo ==========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [ERROR] This script should not be run as administrator
    pause
    exit /b 1
)

REM Function to check if command exists
where go >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Go is already installed
) else (
    echo [INFO] Installing Go...
    echo Please download and install Go from https://golang.org/dl/
    echo Make sure to add Go to your PATH during installation
    echo After installing Go, run this script again
    pause
    exit /b 1
)

where python >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Python is already installed
) else (
    echo [INFO] Installing Python...
    echo Please download and install Python 3.11+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    echo After installing Python, run this script again
    pause
    exit /b 1
)

where git >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Git is already installed
) else (
    echo [INFO] Installing Git...
    echo Please download and install Git from https://git-scm.com/downloads
    echo After installing Git, run this script again
    pause
    exit /b 1
)

REM Install UV
where uv >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] UV is already installed
) else (
    echo [INFO] Installing UV package manager...
    powershell -Command "irm https://astral.sh/uv/install.ps1 | iex"
    if %errorLevel% neq 0 (
        echo [ERROR] Failed to install UV. Please install manually from https://docs.astral.sh/uv/getting-started/installation/
        pause
        exit /b 1
    )
    echo [SUCCESS] UV installed successfully
)

REM Install FFmpeg (optional)
where ffmpeg >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] FFmpeg is already installed
) else (
    echo [WARNING] FFmpeg not found. This is optional but recommended for audio conversion.
    echo Please install FFmpeg from https://ffmpeg.org/download.html if you want audio support
)

REM Setup project
echo [INFO] Setting up WhatsApp MCP project...

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0

REM Install Go dependencies
echo [INFO] Installing Go dependencies...
cd /d "%SCRIPT_DIR%whatsapp-bridge"
go mod tidy
go build -o main.exe main.go
cd /d "%SCRIPT_DIR%"

REM Install Python dependencies
echo [INFO] Installing Python dependencies...
cd /d "%SCRIPT_DIR%whatsapp-mcp-server"
uv sync
cd /d "%SCRIPT_DIR%"

echo [SUCCESS] Project setup completed

REM Create configuration files
echo [INFO] Creating configuration files...

REM Find UV executable
for /f "tokens=*" %%i in ('where uv') do set UV_PATH=%%i

REM Create Claude Desktop configuration
set CLAUDE_CONFIG_DIR=%APPDATA%\Claude
if not exist "%CLAUDE_CONFIG_DIR%" mkdir "%CLAUDE_CONFIG_DIR%"

echo {> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo   "mcpServers": {>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo     "whatsapp": {>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo       "command": "!UV_PATH!",>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo       "args": [>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo         "--directory",>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo         "%SCRIPT_DIR%whatsapp-mcp-server",>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo         "run",>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo         "main.py">> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo       ]>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo     }>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo   }>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"
echo }>> "%CLAUDE_CONFIG_DIR%\claude_desktop_config.json"

REM Create Cursor configuration
set CURSOR_CONFIG_DIR=%APPDATA%\Cursor
if not exist "%CURSOR_CONFIG_DIR%" mkdir "%CURSOR_CONFIG_DIR%"

echo {> "%CURSOR_CONFIG_DIR%\mcp.json"
echo   "mcpServers": {>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo     "whatsapp": {>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo       "command": "!UV_PATH!",>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo       "args": [>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo         "--directory",>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo         "%SCRIPT_DIR%whatsapp-mcp-server",>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo         "run",>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo         "main.py">> "%CURSOR_CONFIG_DIR%\mcp.json"
echo       ]>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo     }>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo   }>> "%CURSOR_CONFIG_DIR%\mcp.json"
echo }>> "%CURSOR_CONFIG_DIR%\mcp.json"

echo [SUCCESS] Configuration files created
echo [INFO] Claude Desktop config: %CLAUDE_CONFIG_DIR%\claude_desktop_config.json
echo [INFO] Cursor config: %CURSOR_CONFIG_DIR%\mcp.json

REM Create startup scripts
echo [INFO] Creating startup scripts...

REM Create start script for WhatsApp Bridge
echo @echo off > "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo cd /d "%SCRIPT_DIR%whatsapp-bridge" >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo echo Starting WhatsApp Bridge... >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo echo Scan the QR code with your WhatsApp mobile app to authenticate. >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo echo Press Ctrl+C to stop the bridge. >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo echo. >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo main.exe >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"
echo pause >> "%SCRIPT_DIR%start_whatsapp_bridge.bat"

REM Create start script for MCP Server
echo @echo off > "%SCRIPT_DIR%start_mcp_server.bat"
echo cd /d "%SCRIPT_DIR%whatsapp-mcp-server" >> "%SCRIPT_DIR%start_mcp_server.bat"
echo echo Starting WhatsApp MCP Server... >> "%SCRIPT_DIR%start_mcp_server.bat"
echo echo Make sure the WhatsApp Bridge is running first! >> "%SCRIPT_DIR%start_mcp_server.bat"
echo echo. >> "%SCRIPT_DIR%start_mcp_server.bat"
echo uv run main.py >> "%SCRIPT_DIR%start_mcp_server.bat"
echo pause >> "%SCRIPT_DIR%start_mcp_server.bat"

echo [SUCCESS] Startup scripts created
echo [INFO] Start WhatsApp Bridge: start_whatsapp_bridge.bat
echo [INFO] Start MCP Server: start_mcp_server.bat

echo.
echo ==========================================
echo [SUCCESS] Installation completed successfully!
echo ==========================================
echo.
echo Next steps:
echo 1. Start the WhatsApp Bridge: start_whatsapp_bridge.bat
echo 2. Scan the QR code with your WhatsApp mobile app
echo 3. Start the MCP Server: start_mcp_server.bat
echo 4. Restart Claude Desktop or Cursor
echo 5. You should now see WhatsApp as an available integration
echo.
echo For troubleshooting, see the README.md file
echo.
pause
