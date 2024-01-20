// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {VotingSystem} from "../src/VotingSystem.sol";

contract DecentralizedVotingTest is Test {
    VotingSystem public votingContract;
    address public owner;
    address public voter1;
    address public voter2;
    address public nonVoter;

    /**
     * @dev Sets up the testing environment before each test.
     *      Deploys the voting contract, sets up test accounts, registers voters, and adds candidates.
     */
    function setUp() public {
        owner = address(this);
        votingContract = new VotingSystem(1);

        // Setting up test accounts
        voter1 = vm.addr(1);
        voter2 = vm.addr(2);
        nonVoter = vm.addr(3);

        // Registering voters
        vm.prank(voter1);
        votingContract.registerVoter();

        vm.prank(voter2);
        votingContract.registerVoter();

        // Adding candidates by the owner
        votingContract.addCandidate("Alice");
        votingContract.addCandidate("Bob");
    }

    /**
     * @dev Tests the voter registration functionality.
     *      Ensures that already registered voters cannot register again.
     */
    function testVoterRegistration() public {
        vm.expectRevert(abi.encodeWithSignature("VoterAlreadyRegistered()"));
        vm.prank(voter1);
        votingContract.registerVoter();
    }

    /**
     * @dev Tests candidate registration functionality.
     *      Ensures that only the owner can register candidates.
     */
    function testAddCandidate() public {
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        vm.prank(nonVoter);
        votingContract.registerCandidate("Charlie");
    }

    /**
     * @dev Tests the voting functionality.
     *      Checks that voters can vote only once and non-registered voters cannot vote.
     */
    function testVoting() public {
        // Voter1 votes for candidate 1
        vm.prank(voter1);
        votingContract.vote(1);

        // Voter1 should not be able to vote again
        vm.expectRevert(abi.encodeWithSignature("VoterAlreadyVoted()"));
        vm.prank(voter1);
        votingContract.vote(1);

        // Non-registered voter should not be able to vote
        vm.expectRevert(abi.encodeWithSignature("OnlyRegisteredVoters()"));
        vm.prank(nonVoter);
        votingContract.vote(1);
    }

    /**
     * @dev Tests the declare winner functionality.
     * Simulates voting, ensures only the owner can declare the winner,
     * and verifies the correctness of the declared winner.
     */
    function testDeclareWinner() public {
        // Simulate voting by voter1 and voter2
        vm.prank(voter1);
        votingContract.vote(1);

        vm.prank(voter2);
        votingContract.vote(1);

        // Forward time to after the voting period
        vm.warp(block.timestamp + 2 minutes);

        // Ensure that only the owner can declare the winner
        vm.expectRevert(abi.encodeWithSignature("OnlyOwner()"));
        vm.prank(nonVoter);
        votingContract.declareWinner();

        // Owner declares the winner
        vm.prank(owner);
        uint256 winningCandidateId = votingContract.declareWinner();
        console.log("winningCandidateId", winningCandidateId);

        // Fetch and log the declared winner's details
        (uint256 id, string memory name, uint256 voteCount) = getCandidateDetails(winningCandidateId);
        console.log("winner.id", id);
        console.log("winner.name", name);
        console.log("winner.voteCount", voteCount);

        // Assertions to check the correctness of the winner's details
        assertEq(id, winningCandidateId, "Winner ID does not match expected value.");
        assertEq(name, "Bob", "The declared winner should be Alice.");
    }

    /**
     * @dev Helper function to get candidate details for verification.
     * @param candidateId The ID of the candidate to fetch details for.
     * @return Tuple containing the candidate's ID, name, and vote count.
     */
    function getCandidateDetails(uint256 candidateId) internal view returns (uint256, string memory, uint256) {
        DecentralizedVoting.Candidate memory candidate = votingContract.getCandidate(candidateId);
        return (candidate.id, candidate.name, candidate.voteCount);
    }
}
