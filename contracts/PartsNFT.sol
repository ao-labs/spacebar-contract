// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IPartsNFT.sol";

contract PartsNFT is ERC1155Supply, ERC1155Burnable, AccessControl, IPartsNFT {
    /* ============ Variables ============ */

    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");

    /* ============ Errors ============ */

    error ExceedMaximumTokenId(uint256 id);

    /* ============ Constructor ============ */

    constructor(
        address spaceFactory
    ) ERC1155("https://www.spacebar.xyz/parts/") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks

    // Space Factory generates a random part, and the info is encoded within the token id
    function mintParts(
        address to,
        uint256 id
    ) external onlyRole(SPACE_FACTORY) {
        if (id > type(uint24).max) {
            revert ExceedMaximumTokenId(id);
        }
        _mint(to, id, 1, "");
    }

    function batchMintParts(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(SPACE_FACTORY) {
        for (uint i = 0; i < ids.length; ) {
            if (ids[i] > type(uint24).max) {
                revert ExceedMaximumTokenId(ids[i]);
            }
            unchecked {
                ++i;
            }
        }
        _mintBatch(to, ids, amounts, "");
    }

    // This is called from Space Factory when creating new ultimate spaceship or updating it
    function burnParts(
        address from,
        uint256 id,
        uint256 amount
    ) external onlyRole(SPACE_FACTORY) {
        _burn(from, id, amount);
    }

    function batchBurnParts(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(SPACE_FACTORY) {
        _burnBatch(from, ids, amounts);
    }

    /* ============ View Functions ============ */

    function uri(uint256 tokenId) public view override returns (string memory) {
        return string.concat(super.uri(tokenId), Strings.toString(tokenId));
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
