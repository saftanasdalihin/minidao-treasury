// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract Treasury {
    // -- CUSTOM ERRORS --
    // custom error for authorization
    error Unauthorized();

    // custom error for payable function
    error InsufficientDeposit();

    address public governor;

    constructor(address _governor) {
        governor = _governor;
    }

    event Deposit(address indexed sender, uint256 amount, uint256 timestamp);
    event Withdrawal(address indexed recipient, uint256 amount, uint256 timestamp);

    // function to receive ether. msg.data must be empty
    receive() external payable {}

    // fallback function is called when msg.data is not empty
    fallback() external payable {}

    // function deposit
    function deposit() external payable {
        if (msg.value == 0) {
            revert InsufficientDeposit();
        }
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    // function withdraw that only the governor can call
    function withdraw(address payable recipient, uint256 amount) external {
        if (msg.sender != governor) {
            revert Unauthorized();
        }
        (bool success,) = recipient.call{value: amount}("");
        require(success, "Transfer failed.");
        emit Withdrawal(recipient, amount, block.timestamp);
    }
}
