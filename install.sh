#!/bin/bash
# agy-godmode installer
# Run this script on any new WSL instance or machine to activate the full setup.
# Usage: bash install.sh

set -e

command -v python3 >/dev/null 2>&1 || { echo "Python 3 is required."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/home/$(whoami)}"
AGY_CONFIG="$HOME_DIR/.gemini/antigravity-cli/settings.json"

echo "[1/4] Installing GEMINI.md to $HOME_DIR/.gemini/..."
mkdir -p "$HOME_DIR/.gemini"
cp "$SCRIPT_DIR/GEMINI.md" "$HOME_DIR/.gemini/GEMINI.md"
echo "      Done — $HOME_DIR/.gemini/GEMINI.md"

echo "[2/4] Symlinking skill files to $HOME_DIR/.gemini/skills/..."
mkdir -p "$HOME_DIR/.gemini/skills"
# Use symlinks so git pull automatically updates live skills
for f in "$SCRIPT_DIR/skills/"*.md; do
    ln -sf "$f" "$HOME_DIR/.gemini/skills/$(basename "$f")"
done
echo "      Done — $(ls "$SCRIPT_DIR/skills/" | wc -l) skills linked"

echo "[3/4] Injecting GEMINI.md into agy settings (systemPrompt)..."
mkdir -p "$(dirname "$AGY_CONFIG")"

export AGY_CONFIG_PATH="$AGY_CONFIG"
export GEMINI_MD_PATH="$HOME_DIR/.gemini/GEMINI.md"

if [ -f "$AGY_CONFIG" ]; then
    cp "$AGY_CONFIG" "${AGY_CONFIG}.bak"
    echo "      Created backup at ${AGY_CONFIG}.bak"
    
    python3 -c '
import json, sys, os
try:
    with open(os.environ["AGY_CONFIG_PATH"]) as f:
        settings = json.load(f)
except Exception:
    settings = {}

with open(os.environ["GEMINI_MD_PATH"]) as f:
    settings["systemPrompt"] = f.read()

with open(os.environ["AGY_CONFIG_PATH"], "w") as f:
    json.dump(settings, f, indent=2)
'
    echo "      Merged into existing settings.json"
else
    python3 -c '
import json, os
with open(os.environ["GEMINI_MD_PATH"]) as f:
    content = f.read()
settings = {"systemPrompt": content}
with open(os.environ["AGY_CONFIG_PATH"], "w") as f:
    json.dump(settings, f, indent=2)
'
    echo "      Created new settings.json"
fi

echo "[4/4] Verifying..."
echo "      GEMINI.md: $(wc -l < "$HOME_DIR/.gemini/GEMINI.md") lines"
echo "      settings.json: $(wc -c < "$AGY_CONFIG") bytes"
echo "Setup complete! Run 'agy' to begin."
