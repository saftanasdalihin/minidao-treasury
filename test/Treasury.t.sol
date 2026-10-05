// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Treasury} from "../src/Treasury.sol";

contract TreasuryTest is Test {
    Treasury treasury;

    function setUp() public {
        treasury = new Treasury();
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
