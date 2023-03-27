// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;
import "./IERC4907.sol";

interface IBaseSpaceshipNFT is IERC4907 {
    function burn(uint256 tokenId) external;
}
