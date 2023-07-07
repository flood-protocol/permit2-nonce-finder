// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {Permit2NonceFinder} from "src/Permit2NonceFinder.sol";
import {Create2Deploy} from "script/Create2Deploy.sol";

contract DeployScript is Create2Deploy {
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function run() public {
        console.logBytes32(keccak256(bytes.concat(type(Permit2NonceFinder).creationCode, abi.encode(PERMIT2))));
        vm.broadcast();
        SALT = 0x45bddd7a4404868c5a41cb716e01a4006b38bab040000000000000000007cfee;
        address deployed = deploy2(type(Permit2NonceFinder).creationCode, SALT, abi.encode(PERMIT2));
        console.log("Deployed Permit2NonceFinder at", deployed);
    }
}
