// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ISignatureTransfer} from "permit2/src/interfaces/ISignatureTransfer.sol";

contract Permit2NonceFinder {
    ISignatureTransfer public immutable permit2;

    /// @notice Constructs the Permit2NonceFinder contract
    /// @param _permit2 The address of the Permit2 contract
    constructor(address _permit2) {
        permit2 = ISignatureTransfer(_permit2);
    }

    /// @notice Finds the next valid nonce for a user, starting from 0.
    /// @param owner The owner of the nonces
    /// @return nonce The first valid nonce starting from 0
    function nextNonce(address owner) external view returns (uint256 nonce) {
        nonce = _nextNonce(owner, 0, 0);
    }

    /// @notice Finds the next valid nonce for a user, after from a given nonce.
    /// @dev This can be helpful if you're signing multiple nonces in a row and need the next nonce to sign but the start one is still valid.
    /// @param owner The owner of the nonces
    /// @param start The nonce to start from
    /// @return nonce The first valid nonce after the given nonce
    function nextNonceAfter(address owner, uint256 start) external view returns (uint256 nonce) {
        uint248 word = uint248(start >> 8);
        uint8 pos = uint8(start);
        if (pos == type(uint8).max) {
            // If the position is 255, we need to move to the next word
            word++;
            pos = 0;
        } else {
            // Otherwise, we just move to the next position
            pos++;
        }
        nonce = _nextNonce(owner, word, pos);
    }

    /// @notice Finds the next valid nonce for a user, starting from a given word and position.
    /// @param owner The owner of the nonces
    /// @param word Word to start looking from
    /// @param pos Position inside the word to start looking from
    function _nextNonce(address owner, uint248 word, uint8 pos) internal view returns (uint256 nonce) {
        while (true) {
            uint256 bitmap = permit2.nonceBitmap(owner, word);

            // Check if the bitmap is completely full
            if (bitmap == type(uint256).max) {
                // If so, move to the next word
                ++word;
                pos = 0;
                continue;
            }
            if (pos != 0) {
                // If the position is not 0, we need to shift the bitmap to ignore the bits before position
                bitmap = bitmap >> pos;
            }
            // Find the first zero bit in the bitmap
            while (bitmap & 1 == 1) {
                bitmap = bitmap >> 1;
                ++pos;
            }

            return _nonceFromWordAndPos(word, pos);
        }
    }

    /// @notice Constructs a nonce from a word and a position inside the word
    /// @param word The word containing the nonce
    /// @param pos The position of the nonce inside the word
    /// @return nonce The nonce constructed from the word and position
    function _nonceFromWordAndPos(uint248 word, uint8 pos) internal pure returns (uint256 nonce) {
        // The last 248 bits of the word are the nonce bits
        nonce = uint256(word) << 8;
        // The first 8 bits of the word are the position inside the word
        nonce |= pos;
    }
}
