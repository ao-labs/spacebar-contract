// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC4906.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ISpaceshipNFT.sol";

/// @title Spacecship NFT
/// @notice ERC-721 contract for spaceship NFTs. Spaceships are minted by burning parts and a base spaceship.
contract SpaceshipNFT is ERC721, AccessControl, IERC4906, ISpaceshipNFT {
    /* ============ Variables ============ */
    /// @dev The constant for the space factory role
    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");
    /// @dev The total supply of tokens
    uint256 public totalSupply;

    mapping(uint256 => Traits) private _traits;

    /* ============ Structs ============ */

    struct Traits {
        bytes32 nickname;
        uint24[] parts; // MAX: 16777215
    }

    /* ============ Events ============ */

    event MintSpaceship(
        address indexed to,
        uint indexed id,
        uint24[] parts,
        bytes32 nickname
    );

    /// @dev Emitted when spaceship parts are updated.
    /// If parts is a zero array, nickname is updated. If nickname is empty, parts are updated.
    event UpdateSpaceship(uint indexed id, uint24[] parts, bytes32 nickname);

    /* ============ Errors ============ */

    error InvalidParts();

    /* ============ Modifiers ============ */

    modifier onlyValidPartsList(uint24[] calldata parts) {
        if (parts.length == 0) {
            revert InvalidParts();
        }
        for (uint i = 1; i < parts.length; ) {
            // parts type (the first two decimal) should be in ascending order
            if (parts[i] / 1000000 <= parts[i - 1] / 1000000) {
                revert InvalidParts();
            }
            unchecked {
                ++i;
            }
        }
        _;
    }

    /* ============ Constructor ============ */

    constructor(address spaceFactory) ERC721("Spaceship NFT", "SPACESHIP") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
    }

    /* ============ External Functions ============ */

    /// @inheritdoc ISpaceshipNFT
    function mintSpaceship(
        address to,
        bytes32 nickname,
        uint24[] calldata parts
    ) external onlyRole(SPACE_FACTORY) onlyValidPartsList(parts) {
        _safeMint(to, totalSupply);
        _traits[totalSupply].parts = parts;
        _traits[totalSupply].nickname = nickname;
        emit MintSpaceship(to, totalSupply, parts, nickname);
        unchecked {
            ++totalSupply;
        }
    }

    /// @inheritdoc ISpaceshipNFT
    function updateSpaceshipParts(
        uint tokenId,
        uint24[] calldata parts
    ) external onlyRole(SPACE_FACTORY) onlyValidPartsList(parts) {
        _traits[tokenId].parts = parts;
        emit UpdateSpaceship(tokenId, parts, "");
        emit MetadataUpdate(tokenId);
    }

    /// @inheritdoc ISpaceshipNFT
    function updateSpaceshipNickname(
        uint tokenId,
        bytes32 nickname
    ) external onlyRole(SPACE_FACTORY) {
        _traits[tokenId].nickname = nickname;
        emit UpdateSpaceship(tokenId, new uint24[](0), nickname);
        emit MetadataUpdate(tokenId);
    }

    /// @dev Burn a spaceship NFT. only owner can burn
    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "only owner can burn");
        _burn(tokenId);
        unchecked {
            --totalSupply;
        }
    }

    /* ============ View Functions ============ */

    /// @inheritdoc ISpaceshipNFT
    function getParts(uint256 tokenId) external view returns (uint24[] memory) {
        return (_traits[tokenId].parts);
    }

    /// @inheritdoc ISpaceshipNFT
    function getNickname(uint256 tokenId) external view returns (bytes32) {
        return (_traits[tokenId].nickname);
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl, IERC165) returns (bool) {
        return
            interfaceId == bytes4(0x49064906) || //IERC4906
            super.supportsInterface(interfaceId);
    }

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "https://www.spacebar.xyz/spaceship/";
    }
}
