// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import Truffle testing library
import {Test, console} from "forge-std/Test.sol";
import {TokenSwap} from "../src/TokenSwap.sol";

contract TestTokenSwap {
    // Initialize the contract with some initial values
    IERC20 private token1 = IERC20(DeployedAddresses.Token1()); // Replace with your actual Token1 contract address
    IERC20 private token2 = IERC20(DeployedAddresses.Token2()); // Replace with your actual Token2 contract address
    uint256 private initialExchangeRate = 100;

    TokenSwap private tokenSwap;

    function beforeEach() public {
        tokenSwap = new TokenSwap(token1, token2, initialExchangeRate);
    }

    // Test that the constructor sets the correct initial values
    function testInitialValues() public {
        Assert.equal(tokenSwap.token1(), token1, "Token1 address is incorrect");
        Assert.equal(tokenSwap.token2(), token2, "Token2 address is incorrect");
        Assert.equal(
            tokenSwap.exchangeRate(),
            initialExchangeRate,
            "Exchange rate is incorrect"
        );
    }

    // Test that only the owner can update the exchange rate
    function testUpdateExchangeRate() public {
        uint256 newExchangeRate = 150;
        tokenSwap.updateExchangeRate(newExchangeRate);
        Assert.equal(
            tokenSwap.exchangeRate(),
            newExchangeRate,
            "Exchange rate not updated"
        );

        // Try updating exchange rate from a non-owner address, should revert
        TokenSwap nonOwnerSwap = new TokenSwap(
            token1,
            token2,
            initialExchangeRate
        );
        bool success = nonOwnerSwap.call(
            abi.encodeWithSignature(
                "updateExchangeRate(uint256)",
                newExchangeRate
            )
        );
        Assert.isFalse(success, "Non-owner was able to update exchange rate");
    }

    // Test token swap function
    function testTokenSwap() public {
        uint256 amountIn = 10;
        uint256 expectedAmountOut = amountIn * initialExchangeRate;

        // Perform Token1 to Token2 swap
        tokenSwap.swapTokens(amountIn, TokenSwap.SwapDirection.Token1ToToken2);
        Assert.equal(
            tokenSwap.token1().balanceOf(address(tokenSwap)),
            amountIn,
            "Token1 balance in contract is incorrect"
        );
        Assert.equal(
            tokenSwap.token2().balanceOf(msg.sender),
            expectedAmountOut,
            "Token2 balance for the sender is incorrect"
        );

        // Perform Token2 to Token1 swap
        tokenSwap.swapTokens(amountIn, TokenSwap.SwapDirection.Token2ToToken1);
        Assert.equal(
            tokenSwap.token2().balanceOf(address(tokenSwap)),
            amountIn,
            "Token2 balance in contract is incorrect"
        );
        Assert.equal(
            tokenSwap.token1().balanceOf(msg.sender),
            expectedAmountOut,
            "Token1 balance for the sender is incorrect"
        );
    }

    // Test that attempting to update the exchange rate from a non-owner address fails
    function testUpdateExchangeRateFail() public {
        uint256 newExchangeRate = 150;

        // Attempt to update exchange rate from a non-owner address, should revert
        TokenSwap nonOwnerSwap = new TokenSwap(
            token1,
            token2,
            initialExchangeRate
        );
        bool success = nonOwnerSwap.call(
            abi.encodeWithSignature(
                "updateExchangeRate(uint256)",
                newExchangeRate
            )
        );
        Assert.isFalse(success, "Non-owner was able to update exchange rate");
    }

    // Test that attempting to swap tokens with an invalid direction fails
    function testInvalidSwapDirection() public {
        uint256 amountIn = 10;

        // Attempt to swap with an invalid direction, should revert
        bool success = tokenSwap.call(
            abi.encodeWithSignature(
                "swapTokens(uint256,uint8)",
                amountIn,
                uint8(2)
            )
        );
        Assert.isFalse(success, "Invalid swap direction did not revert");
    }

    // Test that attempting to swap tokens with insufficient balance fails
    function testInsufficientBalance() public {
        uint256 amountIn = 100; // Assuming the contract has insufficient balance

        // Attempt to swap tokens with insufficient balance, should revert
        bool success = tokenSwap.call(
            abi.encodeWithSignature(
                "swapTokens(uint256,uint8)",
                amountIn,
                uint8(TokenSwap.SwapDirection.Token1ToToken2)
            )
        );
        Assert.isFalse(success, "Insufficient balance did not revert");
    }
}
