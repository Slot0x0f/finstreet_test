// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FinGovToken is ERC20, ERC20Votes, ERC20Permit {
    constructor() ERC20("FinGovToken", "FGT") ERC20Permit("FinGovToken") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    /*
    ==============================
    ====== Parent Functions ======
    ==============================
    */

    function _update(address from, address to, uint256 amount) internal override(ERC20, ERC20Votes) {
        super._update(from, to, amount);
    }

    function nonces(address owner) public view override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);
    }
}
