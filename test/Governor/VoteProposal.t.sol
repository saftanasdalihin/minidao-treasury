// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Governor} from "../../src/Governor.sol";
import {GovernanceToken} from "../../src/GovernanceToken.sol";

contract VoteProposalTest is Test {
    GovernanceToken public governanceToken;
    Governor public governor;

    address public nonTokenHolder = address(0x1);
    address public nonGovernor = address(0x2);

    function setUp() public {
        governanceToken = new GovernanceToken(address(this), address(this));
        governor = new Governor(address(governanceToken));

        governanceToken.grantRole(governanceToken.GOVERNOR_ROLE(), address(governor));
    }

    function testVoteOnProposal() public {
        // Create a proposal
        governor.createProposal(address(0), 0, "Test Proposal", "");

        // Vote on the proposal
        governor.voteOnProposal(0, true);

        // Check that the vote count increased
        (,,, uint256 voteCount,,) = governor.proposals(0);
        assertEq(voteCount, governanceToken.balanceOf(address(this)));
    }

    function testVoteOnProposalUnauthorized() public {
        // Create a proposal
        governor.createProposal(address(0), 0, "Test Proposal", "");

        // Try to vote on the proposal without TOKEN_HOLDER_ROLE
        vm.startPrank(nonTokenHolder);
        vm.expectRevert(Governor.Unauthorized.selector);
        governor.voteOnProposal(0, true);
        vm.stopPrank();
    }

    // Token yang sama mungkin bisa digunakan berkali-kali untuk voting
    // misalnya, A punya 100 token, A voting, lalu A kirim tokennya ke B, lalu B voting, maka total voting menjadi 200.
    // ini memungkinkan seseorang yang tidak memiliki token menjadi bisa voting/buat/eksekusi proposal dengan cara meminjam token orang lain
    //

    // function testVoteWithSameTokenDifferentAccounts() public {
    //     // Create a proposal
    //     governor.createProposal(address(0), 0, "Test Proposal", "");

    // }
}
