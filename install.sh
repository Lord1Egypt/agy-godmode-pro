#!/bin/bash
# agy-godmode installer
# Run this script on any new WSL instance or machine to activate the full setup.
# Usage: bash install.sh

set -eu

# Force execution in bash
if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
fi

command -v python3 >/dev/null 2>&1 || { echo "Error: Python 3 is required."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"
AGY_CONFIG="$HOME_DIR/.gemini/antigravity-cli/settings.json"

echo "[1/5] Symlinking GEMINI.md to $HOME_DIR..."
# Use symlink so git pull updates live instructions automatically
ln -sf "$SCRIPT_DIR/GEMINI.md" "$HOME_DIR/GEMINI.md"
echo "      Done — $HOME_DIR/GEMINI.md"

echo "[2/5] Symlinking skill files to $HOME_DIR/.gemini/skills/..."
mkdir -p "$HOME_DIR/.gemini/skills"

# Clean up stale/old symlinks in skills folder
find "$HOME_DIR/.gemini/skills" -type l -exec rm -f {} +

shopt -s nullglob
for f in "$SCRIPT_DIR/skills/"*.md; do
    # Protect against directories existing at target path
    TARGET_PATH="$HOME_DIR/.gemini/skills/$(basename "$f")"
    if [ -d "$TARGET_PATH" ] && [ ! -L "$TARGET_PATH" ]; then
        echo "Warning: $TARGET_PATH is a directory, removing to install link..."
        rm -rf "$TARGET_PATH"
    fi
    ln -sf "$f" "$TARGET_PATH"
done
echo "      Done — $(ls "$SCRIPT_DIR/skills/"*.md 2>/dev/null | tr -d ' ' | wc -l | tr -d ' ') skills linked"

echo "[3/5] Injecting GEMINI.md into agy settings (systemPrompt)..."
mkdir -p "$(dirname "$AGY_CONFIG")"

export AGY_CONFIG_PATH="$AGY_CONFIG"
export GEMINI_MD_PATH="$HOME_DIR/GEMINI.md"

# Safe, atomic Python merge script with strict JSON parsing
python3 -c '
import json, sys, os, tempfile
config_path = os.environ["AGY_CONFIG_PATH"]
gemini_path = os.environ["GEMINI_MD_PATH"]

try:
    with open(gemini_path, "r", encoding="utf-8") as f:
        prompt = f.read()
except Exception as e:
    print(f"Error reading GEMINI.md: {e}")
    sys.exit(1)

settings = {}
if os.path.exists(config_path):
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            content = f.read().strip()
            if content:
                settings = json.loads(content)
    except json.JSONDecodeError as je:
        print(f"Error: settings.json is malformed/invalid JSON. Details: {je}")
        print("Please fix settings.json before continuing to prevent overwriting other configuration keys.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading settings.json: {e}")
        sys.exit(1)

settings["systemPrompt"] = prompt

# Atomic write using temporary file
temp_dir = os.path.dirname(config_path)
try:
    with tempfile.NamedTemporaryFile("w", dir=temp_dir, delete=False, encoding="utf-8") as tf:
        json.dump(settings, tf, indent=2)
        temp_name = tf.name
    # Backup existing config
    if os.path.exists(config_path):
        if os.path.exists(config_path + ".bak"):
            os.remove(config_path + ".bak")
        os.rename(config_path, config_path + ".bak")
    os.rename(temp_name, config_path)
except Exception as e:
    print(f"Error writing settings: {e}")
    sys.exit(1)
'
echo "      Merged into settings.json"

echo "[4/5] Setting up Git post-merge hook..."
HOOK_DIR="$SCRIPT_DIR/.git/hooks"
if [ -d "$HOOK_DIR" ]; then
    HOOK_PATH="$HOOK_DIR/post-merge"
    cat > "$HOOK_PATH" << 'EOF'
#!/bin/bash
# agy-godmode-pro auto-update post-merge hook
echo "▶ git merge detected: re-running agy-godmode-pro installer..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bash "$SCRIPT_DIR/install.sh"
EOF
    chmod +x "$HOOK_PATH"
    echo "      Git post-merge hook installed successfully."
else
    echo "      Skipped (not a git repository or .git directory missing)."
fi

echo "[5/5] Verifying..."
echo "      GEMINI.md: $(wc -l < "$HOME_DIR/GEMINI.md" | tr -d ' ') lines"
echo "      settings.json: $(wc -c < "$AGY_CONFIG" | tr -d ' ') bytes"
echo "Setup complete! Run 'agy' to begin."
