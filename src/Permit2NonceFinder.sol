// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

contract Permit2NonceFinder {
    ISignatureTransfer public immutable permit2;

    constructor(address _permit2) {
        permit2 = ISignatureTransfer(_permit2);
    }

    function nextNonce(address _owner) external view returns (uint256 nonce) {
        nonce = _nextNonce(_owner, 0, 0);
    }

    function nextNonce(address owner, uint256 start) external view returns (uint256 nonce) {
        nonce = _nextNonce(owner, uint248(start >> 8), uint8(start));
    }

    function _nextNonce(address owner, uint248 word, uint8 pos) internal view returns (uint256 nonce) {
        while (true) {
            uint256 bitmap = permit2.nonceBitmap(owner, word);

            // Check if the bitmap is completely full
            if (bitmap == type(uint256).max) {
                // If so, move to the next word
                word++;
                continue;
            }
            // Find the first zero bit in the bitmap
            while (bitmap & 1 == 1) {
                bitmap = bitmap >> 1;
                pos++;
            }

            return _nonceFromWordAndPos(word, pos);
        }
    }

    function _nonceFromWordAndPos(uint248 word, uint8 pos) internal pure returns (uint256 nonce) {
        // The last 248 bits of the word are the nonce bits
        nonce = uint256(word) << 8;
        // The first 8 bits of the word are the position inside the word
        nonce |= pos;
    }
}
