// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract VotingSystem is Ownable {
    uint256 candidatesCount = 0;

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
    mapping(address => Voter) private voter;

    constructor() {
        CandidateCounts += 1;
    }

    modifier isRegistered() {
        require(!voter[msg.sender].isRegistered, "Not registered");
        _;
    }

    modifier hasVoted() {
        require(!voters[msg.sender].hasVoted, "Already voted!");
        _;
    }

    function addCandidate(string calldata _name) public onlyOwner {
        require(bytes(_name).length > 0, "Invalid name");
        candidates[CandidateCounts.current()] = Candidate(_name, 0);
        CandidateCounts.increment();
    }

    function register() public {
        require(!voters[msg.sender].isRegistered, "Already registered");
        voters[msg.sender].isRegistered = true;
    }

    function vote(uint256 _candidateId) public isRegistered hasVoted {
        require(_candidateId > 0 && _candidateId <= CandidateCounts.current(), "Invalid id");
        candidates[_candidateId].voteCount += 1;

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
    }
}
