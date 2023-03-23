// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "./IERC5484.sol";

interface IBadgeSBT is IERC5484 {
    function mintBadge(address to, uint8 category, BurnAuth _burnAuth) external;
}
