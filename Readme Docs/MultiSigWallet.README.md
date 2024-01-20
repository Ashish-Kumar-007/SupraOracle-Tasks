# MultiSigWallet

## Overview

The `MultiSigWallet` is a Solidity smart contract implementation of a multi-signature wallet. It enables multiple owners to collectively approve and execute transactions, providing an added layer of security for managing funds.

## Features

1. **Multi-Signature Functionality:** Multiple owners are required to collectively approve and execute transactions.
2. **Transaction Submission:** Owners can submit transactions with a recipient address, amount of Ether to send, and transaction data.
3. **Transaction Approval:** Owners can individually approve transactions.
4. **Transaction Execution:** Once a transaction has the required number of approvals, it can be executed, sending Ether and executing the specified data.
5. **Approval Revoke:** Owners can revoke their approval for a transaction before it is executed.

## Contract Structure

### State Variables

- `isOwner`: Mapping of owner addresses to a boolean indicating ownership.
- `required`: The number of required approvals for executing a transaction.
- `ownerCount`: Total number of owners.
- `transactions`: Array of transaction details.
- `approved`: Mapping of transaction ID to a mapping of owner addresses to approval status.
- `approvalCounts`: Mapping of transaction ID to the number of approvals received.

### Events

- `Deposit`: Emitted when the contract receives funds.
- `Submit`: Emitted when a new transaction is submitted for approval.
- `Approve`: Emitted when an owner approves a transaction.
- `Revoke`: Emitted when an owner revokes approval for a transaction.
- `Execute`: Emitted when a transaction is successfully executed.

### Modifiers

- `onlyOwner`: Ensures that the caller is an owner of the wallet.
- `txExists`: Ensures that the transaction ID exists.
- `notApproved`: Ensures that the transaction has not been approved by the caller.
- `notExecuted`: Ensures that the transaction has not been executed.

## Constructor

The constructor initializes the wallet with a specified set of owners and the required number of approvals.

```solidity
constructor(address[] memory _owners, uint256 _required)
```

## Usage

1. **Deposit Funds:**
   - Users can deposit funds to the wallet by sending Ether directly to the contract.

2. **Submit Transaction:**
   - Owners can submit a new transaction for approval using the `submit` function, providing the recipient address, amount of Ether, and transaction data.

3. **Approve Transaction:**
   - Owners can individually approve a pending transaction using the `approve` function.

4. **Execute Transaction:**
   - Once a transaction has received the required number of approvals, any owner can execute the transaction using the `execute` function.

5. **Revoke Approval:**
   - Owners can revoke their approval for a pending transaction using the `revoke` function.

## Deployment

Deploy the `MultiSigWallet` contract by providing an array of owner addresses and the required number of approvals in the constructor.

## Security Considerations

- Ensure that the list of owners is valid and unique during contract deployment.
- Be cautious with the required number of approvals to prevent accidental or unauthorized transactions.

## License

This smart contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.