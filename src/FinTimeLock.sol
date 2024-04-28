// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/governance/TimelockController.sol";
import "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/**
 * @title TimeLock
 * @dev This contract extends the OpenZeppelin TimelockController contract and adds additional functionality for specifying proposers and executors.
 */

contract FinTimeLock is Initializable, TimelockControllerUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin)
        public
        initializer
    {
        __TimelockController_init(minDelay, proposers, executors, admin);
    }
}
