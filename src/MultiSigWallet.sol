// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public quorum;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvals;
    }

    Transaction[] public transactions;

    event TransactionSubmitted(uint256 indexed txIndex, address indexed to, uint256 value, bytes data);
    event TransactionApproved(uint256 indexed txIndex, address indexed approver);
    event TransactionCancelled(uint256 indexed txIndex, address indexed canceller);
    event Execution(uint256 indexed txIndex);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier transactionExists(uint256 _txIndex) {
        require(_txIndex < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 _txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _quorum) {
        require(_owners.length > 0, "Owners required");
        require(_quorum > 0 && _quorum <= _owners.length, "Invalid quorum");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner");
            isOwner[owner] = true;
            owners.push(owner);
        }

        quorum = _quorum;
    }

    function submitTransaction(address _to, uint256 _value, bytes memory _data) public onlyOwner {
        uint256 txIndex = transactions.length;
        Transaction memory newTransaction =
            Transaction({to: _to, value: _value, data: _data, executed: false, approvals: 0});

        transactions.push(newTransaction);
        emit TransactionSubmitted(txIndex, _to, _value, _data);
    }

    function approveTransaction(uint256 _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        require(!transactions[_txIndex].executed, "Transaction already executed");
        require(isOwner[msg.sender], "Not an owner");
        require(!transactions[_txIndex].approvals & (1 << uint256(msg.sender)), "Already approved");

        transactions[_txIndex].approvals |= (1 << uint256(msg.sender));

        emit TransactionApproved(_txIndex, msg.sender);

        if (transactions[_txIndex].approvals == quorum) {
            executeTransaction(_txIndex);
        }
    }

    function cancelTransaction(uint256 _txIndex) public onlyOwner transactionExists(_txIndex) notExecuted(_txIndex) {
        require(isOwner[msg.sender], "Not an owner");
        transactions[_txIndex].executed = true;

        emit TransactionCancelled(_txIndex, msg.sender);
    }

    function executeTransaction(uint256 _txIndex) internal {
        require(transactions[_txIndex].approvals == quorum, "Not enough approvals");

        Transaction storage transaction = transactions[_txIndex];
        transaction.executed = true;

        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction execution failed");

        emit Execution(_txIndex);
    }
}
