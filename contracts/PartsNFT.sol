// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract PartsNFT is ERC1155Supply, ERC1155Burnable, AccessControl {
    /* ============ Variables ============ */

    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");

    /* ============ Events ============ */

    event PartsConsumed(address indexed from, uint256[] ids, uint256[] amounts);

    /* ============ Errors ============ */

    error NotEnoughBalance(uint256 id, uint256 currentBalance);

    /* ============ Constructor ============ */

    constructor(
        address spaceFactory
    ) ERC1155("https://www.spacebar.xyz/parts/") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
    }

    /* ============ External Functions ============ */

    // Space Factory generates a random part, and the info is encoded within the token id
    // Assumes that "reveal" feature does not exist. If it does, this architecture has to change
    function mintParts(
        address to,
        uint256 id
    ) external onlyRole(SPACE_FACTORY) {
        _mint(to, id, 1, "");
    }

    function batchMintParts(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(SPACE_FACTORY) {
        _mintBatch(to, ids, amounts, "");
    }

    // This is called from Space Factory when creating new ultimate spaceship or updating it
    function consumeParts(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(SPACE_FACTORY) {
        _burnBatch(from, ids, amounts);
        emit PartsConsumed(from, ids, amounts);
    }

    /* ============ View Functions ============ */

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(tokenId), tokenId));
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
