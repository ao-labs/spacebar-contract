// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

/// @title Score NFT
/// @notice ERC-721 contract for recording user scores. Users can mint their scores as NFTs.
interface IScoreNFT {
    /// @notice Mints a new score NFT
    /// @dev Only space factory contract can call this function.
    /// @param to The address to mint the score NFT to. This is the user who played the game.
    /// @param category The category of the score (ex. Singleplayer, Multiplayer, etc.)
    /// @param score User's score
    function mintScore(address to, uint8 category, uint88 score) external;
}
