//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Interface for ERC20 token standard, including transfer functionalities
interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// Extension of ERC20 interface to include burn functionality
interface IERC20Burnable is IERC20 {
    function burnFrom(address account, uint256 amount) external;
}

/**
 * @title TokenSale
 * @dev Contract for managing token pre-sales and public sales.
 *      Allows for token purchase, distribution, and refund functionalities.
 */
contract TokenSale {
    enum SaleState {
        PreSale,
        PublicSale,
        PostSale
    }

    SaleState public currentSaleState;

    uint256 public totalPresaleEther;
    uint256 public tokenRatePerEth = 1;
    uint256 public totalPublicSaleEther;
    uint256 public presaleCap;
    uint256 public publicSaleCap;
    uint256 public minContribution;
    uint256 public maxContribution;
    address private immutable owner;
    uint256 public immutable publicSaleStartTime;

    mapping(address => uint256) public contributions;
    IERC20Burnable public immutable tokenContract;

    // Ensures only the contract owner can execute certain functions
    modifier onlyOwner() {
        if (msg.sender != owner) revert("only owner");
        _;
    }

    /**
     * @dev Initializes the contract with token address and public sale start time.
     * @param _tokenAddress Address of the token being sold
     * @param _publicSaleStartTime Time until the start of the public sale
     */
    constructor(address _tokenAddress, uint256 _publicSaleStartTime) {
        tokenContract = IERC20Burnable(_tokenAddress);
        owner = msg.sender;
        publicSaleStartTime = block.timestamp + _publicSaleStartTime;
    }

    /**
     * @dev Updates the caps for pre-sale and public sale.
     * @param _presaleCap Cap for the pre-sale
     * @param _publicSaleCap Cap for the public sale
     */
    function updateCaps(uint256 _presaleCap, uint256 _publicSaleCap) external onlyOwner {
        presaleCap = _presaleCap;
        publicSaleCap = _publicSaleCap;
    }

    /**
     * @dev Updates the contribution limits for token purchase.
     * @param _min Minimum contribution limit
     * @param _max Maximum contribution limit
     */
    function updateContributionLimits(uint256 _min, uint256 _max) external onlyOwner {
        minContribution = _min;
        maxContribution = _max;
    }

    /**
     * @dev Allows users to purchase tokens during the sale.
     *      Ensures contributions are within set limits and sale is active.
     */
    function buyTokens() public payable {
        SaleState state = getCurrentSaleState();
        require(state != SaleState.PostSale, "Token sale is not active");
        require(msg.value >= minContribution && msg.value <= maxContribution, "Contribution outside allowed limits");

        updateEtherCollected(state, msg.value);
        contributions[msg.sender] += msg.value;
        transferFrom(msg.sender, calculateTokenAmount(msg.value));
    }

    /**
     * @dev Internal function to update ether collected based on the sale state.
     * @param state Current sale state
     * @param value Contribution value in ether
     */
    function updateEtherCollected(SaleState state, uint256 value) internal {
        if (state == SaleState.PreSale) {
            require(totalPresaleEther + value <= presaleCap, "Presale cap exceeded");
            totalPresaleEther += value;
        } else {
            require(totalPublicSaleEther + value <= publicSaleCap, "Public sale cap exceeded");
            totalPublicSaleEther += value;
        }
    }

    /**
     * @dev Allows the owner to distribute tokens.
     * @param _to Address of the recipient.
     * @param _amount Amount of tokens to distribute.
     */
    function distributeTokens(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Invalid address");
        require(_amount >= minContribution && _amount <= maxContribution, "Amount out of range");
        transferFrom(_to, _amount);
    }

    /**
     * @dev Distributes tokens to a recipient address.
     * @param _to Recipient address
     * @param _amount Amount of tokens to distribute
     */
    function transferFrom(address _to, uint256 _amount) internal {
        require(tokenContract.transfer(_to, _amount), "Token transfer failed");
    }

    /**
     * @dev Determines the current state of the sale based on the current time.
     * @return The current state of the sale (PreSale, PublicSale, or PostSale).
     */
    function getCurrentSaleState() public view returns (SaleState) {
        if (block.timestamp < publicSaleStartTime) {
            return SaleState.PreSale;
        } else {
            return SaleState.PublicSale;
        }
    }

    /**
     * @dev Calculates the token amount based on the provided ETH amount.
     * @param ethAmount The amount of ETH for which tokens are to be calculated.
     * @return The amount of tokens to be received for the given ETH amount.
     */
    function calculateTokenAmount(uint256 ethAmount) internal view returns (uint256) {
        return ethAmount * tokenRatePerEth;
    }

    /**
     * @dev Sets the contract state to PostSale. Can only be called by the contract owner.
     */
    function setPostSaleState() external onlyOwner {
        currentSaleState = SaleState.PostSale;
    }

    /**
     * @dev Allows contributors to claim refunds under specific conditions.
     */
    function claimRefund() external {
        uint256 amountContributed = contributions[msg.sender];
        require(amountContributed > 0, "No contribution found");

        if (getCurrentSaleState() == SaleState.PublicSale) {
            require(totalPresaleEther < presaleCap, "Presale minimum cap met");
        } else if (currentSaleState == SaleState.PostSale) {
            require(totalPublicSaleEther < publicSaleCap, "Public Sale minimum cap met");
        } else {
            revert("Refund not available");
        }
        contributions[msg.sender] = 0;
        uint256 tokenAmountToBurn = calculateTokenAmount(contributions[msg.sender]);
        tokenContract.burnFrom(msg.sender, tokenAmountToBurn);
        payable(msg.sender).transfer(amountContributed);
    }
}
