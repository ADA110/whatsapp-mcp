@echo off
setlocal enabledelayedexpansion

REM WhatsApp MCP Server - Installation Test Script for Windows
REM This script tests if all dependencies are properly installed

echo ==========================================
echo WhatsApp MCP Server - Installation Test
echo ==========================================
echo.

set tests_passed=0
set total_tests=0

REM Test Git
echo [INFO] Testing Git installation...
where git >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] Git is installed
    set /a tests_passed+=1
) else (
    echo [ERROR] Git is not installed
)
set /a total_tests+=1

REM Test Go
echo [INFO] Testing Go installation...
where go >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] Go is installed
    go version
    echo [INFO] Testing Go build...
    cd whatsapp-bridge
    go build -o test_build.exe main.go 2>nul
    if %errorlevel%==0 (
        echo [SUCCESS] Go can build the WhatsApp bridge
        del test_build.exe 2>nul
    ) else (
        echo [ERROR] Go cannot build the WhatsApp bridge
    )
    cd ..
    set /a tests_passed+=1
) else (
    echo [ERROR] Go is not installed
)
set /a total_tests+=1

REM Test Python
echo [INFO] Testing Python installation...
where python >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] Python is installed
    python --version
    echo [INFO] Testing Python version compatibility...
    python -c "import sys; exit(0 if sys.version_info >= (3, 11) else 1)" 2>nul
    if %errorlevel%==0 (
        echo [SUCCESS] Python version is compatible
    ) else (
        echo [ERROR] Python version is too old (need 3.11+)
    )
    set /a tests_passed+=1
) else (
    echo [ERROR] Python is not installed
)
set /a total_tests+=1

REM Test UV
echo [INFO] Testing UV installation...
where uv >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] UV is installed
    uv --version
    echo [INFO] Testing UV sync...
    cd whatsapp-mcp-server
    uv sync --dry-run 2>nul
    if %errorlevel%==0 (
        echo [SUCCESS] UV can manage Python dependencies
    ) else (
        echo [ERROR] UV cannot manage Python dependencies
    )
    cd ..
    set /a tests_passed+=1
) else (
    echo [ERROR] UV is not installed
)
set /a total_tests+=1

REM Test FFmpeg
echo [INFO] Testing FFmpeg installation...
where ffmpeg >nul 2>&1
if %errorlevel%==0 (
    echo [SUCCESS] FFmpeg is installed
    ffmpeg -version 2>nul | find "ffmpeg version"
    set /a tests_passed+=1
) else (
    echo [WARNING] FFmpeg is not installed (optional for audio conversion)
    set /a tests_passed+=1
)
set /a total_tests+=1

REM Test project structure
echo [INFO] Testing project structure...
set required_files=whatsapp-bridge\main.go whatsapp-bridge\go.mod whatsapp-mcp-server\main.py whatsapp-mcp-server\pyproject.toml install.bat launch.bat
set missing_files=0
for %%f in (%required_files%) do (
    if not exist "%%f" (
        echo [ERROR] Missing %%f
        set /a missing_files+=1
    ) else (
        echo [SUCCESS] Found %%f
    )
)
if %missing_files%==0 (
    set /a tests_passed+=1
) else (
    echo [ERROR] Some required files are missing
)
set /a total_tests+=1

REM Test configuration files
echo [INFO] Testing configuration files...
set config_files=%APPDATA%\Claude\claude_desktop_config.json %APPDATA%\Cursor\mcp.json
set found_configs=0
for %%f in (%config_files%) do (
    if exist "%%f" (
        echo [SUCCESS] Found %%f
        set /a found_configs+=1
    ) else (
        echo [WARNING] Missing %%f (will be created on first run)
    )
)
if %found_configs%==0 (
    echo [WARNING] No configuration files found. Run the installer to create them.
)
set /a tests_passed+=1
set /a total_tests+=1

echo.
echo ==========================================
echo Test Results: %tests_passed%/%total_tests% tests passed
echo ==========================================

if %tests_passed%==%total_tests% (
    echo [SUCCESS] All tests passed! Installation is ready.
    echo.
    echo Next steps:
    echo 1. Run: launch.bat
    echo 2. Start the WhatsApp Bridge
    echo 3. Scan the QR code with your WhatsApp mobile app
    echo 4. Start the MCP Server
    echo 5. Restart Claude Desktop or Cursor
) else (
    echo [ERROR] Some tests failed. Please check the errors above.
    echo.
    echo To fix issues:
    echo 1. Run: install.bat (to install missing dependencies)
    echo 2. Run: test_installation.bat (to test again)
)

echo.
pause
