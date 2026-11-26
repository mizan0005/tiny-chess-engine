# Mizan Agent Identity Hub

An open-source, self-service registry concept for binding a human-readable AI Agent ID to an EVM wallet on BNB Smart Chain.

## Repository contents

- `contracts/AgentIdentityRegistry.sol` — Solidity registry source.
- `site/index.html` — lightweight wallet-connect product interface.
- `main.py` — separate experimental Tiny Chess Engine module retained in this repository.

## Contract functions

- Register an unused Agent ID for the connected wallet.
- Update the metadata URI.
- Transfer the identity to another wallet.
- Deactivate an identity.
- Read the public identity record.

## Important deployment status

The Solidity source is prepared but is **not deployed**. There is no contract address yet and no BscScan verification link. Do not submit a fabricated address. Deployment requires the owner to review the source and sign a transaction with their own wallet on BNB Smart Chain; never share a seed phrase or private key.

## Product website

The static product interface is in `site/index.html`. GitHub Actions is configured to publish the `site/` directory to GitHub Pages. The repository owner may need to enable GitHub Pages / Actions in repository Settings before the first deployment.

## Agent ID

Intended initial Agent ID: `mizan0005.ai`. The registry does not claim ownership or verification of an Agent ID outside the on-chain transaction.
