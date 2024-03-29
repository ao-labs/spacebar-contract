// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title Badge (Soulbound Token) contract interface for Spacebar Universe 1.
/// @dev Soulbound Tokens (SBT) are non-transferable tokens.
interface IBadgeUniverse1 {
    struct TokenType {
        uint128 primaryType;
        uint128 secondaryType;
    }

    /// @notice Mints a new badge.
    /// @param to The address to which the badge will be minted.
    /// @param primaryType The primary type of the badge.
    /// @param secondaryType The secondary type of the badge.
    function mintBadge(
        address to,
        uint128 primaryType,
        uint128 secondaryType,
        string memory tokenURI
    ) external;

    /// @dev Returns the type of the badge (primary type, secondary type).
    /// @param tokenId The ID of the token.
    function getTokenType(uint256 tokenId) external returns (TokenType memory);

    /// @dev Determines whether the user owns a specific token type.
    /// @param user The user's address.
    /// @param primaryType The primary type of the token.
    /// @param secondaryType The secondary type of the token.
    function isOwnerOfTokenType(
        address user,
        uint128 primaryType,
        uint128 secondaryType
    ) external returns (bool);

    /// @dev Returns the balance of a specific token type that user has.
    /// @param user The user's address.
    /// @param primaryType The primary type of the token.
    /// @param secondaryType The secondary type of the token.
    function balanceOfTokenType(
        address user,
        uint128 primaryType,
        uint128 secondaryType
    ) external view returns (uint256);
}
