# DROPMOLT DEADMAN

### Onchain Dead Man's Switch — Built on Monad

**Created by:** [dropxtor](https://github.com/dropxtor) ([@0xDropxtor](https://x.com/0xDropxtor))
**Hackathon:** BuildAnything Spark — powered by Monad
**Date:** July 18, 2026

---

## The Problem

If you die, disappear, or lose your keys, your crypto is lost forever. Traditional banks have inheritance processes. Crypto doesn't — until now.

## The Solution

**DROPMOLT DEADMAN** is an onchain dead man's switch. You deposit crypto, set a beneficiary, and check in regularly. If you stop checking in, your beneficiary can claim all funds automatically — no lawyer, no custodian, no server.

## How it works

1. **Deploy** a switch with your beneficiary address and a timeout (e.g. 30 days)
2. **Check in** before the deadline to reset the timer
3. If you miss the deadline, your beneficiary **claims** all funds

## Stack

- **Smart Contract:** Solidity 0.8.24, Foundry
- **Blockchain:** Monad Testnet (chain ID 10143)
- **Frontend:** Vanilla JS + ethers.js v5, glass morphism UI
- **Design:** Dark luxury theme — gold gradients, glass cards, animated countdown ring

## Smart Contract

`src/DeadManSwitch.sol` — 200 lines, 9 tests, fully verified.

### Functions

| Function | Who | Description |
|----------|-----|-------------|
| `checkIn()` | Owner | Reset the timer |
| `fund()` | Owner | Deposit ETH/MON |
| `withdraw(amount)` | Owner | Partial withdraw |
| `updateBeneficiary(addr)` | Owner | Change beneficiary |
| `updateTimeout(seconds)` | Owner | Change timeout |
| `cancel()` | Owner | Cancel + refund all |
| `claim()` | Beneficiary | Claim all if owner missed deadline |
| `status()` | Anyone | View all state |
| `isDead()` | Anyone | Check if claimable |

## Build & test

```bash
forge install
forge build
forge test -vv
```

## Deploy

```bash
forge create src/DeadManSwitch.sol:DeadManSwitch \
  --rpc-url https://testnet-rpc.monad.xyz \
  --private-key $YOUR_KEY \
  --constructor-args $BENEFICIARY 2592000 \
  --value 0.1ether
```

## Credits

- **Creator:** [dropxtor](https://github.com/dropxtor) — [@0xDropxtor](https://x.com/0xDropxtor)
- **Blockchain:** [Monad](https://monad.xyz)
- **Hackathon:** [BuildAnything Spark](https://buildanything.so/hackathons/spark)
