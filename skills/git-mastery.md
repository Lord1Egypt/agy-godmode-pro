# Git Mastery Skill

## Archaeology — Understanding Code History

```bash
# Find who wrote a specific line and why
git blame -L 42,52 src/main.py
git blame -C -C -L 42,52 src/main.py  # -C -C traces through copies/renames

# Find when specific code was introduced
git log -p -S "the code fragment" -- path/to/file
git log -p -G "regex pattern" -- path/to/file

# Find all commits that touched a function
git log -L :function_name:file.py

# Binary search for a regression
git bisect start
git bisect bad HEAD
git bisect good v2.0.0  # last known good tag
# Mark each checkout: git bisect good / git bisect bad
git bisect run pytest tests/test_regression.py  # automate it
git bisect reset

# What changed between two releases
git log v1.0..v2.0 --oneline
git diff v1.0..v2.0 -- path/to/file

# Full file history including renames
git log --follow --all --oneline -- src/old_name.py
```

---

## Commit Discipline

```bash
# Stage specific hunks (not whole files)
git add -p

# Verify what's staged before committing
git diff --staged

# Good commit message format:
# <type>(<scope>): <concise what+why in imperative mood>
#
# feat(auth): add JWT refresh token rotation
# fix(api): handle null response from upstream when rate limited
# refactor(core): extract validation into reusable middleware
# perf(db): cache user lookups to reduce query count by 80%

# Amend the last commit (only if not pushed)
git commit --amend --no-edit  # keep message
git commit --amend            # edit message

# Squash last N commits into one clean commit
git reset --soft HEAD~N
git commit -m "clean commit message"
```

---

## Branch Management

```bash
# Create feature branch from latest main
git fetch origin
git checkout -b feat/my-feature origin/main

# Keep feature branch up to date (rebase, not merge — cleaner history)
git fetch origin
git rebase origin/main

# Interactive rebase to clean up commits before PR
git rebase -i origin/main  # squash, reword, fixup

# Delete merged branches locally and remotely
git branch -d old-branch
git push origin --delete old-branch

# Find branches not yet merged into main
git branch --no-merged main
```

---

## Recovery Operations

```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Undo last commit, keep changes unstaged
git reset HEAD~1

# Throw away last commit and its changes (destructive — confirm first)
git reset --hard HEAD~1

# Recover a dropped stash or deleted commit
git reflog
git checkout <hash>

# Undo a specific commit already in history (creates a new revert commit)
git revert <commit-hash>

# Cherry-pick a specific commit from another branch
git cherry-pick <commit-hash>

# Stash only staged changes
git stash --staged

# Stash with a name
git stash push -m "WIP: half-done auth refactor"
git stash list
git stash pop stash@{0}
```

---

## Effective Diffs

```bash
# Word-level diff (better for prose/config)
git diff --word-diff

# Ignore whitespace changes
git diff -w

# Diff a specific function across branches
git diff main..feature -- -L :function_name:file.py

# Show stat summary of what changed
git diff --stat HEAD~5

# Find files changed in last 7 days
git log --since="7 days ago" --name-only --format="" | sort -u
```

---

## GitHub CLI (gh) Workflows

```bash
# Create PR from current branch
gh pr create --fill  # uses commit message as title/body
gh pr create --title "feat: add X" --body "$(cat pr_body.md)"

# View and check PRs
gh pr list
gh pr view <number>
gh pr checks <number>

# Checkout a PR locally
gh pr checkout <number>

# Comment on a PR
gh pr comment <number> --body "LGTM after addressing the nit"

# Merge a PR
gh pr merge <number> --squash --delete-branch

# Create and push a release
gh release create v1.2.0 --title "v1.2.0" --notes "$(cat CHANGELOG.md)"

# Clone any repo
gh repo clone <your-username>/<your-repo>

# Fork and clone
gh repo fork upstream/repo --clone
```

---

## .gitignore Patterns by Stack

```gitignore
# Python
__pycache__/
*.pyc
*.pyo
.venv/
dist/
*.egg-info/
.env
.env.*

# Rust
target/
Cargo.lock  # only ignore for libraries, not binaries

# Node/JS
node_modules/
dist/
.next/
.env
.env.local

# Solidity/Foundry
out/
cache/
broadcast/
.env

# General
.DS_Store
*.log
*.swp
.idea/
.vscode/
```
