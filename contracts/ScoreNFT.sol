// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO add natspec comments
contract ScoreNFT is ERC721, AccessControl {
    /* ============ Variables ============ */

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    uint256 public totalSupply;

    mapping(uint256 => Score) private tokenId2Score;
    bytes32[255] public categories; // SINGLE, MULTI, etc

    /* ============ Structs ============ */

    struct Score {
        uint8 categoryIndex;
        uint88 score; // MAX SCORE = 309,485,009,821,345,068,724,781,055
        address player;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /* ============ Events ============ */
    event CategoriesUpdated(bytes32[] categories);
    event ScoreMinted(
        uint8 indexed categoryIndex,
        uint88 indexed score,
        address indexed player
    );

    /* ============ Errors ============ */

    error AlreadyHaveAccess(address user, uint256 tokenId);
    error AlreadyClaimedToken(uint256 tokenId);
    error NotWithinExtensionPeriod(address user, uint256 tokenId);
    error InvalidSignature();

    /* ============ Constructor ============ */

    constructor(address signer, bytes32[] memory newCategories)
        ERC721("Untitled Spaceship", "US")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, signer);
        for (uint256 i = 0; i < newCategories.length; ) {
            categories[i] = newCategories[i];
            unchecked {
                ++i;
            }
        }
        emit CategoriesUpdated(newCategories);
    }

    /* ============ External Functions ============ */

    // @TODO might want to implement custom token URI (not by increasing integer)
    function mintScore(
        uint8 categoryIndex,
        uint88 score,
        Signature calldata signature
    ) external {
        // @TODO format of digest may change in the future
        bytes32 digest = keccak256(
            abi.encode("mintScore", score, msg.sender, address(this))
        );
        _checkSignature(digest, signature);
        _mint(msg.sender, totalSupply);
        tokenId2Score[totalSupply] = Score(categoryIndex, score, msg.sender);
        unchecked {
            ++totalSupply;
        }
        emit ScoreMinted(categoryIndex, score, msg.sender);
    }

    function updateCategories(bytes32[] memory newCategories)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        for (uint256 i = 0; i < newCategories.length; ) {
            categories[i] = newCategories[i];
            unchecked {
                ++i;
            }
        }
        emit CategoriesUpdated(newCategories);
    }

    /* ============ View Functions ============ */

    function getScore(uint256 tokenId)
        public
        view
        returns (
            uint8 categoryIndex,
            uint88 score,
            address player,
            address owner
        )
    {
        return (
            tokenId2Score[tokenId].categoryIndex,
            tokenId2Score[tokenId].score,
            tokenId2Score[tokenId].player,
            ownerOf(tokenId)
        );
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /* ============ Internal Functions ============ */

    function _checkSignature(bytes32 digest, Signature calldata signature)
        internal
        view
    {
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

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "https://www.spacebar.xyz/score/";
    }
    //     Metadata Example
    // {
    // 	"name": "Score : #100060",
    // 	"image": "https://resource.spacebar.xyz/score/100060",
    // 	"description": "Spacebar game score.",
    // 	"external_url": "https://www.spacebar.xyz/score/100060",
    // 	"attributes": [
    // 		{ "trait_type": "Category", "value": "Multi Play" },
    // 		{ "trait_type": "Score", "value": "324" },
    // 		{ "trait_type": "Player Address", "value": "0x..." },
    // 		{ "trait_type": "Player Name", "value": "pluto777" },
    // 		{ "trait_type": "Spaceship", "value": "#1232" },
    // 		{ "trait_type": "PFP Address", "value": "0x..." },
    // 		{ "trait_type": "PFP Token Id", "value": "1223" },
    // 		{ "trait_type": "PFP Chaind Id", "value": "1001" },
    // 		{ "trait_type": "Timestamp", "value": "1678239866" },
    // 		{ "trait_type": "Replay Data??", "value": "???" },
    // 		{ "trait_type": "Opponent PFP??", "value": "??" }
    // 	]
    // }
}
