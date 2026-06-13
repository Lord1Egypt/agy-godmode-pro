# agy-godmode-pro

Elite configuration and preloaded skill library for **Antigravity CLI (agy)** and other compatible AI coding agents. 

This repository merges the elite system instructions and core workflows of `agy-godmode` with over 50+ professional, converted specialist skills from Garry Tan's `gstack` workflow.

---

## What's Inside

```
agy-godmode-pro/
├── GEMINI.md          ← Core system instructions (loaded by agy)
├── install.sh         ← Linux/macOS/WSL installer
├── install.ps1        ← Windows PowerShell installer
├── install.bat        ← Windows cmd/bat wrapper
├── README.md          ← This guide
└── skills/            ← Preloaded skill library
    ├── rust.md        ← Rust, wgpu, WASM, ThothTerm patterns
    ├── solidity.md    ← Smart contract audits + ethsmith workflows
    ├── python.md      ← Python best practices, async, packaging
    ├── debugging.md   ← Systematic root-cause protocols
    ├── code-review.md ← PR & Diff checklist (CRITICAL → NIT)
    ├── git-mastery.md ← advanced git bisect & gh CLI workflows
    ├── multi-agent.md ← agy subshell token-saving patterns
    └── gstack-*.md    ← 55+ converted gstack engineering roles
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
2. Copy all skill files to `~/.gemini/skills/`.
3. Inject the `systemPrompt` into `~/.gemini/antigravity-cli/settings.json`.

---

## Using the Skills

Prefix any query/prompt with `@~/.gemini/skills/<skill-name>.md` to load it on-demand:

```bash
# Analyze product concept before writing code
agy
> @~/.gemini/skills/gstack-office-hours.md rethink this YC startup idea

# Run CEO review to think bigger and expand scope
> @~/.gemini/skills/gstack-plan-ceo-review.md evaluate our current roadmap

# Visual audit & QA on website layout
> @~/.gemini/skills/gstack-qa.md test the user signup flow on http://localhost:3000
```

*Originally compiled and curated by [Lord1Egypt](https://github.com/Lord1Egypt).*
