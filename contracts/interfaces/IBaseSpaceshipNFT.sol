// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface IBaseSpaceshipNFT {
    function grantAccess(address user, uint256 tokenId) external;

    function extendAccess(address user, uint256 tokenId) external;

    function burn(uint256 tokenId) external;
}
