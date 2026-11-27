@echo off
setlocal EnableDelayedExpansion

TITLE Installing School Fee Tracking System
echo Starting installation. Please wait and do not close this window...
echo.

set "SRC_DIR=%~dp0"
if "%SRC_DIR:~-1%"=="\" set "SRC_DIR=%SRC_DIR:~0,-1%"

if exist "D:\" (
    set "TARGET_DIR=D:\School Fee Tracking system"
) else (
    set "TARGET_DIR=%USERPROFILE%\School Fee Tracking system"
)

echo Copying project files to "%TARGET_DIR%"...
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"
robocopy "%SRC_DIR%" "%TARGET_DIR%" /E /XD "venv" ".git" "__pycache__" /XF "*.xlsx" "*.csv" "install.bat" >nul
if %errorlevel% geq 8 (
    echo [ERROR] Failed to copy project files.
    pause
    exit /b 1
)

where python >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed on this PC.
    echo Please install Python 3.10+ and check "Add Python to PATH", then run install.bat again.
    pause
    exit /b 1
)

echo Creating Python virtual environment and installing packages...
if not exist "%TARGET_DIR%\venv\Scripts\python.exe" (
    python -m venv "%TARGET_DIR%\venv"
    if %errorlevel% neq 0 (
        echo [ERROR] Could not create virtual environment.
        pause
        exit /b 1
    )
)

"%TARGET_DIR%\venv\Scripts\python.exe" -m pip install --upgrade pip >nul
"%TARGET_DIR%\venv\Scripts\pip.exe" install pandas openpyxl "fastmcp>=1.0.0" matplotlib chardet psutil
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install required Python libraries. Check internet access.
    pause
    exit /b 1
)

if not exist "%TARGET_DIR%\data" mkdir "%TARGET_DIR%\data"
if not exist "%TARGET_DIR%\charts" mkdir "%TARGET_DIR%\charts"

set "SRV_PATH=%TARGET_DIR%\server.py"
if not exist "%SRV_PATH%" (
    if exist "%TARGET_DIR%\pandas-mcp-server-main\server.py" (
        set "SRV_PATH=%TARGET_DIR%\pandas-mcp-server-main\server.py"
    )
)

set "CLAUDE_DIR=%APPDATA%\Claude"
set "CLAUDE_CFG=%CLAUDE_DIR%\claude_desktop_config.json"
if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"

set "PY_JSON=%TARGET_DIR:\=\\%\\venv\\Scripts\\python.exe"
set "SRV_JSON=%SRV_PATH:\=\\%"

(
echo {
echo   "mcpServers": {
echo     "pandas-server": {
echo       "command": "%PY_JSON%",
echo       "args": [
echo         "%SRV_JSON%"
echo       ]
echo     }
echo   }
echo }
) > "%CLAUDE_CFG%"

echo.
echo All done! Installed to: %TARGET_DIR%
echo Put school Excel files inside: %TARGET_DIR%\data
echo Restart Claude Desktop before asking questions about fee files.
pause