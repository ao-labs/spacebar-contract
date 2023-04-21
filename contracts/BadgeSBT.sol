// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IBadgeSBT.sol";

/// @title Badge soulbound token.
/// @dev  A soulbound token that can be burned by the issuer or the owner.
/// Token cannot be transferred and its burn authorization is determined by the issuer.
contract BadgeSBT is ERC721, AccessControl, IBadgeSBT {
    /* ============ Variables ============ */

    /// @dev The constant for the space factory role
    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");
    /// @dev The constant for the burner role (issuer)
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    /// @dev The total supply of tokens
    uint256 public totalSupply;

    mapping(uint256 => TokenType) private _tokenTypes;

    /* ============ Structs ============ */

    struct TokenType {
        uint8 category;
        BurnAuth burnAuth;
    }

    /* ============ Events ============ */

    event MintBadge(
        address indexed to,
        uint8 indexed category,
        uint256 indexed tokenId,
        BurnAuth burnAuth
    );

    /* ============ Errors ============ */

    error CanNotTransfer();
    error CanNotBurn(address burner, BurnAuth burnAuth, uint256 tokenId);

    /* ============ Constructor ============ */

    constructor(
        address spaceFactory,
        address burner
    ) ERC721("Badge SBT", "BADGE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
        _grantRole(BURNER_ROLE, burner);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks
    // @TODO might want to implement custom token URI (not by increasing integer)
    /// @inheritdoc IBadgeSBT
    function mintBadge(
        address to,
        uint8 category,
        BurnAuth _burnAuth
    ) external onlyRole(SPACE_FACTORY) {
        _safeMint(to, totalSupply);
        _tokenTypes[totalSupply] = TokenType(category, _burnAuth);
        emit MintBadge(to, category, totalSupply, _burnAuth);
        emit Issued(msg.sender, to, totalSupply, _burnAuth);
        unchecked {
            ++totalSupply;
        }
    }

    /// @notice Burns a badge
    /// @dev Burner account(issuer), owner, or both can burn depending on the burn authorization.
    /// @param tokenId The ID of the token to burn
    function burn(uint256 tokenId) external {
        BurnAuth auth = _tokenTypes[tokenId].burnAuth;
        if (auth == BurnAuth.IssuerOnly && !hasRole(BURNER_ROLE, msg.sender)) {
            revert CanNotBurn(msg.sender, auth, tokenId);
        }
        if (auth == BurnAuth.OwnerOnly && msg.sender != ownerOf(tokenId)) {
            revert CanNotBurn(msg.sender, auth, tokenId);
        }
        if (auth == BurnAuth.Both) {
            if (
                msg.sender != ownerOf(tokenId) &&
                !hasRole(BURNER_ROLE, msg.sender)
            ) {
                revert CanNotBurn(msg.sender, auth, tokenId);
            }
        }
        if (auth == BurnAuth.Neither) {
            revert CanNotBurn(msg.sender, auth, tokenId);
        }

        _burn(tokenId);
    }

    /* ============ View Functions ============ */

    ///@dev Returns the category of the token
    ///@param tokenId The ID of the token
    function getCategory(uint256 tokenId) external view returns (uint8) {
        require(_exists(tokenId), "ERC721: invalid token ID");
        return _tokenTypes[tokenId].category;
    }

    ///@dev Returns the burn authorization of the token
    ///@param tokenId The ID of the token
    function burnAuth(uint256 tokenId) external view returns (BurnAuth) {
        require(_exists(tokenId), "ERC721: invalid token ID");
        return _tokenTypes[tokenId].burnAuth;
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC5484).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

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
