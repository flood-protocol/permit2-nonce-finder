// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Permit2NonceFinder} from "src/Permit2NonceFinder.sol";

contract DeployScript is Script {
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    bytes32 internal salt = bytes32(uint256(0xf100d));

    function setUp() public {}

    function run() public {
        vm.broadcast();
        Permit2NonceFinder deployed = new Permit2NonceFinder{salt: salt}(PERMIT2);
        console.log("Deployed Permit2NonceFinder at", address(deployed));
    }
}
