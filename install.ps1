# install.ps1 for Windows PowerShell / PowerShell Core
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = [System.Environment]::GetFolderPath("UserProfile")
$AgyConfig = Join-Path $HomeDir ".gemini\antigravity-cli\settings.json"

Write-Host "[1/4] Installing GEMINI.md to $HomeDir..."
Copy-Item (Join-Path $ScriptDir "GEMINI.md") (Join-Path $HomeDir "GEMINI.md") -Force

Write-Host "[2/4] Installing skill files to $HomeDir\.gemini\skills\..."
$DestSkills = Join-Path $HomeDir ".gemini\skills"
New-Item -ItemType Directory -Force -Path $DestSkills | Out-Null
Copy-Item (Join-Path $ScriptDir "skills\*") $DestSkills -Force

Write-Host "[3/4] Injecting GEMINI.md into agy settings (systemPrompt)..."
$GeminiContent = Get-Content (Join-Path $HomeDir "GEMINI.md") -Raw -Encoding UTF8

if (Test-Path $AgyConfig) {
    $Settings = Get-Content $AgyConfig -Raw -Encoding UTF8 | ConvertFrom-Json
    $Settings.systemPrompt = $GeminiContent
    $Settings | ConvertTo-Json -Depth 10 | Set-Content $AgyConfig -Encoding UTF8
    Write-Host "      Merged into existing settings.json"
} else {
    $SettingsDir = Split-Path $AgyConfig -Parent
    New-Item -ItemType Directory -Force -Path $SettingsDir | Out-Null
    $Settings = @{ systemPrompt = $GeminiContent }
    $Settings | ConvertTo-Json -Depth 10 | Set-Content $AgyConfig -Encoding UTF8
    Write-Host "      Created new settings.json"
}

Write-Host "[4/4] Verifying..."
$SkillsCount = (Get-ChildItem $DestSkills -Filter *.md).Count
Write-Host "      GEMINI.md lines: $((Get-Content (Join-Path $HomeDir "GEMINI.md")).Count)"
Write-Host "      Skills installed: $SkillsCount files"

Write-Host ""
Write-Host "Setup complete. GEMINI.md loads automatically on every agy session."
Write-Host "Load a skill in any prompt: @~/.gemini/skills/gstack-qa.md <your task>"
