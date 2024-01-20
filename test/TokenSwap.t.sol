// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {MockERC20Token} from "../src/mocks/MockERC20Token.sol";
import {TokenSwap} from "../src/TokenSwap.sol";


contract TOkenSwapTest is Test {
    TokenSwap public swapToken;
    MockERC20Token public tokenA;
    MockERC20Token public tokenB;

    address public testUser1;
    address public testUser2;

    function setUp() public {
        tokenA = new MockERC20Token("Token A", "TKNA");
        tokenB = new MockERC20Token("Token B", "TKNB");

        uint256 exchangeRate = 2;

        swapToken = new TokenSwap(address(tokenA), address(tokenB), exchangeRate);

        testUser1 = address(0x100);
        testUser2 = address(0x101);

        tokenA.mint(testUser1, 500 ether); 
        tokenB.mint(testUser2, 500 ether);

        tokenA.mint(address(swapToken), 500 ether); 
        tokenB.mint(address(swapToken), 500 ether);
    }

    function testSwapWithoutApproval() public {
        // Initial balance checks (optional but good for thorough testing)
        uint256 initialUser1TokenABalance = tokenA.balanceOf(testUser1);
        uint256 initialContractTokenBBalance = tokenB.balanceOf(address(swapToken));

        // Expect the contract to revert the transaction due to insufficient allowance
        vm.prank(testUser1);
        vm.expectRevert(abi.encodeWithSignature("InsufficientAllowance()"));
        swapToken.swapTokens(100 ether, TokenSwap.SwapDirection.AtoB);

        // Balance checks to confirm no tokens were transferred
        uint256 finalUser1TokenABalance = tokenA.balanceOf(testUser1);
        uint256 finalContractTokenBBalance = tokenB.balanceOf(address(swapToken));


        // Assert that the balances remain unchanged
        assertEq(initialUser1TokenABalance, finalUser1TokenABalance, "User's Token A balance should not change");
        assertEq(initialContractTokenBBalance, finalContractTokenBBalance, "Contract's Token B balance should not change");
    }

    function testSwapWithInsufficientApproval() public {
        // Initial balance checks
        uint256 initialUser1TokenABalance = tokenA.balanceOf(testUser1);
        uint256 initialContractTokenBBalance = tokenB.balanceOf(address(swapToken));

        // Approve the SwapToken contract to spend 50 Token A from testUser1's account
        vm.prank(testUser1);
        tokenA.approve(address(swapToken), 50 ether);

        // Attempt to swap 100 Token A, which should fail due to insufficient allowance
        vm.prank(testUser1);
        vm.expectRevert(abi.encodeWithSignature("InsufficientAllowance()"));
        swapToken.swapTokens(100 ether, TokenSwap.SwapDirection.AtoB);

        // Check final balances to ensure no tokens were transferred
        uint256 finalUser1TokenABalance = tokenA.balanceOf(testUser1);
        uint256 finalContractTokenBBalance = tokenB.balanceOf(address(swapToken));

        // Assert that the balances remain unchanged
        assertEq(initialUser1TokenABalance, finalUser1TokenABalance, "User's Token A balance should not change");
        assertEq(initialContractTokenBBalance, finalContractTokenBBalance, "Contract's Token B balance should not change");
    }

    function testSuccessfulSwap() public {
        // Initial balance checks for Token B of User 1 and Token A of the contract
        uint256 initialBalanceTokenBUser1 = tokenB.balanceOf(testUser1);
        uint256 initialBalanceTokenAContract = tokenA.balanceOf(address(swapToken)); 

        // User 1 approves the SwapToken contract to spend 100 Token A
        vm.prank(testUser1);
        tokenA.approve(address(swapToken), 100 ether);

        // User 1 swaps 100 Token A for Token B
        vm.prank(testUser1);
        swapToken.swapTokens(100 ether, TokenSwap.SwapDirection.AtoB);

        // Final balance checks for Token B of User 1 and Token A of the contract
        uint256 finalBalanceTokenBUser1 = tokenB.balanceOf(testUser1);
        uint256 finalBalanceTokenAContract = tokenA.balanceOf(address(swapToken));

        // Assert final balances to check if the swap was successful
        assertEq(finalBalanceTokenBUser1, initialBalanceTokenBUser1 + finalBalanceTokenBUser1, "User did not receive correct amount of Token B");
        assertEq(finalBalanceTokenAContract, initialBalanceTokenAContract + 100 ether, "Contract did not receive correct amount of Token A");
    }

    function testSuccessfulSwapAndReverseSwap() public {
    // Initial balance checks for both tokens
    uint256 initialBalanceTokenAUser1 = tokenA.balanceOf(testUser1);
    uint256 initialBalanceTokenBUser1 = tokenB.balanceOf(testUser1);
    uint256 initialBalanceTokenAContract = tokenA.balanceOf(address(swapToken));
    uint256 initialBalanceTokenBContract = tokenB.balanceOf(address(swapToken));

    // User 1 swaps 100 Token A for Token B
    vm.prank(testUser1);
    tokenA.approve(address(swapToken), 100 ether);
    vm.prank(testUser1);
    swapToken.swapTokens(100 ether, TokenSwap.SwapDirection.AtoB);

    // Check balances after first swap
    uint256 afterSwap1BalanceTokenAUser1 = tokenA.balanceOf(testUser1);
    uint256 afterSwap1BalanceTokenBUser1 = tokenB.balanceOf(testUser1);
    assertEq(afterSwap1BalanceTokenAUser1, initialBalanceTokenAUser1 - 100 ether, "User's Token A balance incorrect after swap");
    assertEq(afterSwap1BalanceTokenBUser1, initialBalanceTokenBUser1 + 200 ether, "User's Token B balance incorrect after swap");

    // User 1 swaps 200 Token B for Token A (Reverse Swap)
    vm.prank(testUser1);
    tokenB.approve(address(swapToken), 200 ether);
    vm.prank(testUser1);
    swapToken.swapTokens(200 ether, TokenSwap.SwapDirection.BtoA);

    // Check balances after reverse swap
    uint256 finalBalanceTokenAUser1 = tokenA.balanceOf(testUser1);
    uint256 finalBalanceTokenBUser1 = tokenB.balanceOf(testUser1);
    assertEq(finalBalanceTokenAUser1, afterSwap1BalanceTokenAUser1 + 100 ether, "User's Token A balance incorrect after reverse swap");
    assertEq(finalBalanceTokenBUser1, afterSwap1BalanceTokenBUser1 - 200 ether, "User's Token B balance incorrect after reverse swap");

    // Console log for debugging
    console.log("Initial Token A User1 Balance:", initialBalanceTokenAUser1);
    console.log("Initial Token B User1 Balance:", initialBalanceTokenBUser1);
    console.log("Initial Token A Contract Balance:", initialBalanceTokenAContract);
    console.log("Initial Token B Contract Balance:", initialBalanceTokenBContract);
    console.log("After Swap 1 Token A User1 Balance:", afterSwap1BalanceTokenAUser1);
    console.log("After Swap 1 Token B User1 Balance:", afterSwap1BalanceTokenBUser1);
    console.log("Final Token A User1 Balance:", finalBalanceTokenAUser1);
    console.log("Final Token B User1 Balance:", finalBalanceTokenBUser1);
}


}