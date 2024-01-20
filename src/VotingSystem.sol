// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VotingSystem {
    address public immutable owner;
    uint256 public candidatesCount = 0;
    uint256 deadline = 0;
    uint256 private winningCandidateId = 0;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    mapping(uint256 => Candidate) private candidates;
    mapping(address => Voter) public voters;

    event voted(address user, uint256 candidateId, bool voted);
    event candidateAdded(uint256 candidateId, string name);
    event candidateDetails(uint256 candidateId, string name, uint256 voteCount);
    event userRegistered(address user, bool registered);
    event Winner(uint256 candidateId);

    constructor() {
        owner = msg.sender;
        candidatesCount += 1;
        deadline = block.timestamp + 5 minutes;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isRegistered() {
        require(!voters[msg.sender].isRegistered, "Not registered");
        _;
    }

    modifier hasVoted() {
        require(!voters[msg.sender].hasVoted, "Already voted!");
        _;
    }

    function addCandidate(string calldata _name) public onlyOwner {
        require(bytes(_name).length > 0, "Invalid name");
        candidates[candidatesCount] = Candidate(_name, 0);
        candidatesCount += 1;

        emit candidateAdded(candidatesCount - 1, _name);
    }

    function registerVoter() public {
        require(!voters[msg.sender].isRegistered, "Already registered");
        voters[msg.sender].isRegistered = true;

        emit userRegistered(msg.sender, true);
    }

    function vote(uint256 _candidateId) public isRegistered hasVoted {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid id");
        require(block.timestamp < deadline, "Voting has already closed");
        candidates[_candidateId].voteCount += 1;

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;

        if (candidates[_candidateId].voteCount > candidates[winningCandidateId].voteCount) {
            winningCandidateId = _candidateId;
        }

        emit voted(msg.sender, _candidateId, true);
    }

    function getWinningCandidateId() public returns (uint256) {
        require(block.timestamp >= deadline, "Voting is still open");
        emit Winner(winningCandidateId);
        return winningCandidateId;
    }

    function getCandidateDetails(uint256 _candidateId) public returns (Candidate memory) {
        require(block.timestamp >= deadline, "Voting is still open");
        emit candidateDetails(_candidateId, candidates[_candidateId].name, candidates[_candidateId].voteCount);
        return candidates[_candidateId];
    }
}
