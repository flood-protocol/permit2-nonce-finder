// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Permit2NonceFinder} from "src/Permit2NonceFinder.sol";
import {Test, console} from "forge-std/Test.sol";
import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";
import {DeployPermit2} from "permit2/test/utils/DeployPermit2.sol";

contract Permit2NonceFinderTest is Test, DeployPermit2 {
    Permit2NonceFinder internal finder;
    ISignatureTransfer internal permit2;

    function setUp() public {
        permit2 = ISignatureTransfer(deployPermit2());
        finder = new Permit2NonceFinder(address(permit2));
    }

    function test_findNonce() public {
        // We invalidate the first nonce to make sure it's not returned.
        // We pass a mask of 0...0011 to invalidate nonce 0 and 1.
        permit2.invalidateUnorderedNonces(0, 3);
        assertEq(finder.nextNonce(address(this)), 2);

        // Invalidate the first word minus 1 nonce
        permit2.invalidateUnorderedNonces(0, type(uint256).max >> 1);
        // We should find the last nonce in the first word
        assertEq(finder.nextNonce(address(this)), 255);
    }

    function test_findNonceAfter() public {
        // We want to start from the second word
        uint256 start = 256;
        // We invalidate the whole next word to make sure it's not returned.
        permit2.invalidateUnorderedNonces(1, type(uint256).max);
        assertEq(finder.nextNonceAfter(address(this), start), 512);

        // Invalidate the next word minus 1 nonce
        permit2.invalidateUnorderedNonces(2, type(uint256).max >> 1);
        // We should find the first nonce in the third word
        assertEq(finder.nextNonceAfter(address(this), 767), 768);

        // The first word is still accessible if we start from a lower nonce
        assertEq(finder.nextNonceAfter(address(this), 1), 2);
    }
}
