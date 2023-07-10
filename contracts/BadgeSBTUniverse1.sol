// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interfaces/IBadgeSBTUniverse1.sol";
import "./interfaces/ISpaceFactoryV1.sol";

/* ============ Errors ============ */
error CanNotTransfer();
error CanNotApprove();
error OnlySpaceFactory();
error InvalidTokenId();

/// @title Badge(Soulbound Token)contract for Spacebar Universe 1
/// @dev Souldbound Tokens(SBT) are non-transferable tokens.
contract BadgeSBTUniverse1 is ERC721, IBadgeSBTUniverse1 {
    /* ============ Variables ============ */

    /// @dev The total supply of tokens
    uint256 public totalSupply;
    address public immutable spaceFactory;
    mapping(uint256 => TokenType) private _tokenTypes;

    /* ============ Events ============ */

    event MintBadge(
        address indexed to,
        uint128 indexed primaryType,
        uint128 indexed secondaryType,
        uint256 tokenId
    );

    /* ============ Constructor ============ */

    constructor(address _spaceFactory) ERC721("Badge SBT Universe1", "BADGE") {
        spaceFactory = _spaceFactory;
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks
    // @TODO might want to implement custom token URI (not by increasing integer)
    /// @inheritdoc IBadgeSBTUniverse1
    function mintBadge(
        address to,
        uint128 primaryType,
        uint128 secondaryType
    ) external {
        if (msg.sender != spaceFactory) {
            revert OnlySpaceFactory();
        }
        _safeMint(to, totalSupply);
        _tokenTypes[totalSupply] = TokenType(primaryType, secondaryType);
        emit MintBadge(to, primaryType, secondaryType, totalSupply);
        unchecked {
            ++totalSupply;
        }
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

    /// @inheritdoc IBadgeSBTUniverse1
    function getTokenType(
        uint256 tokenId
    ) external view override returns (TokenType memory) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return _tokenTypes[tokenId];
    }

    /* ============ Internal Functions ============ */

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
        return "https://www.spacebar.xyz/badge/";
    }
}
