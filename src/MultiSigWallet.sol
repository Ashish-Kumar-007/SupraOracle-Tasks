// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title MultiSigWallet
 * @dev Implementation of a multi-signature wallet. Allows multiple owners to
 * collectively approve and execute transactions.
 */
contract MultiSigWallet {
    // Events
    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    /**
     * @dev Struct to store details of a transaction.
     */
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
    }

    // State variables
    mapping(address => bool) public isOwner;
    uint256 public immutable required;
    uint256 public immutable ownerCount;
    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;
    mapping(uint256 => uint256) public approvalCounts;

    // Modifiers
    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert("not owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        if (_txId >= transactions.length) revert("tx does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        if (approved[_txId][msg.sender]) revert("tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        if (transactions[_txId].executed) revert("tx already executed");
        _;
    }

    /**
     * @dev Constructor to create the MultiSigWallet.
     * @param _owners Array of addresses to be owners of the wallet.
     * @param _required Number of required approvals for executing a transaction.
     */
    constructor(address[] memory _owners, uint256 _required) {
        if (_owners.length == 0) revert("owners required");
        if (!(_required > 0 && _required <= _owners.length)) {
            revert("invalid required number of owners");
        }

        for (uint256 i; i < _owners.length; i++) {
            if (_owners[i] == address(0)) revert("invalid owner");
            if (isOwner[_owners[i]]) revert("owner is not unique");

            isOwner[_owners[i]] = true;
        }
        ownerCount = _owners.length;
        required = _required;
    }

    /**
     * @dev Allows the contract to receive funds.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Submits a new transaction for approval.
     * @param _to Recipient address.
     * @param _value Amount of Ether to send.
     * @param _data Transaction data.
     */
    function submit(address _to, uint256 _value, bytes calldata _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));
        emit Submit(transactions.length - 1);
    }

    /**
     * @dev Approves a transaction.
     * @param _txId Transaction ID.
     */
    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        approvalCounts[_txId]++;
        emit Approve(msg.sender, _txId);
    }

    /**
     * @dev Executes a transaction if it has the required number of approvals.
     * @param _txId Transaction ID.
     */
    function execute(uint256 _txId) external txExists(_txId) notExecuted(_txId) {
        if (approvalCounts[_txId] < required) revert("approvals count < required count");

        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        if (!success) revert("tx failed");

        emit Execute(_txId);
    }

    /**
     * @dev Revokes approval for a transaction.
     * @param _txId Transaction ID.
     */
    function revoke(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        if (!approved[_txId][msg.sender]) revert("tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}
