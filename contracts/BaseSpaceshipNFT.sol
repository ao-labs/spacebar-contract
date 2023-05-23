// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Consecutive.sol";
import "./interfaces/IBaseSpaceshipNFT.sol";

/// @title Base spaceship NFT.
/// @notice The owner of the tokens is space factory contract.
/// Space factory will rent this NFT to users, and will burn base spaceship and parts to mint a new spaceship.
/// User has to frequently extend the rent time to keep the spaceship. This logic is in SpaceFactory.sol.
/// @dev During construction, maximum amount of tokens are minted to the space factory contract.
contract BaseSpaceshipNFT is ERC721Consecutive, IBaseSpaceshipNFT {
    /* ============ Variables ============ */

    /// @dev The current supply of tokens
    uint public totalSupply;
    /// @dev The maximum supply of tokens. They are minted during construction.
    uint16 public constant MAXIMUM_SUPPLY = 1000;

    mapping(uint256 => UserInfo) private _users;

    /* ============ Structs ============ */

    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    /* ============ Constructor ============ */

    constructor(address spaceFactory) ERC721("Base Spaceship", "BASE") {
        _mintConsecutive(spaceFactory, MAXIMUM_SUPPLY);
        totalSupply = MAXIMUM_SUPPLY;
        //Without this event, Alchemy/Infura does not detect tokens
        for (uint i = 0; i < totalSupply; i++) {
            emit Transfer(address(0), spaceFactory, i);
        }
    }

    /* ============ External Functions ============ */

    /// @inheritdoc IERC4907
    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC4907: transfer caller is not owner nor approved"
        );
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @inheritdoc IBaseSpaceshipNFT
    function burn(uint256 tokenId) external {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: caller is not token owner or approved"
        );
        unchecked {
            --totalSupply;
        }
        _burn(tokenId);
    }

    /* ============ View Functions ============ */

    /// @inheritdoc IERC4907
    function userOf(uint256 tokenId) public view virtual returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    /// @inheritdoc IERC4907
    function userExpires(
        uint256 tokenId
    ) public view virtual returns (uint256) {
        return _users[tokenId].expires;
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721) returns (bool) {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "https://www.spacebar.xyz/base/";
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);

        if (from != to && _users[tokenId].user != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }
}
