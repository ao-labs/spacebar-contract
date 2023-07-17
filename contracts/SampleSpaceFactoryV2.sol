// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./SpaceFactoryV1.sol";

/// @title SpaceFactoryV2
/// @notice This contract is just for testing purposes
contract SpaceFactoryV2 is SpaceFactoryV1 {
    uint256 public test;

    function mintProtoShipUniverse1(
        address tokenContract,
        uint256 tokenId
    ) external override returns (address) {
        test = tokenId;
        return tokenContract;
    }
}
