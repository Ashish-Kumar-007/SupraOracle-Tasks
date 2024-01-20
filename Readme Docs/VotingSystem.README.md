# Voting System Smart Contract

This smart contract, written in Solidity, provides a simple voting system. Users can register, add candidates, vote for their preferred candidate, and retrieve information about the winning candidate and individual candidate details.

## Smart Contract Details

### SPDX-License-Identifier
The contract uses the MIT license.

### Pragma Directive
The contract is written for Solidity version ^0.8.19.

### Import Statements
The contract imports the Ownable contract from the OpenZeppelin library, which provides basic authorization control.

### State Variables
- `candidatesCount`: The count of candidates registered.
- `deadline`: The timestamp indicating the deadline for voting.
- `winningCandidateId`: The ID of the winning candidate.

### Structs
#### Candidate
- `name`: The name of the candidate.
- `voteCount`: The count of votes received by the candidate.

#### Voter
- `isRegistered`: Indicates whether the voter is registered.
- `hasVoted`: Indicates whether the voter has already voted.
- `votedCandidateId`: The ID of the candidate the voter has voted for.

### Mappings
- `candidates`: Maps candidate IDs to Candidate structs.
- `voters`: Maps voter addresses to Voter structs.

### Events
- `voted`: Emitted when a voter casts a vote.
- `candidateAdded`: Emitted when a new candidate is added.
- `candidateDetails`: Emitted when details about a specific candidate are requested.
- `userRegistered`: Emitted when a user successfully registers.
- `Winner`: Emitted when the winning candidate is determined.

### Constructor
- Initializes the contract by setting the initial count of candidates and the deadline for voting.

### Modifiers
- `isRegistered`: Checks whether the sender is a registered voter.
- `hasVoted`: Checks whether the sender has already voted.

### Functions
#### `addCandidate`
- Only callable by the owner.
- Adds a new candidate with the specified name.

#### `register`
- Allows users to register as voters.

#### `vote`
- Allows registered voters to cast their votes for a specific candidate.

#### `getWinningCandidateId`
- Returns the ID of the winning candidate after the voting deadline.

#### `getCandidateDetails`
- Returns details about a specific candidate after the voting deadline.

## Usage
1. Deploy the contract.
2. Register voters using the `register` function.
3. Add candidates using the `addCandidate` function.
4. Allow registered voters to cast their votes using the `vote` function.
5. Retrieve the winning candidate's ID and individual candidate details after the voting deadline using `getWinningCandidateId` and `getCandidateDetails` functions, respectively.

Note: Ensure proper testing and verification before deploying this contract in a production environment.