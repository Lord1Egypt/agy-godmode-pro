@echo off
REM install.bat for Windows Command Prompt
echo Running installation via PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
