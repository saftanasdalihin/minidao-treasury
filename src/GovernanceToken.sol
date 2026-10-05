// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.30;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract GovernanceToken is ERC20, ERC20Pausable, AccessControl, ERC20Permit {
    // custom error
    error noMeetMinimumTokens();

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TOKEN_HOLDER_ROLE = keccak256("TOKEN_HOLDER_ROLE");
    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");

    constructor(address recipient, address pauser, address governor)
        ERC20("GovernanceToken", "GTK")
        ERC20Permit("GovernanceToken")
    {
        _mint(recipient, 1000000 * 10 ** decimals());
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(TOKEN_HOLDER_ROLE, recipient);
        _grantRole(GOVERNOR_ROLE, governor);
    }

    function grantTokenHolderRole() public {
        if (balanceOf(msg.sender) < 1000 * 10 ** decimals()) {
            revert noMeetMinimumTokens();
        }
        _grantRole(TOKEN_HOLDER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(GOVERNOR_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(GOVERNOR_ROLE) {
        _burn(from, amount);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }
}
