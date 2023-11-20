// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISpaceFactoryV1 {
    ///@dev Returns the TBA address of SpaceshipUniverse1
    ///@param tokenId ID of the token
    function getSpaceshipUniverse1TBA(
        uint256 tokenId
    ) external view returns (address);

    /// @notice Mints a whitelist badge (SBT) to the TBA address associated with the user's NFT.
    /// During the whitelist period, a user must own a specific type of badge to mint a Protoship.
    /// @param tokenContract The contract address of the user's NFT.
    /// @param tokenId The token ID of the user's NFT.
    /// @param tokenURI The token URI of the badge.
    function mintWhitelistBadgeUniverse1(
        address tokenContract,
        uint256 tokenId,
        string memory tokenURI
    ) external;
}
