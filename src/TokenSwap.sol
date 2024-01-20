// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract TokenSwap is ReentrancyGuard {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public immutable exchangeRate;

    enum SwapDirection { AtoB, BtoA }
    event Swap(address indexed user, uint256 amountIn, uint256 amountOut, string direction);

    error InsufficientBalance();
    error InsufficientAllowance();
    error TransferFailed();

    constructor(address _tokenA, address _tokenB, uint256 _exchangeRate) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        exchangeRate = _exchangeRate;
    }

    function swapTokens(uint256 amount, SwapDirection direction) external nonReentrant {
        if (amount <= 0) revert InsufficientBalance();

        IERC20 tokenIn = (direction == SwapDirection.AtoB) ? tokenA : tokenB;
        IERC20 tokenOut = (direction == SwapDirection.AtoB) ? tokenB : tokenA;
        uint256 amountOut = (direction == SwapDirection.AtoB) ? amount * exchangeRate : amount / exchangeRate;

        handleTransfer(tokenIn, msg.sender, address(this), amount);
        handleTransfer(tokenOut, address(this), msg.sender, amountOut);
        emit Swap(msg.sender, amount, amountOut, direction == SwapDirection.AtoB ? "A for B" : "B for A");
    }

    function handleTransfer(IERC20 token, address from, address to, uint256 amount) internal {
        if (token.balanceOf(from) < amount) revert InsufficientBalance();
        if (from != address(this) && token.allowance(from, address(this)) < amount) revert InsufficientAllowance();
        
        bool success = from == address(this) ? token.transfer(to, amount) : token.transferFrom(from, to, amount);
        if (!success) revert TransferFailed();
    }
}