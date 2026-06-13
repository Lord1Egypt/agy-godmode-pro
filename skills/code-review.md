# Code Review Skill

## Full Review Protocol

Run all sections. Report findings by severity: CRITICAL → HIGH → MEDIUM → LOW → NIT.

---

## Section 1 — Correctness

- [ ] Does the logic actually solve the stated problem?
- [ ] Are all edge cases handled? (empty input, null, zero, max value, negative)
- [ ] Off-by-one errors in loops, slices, pagination?
- [ ] Integer overflow/underflow possible?
- [ ] Floating point precision issues? (financial code must use integers/Decimal)
- [ ] Race conditions? (shared mutable state accessed from multiple threads/async paths)
- [ ] Error return values ignored?
- [ ] All code paths return a value (or explicitly panic/raise)?

## Section 2 — Security

- [ ] **Injection**: SQL, shell command, LDAP, XPath — any user input concatenated into a query?
- [ ] **XSS**: user content rendered as HTML without escaping?
- [ ] **Auth**: is the caller authorized before the operation executes?
- [ ] **Secrets**: are API keys, tokens, passwords logged, hardcoded, or in source control?
- [ ] **Path traversal**: user-controlled file paths validated and sandboxed?
- [ ] **SSRF**: user-controlled URLs fetched server-side?
- [ ] **Mass assignment**: are only expected fields accepted from user input?
- [ ] **Timing attacks**: secrets compared with `==` instead of constant-time comparison?

## Section 3 — Robustness

- [ ] All external calls have timeouts?
- [ ] Network errors, HTTP 5xx, and timeouts handled gracefully?
- [ ] Database transactions rolled back on error?
- [ ] Resources (files, connections, sockets) always closed — even on error?
- [ ] Retry logic has exponential backoff + jitter (not tight loops)?
- [ ] Idempotent operations where needed (retry-safe)?

## Section 4 — Maintainability

- [ ] Function names clearly describe what they do?
- [ ] Functions do one thing? (>30 lines of logic = consider splitting)
- [ ] No magic numbers — named constants instead?
- [ ] No duplicated logic — DRY where it adds clarity?
- [ ] Are new abstractions actually used more than once?
- [ ] Are tests updated/added for the change?

## Section 5 — Performance

- [ ] N+1 query problems? (loop with a DB/API call inside)
- [ ] Unnecessary work in hot paths?
- [ ] Large allocations or copies inside loops?
- [ ] Missing indexes on queried database columns?
- [ ] Caching appropriate for read-heavy data?

## Section 6 — Compatibility

- [ ] Breaking changes to public API, CLI flags, or config format?
- [ ] Database migrations backward-compatible (no column drops in forward migration)?
- [ ] New dependencies pinned to minimum version, not exact version?

---

## Severity Definitions

| Level | Meaning | Action |
|-------|---------|--------|
| **CRITICAL** | Security vulnerability or data loss bug | Block merge, fix now |
| **HIGH** | Correctness bug affecting core functionality | Block merge |
| **MEDIUM** | Robustness or performance issue | Fix before merge |
| **LOW** | Code quality, maintainability | Fix or note for follow-up |
| **NIT** | Style, naming preference | Optional, author's call |

---

## Review Comment Format

```
[CRITICAL] src/auth.py:42 — SQL query built with string concatenation.
User input `username` is directly interpolated: `f"SELECT * FROM users WHERE name='{username}'"`.
Fix: use parameterized query: `cursor.execute("SELECT * FROM users WHERE name=?", (username,))`

[HIGH] src/payment.py:88 — Float used for currency amount.
`price: float = 9.99` will have precision errors in calculation.
Fix: use `Decimal('9.99')` or store as integer cents.

[NIT] src/utils.py:15 — Variable name `d` is not descriptive.
Consider `data` or `response_dict`.
```

---

## Quick Review (for small PRs)

For changes under ~50 lines, run this condensed check:

1. Read the diff top to bottom
2. Does it do what the PR description says?
3. Any security issues? (injection, auth, secrets)
4. Any obvious logic bugs?
5. Are tests present and relevant?
6. Does it break any existing behavior?
