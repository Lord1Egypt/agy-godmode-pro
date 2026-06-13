# Solidity / Web3 Security Skill

## Audit Checklist — Run This on Every Contract

### 1. Reentrancy
- [ ] All payable external functions use `ReentrancyGuard` (`nonReentrant` modifier)
- [ ] CEI pattern enforced: Checks → Effects → Interactions (state updated BEFORE external calls)
- [ ] No `.call{value:}()` without reentrancy guard
- [ ] Cross-function reentrancy: multiple functions sharing state both guarded

### 2. Access Control
- [ ] `onlyOwner` / `onlyRole` on all privileged functions
- [ ] `msg.sender` used for authentication, never `tx.origin`
- [ ] Ownership transfer is two-step (OpenZeppelin `Ownable2Step`) not single-step
- [ ] Constructor initializes all access control correctly
- [ ] No uninitialized proxies (can be front-run initialized by attacker)

### 3. Integer Arithmetic
- [ ] Using Solidity ≥0.8 (built-in overflow/underflow checks) OR explicit `SafeMath`
- [ ] No division before multiplication (precision loss)
- [ ] Casting downsizes (e.g., `uint256` → `uint128`) checked
- [ ] No unchecked blocks around arithmetic unless gas-optimized and explicitly safe

### 4. Front-Running / MEV
- [ ] Commit-reveal scheme for sensitive operations (auctions, randomness)
- [ ] `block.timestamp` not used for randomness or precise timing
- [ ] No slippage tolerance = 0 in DEX integrations
- [ ] Price oracle not manipulable in single transaction (use TWAP over spot price)

### 5. Logic & State
- [ ] All state changes emit events
- [ ] No leftover debugging code or commented-out logic
- [ ] Fallback/receive functions are intentional and documented
- [ ] `selfdestruct` usage reviewed (deprecated in EIP-6049, breaks assumptions)
- [ ] Flash loan attack surface checked (price manipulation, governance attacks)

### 6. Gas & DoS
- [ ] No unbounded loops over user-controlled arrays
- [ ] No `transfer()` or `send()` (2300 gas limit breaks with complex receivers — use `.call{value:}()`)
- [ ] Pull-over-push for ETH payments (user calls withdraw, not contract pushes)
- [ ] Storage reads cached in memory variables inside loops

### 7. External Calls
- [ ] Return values of external calls checked
- [ ] No assumptions about external contract behavior
- [ ] ERC20 `transfer`/`transferFrom` return value checked (some tokens don't revert on failure — use SafeERC20)
- [ ] Delegatecall storage collision checked (especially in proxies)

### 8. Proxy Patterns
- [ ] Storage layout consistent between proxy and implementation
- [ ] `initialize()` function protected against re-initialization (`initializer` modifier)
- [ ] Implementation contract cannot be directly called (initialized with dummy data)
- [ ] Upgrade function properly access-controlled

---

## Common Vulnerability Patterns

### Reentrancy
```solidity
// VULNERABLE
function withdraw(uint amount) external {
    require(balances[msg.sender] >= amount);
    (bool ok,) = msg.sender.call{value: amount}(""); // external call FIRST
    balances[msg.sender] -= amount; // state updated AFTER — too late
}

// SAFE (CEI)
function withdraw(uint amount) external nonReentrant {
    require(balances[msg.sender] >= amount);
    balances[msg.sender] -= amount; // state FIRST
    (bool ok,) = msg.sender.call{value: amount}("");
    require(ok);
}
```

### Oracle Manipulation
```solidity
// VULNERABLE — spot price manipulable in one tx
uint price = IUniswap(pair).getReserves(); // can be manipulated

// SAFER — TWAP over multiple blocks
uint price = ITWAPOracle(oracle).consult(token, period);
```

### SafeERC20
```solidity
// VULNERABLE — USDT doesn't return bool
token.transfer(recipient, amount);

// SAFE
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
using SafeERC20 for IERC20;
token.safeTransfer(recipient, amount);
```

---

## Foundry Audit Workflow (ethsmith)

```bash
# Static analysis
forge build
slither . --exclude-informational

# Fuzz testing
forge test --fuzz-runs 10000

# Gas snapshots
forge snapshot

# Fork mainnet for integration tests
forge test --fork-url $MAINNET_RPC --fork-block-number <block>

# Coverage
forge coverage --report lcov
```

### Writing Invariant Tests
```solidity
contract InvariantTest {
    // Invariant: total supply never exceeds max
    function invariant_supplyBound() external {
        assertLe(token.totalSupply(), token.MAX_SUPPLY());
    }
}
```

---

## Gas Optimization Patterns

```solidity
// Pack structs — order fields from largest to smallest
struct Packed {
    uint256 amount;    // slot 0
    address owner;     // slot 1 (20 bytes)
    uint96 timestamp;  // slot 1 (12 bytes) — shares slot with owner
}

// Cache storage reads
uint256 len = array.length; // read once
for (uint i; i < len; ++i) { } // use cached value

// Use ++i not i++ (saves ~5 gas per iteration)
// Use custom errors not strings
error InsufficientBalance(address user, uint256 needed);

// Mark functions view/pure
function getBalance(address user) external view returns (uint256) { }
```

---

## Ethsmith Workflow

```bash
# Audit a contract
ethsmith audit contracts/MyContract.sol

# Generate report
ethsmith report --format markdown

# Check specific vulnerability class
ethsmith check reentrancy contracts/

# Run full suite
ethsmith full-audit --contracts contracts/ --output reports/
```
