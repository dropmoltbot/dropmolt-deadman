// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/DeadManSwitch.sol";

contract Deploy is Script {
    function run() external {
        uint256 key = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(key);

        address ben = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        uint256 timeout = 2592000;

        DeadManSwitch dms = new DeadManSwitch(ben, timeout);
        console.log("Deployed:", address(dms));

        vm.stopBroadcast();
    }
}
