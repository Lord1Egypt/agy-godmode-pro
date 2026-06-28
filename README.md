# agy-godmode-pro

Elite configuration and preloaded skill library for **Antigravity CLI (agy)** and other compatible AI coding agents. 

This repository merges the elite system instructions and core workflows of `agy-godmode` with over 50+ professional, converted specialist skills from Garry Tan's `gstack` workflow, now fully adapted for AGY.

---

## What's Inside

```
agy-godmode-pro/
├── GEMINI.md          ← Core system instructions (loaded by agy)
├── install.sh         ← Linux/macOS/WSL installer
├── install.ps1        ← Windows PowerShell installer
├── install.bat        ← Windows cmd/bat wrapper
├── README.md          ← This guide
├── skills/            ← Preloaded skill library (53 files)
│   ├── rust.md / solidity.md / python.md     ← Language expertise
    ├── debugging.md / code-review.md         ← Engineering protocols
    ├── git-mastery.md / multi-agent.md       ← Workflow mastery
    ├── agy-auto-review.md / agy-brainstorm.md ← AGY-specific tools
    └── agy-*.md                           ← 44+ adapted specialist skills
```

---

## Installation

### Linux, macOS, WSL
```bash
bash install.sh
```

### Windows (PowerShell)
```powershell
.\install.ps1
```

### Windows (Command Prompt)
Double-click `install.bat` or run:
```cmd
install.bat
```

The installer will:
1. Copy `GEMINI.md` to your user home directory `~/GEMINI.md`.
2. Symlink/copy all skill files to `~/.gemini/skills/`.
3. Inject the `systemPrompt` into `~/.gemini/antigravity-cli/settings.json`.

---

## Using the Skills

Prefix any query/prompt with `@~/.gemini/skills/<skill-name>.md` to load it on-demand:

```bash
# Analyze product concept before writing code
agy
> @~/.gemini/skills/agy-office-hours.md rethink this YC startup idea

# Run CEO review to think bigger and expand scope
> @~/.gemini/skills/agy-plan-ceo-review.md evaluate our current roadmap

# Visual audit & QA on website layout
> @~/.gemini/skills/agy-qa.md test the user signup flow on http://localhost:3000
```

*Originally compiled and curated by [Lord1Egypt](https://github.com/Lord1Egypt).*
