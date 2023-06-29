// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

/// @title Parts NFT
/// @notice ERC-1155 contract for spaceship parts. Parts are burned along with base spaceship to mint a new spaceship.
/// Parts can be also burned to update existing spaceship.
interface IPartsNFT {
    /// @notice Mints a new part.
    /// @dev Only space factory contract can call this function.
    /// @param to The user address to mint the part to
    /// @param id The id of the part (id contains the type and the design of the part)
    function mintParts(address to, uint256 id) external;

    /// @notice Mints new parts.
    /// @dev Only space factory contract can call this function.
    /// @param to The user address to mint the parts to
    /// @param ids The ids of the parts (id contains the type and the design of the part)
    /// @param amounts The amounts of the parts
    function batchMintParts(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;

    /// @notice Burns a part.
    /// @dev Only space factory contract can call this function to create or update a spaceship.
    /// @param from The user address to burn the part from
    /// @param id The id of the part
    /// @param amount The amount of the part (should be 1)
    function burnParts(address from, uint256 id, uint256 amount) external;

    /// @notice Burns several parts at the same time.
    /// @dev Only space factory contract can call this function to create or update a spaceship.
    /// @param from The user address to burn the parts from
    /// @param ids The ids of the parts
    /// @param amounts The amounts of the parts (should be an array of 1s)
    function batchBurnParts(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}
