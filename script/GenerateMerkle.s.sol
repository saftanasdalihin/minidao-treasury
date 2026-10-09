// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Script, console} from "forge-std/Script.sol";
import {Hashes} from "@openzeppelin/contracts/utils/cryptography/Hashes.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract GenerateMerkleScript is Script {
    struct AirdropEntry {
        address account;
        uint256 amount;
    }

    function run() external view {
        // 1. read data JSON from airdrop.json file
        string memory rootPath = vm.projectRoot();
        string memory path = string.concat(rootPath, "/script/data/airdrop.json");
        string memory json = vm.readFile(path);

        // 2. Parse data JSON into AirdropEntry array
        bytes memory rawEntries = vm.parseJson(json);
        AirdropEntry[] memory entries = abi.decode(rawEntries, (AirdropEntry[]));

        console.log("The number of airdrop recipients:", entries.length);

        // 3. Generate leaves for Merkle Tree
        bytes32[] memory leaves = new bytes32[](entries.length);
        for (uint256 i = 0; i < entries.length; i++) {
            leaves[i] = getLeaf(entries[i].account, entries[i].amount);
        }

        // 4. Generate Merkle Root from leaves
        bytes32 root = generateMerkleRoot(leaves);

        console.log("--------------------------------------------------");
        console.log("RESULT OF MERKLE ROOT (Save this for contract!):"); // Display the Merkle Root
        console.logBytes32(root);
        console.log("--------------------------------------------------");

        // 5. Generate proof for User 0 (first entry) and display it
        bytes32[] memory proofUser0 = getProofForIndex(leaves, 0);
        console.log("Proof for User 0 (", entries[0].account, "):");
        for (uint256 p = 0; p < proofUser0.length; p++) {
            console.logBytes32(proofUser0[p]);
        }

        // 6. Verify proof for User 0
        bool isValid = MerkleProof.verify(proofUser0, root, leaves[0]);
        console.log("is the proof valid?", isValid ? "VALID!" : "INVALID!");
    }

    // function to generate leaf from account and amount
    function getLeaf(address account, uint256 amount) public pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
    }

    // function to generate Merkle Root from leaves
    function generateMerkleRoot(bytes32[] memory leaves) internal pure returns (bytes32) {
        bytes32[] memory currentLayer = leaves;

        while (currentLayer.length > 1) {
            bytes32[] memory nextLayer = new bytes32[]((currentLayer.length + 1) / 2);
            for (uint256 i = 0; i < currentLayer.length; i += 2) {
                if (i + 1 < currentLayer.length) {
                    // merge two leaves into one using commutative keccak256
                    nextLayer[i / 2] = Hashes.commutativeKeccak256(currentLayer[i], currentLayer[i + 1]);
                } else {
                    nextLayer[i / 2] = currentLayer[i];
                }
            }
            currentLayer = nextLayer;
        }

        return currentLayer[0];
    }

    // function to generate proof for a specific index in the leaves
    function getProofForIndex(bytes32[] memory leaves, uint256 index) internal pure returns (bytes32[] memory) {
        bytes32[] memory proof = new bytes32[](2);

        // sibling index is the index of the sibling node in the leaves array
        uint256 siblingIndex = index % 2 == 0 ? index + 1 : index - 1;
        proof[0] = leaves[siblingIndex];

        // sibling index for the next layer (the parent of the current node)
        bytes32 branch0 = Hashes.commutativeKeccak256(leaves[0], leaves[1]);
        bytes32 branch1 = Hashes.commutativeKeccak256(leaves[2], leaves[3]);
        proof[1] = index < 2 ? branch1 : branch0;

        return proof;
    }
}
