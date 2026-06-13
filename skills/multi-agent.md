# Multi-Agent Orchestration Skill

## When to Use Subagents

Spawn an `agy` subshell when a task is:
- **Independent** — doesn't need current conversation context
- **Parallel** — can run alongside other tasks simultaneously
- **Isolated** — self-contained input → output with no follow-up iteration needed
- **Token-heavy** — large analysis that would pollute the main context

Don't spawn when you need to refine output iteratively or when the task requires conversation history.

---

## Subshell Patterns

### Single Task
```bash
agy --print "TASK_DESCRIPTION" --dangerously-skip-permissions
```

### With Model Selection (Cost Control)
```bash
# Complex reasoning → expensive model
agy --print "audit this Solidity contract for reentrancy: $(cat contract.sol)" \
    --model "Gemini 1.5 Pro (Thinking)" --dangerously-skip-permissions

# Simple tasks → cheap model  
agy --print "summarize this file in 3 bullets: $(cat README.md)" \
    --model "Gemini 3.5 Flash (Low)" --dangerously-skip-permissions
```

### Parallel Execution
```bash
# Launch multiple agents simultaneously
agy --print "analyze ~/project/contracts/TokenA.sol for security issues" \
    --dangerously-skip-permissions > /tmp/agent_a.txt &

agy --print "analyze ~/project/contracts/TokenB.sol for security issues" \
    --dangerously-skip-permissions > /tmp/agent_b.txt &

agy --print "analyze ~/project/contracts/TokenC.sol for security issues" \
    --dangerously-skip-permissions > /tmp/agent_c.txt &

wait  # wait for all background jobs

echo "=== TokenA ===" && cat /tmp/agent_a.txt
echo "=== TokenB ===" && cat /tmp/agent_b.txt
echo "=== TokenC ===" && cat /tmp/agent_c.txt
```

### File Generation Pipeline
```bash
# Stage 1: Generate
agy --print "write unit tests for $(cat src/utils.py)" \
    --dangerously-skip-permissions > tests/test_utils.py

# Stage 2: Verify the generated output
agy --print "review these tests for correctness and completeness: $(cat tests/test_utils.py)" \
    --dangerously-skip-permissions
```

### Directory-Scoped Agent
```bash
# Scope agent to a specific project
agy --print "TASK" --add-dir ~/my-project --dangerously-skip-permissions
```

---

## Orchestration Patterns

### Map-Reduce Over Files
```bash
#!/bin/bash
# Map: analyze each contract independently
results=""
for contract in contracts/*.sol; do
    result=$(agy --print "audit $contract for OWASP smart contract top 10" \
             --dangerously-skip-permissions)
    results+="=== $contract ===\n$result\n\n"
done

# Reduce: synthesize findings
echo -e "$results" | agy --print "synthesize these audit findings into a ranked risk report" \
    --dangerously-skip-permissions
```

### Sequential Refinement
```bash
# Draft
draft=$(agy --print "write a README for my-tool" --dangerously-skip-permissions)

# Refine
final=$(echo "$draft" | agy --print \
    "improve this README: add badges, better examples, and a quickstart. Input: $draft" \
    --dangerously-skip-permissions)

echo "$final" > README.md
```

### Validation Agent
```bash
# Implement something
agy --print "implement the JWT auth middleware in src/auth.py" --dangerously-skip-permissions

# Independent validation (separate context = no bias)
agy --print "review src/auth.py for security issues and correctness. Be critical." \
    --dangerously-skip-permissions
```

---

## Token Budget Management

### Estimate Token Cost
- Simple question: ~500-2K tokens
- File analysis (small file): ~2-5K tokens
- Code generation (function): ~3-8K tokens
- Full audit (contract): ~10-20K tokens
- Large codebase exploration: ~50K+ tokens (use subshells to parallelize)

### Strategy: Main Session = Orchestration Only
Reserve the main agy session for:
- High-level decisions
- Synthesis of subagent results
- Tasks requiring conversation history

Push everything else to subshells.

### Context Reset with Continuity
```bash
# 1. Save current session state
agy --print "summarize what we've done this session and what's next" \
    --dangerously-skip-permissions > /tmp/session_checkpoint.md

# 2. Start fresh session with context injected
agy --prompt-interactive \
    "Continue from checkpoint: $(cat /tmp/session_checkpoint.md). Next task: ..."
```

---

## Useful Compositions

### Codebase Explorer
```bash
agy --print "explore the codebase at ~/my-project and explain its architecture in 500 words" \
    --add-dir ~/my-project --dangerously-skip-permissions
```

### Batch Commit Messages
```bash
# For each changed file, generate a targeted commit message
git diff --name-only | while read file; do
    diff=$(git diff -- "$file")
    msg=$(echo "$diff" | agy --print "write a one-line git commit message for this diff" \
          --model "Gemini 3.5 Flash (Low)" --dangerously-skip-permissions)
    echo "$file: $msg"
done
```

### PR Description Generator
```bash
diff=$(git diff main...HEAD)
agy --print "write a GitHub PR description with ## Summary and ## Test Plan sections for this diff: $diff" \
    --dangerously-skip-permissions
```
