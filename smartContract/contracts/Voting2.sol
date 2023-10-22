// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

// Structures
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

// Enum
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

// Variables
    WorkflowStatus public currentStatus;
    uint public winningProposalId;
    Proposal[] public proposals;
    mapping(address => Voter) public addressToVoter;
    

// Events
    event VoterRegistered(address indexed voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address indexed voter, uint proposalId);

    constructor() Ownable(msg.sender) {
        currentStatus = WorkflowStatus.RegisteringVoters;
    }

// Modifiers


    modifier checkRegisteredVoter() {
        require(addressToVoter[msg.sender].isRegistered, "Les participants doivent etre enregistres pour voter");
        _;
    }

    modifier checkStatus(WorkflowStatus status) {
        require(currentStatus == status, "Statut invalide");
        _;
    }

// Functions

    // Only Owner functions
    function registerVoter(address _voterAddress) external onlyOwner checkStatus(WorkflowStatus.RegisteringVoters) {
        require(!addressToVoter[_voterAddress].isRegistered, "Votant deja enregistre");
        
        addressToVoter[_voterAddress].isRegistered = true;
        addressToVoter[_voterAddress].hasVoted = false;
        addressToVoter[_voterAddress].votedProposalId = 0;  
        
        emit VoterRegistered(_voterAddress);
    }

    // Change status 
    function startProposalsRegistration() external onlyOwner checkStatus(WorkflowStatus.RegisteringVoters) {
        currentStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function endProposalsRegistration() external onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        currentStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() external onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationEnded) {
        currentStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function endVotingSession() external onlyOwner checkStatus(WorkflowStatus.VotingSessionStarted) {
        currentStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function tallyVotes() external onlyOwner checkStatus(WorkflowStatus.VotingSessionEnded) {
        currentStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        uint winningVoteCount = 0;
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }
    }

    //For voters

    function submitProposal(string memory _description) external checkRegisteredVoter checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(proposals.length - 1);
    }
    
    function vote(uint _proposalId) external checkRegisteredVoter checkStatus(WorkflowStatus.VotingSessionStarted) {
        require(!addressToVoter[msg.sender].hasVoted, "Vous avez deja vote !");
        require(_proposalId < proposals.length, "Proposal ID Invalide");

        addressToVoter[msg.sender].hasVoted = true;
        addressToVoter[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, _proposalId);
    }

    // View 
    function getWinner() external checkRegisteredVoter checkStatus(WorkflowStatus.VotesTallied) view returns (uint) {
        return winningProposalId;
    }
}
