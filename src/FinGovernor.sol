// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract FinGovernor is
    Initializable,
    GovernorUpgradeable,
    GovernorSettingsUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorStorageUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorTimelockControlUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    address govtoken;
    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor() {
        _disableInitializers();
    }

    /// @notice This is the iniatizer function for the governor
    /// @param _token This is the ERC20votes governance token
    /// @param _timelock This is the timelock controller for the governance contract
    /// @param initialOwner The initial owner of the contract
    function initialize(IVotes _token, TimelockControllerUpgradeable _timelock, address initialOwner)
        public
        initializer
    {
        __Governor_init("FinGovernor");
        __GovernorSettings_init(1,50400, 0); // 1 block voting delay, 1 week voting peiord
        __GovernorCountingSimple_init();
        __GovernorStorage_init();
        __GovernorVotes_init(_token);
        __GovernorVotesQuorumFraction_init(4); // % quorum required
        __GovernorTimelockControl_init(_timelock);
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        govtoken = address(_token);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /*
    ==============================
    ====== Parent Functions ======
    ==============================
    */

    function votingDelay() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingPeriod();
    }

    /// @param blockNumber This is to check quorom for a given block number
    /// @return A uint256 for the quorum
    function quorum(uint256 blockNumber)
        public
        view
        override(GovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    /// @param proposalId This the ID of a proposal in governance
    /// @return Returns the current state a proposal is at
    function state(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    /// @param proposalId This the ID of a proposal in governance
    /// @return Returns a bool about of the proposal needs to be queued
    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function proposalThreshold()
        public
        view
        override(GovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    /// @param targets The target contracts to call
    /// @param values The gas/eth value sent with each call
    /// @param calldatas The call data used to call an address with function selector and params
    /// @param description The description of the proposal
    /// @param proposer The address of the proper
    function _propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description,
        address proposer
    ) internal override(GovernorUpgradeable, GovernorStorageUpgradeable) returns (uint256) {
        return super._propose(targets, values, calldatas, description, proposer);
    }

    /// @param proposalId The Id of a proposal
    /// @param targets The target contracts to call
    /// @param values The gas/eth value sent with each call
    /// @param calldatas The call data used to call an address with function selector and params
    /// @param descriptionHash The hash of the description of the proposal
    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint48) {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @param proposalId The Id of a proposal
    /// @param targets The target contracts to call
    /// @param values The gas/eth value sent with each call
    /// @param calldatas The call data used to call an address with function selector and params
    /// @param descriptionHash The hash of the description of the proposal
    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) {
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    /// @param targets The target contracts to call
    /// @param values The gas/eth value sent with each call
    /// @param calldatas The call data used to call an address with function selector and params
    /// @param descriptionHash The hash of the description of the proposal
    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(GovernorUpgradeable, GovernorTimelockControlUpgradeable) returns (uint256) {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return super._executor();
    }

    /// @param proposalId The Id of a proposal
    /// @param account The account of the voter
    /// @param support The vote (0,1,2)
    /// @param reason The voters reason for voting
    function _castVote(uint256 proposalId, address account, uint8 support, string memory reason)
        internal
        override(GovernorUpgradeable)
        returns (uint256)
    {
        bytes memory data = abi.encodeWithSignature("mint(address,uint256)", msg.sender, 1);
        (bool success,) = govtoken.call(data);
        require(success, "Mint function call failed");
        return super._castVote(proposalId, account, support, reason);
    }
}
