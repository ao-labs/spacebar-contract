// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./KeyMinterV1.sol";

/// @title SampleKeyMinterV2
/// @notice This contract is just for testing upgradeability
contract SampleKeyMinterV2 is KeyMinterV1 {
    function _authorizeUpgrade(address) internal override {
        // allow anyone to upgrade
    }

    function _checkNFTOwnership(
        address profileContractAddress,
        uint256 profileTokenId
    ) internal view override {
        // do nothing
    }
}
