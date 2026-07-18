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

## Deployed Contract

**Address:** `0x676A091c15C2e6ad323070a8e1C1a28718fE2De5`
**Chain:** Monad Testnet (chain ID 10143)
**RPC:** `https://testnet-rpc.monad.xyz`
**Explorer:** `https://testnet.monadexplorer.com/address/0x676A091c15C2e6ad323070a8e1C1a28718fE2De5`

### Onchain state (verified July 18 2026)

| | |
|---|---|
| Owner | `0x2E945b445Db72f00D3F0433b8563C7a0AaF8aa0E` |
| Beneficiary | `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` |
| Balance | 0.05 MON |
| Timeout | 30 days (2,592,000 s) |
| Last check-in | Block 45,924,535 |
| Status | ✅ ACTIVE |

## Build & test

```bash
forge install
forge build
forge test -vv
```

## Live demo

- **Frontend:** https://dropmoltbot.github.io/dropmolt-deadman/
- **Contract:** `0x676A091c15C2e6ad323070a8e1C1a28718fE2De5`
- **Chain:** Monad Testnet (10143)

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
