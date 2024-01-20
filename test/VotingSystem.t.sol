// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import {VotingSystem} from "../src/VotingSystem.sol";

contract VotingSystemTest is Test {
    VotingSystem public votingSystem;
    address public voter1;
    address public voter2;
    address public nonVoter;

    function setUp() public {
        // owner = address(this);
        votingSystem = new VotingSystem();

        // Setting up test accounts
        voter1 = vm.addr(1);
        voter2 = vm.addr(2);
        nonVoter = vm.addr(3);

        // Registering voters
        vm.prank(voter1);
        votingSystem.registerVoter();

        vm.prank(voter2);
        votingSystem.registerVoter();

        // Adding candidates by the owner
        votingSystem.addCandidate("Alice");
        votingSystem.addCandidate("Bob");
    }

    function testAddCandidate() public {
        vm.expectRevert("Not owner");
        vm.prank(nonVoter);
        votingSystem.addCandidate("Charlie");
    }

    function testRegisterVoter() public {
        vm.expectRevert("Already registered");
        vm.prank(voter1);
        votingSystem.registerVoter();
    }

    function testVoting() public {
                vm.expectRevert("Already registered");
        vm.prank(voter1);
        votingSystem.registerVoter();

        // Voter1 votes for candidate 1
        vm.prank(voter1);
        votingSystem.vote(1);

        // Voter1 should not be able to vote again
        vm.expectRevert("Already voted!");
        vm.prank(voter1);
        votingSystem.vote(1);

        // Non-registered voter should not be able to vote
        vm.expectRevert("Not registered");
        vm.prank(nonVoter);
        votingSystem.vote(1);
    }

    function testGetWinningCandidateId() public {
        // Assuming candidates have been added and voting has taken place
        vm.expectRevert("Voting is still open");
        uint256 winningCandidateId = votingSystem.getWinningCandidateId();

        assertEq(winningCandidateId, 0, "Winning candidate ID should be greater than 0");
    }

    function testGetCandidateDetails() public {
        uint256 candidateId = 1;
        vm.expectRevert("Voting is still open");
        VotingSystem.Candidate memory candidate = votingSystem.getCandidateDetails(candidateId);

        assertEq(candidate.voteCount, 0, "Vote count should be initialized to 0");
    }
}
