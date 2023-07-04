// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title Spacecship NFT
/// @notice ERC-721 contract for spaceship NFTs. Spaceships are minted by burning parts and a base spaceship.
interface ISpaceshipNFT is IERC721 {
    /// @notice Mints a new spaceship
    /// @dev Only space factory contract can call this function. The factory will burn
    /// spaceship parts and a base spaceship to mint a new spaceship.
    /// @param to Address to mint the spaceship to
    /// @param nickname Nickname of the spaceship
    /// @param parts Parts that are burned during creation
    function mintSpaceship(
        address to,
        bytes32 nickname,
        uint24[] calldata parts
    ) external;

    /// @notice Updates spaceship parts
    /// @dev Only space factory contract can call this function.
    /// @param tokenId Id of the spaceship to update
    /// @param parts Parts to update
    function updateSpaceshipParts(
        uint tokenId,
        uint24[] calldata parts
    ) external;

    /// @notice Updates spaceship nickname
    /// @dev Only space factory contract can call this function.
    /// @param tokenId Id of the spaceship to update
    /// @param nickname Nickname to update
    function updateSpaceshipNickname(uint tokenId, bytes32 nickname) external;

    /// @notice Gets the list of the parts of a spaceship
    /// @param tokenId Id of the spaceship to get the parts of
    function getParts(uint256 tokenId) external view returns (uint24[] memory);

    /// @notice Gets nickname of a spaceship
    /// @param tokenId Id of the spaceship to get the nickname of
    function getNickname(uint256 tokenId) external view returns (bytes32);
}
