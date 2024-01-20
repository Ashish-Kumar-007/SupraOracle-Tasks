# TokenSwap Contract

## Overview

The `TokenSwap` contract is a Solidity smart contract that facilitates the exchange of two ERC-20 tokens (`tokenA` and `tokenB`) at a predefined exchange rate. Users can swap a specified amount of one token for the other, and the contract ensures that the necessary balances and allowances are in place. The contract is also protected against reentrancy attacks using the `ReentrancyGuard` modifier.

## Contract Structure

### State Variables

- `tokenA`: Instance of the ERC-20 token A.
- `tokenB`: Instance of the ERC-20 token B.
- `exchangeRate`: Constant exchange rate between `tokenA` and `tokenB`.

### Events

- `Swap`: Emitted when a user swaps tokens, indicating the user's address, the amount swapped, the amount received, and the swap direction.

### Enum

- `SwapDirection`: Enumeration representing the swap direction (A to B or B to A).

### Errors

- `InsufficientBalance`: Error thrown when the user has an insufficient balance for the swap.
- `InsufficientAllowance`: Error thrown when the user has an insufficient allowance for the swap.
- `TransferFailed`: Error thrown when a token transfer operation fails.

### Constructor

```solidity
constructor(address _tokenA, address _tokenB, uint256 _exchangeRate)
```

Initializes the contract with the addresses of the two ERC-20 tokens and the exchange rate between them.

### Functions

#### `swapTokens`

```solidity
function swapTokens(uint256 amount, SwapDirection direction) external nonReentrant
```

Allows users to swap a specified amount of one token for the other, based on the defined exchange rate. The function handles the necessary transfers and emits a `Swap` event.

#### `handleTransfer`

```solidity
function handleTransfer(IERC20 token, address from, address to, uint256 amount) internal
```

Internal function to handle token transfers, checking balances and allowances to prevent errors. Throws errors if conditions are not met.

## Security Considerations

- The contract is protected against reentrancy attacks using the `ReentrancyGuard` modifier.
- Ensure that the exchange rate is set accurately to reflect the intended token swap ratio.
- Be cautious with token approvals and allowances to prevent potential vulnerabilities.

## License

This smart contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.