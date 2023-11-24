// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./helper/Error.sol";

/// @title KeyUniverse1
/// @dev Keys are non-transferable semi-fungible tokens.
contract KeyUniverse1 is ERC1155URIStorage, Ownable, AccessControl, Error {
    /* ============ Variables ============ */

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /* ============ Constructor ============ */

    constructor(
        address defaultAdmin,
        address operator,
        address minter
    ) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(OPERATOR_ROLE, operator);
        _grantRole(MINTER_ROLE, minter);
        transferOwnership(defaultAdmin); // this is for OpenSea's collection admin
        _setBaseURI("ipfs://");
    }

    /* ============ External Functions ============ */

    function mint(address to, uint256 tokenId) public onlyRole(MINTER_ROLE) {
        if (balanceOf(to, tokenId) != 0) {
            revert TokenAlreadyMinted();
        }
        if (bytes(uri(tokenId)).length == 0) {
            revert OnlyExistingToken();
        }
        _mint(to, tokenId, 1, "");
    }

    function mintBatch(
        address to,
        uint256[] memory ids
    ) public onlyRole(MINTER_ROLE) {
        uint256[] memory amounts = new uint256[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            if (balanceOf(to, ids[i]) != 0) {
                revert TokenAlreadyMinted();
            }
            if (bytes(uri(ids[i])).length == 0) {
                revert OnlyExistingToken();
            }
            amounts[i] = 1;
        }
        _mintBatch(to, ids, amounts, "");
    }

    function setURIs(
        uint256[] memory tokenIds,
        string[] memory tokenURIs
    ) public onlyRole(OPERATOR_ROLE) {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setURI(tokenIds[i], tokenURIs[i]);
        }
    }

    /// @dev This function is not implemented.
    function setApprovalForAll(address, bool) public virtual override {
        revert CanNotApprove();
    }

    /// @dev This function is not implemented.
    function safeTransferFrom(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override {
        revert CanNotTransfer();
    }

    /// @dev This function is not implemented.
    function safeBatchTransferFrom(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override {
        revert CanNotTransfer();
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
