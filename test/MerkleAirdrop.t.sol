// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {GovernanceToken} from "../src/GovernanceToken.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {GenerateMerkleScript} from "../script/GenerateMerkle.s.sol";

contract MerkleAirdropTest is Test {
    GovernanceToken public governanceToken;
    MerkleAirdrop public airdrop;
    bytes32 public merkleRoot = 0x87080cbf72f62ad06977c108228f0d216535cbc228e0e88cfc8860e347bccb51;

    function setUp() public {
        // Deploy the GovernanceToken contract
        governanceToken = new GovernanceToken(address(this), address(this));

        // Deploy the MerkleAirdrop contract with the generated Merkle Root
        airdrop = new MerkleAirdrop(address(governanceToken), merkleRoot);
    }

    // function testClaim() public {
    //     // Example account and amount from the airdrop.json
    //     address account = 0x1234567890123456789012345678901234567890;
    //     uint256 amount = 100 * 10 ** 18; // Assuming 18 decimals

    //     // Generate the Merkle proof for the account and amount
    //     bytes32[] memory proof = new bytes32[](2);
    // }
}
