@echo off
REM install.bat for Windows Command Prompt
REM Try PowerShell 7+ first, fall back to Windows PowerShell
where pwsh >nul 2>nul
if %ERRORLEVEL% equ 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
)
if %ERRORLEVEL% neq 0 (
    echo Installation failed with error code %ERRORLEVEL%.
    pause
    exit /b %ERRORLEVEL%
)
echo Installation completed successfully.
pause
