// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FinGovToken is ERC20, ERC20Votes, ERC20Permit, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address admin) ERC20("FinGovToken", "FGT") ERC20Permit("FinGovToken") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    /*
    ==============================
    ====== Public Functions ======
    ==============================
    */

    /// @param to This address to mint the token to
    /// @param amount The ammount to mint
    function mint(address to, uint256 amount) public {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _mint(to, amount);
    }

    /// @param to This address to give the role to
    function giveMinterRoleTo(address to) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not a admin");
        _grantRole(MINTER_ROLE, to);
    }

    /*
    ==============================
    ====== Parent Functions ======
    ==============================
    */

    /// @notice This is used to update balances
    /// @param from The address the balance change is coming from
    /// @param to This address the balance change is going too
    /// @param amount The amount changed
    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    /// @param owner This is an address given to the Nonces contract to keep track of the nonce of the given address
    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
