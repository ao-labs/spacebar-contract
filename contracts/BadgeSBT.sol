// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC5484.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO add natspec comments
contract BadgeSBT is ERC721, AccessControl, IERC5484 {
    /* ============ Variables ============ */

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    uint256 public totalSupply;

    mapping(uint256 => TokenType) private _tokenTypes;

    /* ============ Structs ============ */

    struct TokenType {
        uint8 category;
        BurnAuth burnAuth;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /* ============ Events ============ */

    event BadgeMinted(
        uint8 indexed category,
        address indexed to,
        uint256 indexed tokenId
    );
    event BadgeMintedByAdmin(
        uint8 indexed category,
        address indexed to,
        uint256 indexed tokenId
    );

    /* ============ Errors ============ */

    error InvalidSignature();
    error CanNotTransfer();
    error CanNotBurn(address burner, BurnAuth burnAuth, uint256 tokenId);

    /* ============ Constructor ============ */

    constructor(address signer, address burner) ERC721("Badge SBT", "BADGE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, signer);
        _grantRole(BURNER_ROLE, burner);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks

    // @TODO might want to implement custom token URI (not by increasing integer)
    function mintBadge(
        uint8 category,
        BurnAuth _burnAuth,
        Signature calldata signature
    ) external {
        // @TODO format of digest may change in the future
        bytes32 digest = keccak256(
            abi.encode(
                "mintBadge",
                category,
                _burnAuth,
                msg.sender,
                address(this)
            )
        );
        _checkSignature(digest, signature);
        _safeMint(msg.sender, totalSupply);
        _tokenTypes[totalSupply] = TokenType(category, _burnAuth);
        emit BadgeMinted(category, msg.sender, totalSupply);
        emit Issued(msg.sender, msg.sender, totalSupply, _burnAuth);
        unchecked {
            ++totalSupply;
        }
    }

    function mintBadgeByAdmin(
        address to,
        uint8 category,
        BurnAuth _burnAuth
    ) external onlyRole(SIGNER_ROLE) {
        _safeMint(to, totalSupply);
        _tokenTypes[totalSupply] = TokenType(category, _burnAuth);
        emit BadgeMintedByAdmin(category, to, totalSupply);
        emit Issued(msg.sender, to, totalSupply, _burnAuth);
        unchecked {
            ++totalSupply;
        }
    }

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
                msg.sender != ownerOf(tokenId) ||
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

    function getCategory(uint256 tokenId) external view returns (uint8) {
        require(_exists(tokenId), "ERC721: invalid token ID");
        return _tokenTypes[tokenId].category;
    }

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

    function _checkSignature(
        bytes32 digest,
        Signature calldata signature
    ) internal view {
        address signer = ecrecover(
            digest,
            signature.v,
            signature.r,
            signature.s
        );
        if (!hasRole(SIGNER_ROLE, signer)) {
            revert InvalidSignature();
        }
    }

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
