# TokenSwap Smart Contract

## Overview

The TokenSwap smart contract is a Solidity-based contract designed to facilitate the exchange of two ERC-20 tokens at a predetermined exchange rate. This contract allows users to swap tokens bidirectionally, converting Token1 to Token2 and vice versa.

## License

This smart contract is licensed under the MIT License. Refer to the SPDX-License-Identifier at the beginning of the file for detailed information.

## Dependencies

This contract relies on the OpenZeppelin library for ERC-20 token functionality. Before deploying the contract, make sure to install the necessary dependencies:

- `IERC20`: ERC-20 token interface.
- `SafeERC20`: Library for secure ERC-20 token transfers.
- `Ownable`: Contract providing basic authorization control functions.

## Contract Parameters

- `token1` and `token2`: Instances of the ERC-20 tokens involved in the swap.
- `exchangeRate`: Constant exchange rate between Token1 and Token2.
- `owner`: The owner of the contract, possessing the authority to update the exchange rate.

## Events

The contract emits the `TokenSwap` event when a token swap occurs. This event captures the sender's address, swap direction, amount in, and amount out.

## Constructor

The constructor initializes the contract with the provided instances of Token1 and Token2, along with the initial exchange rate.

```solidity
constructor(IERC20 _token1, IERC20 _token2, uint256 _exchangeRate)
```

## Owner Functionality

The contract inherits from `Ownable`, granting exclusive rights to the contract owner to update the exchange rate using the `updateExchangeRate` function.

```solidity
function updateExchangeRate(uint256 newRate) external onlyOwner
```

## Token Swapping

The primary functionality of the contract is to facilitate token swaps through the `swapTokens` function. Users can specify the amount to swap and the direction (Token1 to Token2 or Token2 to Token1).

```solidity
function swapTokens(uint256 amountIn, SwapDirection direction) external
```

## Internal Function

The `_performTokenSwap` function is an internal helper function responsible for transferring tokens between the user and the contract during a swap.

```solidity
function _performTokenSwap(IERC20 fromToken, IERC20 toToken, address recipient, uint256 amountIn, uint256 amountOut) internal
```

## Usage

Deploy the contract with the desired ERC-20 tokens and exchange rate. Users can then interact with the contract to swap tokens based on the specified exchange rate.

## Example

```solidity
// Deploy the contract with TokenA, TokenB, and an initial exchange rate of 1:100
TokenSwap tokenSwap = new TokenSwap(TokenA, TokenB, 100);

// Swap 10 TokenA for TokenB
tokenSwap.swapTokens(10, TokenSwap.SwapDirection.Token1ToToken2);
```

**Note**: Ensure that the contract is deployed and used on a compatible Ethereum network supporting ERC-20 tokens and the specified dependencies.