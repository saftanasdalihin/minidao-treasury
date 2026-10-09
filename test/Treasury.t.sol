// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {Treasury} from "../src/Treasury.sol";
import {Governor} from "../src/Governor.sol";

contract TreasuryTest is Test {
    GovernanceToken public governanceToken;
    Treasury treasury;
    Governor governor;

    function setUp() public {
        governanceToken = new GovernanceToken(address(this), address(this));
        governor = new Governor(address(governanceToken));
        treasury = new Treasury(address(governor));

        governanceToken.grantRole(governanceToken.GOVERNOR_ROLE(), address(governor));
    }

    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        treasury.deposit{value: depositAmount}();
        // Add assertions to check the state after deposit
    }

    function testWithdraw() public {
        uint256 withdrawAmount = 0.5 ether;
        // Assuming the contract has enough balance for withdrawal
        vm.expectRevert(Treasury.Unauthorized.selector);
        treasury.withdraw(payable(address(this)), withdrawAmount);
    }
}
