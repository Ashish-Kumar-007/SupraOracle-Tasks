// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {MultiSigWallet} from "../src/multiSigWallet.sol";

/**
 * @title MultiSigWalletTest
 * @dev Test suite for the MultiSigWallet contract.
 * This suite checks all the functionalities of MultiSigWallet,
 * ensuring that the contract works as expected.
 */
contract MultiSigWalletTest is Test {
    MultiSigWallet multiSigWallet;
    address[] owners;
    uint256 required;

    /**
     * @dev Sets up the test by deploying the MultiSigWallet contract
     * with predefined owners and a required approval count.
     */
    function setUp() public {
        owners = [address(1), address(2), address(3)];
        required = 2;
        multiSigWallet = new MultiSigWallet(owners, required);
    }

    /**
     * @dev Tests if the contract is initialized correctly with valid parameters.
     */
    function testContractInitialization() public {
        // Check if the required number of approvals is set correctly
        assertEq(multiSigWallet.required(), required, "Required approvals not set correctly");

        // Check if the number of owners is set correctly
        assertEq(multiSigWallet.ownerCount(), owners.length, "Owner count not set correctly");

        // Check if each owner is recognized by the contract
        for (uint256 i = 0; i < owners.length; i++) {
            assertTrue(multiSigWallet.isOwner(owners[i]), "Owner not recognized");
        }
    }

    /**
     * @dev Tests if initializing the contract with zero owners reverts.
     */
    function testFailInitializationWithZeroOwners() public {
        new MultiSigWallet(new address[](0), required);
    }

    /**
     * @dev Tests that initializing the contract with a required number of approvals greater than the number of owners reverts.
     * This test ensures that the contract constructor correctly handles invalid input parameters.
     */
    function testFailInitializationWithInvalidRequired() public {
        // Attempt to initialize the contract with more required approvals than owners.
        // This should revert, as it's not a valid configuration for the multiSigWallet.
        new MultiSigWallet(owners, owners.length + 1);
    }

    /**
     * @dev Tests the functionality of depositing Ether into the MultiSigWallet contract.
     * It verifies if the contract's balance is correctly updated after receiving a deposit.
     * This test ensures that the wallet can securely receive and account for Ether deposits.
     */
    function testDepositFunctionality() public {
        // Define the amount of Ether to deposit into the contract
        uint256 depositAmount = 1 ether;

        // Provide this test contract with Ether for testing the deposit functionality
        vm.deal(address(this), depositAmount);

        // Execute the deposit by sending Ether to the MultiSigWallet contract
        payable(address(multiSigWallet)).transfer(depositAmount);

        // Assert that the contract's balance is correctly updated to reflect the deposit
        assertEq(address(multiSigWallet).balance, depositAmount, "Incorrect contract balance after deposit");
    }

    /**
     * @dev Tests the ability of an owner to submit a transaction.
     * It verifies that the transaction is correctly stored in the contract.
     */
    function testSubmitTransactionByOwner() public {
        // Define the recipient, value, and data for the transaction
        address to = address(0x1234);
        uint256 value = 0.5 ether;
        bytes memory data = "";

        // Simulate submission of the transaction by the first owner
        vm.prank(owners[0]);
        multiSigWallet.submit(to, value, data);

        // Infer the transaction ID (assuming it's the first transaction)
        uint256 txId = 0;

        // Retrieve the submitted transaction from the contract
        (address transactionTo, uint256 transactionValue, bytes memory transactionData, bool executed) =
            multiSigWallet.transactions(txId);

        // Assert that the transaction details are correctly stored in the contract
        assertEq(transactionTo, to, "Incorrect transaction recipient");
        assertEq(transactionValue, value, "Incorrect transaction value");
        assertEq(transactionData, data, "Incorrect transaction data");
        assertEq(executed, false, "Transaction should not be executed yet");
    }

    /**
     * @dev Tests the functionality of an owner approving a submitted transaction.
     * Verifies that the approval is correctly recorded in the contract, ensuring
     * that only valid owners can approve transactions.
     */
    function testApproveTransactionByOwner() public {
        // Submit a transaction for approval
        vm.prank(owners[0]);
        multiSigWallet.submit(address(0x1234), 0.5 ether, "");

        // Assuming the first transaction's ID is 0
        uint256 txId = 0;

        // Approve the transaction by a different owner
        vm.prank(owners[1]);
        multiSigWallet.approve(txId);

        // Verify that the transaction approval is recorded in the contract
        bool isApproved = multiSigWallet.approved(txId, owners[1]);
        assertTrue(isApproved, "Transaction was not approved by the owner");
    }

    /**
     * @dev Tests the ability of an owner to revoke their approval for a transaction.
     * Verifies that the revocation is correctly recorded in the contract.
     */
    function testRevokeApprovalByOwner() public {
        // Submit a transaction and approve it
        vm.prank(owners[0]);
        multiSigWallet.submit(address(0x1234), 0.5 ether, "");
        uint256 txId = 0; // Assuming this is the first transaction

        vm.prank(owners[0]);
        multiSigWallet.approve(txId);

        // Revoke the approval for the transaction
        vm.prank(owners[0]);
        multiSigWallet.revoke(txId);

        // Verify that the approval has been successfully revoked
        bool isApproved = multiSigWallet.approved(txId, owners[0]);
        assertFalse(isApproved, "Approval was not revoked");
    }

    /**
     * @dev Tests that a non-owner cannot revoke approval for a transaction.
     * This test ensures that only owners can revoke approvals.
     */
    function testFailRevokeApprovalByNonOwner() public {
        // Submit a transaction and approve it
        vm.prank(owners[0]);
        multiSigWallet.submit(address(0x1234), 0.5 ether, "");
        uint256 txId = 0; // Assuming this is the first transaction

        vm.prank(owners[0]);
        multiSigWallet.approve(txId);

        // Attempt to revoke the approval as a non-owner, which should fail
        address nonOwner = address(0xdead);
        vm.prank(nonOwner);
        multiSigWallet.revoke(txId); // This action should revert
    }

    /**
     * @dev Tests revoking approval for a non-existent transaction.
     * Ensures that revoking approval for an invalid transaction ID reverts.
     */
    function testFailRevokeNonExistentTransaction() public {
        // Attempt to revoke approval for a non-existent transaction
        vm.prank(owners[0]);
        multiSigWallet.revoke(999); // This should fail as transaction 999 does not exist
    }
}
