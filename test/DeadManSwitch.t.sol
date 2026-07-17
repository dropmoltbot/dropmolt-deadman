// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/DeadManSwitch.sol";

contract DeadManSwitchTest is Test {
    DeadManSwitch dms;
    address owner = address(0xDEAD);
    address beneficiary = address(0xBEEF);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        dms = new DeadManSwitch(beneficiary, 30 days);
    }

    function test_InitialState() public view {
        assertEq(dms.owner(), owner);
        assertEq(dms.beneficiary(), beneficiary);
        assertEq(dms.timeout(), 30 days);
        assertFalse(dms.canceled());
        assertFalse(dms.claimed());
        assertFalse(dms.isDead());
    }

    function test_CheckIn() public {
        vm.prank(owner);
        dms.checkIn();
        assertEq(dms.lastCheckIn(), block.timestamp);
    }

    function test_FundAndBalance() public {
        vm.prank(owner);
        dms.fund{value: 1 ether}();
        assertEq(dms.balance(), 1 ether);
    }

    function test_TimeRemainingAfter30Days() public {
        vm.prank(owner);
        dms.fund{value: 1 ether}();
        
        // Advance 29 days — still alive
        vm.warp(block.timestamp + 29 days);
        assertFalse(dms.isDead());
        assertGt(dms.timeRemaining(), 0);

        // Advance 1 more day — dead
        vm.warp(block.timestamp + 1 days);
        assertTrue(dms.isDead());
        assertEq(dms.timeRemaining(), 0);
    }

    function test_ClaimWhenDead() public {
        vm.prank(owner);
        dms.fund{value: 5 ether}();
        
        // Advance past timeout
        vm.warp(block.timestamp + 31 days);
        assertTrue(dms.isDead());
        
        uint256 balBefore = beneficiary.balance;
        vm.prank(beneficiary);
        dms.claim();
        
        assertEq(beneficiary.balance, balBefore + 5 ether);
        assertTrue(dms.claimed());
    }

    function test_RevertWhenNotDead() public {
        vm.prank(owner);
        dms.fund{value: 1 ether}();
        
        vm.expectRevert("Owner still active");
        vm.prank(beneficiary);
        dms.claim();
    }

    function test_UpdateBeneficiary() public {
        address newBen = address(0xCAFE);
        vm.prank(owner);
        dms.updateBeneficiary(newBen);
        assertEq(dms.beneficiary(), newBen);
    }

    function test_Cancel() public {
        vm.prank(owner);
        dms.fund{value: 2 ether}();
        
        uint256 balBefore = owner.balance;
        vm.prank(owner);
        dms.cancel();
        
        assertEq(owner.balance, balBefore + 2 ether);
        assertTrue(dms.canceled());
    }

    function test_RevertWhenNonOwnerCheckIn() public {
        vm.expectRevert("Not owner");
        vm.prank(beneficiary);
        dms.checkIn();
    }
}
