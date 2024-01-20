// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MockERC20Token} from "../src/mocks/MockERC20Token.sol";
import {TokenSale} from "../src/TokenSale.sol";

/**
 * @title TokenSaleTest
 * @dev Comprehensive testing suite for the TokenSale contract
 */
contract TokenSaleTest is Test {
    TokenSale public tokenSale;
    MockERC20Token public mockERC20Token;

    // Define test addresses
    address public user1 = address(2);
    address public user2 = address(23);
    address public owner = address(763);
    address public nonOwner = address(654);

    // Constants
    uint256 constant tokenRatePerEth = 1;

    /**
     * @dev Setup function to initialize the contracts and mint tokens.
     */
    function setUp() public {
        console.log("Setting up the test environment...");

        // Deploying contracts and setting the owner
        vm.startPrank(owner);
        mockERC20Token = new MockERC20Token("MockToken", "MTK");
        tokenSale = new TokenSale(address(mockERC20Token), 3600);
        mockERC20Token.mint(address(tokenSale), 100 ether);
        vm.stopPrank();

        console.log("Setup complete.");
    }

    /**
     * @dev Test for correct initialization of the contracts.
     */
    function testContractInitialization() public {
        console.log("Testing contract initialization...");

        assertEq(mockERC20Token.name(), "MockToken", "Incorrect token name");
        assertEq(mockERC20Token.symbol(), "MTK", "Incorrect token symbol");
        assertEq(address(tokenSale.tokenContract()), address(mockERC20Token), "TokenSale contract does not have correct token address");

        console.log("Contract initialization test passed.");
    }

     /**
     * @dev Test contributions within limits during PreSale.
     */
    function testContributionWithinLimitsPreSale() public {
        console.log("Testing contributions within limits during PreSale...");

        // Setting up caps and limits for PreSale
        vm.startPrank(owner);
        tokenSale.updateCaps(500 ether, 500 ether);
        tokenSale.updateContributionLimits(1 ether, 10 ether);
        vm.stopPrank();

        // Simulating a valid contribution
        uint256 contributionAmount = 5 ether;
        vm.deal(user1, contributionAmount);
        vm.prank(user1);
        tokenSale.buyTokens{value: contributionAmount}();

        // Assertions to verify the contribution
        assertEq(address(tokenSale).balance, contributionAmount, "Ether balance mismatch after contribution");
        assertEq(tokenSale.contributions(user1), contributionAmount, "Contribution tracking incorrect");
        uint256 expectedTokenAmount = contributionAmount * tokenRatePerEth;
        assertEq(mockERC20Token.balanceOf(user1), expectedTokenAmount, "Token allocation incorrect");

        console.log("Contribution within limits during PreSale test passed.");
    }
  
  /**
 * @notice Test the contribution process within limits during Public Sale.
 */
function testContributionWithinLimitsPublicSale() public {
    // Ensure the initial state is PreSale
    assertEq(uint256(tokenSale.getCurrentSaleState()), uint256(TokenSale.SaleState.PreSale), "Initial state should be PreSale");

    // Update the caps and contribution limits for the Public Sale
    vm.startPrank(owner);
    tokenSale.updateCaps(500 ether, 500 ether);
    tokenSale.updateContributionLimits(8 ether, 50 ether);
    vm.stopPrank();

    // Transition to the Public Sale state
    vm.warp(block.timestamp + 3600);
    assertEq(uint256(tokenSale.getCurrentSaleState()), uint256(TokenSale.SaleState.PublicSale), "State should be PublicSale after time warp");

    // Simulate a valid contribution during the Public Sale
    uint256 contributionAmount = 10 ether;
    vm.deal(user2, contributionAmount);
    vm.prank(user2);
    tokenSale.buyTokens{value: contributionAmount}();

    // Assertions to ensure correct processing of the contribution
    assertEq(address(tokenSale).balance, contributionAmount, "Ether balance should match the contribution amount");
    assertEq(tokenSale.contributions(user2), contributionAmount, "Contribution tracking should match the amount");
    uint256 expectedTokenAmount = contributionAmount * tokenRatePerEth;
    assertEq(mockERC20Token.balanceOf(user2), expectedTokenAmount, "Token balance should match the expected token amount");

    console.log("Public Sale contribution within limits test passed.");
}
  
  /**
 * @notice Test the enforcement of minimum contribution limits during token sales.
 */
function testContributionBelowMinimumLimit() public {
    // Configure the contribution limits for this test
    vm.startPrank(owner);
    tokenSale.updateCaps(500 ether, 500 ether);
    tokenSale.updateContributionLimits(8 ether, 50 ether); // Set the minimum to 8 ether
    vm.stopPrank();

    // Attempt a contribution below the minimum limit
    uint256 lowContribution = 1 ether; // Deliberately below the minimum
    vm.deal(user1, lowContribution);
    vm.expectRevert("Contribution outside allowed limits"); // Expect a revert due to low contribution
    vm.prank(user1);
    tokenSale.buyTokens{value: lowContribution}();

    console.log("Test for contribution below minimum limit passed.");
}

  /**
 * @notice Test the enforcement of maximum contribution limits during token sales.
 */
function testContributionAboveMaximumLimit() public {
    // Configure the contribution limits for this test
    vm.startPrank(owner);
    tokenSale.updateCaps(500 ether, 500 ether);
    tokenSale.updateContributionLimits(1 ether, 10 ether); // Set the maximum to 10 ether
    vm.stopPrank();

    // Attempt a contribution above the maximum limit
    uint256 highContribution = 15 ether; // Deliberately above the maximum
    vm.deal(user2, highContribution);
    vm.expectRevert("Contribution outside allowed limits"); // Expect a revert due to high contribution
    vm.prank(user2);
    tokenSale.buyTokens{value: highContribution}();

    console.log("Test for contribution above maximum limit passed.");
}

  /**
 * @notice Test behavior when attempting contributions after the cap has been reached.
 */
function testContributionAfterCapReached() public {
    // Configure the caps and contribution limits for this test
    vm.startPrank(owner);
    tokenSale.updateCaps(50 ether, 50 ether); // Set both caps to 50 ether
    tokenSale.updateContributionLimits(1 ether, 10 ether); // Set contribution limits
    vm.stopPrank();

    // Simulate reaching the cap
    for (uint i = 0; i < 5; i++) {
        address contributor = address(uint160(i + 1)); // Generate unique user addresses
        vm.deal(contributor, 10 ether); // Provide ether to the contributor
        vm.prank(contributor);
        tokenSale.buyTokens{value: 10 ether}(); // Each user contributes 10 ether
    }

    // Attempt contribution after cap is reached
    uint256 contributionAmount = 1 ether; // Any amount for testing
    vm.deal(user1, contributionAmount);
    vm.expectRevert("Presale cap exceeded"); // Expect a revert due to cap reached
    vm.prank(user1);
    tokenSale.buyTokens{value: contributionAmount}();

    console.log("Test for contribution after cap reached passed.");
}
  
  /**
     * @notice Test the transition from PreSale to PublicSale state in the TokenSale contract.
     */
    function testTransitionFromPreSaleToPublicSale() public {
        // Set up caps and contribution limits for the test.
        vm.startPrank(owner);
        tokenSale.updateCaps(100 ether, 200 ether);
        tokenSale.updateContributionLimits(1 ether, 10 ether);
        vm.stopPrank();

        // Confirm the initial state is PreSale.
        assertEq(uint256(tokenSale.getCurrentSaleState()), uint256(TokenSale.SaleState.PreSale), "State should be PreSale initially");

        // Advance time to simulate transition to PublicSale.
        vm.warp(block.timestamp + 3600);

        // Confirm the state transition to PublicSale.
        assertEq(uint256(tokenSale.getCurrentSaleState()), uint256(TokenSale.SaleState.PublicSale), "State should be PublicSale after time warp");

        // Test a valid contribution in the PublicSale phase.
        uint256 contributionAmount = 5 ether;
        vm.deal(user1, contributionAmount);
        vm.prank(user1);
        tokenSale.buyTokens{value: contributionAmount}();

        // Check the results of the contribution.
        assertEq(address(tokenSale).balance, contributionAmount, "Ether balance did not update correctly");
        assertEq(tokenSale.contributions(user1), contributionAmount, "Contribution tracking failed");
        uint256 expectedTokens = contributionAmount * tokenRatePerEth;
        assertEq(mockERC20Token.balanceOf(user1), expectedTokens, "Token allocation did not occur as expected");
    }

  /**
     * @notice Test the functionality of token distribution by the owner of the TokenSale contract.
     */
    function testTokenDistributionByOwner() public {
        // Mint tokens to TokenSale contract to enable distribution.
        vm.startPrank(owner);
        mockERC20Token.mint(address(tokenSale), 1000 ether);
        tokenSale.updateCaps(500 ether, 500 ether);
        tokenSale.updateContributionLimits(1 ether, 110 ether);
        vm.stopPrank();

        uint256 distributionAmount = 100 ether;
        address recipient = address(user1);

        // Check the initial token balance of the recipient.
        uint256 initialBalance = mockERC20Token.balanceOf(recipient);

        // Execute the token distribution by the owner.
        vm.startPrank(owner);
        tokenSale.distributeTokens(recipient, distributionAmount);
        vm.stopPrank();

        // Confirm the tokens have been successfully transferred.
        uint256 finalBalance = mockERC20Token.balanceOf(recipient);
        assertEq(finalBalance, initialBalance + distributionAmount, "Token distribution should increase recipient's balance");

        // Test that only the owner can distribute tokens.
        vm.expectRevert("only owner");
        vm.prank(nonOwner);
        tokenSale.distributeTokens(recipient, distributionAmount);
    }
  
  /**
     * @notice Test the refund functionality when PreSale cap is not met and the sale transitions to Public Sale.
     */
    function testRefundFunctionalityPreSaleCapNotMet() public {
        // Set up PreSale with a lower cap to ensure it's not met.
        uint256 presaleCap = 50 ether;
        vm.startPrank(owner);
        tokenSale.updateCaps(presaleCap, 500 ether);
        tokenSale.updateContributionLimits(1 ether, 10 ether);
        vm.stopPrank();

        // Simulate contributions below the cap.
        uint256 contributionAmount = 10 ether;
        vm.deal(user1, contributionAmount);
        vm.prank(user1);
        tokenSale.buyTokens{value: contributionAmount}();

        // Transition to Public Sale, ending the PreSale.
        vm.warp(block.timestamp + 3600); // Advance time by 1 hour.

        // Attempt to claim a refund due to not meeting the PreSale cap.
        uint256 initialEthBalance = user1.balance;
        vm.prank(user1);
        tokenSale.claimRefund();

        // Verify that the refund was successfully received.
        assertEq(user1.balance, initialEthBalance + contributionAmount, "Refund should be equal to the contribution amount");
    }

}
