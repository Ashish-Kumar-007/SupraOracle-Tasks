// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenSale is Ownable {
    ERC20 public token; // ERC-20 token being sold

    enum SalePhase {
        NotStarted,
        Presale,
        PublicSale,
        Ended
    }

    SalePhase public currentPhase;

    uint256 public presaleCap; // Maximum cap for presale
    uint256 public publicSaleCap; // Maximum cap for public sale

    uint256 public presaleMinContribution; // Minimum contribution in presale
    uint256 public presaleMaxContribution; // Maximum contribution in presale

    uint256 public publicSaleMinContribution; // Minimum contribution in public sale
    uint256 public publicSaleMaxContribution; // Maximum contribution in public sale

    mapping(address => uint256) public presaleContributions; // Track presale contributions
    mapping(address => uint256) public publicSaleContributions; // Track public sale contributions

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 etherAmount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    constructor(
        ERC20 _token,
        uint256 _presaleCap,
        uint256 _publicSaleCap,
        uint256 _presaleMinContribution,
        uint256 _presaleMaxContribution,
        uint256 _publicSaleMinContribution,
        uint256 _publicSaleMaxContribution
    ) {
        token = _token;
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
        presaleMinContribution = _presaleMinContribution;
        presaleMaxContribution = _presaleMaxContribution;
        publicSaleMinContribution = _publicSaleMinContribution;
        publicSaleMaxContribution = _publicSaleMaxContribution;
        currentPhase = SalePhase.NotStarted;
    }

    modifier onlyDuringPresale() {
        require(currentPhase == SalePhase.Presale, "Presale is not active");
        _;
    }

    modifier onlyDuringPublicSale() {
        require(currentPhase == SalePhase.PublicSale, "Public sale is not active");
        _;
    }

    modifier saleNotEnded() {
        require(currentPhase != SalePhase.Ended, "Sale has ended");
        _;
    }

    function startPresale() external onlyOwner {
        require(currentPhase == SalePhase.NotStarted, "Sale has already started");
        currentPhase = SalePhase.Presale;
    }

    function endPresale() external onlyOwner {
        require(currentPhase == SalePhase.Presale, "Presale is not active");
        currentPhase = SalePhase.PublicSale;
    }

    function endSale() external onlyOwner {
        require(currentPhase == SalePhase.PublicSale, "Public sale is not active");
        currentPhase = SalePhase.Ended;
    }

    function contributeToPresale() external payable onlyDuringPresale saleNotEnded {
        require(msg.value >= presaleMinContribution, "Below minimum contribution");
        require(msg.value <= presaleMaxContribution, "Exceeds maximum contribution");
        require(address(this).balance + msg.value <= presaleCap, "Presale cap reached");

        presaleContributions[msg.sender] += msg.value;
        distributeTokens(msg.sender, msg.value);
    }

    function contributeToPublicSale() external payable onlyDuringPublicSale saleNotEnded {
        require(msg.value >= publicSaleMinContribution, "Below minimum contribution");
        require(msg.value <= publicSaleMaxContribution, "Exceeds maximum contribution");
        require(address(this).balance + msg.value <= publicSaleCap, "Public sale cap reached");

        publicSaleContributions[msg.sender] += msg.value;
        distributeTokens(msg.sender, msg.value);
    }

    function distributeTokens(address _recipient, uint256 _etherAmount) internal {
        uint256 tokenAmount = calculateTokenAmount(_etherAmount);
        require(tokenAmount > 0, "Invalid token amount");

        token.transfer(_recipient, tokenAmount);
        emit TokensPurchased(_recipient, tokenAmount, _etherAmount);
    }

    function calculateTokenAmount(uint256 _etherAmount) internal view returns (uint256) {
        // Implement your own logic for token price calculation
        // This is a basic example, you might want to consider factors like bonuses, etc.
        // For simplicity, assuming 1 ETH = 100 tokens
        return _etherAmount * 100;
    }

    function claimRefund() external saleNotEnded {
        require(currentPhase == SalePhase.Ended, "Refund only available after sale ends");

        uint256 refundAmount = 0;
        if (currentPhase == SalePhase.Presale) {
            refundAmount = presaleContributions[msg.sender];
            presaleContributions[msg.sender] = 0;
        } else if (currentPhase == SalePhase.PublicSale) {
            refundAmount = publicSaleContributions[msg.sender];
            publicSaleContributions[msg.sender] = 0;
        }

        require(refundAmount > 0, "No refund available");
        payable(msg.sender).transfer(refundAmount);
        emit RefundClaimed(msg.sender, refundAmount);
    }
}
