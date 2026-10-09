// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {GovernanceToken} from "./GovernanceToken.sol";

contract Governor {
    // -- TYPE VARIABLES --
    struct Proposal {
        address target;
        uint256 value;
        string description;
        uint256 voteCount;
        bytes data;
        bool executed;
    }
    // -- STATE VARIABLES --
    GovernanceToken public governanceToken;
    uint256 public proposalCount;
    uint256 public constant MINIMUM_TOKENS_TOKEN_HOLDER = 1000 * 10 ** 18; // Minimum tokens required to be a token holder

    // -- CONSTRUCTOR --
    constructor(address _governanceToken) {
        governanceToken = GovernanceToken(_governanceToken);
    }

    // -- MAPPINGS --
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted; // Mapping to track if a voter has already voted on a proposal

    // -- CUSTOM ERRORS --
    error Unauthorized();
    error ProposalNotFound();
    error ProposalAlreadyExecuted();
    error AlreadyVoted();
    error ProposalFailedtoExecute();
    error QuorumNotReached();

    // -- EVENTS --
    event ProposalCreated(
        uint256 indexed proposalId, address indexed target, uint256 value, string description, bytes data
    );
    event ProposalExecuted(uint256 indexed proposalId);

    // function to create a proposal that only token holders can call
    function createProposal(address _target, uint256 _value, string memory _description, bytes memory _data)
        public
        returns (uint256)
    {
        if (governanceToken.balanceOf(msg.sender) <= MINIMUM_TOKENS_TOKEN_HOLDER) {
            revert Unauthorized();
        }
        // logic to create a proposal
        Proposal memory newProposal = Proposal({
            target: _target, value: _value, description: _description, voteCount: 0, data: _data, executed: false
        });
        proposals[proposalCount] = newProposal; // Assign the proposal to the mapping
        proposalCount++; // Increment the proposal count

        emit ProposalCreated(proposalCount - 1, _target, _value, _description, _data);
        return proposalCount - 1;
    }

    // function to vote on a proposal that only token holders can call
    function voteOnProposal(uint256 _proposalId, bool _support) public {
        if (governanceToken.balanceOf(msg.sender) < MINIMUM_TOKENS_TOKEN_HOLDER) {
            revert Unauthorized();
        }
        // logic to vote on a proposal
        if (hasVoted[_proposalId][msg.sender]) {
            revert AlreadyVoted(); // Revert if the voter has already voted
        }
        if (_proposalId >= proposalCount) {
            revert ProposalNotFound();
        }
        if (proposals[_proposalId].executed) {
            revert ProposalAlreadyExecuted();
        }

        uint256 voterBalance = governanceToken.balanceOf(msg.sender); // bug 1: same token can be used to vote multiple times.
        Proposal storage proposal = proposals[_proposalId];
        if (_support) {
            proposal.voteCount += voterBalance;
        }
        hasVoted[_proposalId][msg.sender] = true; // Mark the voter as having voted
    }

    // function to execute a proposal that only token holders can call
    function executeProposal(uint256 _proposalId) public {
        if (governanceToken.balanceOf(msg.sender) <= MINIMUM_TOKENS_TOKEN_HOLDER) {
            revert Unauthorized();
        }
        if (_proposalId >= proposalCount) {
            revert ProposalNotFound();
        }
        if (proposals[_proposalId].executed) {
            revert ProposalAlreadyExecuted();
        }
        uint256 quorum = governanceToken.totalSupply() / 2; // Quorum is set to 50% of the total supply
        if (proposals[_proposalId].voteCount < quorum) {
            revert QuorumNotReached();
        }
        // logic to execute a proposal
        Proposal storage proposal = proposals[_proposalId];
        proposal.executed = true;

        (bool success,) = proposal.target.call{value: proposal.value}(proposal.data);
        if (!success) {
            revert ProposalFailedtoExecute();
        }
        emit ProposalExecuted(_proposalId);
    }
}
