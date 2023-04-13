// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC5484.sol";

/// @title Badge soulbound token.
/// @dev  A soulbound token that can be burned by the issuer or the owner.
/// Token cannot be transferred and its burn authorization is determined by the issuer.
interface IBadgeSBT is IERC5484 {
    /// @notice Mints a new badge
    /// @dev For burn authorization, refer to IERC5484.sol
    /// Only space factory contract can call this function.
    /// @param to The address to mint the badge to
    /// @param category The category of the badge
    /// @param _burnAuth The burn authorization for the badge
    function mintBadge(address to, uint8 category, BurnAuth _burnAuth) external;
}
