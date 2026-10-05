// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Governor} from "../../src/Governor.sol";
import {GovernanceToken} from "../../src/GovernanceToken.sol";

contract CreateProposalTest is Test {
    Governor public governor;
    GovernanceToken public governanceToken;

    address public nonTokenHolder = address(0x1);
    address public nonGovernor = address(0x2);

    function setUp() public {
        governanceToken = new GovernanceToken(address(this), address(this), address(this));
    }

    function testCreateProposal() public {
        // Create a proposal
        governor.createProposal(address(0), 0, "Test Proposal", "");

        // Check that the proposal was created
        (
            address target,
            uint256 value,
            string memory description,
            uint256 voteCount,
            bytes memory data,
            bool executed
        ) = governor.proposals(0);
        assertEq(target, address(0));
        assertEq(value, 0);
        assertEq(description, "Test Proposal");
        assertEq(voteCount, 0);
        assertEq(data, "");
        assertEq(executed, false);
    }

    function testCreateProposalUnauthorized() public {
        // Try to create a proposal without TOKEN_HOLDER_ROLE
        vm.startPrank(nonGovernor);
        vm.expectRevert(Governor.Unauthorized.selector);
        governor.createProposal(address(0), 0, "Test Proposal", "");
        vm.stopPrank();
    }
}
