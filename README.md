# Permit2 Nonce Finder

This contract is designed to help you work with [Permit2](https://docs.uniswap.org/contracts/permit2/overview) signatures.

When using `Permit2`, you should pick nonces sequentially to [minimize gas cost](https://docs.uniswap.org/contracts/permit2/reference/signature-transfer#nonce-schema).

At [Flood](https://flood.bid) we're building a one-signature trading experience. Finding nonces offchain is annoying and can be slow, so we developed Permit2NonceFinder to discover the next available nonce in a single RPC call.

Happy signing 🫡

## Usage

This contract is supposed to be used off-chain to find the first consumable nonce for a given `owner`.

- `nextNonce(address owner)` finds the first available nonce for `owner`
- `nextNonceAfter(address owner, uint start)` finds the first available nonce for `owner` _after_ `start`. Use this if you're signing multiple nonces at once.

## Deployment Address

`Permit2NonceFinder` is deployed on Mainnet and Arbitrum at `0xf100Df4CA9bF942878888c1F05010F1823E5Dc73`
