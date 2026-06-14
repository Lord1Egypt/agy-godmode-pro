# install.ps1 for Windows PowerShell / PowerShell Core
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $HOME
$AgyConfig = Join-Path $HomeDir ".gemini\antigravity-cli\settings.json"

Write-Host "[1/5] Symlinking GEMINI.md to $HomeDir..."
# Attempt symlink so git pull updates live instructions automatically; fallback to copy if privilege fails
$GeminiLink = Join-Path $HomeDir "GEMINI.md"
$GeminiTarget = Join-Path $ScriptDir "GEMINI.md"

if (Test-Path $GeminiLink) { Remove-Item $GeminiLink -Force }
try {
    New-Item -ItemType SymbolicLink -Path $GeminiLink -Value $GeminiTarget -ErrorAction Stop | Out-Null
    Write-Host "      Done (SymbolicLink) — $GeminiLink"
} catch {
    Copy-Item $GeminiTarget $GeminiLink -Force
    Write-Host "      Done (Copy-Fallback) — $GeminiLink"
    Write-Host "      Warning: Link privilege failed. Windows copies GEMINI.md statically."
}

Write-Host "[2/5] Symlinking skill files to $HomeDir\.gemini\skills\..."
$DestSkills = Join-Path $HomeDir ".gemini\skills"
if (!(Test-Path $DestSkills)) {
    New-Item -ItemType Directory -Force -Path $DestSkills | Out-Null
}

# Clean up existing links/files in skills directory first to avoid conflicts
Get-ChildItem $DestSkills -File | Remove-Item -Force

$SymlinkFailed = $false
Get-ChildItem -Path (Join-Path $ScriptDir "skills") -Filter *.md | ForEach-Object {
    $Target = $_.FullName
    $Link = Join-Path $DestSkills $_.Name
    try {
        New-Item -ItemType SymbolicLink -Path $Link -Value $Target -ErrorAction Stop | Out-Null
    } catch {
        Copy-Item $Target $Link -Force
        $SymlinkFailed = $true
    }
}

if ($SymlinkFailed) {
    Write-Host "      Done (Copy-Fallback) — skills copied statically"
    Write-Host "      Warning: Link privilege failed. Updates require re-running this installer."
} else {
    Write-Host "      Done (SymbolicLink) — skills symlinked"
}

Write-Host "[3/5] Injecting GEMINI.md into agy settings (systemPrompt)..."
$GeminiContent = [System.IO.File]::ReadAllText($GeminiLink, [System.Text.Encoding]::UTF8)

# Strict JSON loading and parsing
$Settings = @{}
if (Test-Path $AgyConfig) {
    # Backup existing config
    Copy-Item $AgyConfig "$AgyConfig.bak" -Force
    Write-Host "      Created backup at $AgyConfig.bak"
    
    try {
        $ConfigRaw = [System.IO.File]::ReadAllText($AgyConfig, [System.Text.Encoding]::UTF8)
        $Settings = $ConfigRaw | ConvertFrom-Json
        if ($null -eq $Settings) { $Settings = @{} }
    } catch {
        Write-Error "Error: settings.json is malformed/invalid JSON. Fix settings.json to prevent overwriting other keys."
        exit 1
    }
} else {
    $SettingsDir = Split-Path $AgyConfig -Parent
    if (!(Test-Path $SettingsDir)) {
        New-Item -ItemType Directory -Force -Path $SettingsDir | Out-Null
    }
}

# PowerShell ConvertFrom-Json converts JSON to PSCustomObject. Add/modify property safely.
if ($Settings -is [System.Management.Automation.PSCustomObject]) {
    $Settings.systemPrompt = $GeminiContent
} else {
    $Settings["systemPrompt"] = $GeminiContent
}

# Atomic write by writing to tmp then replacing to prevent truncation
$TempFile = Join-Path (Split-Path $AgyConfig -Parent) "settings.json.tmp"
try {
    $JsonString = ConvertTo-Json -InputObject $Settings -Depth 20
    # Use standard UTF8 without BOM (WriteAllText default on .NET Core; encoding override on .NET Framework)
    $Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($TempFile, $JsonString, $Utf8NoBom)
    
    if (Test-Path $AgyConfig) { Remove-Item $AgyConfig -Force }
    Rename-Item -Path $TempFile -NewName "settings.json" -Force
    Write-Host "      Merged into settings.json"
} catch {
    if (Test-Path $TempFile) { Remove-Item $TempFile -Force }
    Write-Error "Failed to write settings.json atomically: $_"
    exit 1
}

Write-Host "[4/5] Setting up Git post-merge hook..."
$HookDir = Join-Path $ScriptDir ".git\hooks"
if (Test-Path $HookDir) {
    $HookPath = Join-Path $HookDir "post-merge"
    $HookContent = @"
#!/bin/sh
# agy-godmode-pro auto-update post-merge hook
echo "▶ git merge detected: re-running agy-godmode-pro installer..."
SCRIPT_DIR="\$(cd "\$(dirname "\$0")/../.." && pwd)"
if [ -f "\$SCRIPT_DIR/install.ps1" ]; then
    powershell -NoProfile -ExecutionPolicy Bypass -File "\$SCRIPT_DIR/install.ps1"
else
    bash "\$SCRIPT_DIR/install.sh"
fi
"@
    [System.IO.File]::WriteAllText($HookPath, $HookContent, $Utf8NoBom)
    # Mark executable if running inside WSL/git-bash environments
    try {
        bash -c "chmod +x '$($HookPath -replace '\\', '/')'" 2>$null
    } catch {}
    Write-Host "      Git post-merge hook installed successfully."
} else {
    Write-Host "      Skipped (not a git repository or .git directory missing)."
}

Write-Host "[5/5] Verifying..."
$SkillsCount = (Get-ChildItem $DestSkills -Filter *.md).Count
$GeminiLines = (Get-Content $GeminiLink).Count
Write-Host "      GEMINI.md lines: $GeminiLines"
Write-Host "      Skills installed: $SkillsCount files"

Write-Host ""
Write-Host "Setup complete! Run 'agy' to begin."
