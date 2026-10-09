// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    IERC20 public immutable TOKEN;
    bytes32 public immutable MERKLE_ROOT;

    // prevent double claim by tracking claimed addresses
    mapping(address => bool) public hasClaimed;

    // Custom Errors
    error AlreadyClaimed();
    error InvalidProof();
    error TransferFailed();

    event Claimed(address indexed account, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot) {
        TOKEN = IERC20(_token);
        MERKLE_ROOT = _merkleRoot;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (hasClaimed[account]) revert AlreadyClaimed();

        // 1. create leaf node from account and amount
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

        // 2. verify the merkle proof against the stored merkle root
        if (!MerkleProof.verify(merkleProof, MERKLE_ROOT, leaf)) {
            revert InvalidProof();
        }

        // 3. mark the account as claimed to prevent double claiming
        hasClaimed[account] = true;

        // 4. Transfer token to member
        bool success = TOKEN.transfer(account, amount);
        if (!success) revert TransferFailed();

        emit Claimed(account, amount);
    }
}
