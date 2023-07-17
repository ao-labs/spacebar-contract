// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISpaceFactoryV1 {
    ///@dev Returns the TBA address of SpaceshipUniverse1
    ///@param tokenId ID of the token
    function getSpaceshipUniverse1TBA(
        uint256 tokenId
    ) external view returns (address);
}
