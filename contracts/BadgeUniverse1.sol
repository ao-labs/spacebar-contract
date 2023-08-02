// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBadgeUniverse1.sol";
import "./interfaces/ISpaceFactoryV1.sol";
import "./helper/Error.sol";

/// @title Badge (Soulbound Token) contract interface for Spacebar Universe 1.
/// @dev Soulbound Tokens (SBT) are non-transferable tokens.
contract BadgeUniverse1 is ERC721URIStorage, IBadgeUniverse1, Ownable, Error {
    /* ============ Variables ============ */

    uint256 public totalSupply;
    address public immutable spaceFactory;
    mapping(uint256 => TokenType) private _tokenTypes;
    mapping(bytes32 => bool) private _isOwnerOfTokenType;

    /* ============ Events ============ */

    event MintBadge(
        address indexed to,
        uint128 indexed primaryType,
        uint128 indexed secondaryType,
        uint256 tokenId,
        string tokenURI
    );

    /* ============ Modifiers ============ */

    modifier onlySpaceFactory() {
        if (msg.sender != spaceFactory) {
            revert OnlySpaceFactory();
        }
        _;
    }

    /* ============ Constructor ============ */

    constructor(
        address _spaceFactory,
        address defaultAdmin
    ) ERC721("Badge Universe1", "BADGE-U1") {
        spaceFactory = _spaceFactory;
        transferOwnership(defaultAdmin); // this is for OpenSea's collection admin
    }

    /* ============ External Functions ============ */

    /// @inheritdoc IBadgeUniverse1
    function mintBadge(
        address to,
        uint128 primaryType,
        uint128 secondaryType,
        string memory tokenURI
    ) public onlySpaceFactory {
        if (bytes(tokenURI).length == 0) {
            revert InvalidTokenURI();
        }
        _mint(to, totalSupply);
        _setTokenURI(totalSupply, tokenURI);
        _tokenTypes[totalSupply] = TokenType(primaryType, secondaryType);
        _isOwnerOfTokenType[
            keccak256(abi.encodePacked(to, primaryType, secondaryType))
        ] = true;
        emit MintBadge(to, primaryType, secondaryType, totalSupply, tokenURI);
        unchecked {
            ++totalSupply;
        }
    }

    function burnBadge(uint256 tokenId) public {
        if (msg.sender != spaceFactory && msg.sender != ownerOf(tokenId)) {
            revert OnlySpaceFactoryOrOwner();
        }
        _burn(tokenId);
    }

    /// @dev This function is not implemented.
    function approve(address, uint256) public virtual override {
        revert CanNotApprove();
    }

    /// @dev This function is not implemented.
    function setApprovalForAll(address, bool) public virtual override {
        revert CanNotApprove();
    }

    /* ============ View Functions ============ */

    /// @inheritdoc IBadgeUniverse1
    function getTokenType(
        uint256 tokenId
    ) external view override returns (TokenType memory) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return _tokenTypes[tokenId];
    }

    /// @inheritdoc IBadgeUniverse1
    function isOwnerOfTokenType(
        address user,
        uint128 primaryType,
        uint128 secondaryType
    ) external view override returns (bool) {
        return
            _isOwnerOfTokenType[
                keccak256(abi.encodePacked(user, primaryType, secondaryType))
            ];
    }

    /* ============ Internal Functions ============ */

    function _setTokenURI(
        uint256 tokenId,
        string memory _tokenURI
    ) internal virtual override {
        super._setTokenURI(tokenId, _tokenURI);
    }

    /// @dev Users cannot transfer SBTs.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId /* firstTokenId */,
        uint256 batchSize
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert CanNotTransfer();
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }
}
