# Systematic Debugging Skill

## THE SPIRAL RULE — Read This First

The most common failure pattern: code fails → rewrite large chunk → it fails differently → rewrite again → nothing works and you've lost the original.

**Break the spiral:**
- When code fails: READ THE ERROR, don't rewrite
- When fix fails: READ THE NEW ERROR, change 1 line, not the whole function
- When confused: write a 10-line reproducer, debug that
- When tempted to "clean it up": don't. Fix the bug. Cleaning is a separate task.

## The Debugging Protocol

Never guess. Never patch symptoms. Always find the root cause.

### Step 1 — Read the Error Completely
- Read the full stack trace, not just the first line
- Note the exact error type, message, and location
- Note what triggered it (what action, what input)

### Step 2 — Form a Hypothesis
One sentence: "I think the bug is X because Y."

Good: "I think the null dereference is in `parse_config` because the file path isn't validated before use."
Bad: "Something is broken in the config code."

### Step 3 — Find the Minimal Reproducer
- Strip everything that isn't needed to trigger the bug
- If you can't reproduce it, you can't fix it reliably
- Binary search the input to find the minimal failing case

### Step 4 — Verify the Hypothesis
Test one thing at a time. Add a targeted print/log, not a dozen.

```python
# Not this — too much noise
print("DEBUG:", a, b, c, d, e, f)

# This — targeted, labeled
print(f"[hyp check] config path at entry: {config_path!r}")
```

If the hypothesis was wrong, update it and try again. Don't add more patches.

### Step 5 — Fix the Root Cause
Fix the actual problem, not the observable symptom.

- Symptom: "NullPointerException on line 42"
- Symptom fix: `if x is not None:` guard at line 42
- Root cause: "x is None because the caller doesn't validate before passing"
- Root fix: validate at the system boundary where x enters the system

### Step 6 — Verify the Fix
- The original reproducer no longer triggers the bug
- Existing tests still pass
- Edge cases around the fix are handled

---

## Debugging by Error Type

### Segfault / Memory Error (C, Rust unsafe)
1. Run under `valgrind` or `AddressSanitizer`: `RUSTFLAGS="-Z sanitizer=address" cargo test`
2. Check: buffer overflows, use-after-free, double-free, out-of-bounds indexing
3. In Rust: look for `unsafe` blocks, raw pointer arithmetic, FFI calls

### Panic / Exception
1. Read the full backtrace
2. Find the FIRST frame in your code (not stdlib/framework)
3. That's where your bug lives — not necessarily where the panic fires

### Wrong Output (Logic Bug)
1. Binary search with assertions: add `assert_eq!(actual, expected)` midway through the logic
2. Narrow to the smallest function that produces wrong output
3. Trace through that function manually with the failing input

### Race Condition / Deadlock
1. Add thread IDs to log output
2. Check: lock acquisition order (always lock in the same order)
3. Check: holding a lock across an await/yield point
4. Use `tokio-console` for async Rust debugging

### Performance Regression
1. Benchmark before and after: `criterion` (Rust), `timeit` (Python), `hyperfine` (CLI)
2. Profile: `cargo flamegraph`, `py-spy`, `perf record`
3. Look for: N+1 queries, quadratic loops, unnecessary clones/copies, cache misses

### Network / API Failure
1. Capture the raw request and response (curl equivalent, Wireshark, mitmproxy)
2. Check: status code, response body, headers
3. Test with curl directly to isolate: is it the server or your client code?

---

## Git Archaeology — Finding When a Bug Was Introduced

```bash
# Binary search commits for when a bug appeared
git bisect start
git bisect bad HEAD
git bisect good v1.0.0
# git will checkout midpoint commits — test and mark good/bad
git bisect good  # or: git bisect bad
# ... repeat until git identifies the commit
git bisect reset

# Find when a specific line was added
git log -p --follow -S "the broken code" -- path/to/file

# Who last touched these lines
git blame -L 42,52 path/to/file

# What changed in the last N commits for a file
git log -n 10 --oneline -- path/to/file
git diff HEAD~5 HEAD -- path/to/file
```

---

## Debugging Checklists by Language

### Python
- [ ] Check virtual environment is active and correct
- [ ] Check Python version (`python --version`)
- [ ] Try `python -m module` instead of `./module.py` for import issues
- [ ] `import traceback; traceback.print_exc()` for silent exceptions
- [ ] Check for circular imports

### JavaScript / Node
- [ ] `console.error(err.stack)` not just `console.error(err)`
- [ ] Check for unhandled promise rejections: `process.on('unhandledRejection', ...)`
- [ ] `node --inspect` for breakpoint debugging
- [ ] Check `node_modules` is installed: `npm ci`

### Rust
- [ ] `RUST_BACKTRACE=1 cargo run` for full backtraces
- [ ] `RUST_LOG=debug cargo run` if the crate uses `env_logger`
- [ ] Add `dbg!(&value)` for quick inline inspection (removes itself on cleanup)

### Solidity / Foundry
- [ ] `forge test -vvvv` for full trace output
- [ ] Add `console.log(value)` via Hardhat `console.sol` in tests
- [ ] `vm.expectRevert(error)` to test that errors fire correctly
