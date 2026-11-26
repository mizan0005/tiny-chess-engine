# Mizan Agent Identity Hub

An open-source profile registry for the Tiny Chess project on BNB Chain. Registration is gated by ownership of the official Binance/SPACE ID Agent ID NFT.

## Repository contents

- `contracts/AgentIdentityRegistry.sol` — Solidity registry with an on-chain Agent ID-holder check.
- `site/index.html` — lightweight wallet-connect product interface.
- `main.py` — separate experimental Tiny Chess Engine module retained in this repository.

## How Agent ID is used

Before a wallet can register a profile, the contract calls `balanceOf(msg.sender)` on the official Agent ID ERC-721 contract:

`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`

A wallet must hold at least one Agent ID NFT. This is an on-chain access-control check. The profile label entered by the user is not independently resolved to the NFT's actual name by this contract; do not describe the label as cryptographically verified.

## Contract functions

- `hasAgentId(address)` — checks whether a wallet holds an official Agent ID NFT.
- `register(agentId, metadataURI)` — creates a profile for an Agent ID holder.
- `updateMetadata(agentId, metadataURI)` — updates the profile metadata.
- `deactivate(agentId)` — deactivates the profile.
- `getIdentity(agentId)` — reads the public profile record.

The registry profile is separate from the Binance Agent ID NFT. It does not mint, transfer, or modify the official NFT.

## Deployment status

The Solidity source is committed but **not deployed**. There is no contract address and no BscScan verification link yet. Hackathon participation requires deployment on BNB Smart Chain and source-code verification on BscScan. Deployment requires the owner to review the source and sign the transaction with their own wallet. Never share a seed phrase or private key.

## Product website

The static interface is in `site/index.html`. GitHub Actions is configured to publish the `site/` directory to GitHub Pages. The repository owner may need to enable GitHub Pages / Actions in repository Settings before the first deployment.

## Intended initial profile label

`mizan0005.ai` (user-provided label; not independently verified against the NFT name by this registry).
