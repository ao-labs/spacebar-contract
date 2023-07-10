// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISpaceFactoryV1 {
    ///@dev Returns the TBA address of SpaceshipNFTUniverse1
    ///@param tokenId ID of the token
    function getSpaceshipNFTUniverse1TBA(
        uint256 tokenId
    ) external view returns (address);
}
