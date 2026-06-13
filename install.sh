#!/bin/bash
# agy-godmode installer
# Run this script on any new WSL instance or machine to activate the full setup.
# Usage: bash install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-/home/$(whoami)}"
AGY_CONFIG="$HOME_DIR/.gemini/antigravity-cli/settings.json"

echo "[1/4] Installing GEMINI.md to $HOME_DIR..."
cp "$SCRIPT_DIR/GEMINI.md" "$HOME_DIR/GEMINI.md"
echo "      Done — $HOME_DIR/GEMINI.md"

echo "[2/4] Installing skill files to $HOME_DIR/.gemini/skills/..."
mkdir -p "$HOME_DIR/.gemini/skills"
cp "$SCRIPT_DIR/skills/"*.md "$HOME_DIR/.gemini/skills/"
echo "      Done — $(ls "$SCRIPT_DIR/skills/" | wc -l) skill files installed"

echo "[3/4] Injecting GEMINI.md into agy settings (systemPrompt)..."
mkdir -p "$(dirname "$AGY_CONFIG")"

GEMINI_CONTENT=$(cat "$HOME_DIR/GEMINI.md")

if [ -f "$AGY_CONFIG" ]; then
    # Preserve existing settings, overwrite/add systemPrompt using python3
    python3 - <<PYEOF
import json, sys

with open("$AGY_CONFIG") as f:
    settings = json.load(f)

with open("$HOME_DIR/GEMINI.md") as f:
    settings["systemPrompt"] = f.read()

with open("$AGY_CONFIG", "w") as f:
    json.dump(settings, f, indent=2)

print("      Merged into existing settings.json")
PYEOF
else
    # Create minimal settings.json with systemPrompt
    python3 - <<PYEOF
import json

with open("$HOME_DIR/GEMINI.md") as f:
    content = f.read()

settings = {"systemPrompt": content}

with open("$AGY_CONFIG", "w") as f:
    json.dump(settings, f, indent=2)

print("      Created new settings.json")
PYEOF
fi

echo "[4/4] Verifying..."
echo "      GEMINI.md: $(wc -l < "$HOME_DIR/GEMINI.md") lines"
echo "      settings.json: $(wc -c < "$AGY_CONFIG") bytes"
echo "      Skills:"
for f in "$HOME_DIR/.gemini/skills/"*.md; do
    echo "        - $(basename $f)"
done

echo ""
echo "Setup complete. GEMINI.md loads automatically on every agy session."
echo "Load a skill in any prompt: @~/.gemini/skills/rust.md <your task>"
