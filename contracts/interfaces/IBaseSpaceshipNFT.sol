// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;
import "./IERC4907.sol";

/// @title Base spaceship NFT.
/// @notice The owner of the tokens is space factory contract.
/// Space factory will rent this NFT to users, and will burn base spaceship and parts to mint a new spaceship.
/// User has to frequently extend the rent time to keep the spaceship. This logic is in SpaceFactory.sol.
/// @dev During construction, maximum amount of tokens are minted to the space factory contract.
interface IBaseSpaceshipNFT is IERC4907 {
    /// @notice Burns a base spaceship NFT.
    /// @dev Space factory contract can call this function.
    /// @param tokenId The id of the NFT
    function burn(uint256 tokenId) external;
}
