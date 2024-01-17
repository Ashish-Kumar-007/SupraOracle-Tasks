// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSwap is Ownable {
    using SafeERC20 for IERC20;

    enum SwapDirection {
        Token1ToToken2,
        Token2ToToken1
    }

    IERC20 public token1; // Token1 instance
    IERC20 public token2; // Token2 instance
    uint256 public exchangeRate; // Constant exchange rate (e.g., 1 token1 = X token2)

    // Events for logging swap events
    event TokenSwap(
        address indexed sender,
        SwapDirection direction,
        uint256 amountIn,
        uint256 amountOut
    );

    // Constructor to set initial parameters
    constructor(IERC20 _token1, IERC20 _token2, uint256 _exchangeRate) {
        token1 = _token1;
        token2 = _token2;
        exchangeRate = _exchangeRate;
    }

    // Function to update the exchange rate, can only be called by the owner
    function updateExchangeRate(uint256 newRate) external onlyOwner {
        exchangeRate = newRate;
    }

    // Function to swap tokens
    function swapTokens(uint256 amountIn, SwapDirection direction) external {
        uint256 amountOut;

        amountOut = (direction == SwapDirection.Token1ToToken2)
            ? amountIn * exchangeRate
            : amountIn / exchangeRate;

        _performTokenSwap(
            (direction == SwapDirection.Token1ToToken2) ? token1 : token2,
            (direction == SwapDirection.Token1ToToken2) ? token2 : token1,
            msg.sender,
            amountIn,
            amountOut
        );

        // Emit an event to log the swap
        emit TokenSwap(msg.sender, direction, amountIn, amountOut);
    }

    // Internal function to perform the token swap
    function _performTokenSwap(
        IERC20 fromToken,
        IERC20 toToken,
        address recipient,
        uint256 amountIn,
        uint256 amountOut
    ) internal {
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        toToken.safeTransfer(recipient, amountOut);
    }
}
