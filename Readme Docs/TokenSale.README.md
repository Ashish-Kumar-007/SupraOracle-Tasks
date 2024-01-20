# TokenSale Contract

## Overview

The `TokenSale` contract is a Solidity smart contract designed to facilitate the sale of a token through two phases: a pre-sale and a public sale. It allows users to purchase tokens, sets contribution limits, and handles the distribution of tokens based on the amount of Ether contributed. The contract includes features such as updating caps, contribution limits, distributing tokens, and allowing contributors to claim refunds under specific conditions.

## Contract Structure

### State Variables

- `currentSaleState`: Enum representing the current state of the sale (PreSale, PublicSale, PostSale).
- `totalPresaleEther`: Total amount of Ether contributed during the pre-sale.
- `tokenRatePerEth`: Exchange rate of tokens per Ether.
- `totalPublicSaleEther`: Total amount of Ether contributed during the public sale.
- `presaleCap`: Cap for the pre-sale.
- `publicSaleCap`: Cap for the public sale.
- `minContribution`: Minimum contribution limit.
- `maxContribution`: Maximum contribution limit.
- `owner`: Address of the contract owner.
- `publicSaleStartTime`: Time until the start of the public sale.
- `contributions`: Mapping of contributor addresses to their Ether contributions.
- `tokenContract`: Address of the ERC-20 token contract.

### Events

- `Deposit`: Emitted when the contract receives funds.
- `Submit`: Emitted when a new transaction is submitted for approval.
- `Approve`: Emitted when an owner approves a transaction.
- `Revoke`: Emitted when an owner revokes approval for a transaction.
- `Execute`: Emitted when a transaction is successfully executed.

### Modifiers

- `onlyOwner`: Ensures that the caller is the owner of the contract.

## Constructor

```solidity
constructor(address _tokenAddress, uint256 _publicSaleStartTime)
```

Initializes the contract with the token address and the time until the start of the public sale.

## Usage

1. **Setting Caps:**
   - The owner can update caps for the pre-sale and public sale using the `updateCaps` function.

2. **Setting Contribution Limits:**
   - The owner can update contribution limits using the `updateContributionLimits` function.

3. **Buying Tokens:**
   - Users can purchase tokens during the sale by calling the `buyTokens` function.

4. **Distributing Tokens:**
   - The owner can distribute tokens to a recipient using the `distributeTokens` function.

5. **Setting PostSale State:**
   - The owner can set the contract state to PostSale using the `setPostSaleState` function.

6. **Claiming Refunds:**
   - Contributors can claim refunds under specific conditions using the `claimRefund` function.

## Security Considerations

- Ensure that caps and contribution limits are set appropriately.
- Be cautious when setting the post-sale state to avoid unintended behavior.

## License

This smart contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.