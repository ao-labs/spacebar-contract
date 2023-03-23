// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface IPartsNFT {
    function mintParts(address to, uint256 id) external;

    function batchMintParts(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;

    function burnParts(address from, uint256 id, uint256 amount) external;

    function batchBurnParts(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}
