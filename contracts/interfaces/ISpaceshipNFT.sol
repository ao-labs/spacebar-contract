// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ISpaceshipNFT is IERC721 {
    function mintSpaceship(
        address to,
        bytes32 nickname,
        uint24[] calldata parts
    ) external;

    function updateSpaceshipParts(
        uint tokenId,
        uint24[] calldata parts
    ) external;

    function updateSpaceshipNickname(uint tokenId, bytes32 nickname) external;

    function getParts(uint256 tokenId) external view returns (uint24[] memory);
}
