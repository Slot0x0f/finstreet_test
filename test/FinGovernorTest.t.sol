// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {FinGovernor} from "../src/FinGovernor.sol";
import {FinGovToken} from "../src/FinGovToken.sol";
import {FinTimeLock} from "../src/FinTimeLock.sol";
import {Box} from "../src/Box.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract FinGovernorTest is Test {
    
    FinGovToken token;
    FinTimeLock timelock;
    FinGovernor governor;
    Box box;

    uint256 public constant MIN_DELAY = 3600; // 1 hour - after a vote passes, you have 1 hour before you can enact
    uint256 public constant QUORUM_PERCENTAGE = 4; // Need 4% of voters to pass
    uint256 public constant VOTING_PERIOD = 50400; // This is how long voting lasts
    uint256 public constant VOTING_DELAY = 1; // How many blocks till a proposal vote becomes active

    address[] proposers;
    address[] executors;

    bytes[] functionCalls;
    address[] addressesToCall;
    uint256[] values;

    address public constant VOTER = address(1);
    address public constant INITIAL_OWNER = address(2);

    function setUp() public {

        token = new FinGovToken();
        token.mint(VOTER, 100e18);

        vm.prank(VOTER);
        token.delegate(VOTER);

        //timelock = new TimeLock(MIN_DELAY, proposers, executors);

        address payable proxyTimelock = payable (Upgrades.deployUUPSProxy(
        "FinTimeLock.sol",
        abi.encodeCall(FinTimeLock.initialize, (MIN_DELAY, proposers, executors, address(this)))
        ));

        timelock = FinTimeLock(proxyTimelock);
    
        address payable proxy = payable (Upgrades.deployUUPSProxy(
        "FinGovernor.sol",
        abi.encodeCall(FinGovernor.initialize, (token,timelock,INITIAL_OWNER))
        ));

        governor = FinGovernor(proxy);

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        //bytes32 adminRole = timelock.TIMELOCK_ADMIN_ROLE();

        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        //timelock.revokeRole(adminRole, msg.sender);

        box = new Box();
        box.transferOwnership(address(timelock));
    }

    function testGovernanceUpdatesBox(uint256 value) public {
        uint256 valueToStore = value;
        string memory description = "Store 1 in Box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);
        addressesToCall.push(address(box));
        values.push(0);
        functionCalls.push(encodedFunctionCall);

        // 1. Propose to the DAO
        uint256 proposalId = governor.propose(addressesToCall, values, functionCalls, description);

        console.log("Proposal ID is:", proposalId);
        console.log("Proposal State:", uint256(governor.state(proposalId)));
        governor.proposalSnapshot(proposalId);
        governor.proposalDeadline(proposalId);

        vm.warp(block.timestamp + VOTING_DELAY + 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 2. Vote
        string memory reason = "I like the number";
        // 0 = Against, 1 = For, 2 = Abstain for this example
        uint8 voteWay = 1;


        vm.prank(VOTER);
        governor.castVoteWithReason(proposalId, voteWay, reason);

        vm.warp(block.timestamp + VOTING_PERIOD + 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        // 3. Queue
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(addressesToCall, values, functionCalls, descriptionHash);
        vm.roll(block.number + MIN_DELAY + 1);
        vm.warp(block.timestamp + MIN_DELAY + 1);

        // 4. Execute
        governor.execute(addressesToCall, values, functionCalls, descriptionHash);

        assert(box.getNumber() == valueToStore);
    }


    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }
}