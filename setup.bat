@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

TITLE School Fee Tracking MCP Setup
echo ============================================================
echo   School Fee Tracking System - Automated Setup
echo ============================================================
echo.

REM Adjust this path if server.py is inside a subfolder like pandas-mcp-server-main\server.py
set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "SERVER_SCRIPT=%PROJECT_DIR%\server.py"

if not exist "%SERVER_SCRIPT%" (
    if exist "%PROJECT_DIR%\pandas-mcp-server-main\server.py" (
        set "SERVER_SCRIPT=%PROJECT_DIR%\pandas-mcp-server-main\server.py"
    )
)

echo [1/4] Checking Python installation...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH.
    echo Install Python 3.10+ from python.org and check "Add Python to PATH".
    pause
    exit /b 1
)

echo [2/4] Creating virtual environment and installing libraries...
if not exist "venv\Scripts\python.exe" (
    python -m venv venv
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create virtual environment.
        pause
        exit /b 1
    )
)

venv\Scripts\python.exe -m pip install --upgrade pip
venv\Scripts\pip.exe install pandas openpyxl "fastmcp>=1.0.0" matplotlib chardet psutil
if %errorlevel% neq 0 (
    echo [ERROR] Package installation failed. Check internet connection.
    pause
    exit /b 1
)

echo [3/4] Creating data and charts folders...
if not exist "data" mkdir "data"
if not exist "charts" mkdir "charts"

echo [4/4] Updating Claude Desktop MCP configuration...
set "CLAUDE_DIR=%APPDATA%\Claude"
set "CLAUDE_CFG=%CLAUDE_DIR%\claude_desktop_config.json"
if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"

set "PY_ESC=%PROJECT_DIR:\=\\%\\venv\\Scripts\\python.exe"
set "SRV_ESC=%SERVER_SCRIPT:\=\\%"

(
echo {
echo   "mcpServers": {
echo     "pandas-server": {
echo       "command": "%PY_ESC%",
echo       "args": [
echo         "%SRV_ESC%"
echo       ]
echo     }
echo   }
echo }
) > "%CLAUDE_CFG%"

echo.
echo ============================================================
echo   Setup Complete!
echo   - Put school Excel files in: %PROJECT_DIR%\data
echo   - Generated charts save to:  %PROJECT_DIR%\charts
echo   - Restart Claude Desktop to load the updated MCP server.
echo ============================================================
pause