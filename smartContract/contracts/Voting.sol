// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./VotingToken.sol";

contract Voting is Ownable {

// Structures

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
        address addr;
    }

    struct Proposal {
        string description;
        uint voteCount;
        uint proposalId;
        address proposer;
    }

    struct Vote {
        address voter;
        uint proposalId;
        uint timestamp;
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
    Voter[] public voters;
    Vote[] public voteHistory;
    address public votingTokenContractAddress;
    string public subject;  // La variable de stockage pour le sujet

// Events

    event VoterRegistered(address indexed voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted(address indexed voter, uint proposalId);
    event VotingRightsRevoked(address indexed voterAddress);
    event WinnerDetermined(uint winningProposalId);

// Constructor

    constructor(string memory _subject, address _votingTokenContractAddress) Ownable(msg.sender) {
        currentStatus = WorkflowStatus.RegisteringVoters;
        votingTokenContractAddress = _votingTokenContractAddress;
        subject = _subject;
    }

// Modifiers

    modifier checkRegisteredVoter() {
        require(addressToVoter[msg.sender].isRegistered, "Participant non enregistre");
        _;
    }

    modifier checkStatus(WorkflowStatus status) {
        require(currentStatus == status, "Statut invalide");
        _;
    }

// Functions

    // Only Owner functions

    function registerVoter(address _voterAddress) external onlyOwner checkStatus(WorkflowStatus.RegisteringVoters) {
        require(!addressToVoter[_voterAddress].isRegistered, "Participant deja enregistre");
        
        Voter memory newVoter = Voter(true, false, 0, _voterAddress);
        addressToVoter[_voterAddress] = newVoter;
        voters.push(newVoter);
    }

    function revokeVotingRights(address _voterAddress) external onlyOwner checkStatus(WorkflowStatus.RegisteringVoters){ 
        Voter storage voter = addressToVoter[_voterAddress];
        require(voter.isRegistered, "Participant non enregistre");
        
        for (uint i = 0; i < voters.length; i++) {
            if (voters[i].addr == _voterAddress) {
                voters[i] = voters[voters.length - 1];
                voters.pop();
                voter.isRegistered = false;
                voter.hasVoted = false;
                voter.votedProposalId = 0;
                emit VotingRightsRevoked(_voterAddress);
                return;
            }
        }
        
        revert("Participant introuvable");
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
        emit WinnerDetermined(winningProposalId);
        rewardWinner();
    }

    //For voters

    function submitProposal(string memory _description) external checkRegisteredVoter checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal(_description, 0,proposals.length, msg.sender));
        emit ProposalRegistered(proposals.length - 1);
    }

    function vote(uint _proposalId) external checkRegisteredVoter checkStatus(WorkflowStatus.VotingSessionStarted) {
        require(!addressToVoter[msg.sender].hasVoted, "Vous avez deja vote !");
        require(_proposalId < proposals.length, "Proposal ID Invalide");

        Proposal storage selectedProposal = proposals[_proposalId];
        require(selectedProposal.proposer != msg.sender, "Vous ne pouvez pas voter pour votre propre proposition.");
        
        addressToVoter[msg.sender].hasVoted = true;
        addressToVoter[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;

        recordVote(_proposalId);
        emit Voted(msg.sender, _proposalId);
    }

    function recordVote(uint _proposalId) internal checkRegisteredVoter checkStatus(WorkflowStatus.VotingSessionStarted) {
        require(_proposalId < proposals.length, "proposal ID invalide");

        voteHistory.push(Vote({
            voter: msg.sender,
            proposalId: _proposalId,
            timestamp: block.timestamp
        }));
    }

    // View 

    function getSubject() external view returns (string memory) {
        return subject;
    }

    function getWinningProposalDescription() external checkRegisteredVoter checkStatus(WorkflowStatus.VotesTallied) view returns (string memory) {
        require(winningProposalId < proposals.length, "proposal ID gagnant invalide");
        
        return proposals[winningProposalId].description;
    }

    function getAllVoters() external checkRegisteredVoter view returns (Voter[] memory) {
        return voters;
    }

    function getCurrentStatus() external view returns (WorkflowStatus){
        return currentStatus;
    }

    function getAllproposals() external checkRegisteredVoter view returns (Proposal[] memory){
        return proposals;
    }

    function getVoteHistory() external checkRegisteredVoter checkStatus(WorkflowStatus.VotesTallied) view returns (Vote[] memory) {
        return voteHistory;
    }

    // Rewards

    function rewardWinner() internal {
        require(currentStatus == WorkflowStatus.VotesTallied, "Recompense disponible uniquement apres le decompte des votes");
        require(winningProposalId < proposals.length, "ID de proposition gagnante invalide");

        address winner = proposals[winningProposalId].proposer;
        uint256 rewardAmount = 10; // Spécifiez le montant de la récompense ici

        VotingToken votingToken = VotingToken(votingTokenContractAddress);
        votingToken.transferFrom(owner(), winner, rewardAmount);
    }

}
