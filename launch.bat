@echo off
setlocal enabledelayedexpansion

REM WhatsApp MCP Server - Easy Launcher for Windows
REM This script provides a simple menu to start the WhatsApp MCP services

:menu
cls
echo ==========================================
echo WhatsApp MCP Server - Easy Launcher
echo ==========================================
echo.
echo 1. Start WhatsApp Bridge
echo 2. Start MCP Server
echo 3. Start Both Services
echo 4. Stop All Services
echo 5. Show Status
echo 6. Show Logs
echo 7. Install/Update Dependencies
echo 8. Exit
echo.

set /p choice="Choose an option (1-8): "

if "%choice%"=="1" goto start_bridge
if "%choice%"=="2" goto start_mcp
if "%choice%"=="3" goto start_both
if "%choice%"=="4" goto stop_all
if "%choice%"=="5" goto show_status
if "%choice%"=="6" goto show_logs
if "%choice%"=="7" goto install
if "%choice%"=="8" goto exit
echo Invalid option. Please choose 1-8.
pause
goto menu

:start_bridge
echo [INFO] Starting WhatsApp Bridge...
cd whatsapp-bridge
start "WhatsApp Bridge" cmd /k "main.exe"
cd ..
echo [SUCCESS] WhatsApp Bridge started in new window
echo Check the new window for QR code and status
pause
goto menu

:start_mcp
echo [INFO] Starting MCP Server...
cd whatsapp-mcp-server
start "MCP Server" cmd /k "uv run main.py"
cd ..
echo [SUCCESS] MCP Server started in new window
pause
goto menu

:start_both
echo [INFO] Starting both services...
cd whatsapp-bridge
start "WhatsApp Bridge" cmd /k "main.exe"
cd ..
cd whatsapp-mcp-server
start "MCP Server" cmd /k "uv run main.py"
cd ..
echo [SUCCESS] Both services started in new windows
pause
goto menu

:stop_all
echo [INFO] Stopping all services...
taskkill /f /im main.exe 2>nul
taskkill /f /im python.exe 2>nul
echo [SUCCESS] All services stopped
pause
goto menu

:show_status
echo ==========================================
echo WhatsApp MCP Server Status
echo ==========================================
tasklist /fi "imagename eq main.exe" | find "main.exe" >nul
if %errorlevel%==0 (
    echo [SUCCESS] WhatsApp Bridge: RUNNING
) else (
    echo [ERROR] WhatsApp Bridge: NOT RUNNING
)

tasklist /fi "imagename eq python.exe" | find "python.exe" >nul
if %errorlevel%==0 (
    echo [SUCCESS] MCP Server: RUNNING
) else (
    echo [ERROR] MCP Server: NOT RUNNING
)

echo.
echo Log files:
echo - Bridge: Check the WhatsApp Bridge window
echo - MCP Server: Check the MCP Server window
echo.
pause
goto menu

:show_logs
echo ==========================================
echo WhatsApp MCP Server Logs
echo ==========================================
echo Check the individual service windows for logs
echo.
pause
goto menu

:install
echo [INFO] Running installation script...
install.bat
pause
goto menu

:exit
echo [INFO] Goodbye!
exit /b 0
