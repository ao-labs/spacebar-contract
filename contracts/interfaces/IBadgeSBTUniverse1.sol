// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title Badge(Soulbound Token) contract interface for Spacebar Universe 1
/// @dev Souldbound Tokens(SBT) are non-transferable tokens.
interface IBadgeSBTUniverse1 {
    struct TokenType {
        uint128 primaryType;
        uint128 secondaryType;
    }

    /// @notice Mints a new badge
    /// @param to The address to mint the badge to
    /// @param primaryType The primary type of the badge
    /// @param secondaryType The secondary type of the badge
    function mintBadge(
        address to,
        uint128 primaryType,
        uint128 secondaryType
    ) external;

    ///@dev Returns the type of the badge (primary type, secondary type)
    ///@param tokenId The ID of the token
    function getTokenType(uint256 tokenId) external returns (TokenType memory);
}
