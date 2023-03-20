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

    mapping(uint256 => Score) private _scores;

    /* ============ Structs ============ */

    struct Score {
        uint8 category;
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
        uint8 indexed category,
        uint88 score,
        address indexed player,
        uint256 indexed tokenId
    );
    event ScoreMintedByAdmin(
        uint8 indexed category,
        uint88 score,
        address indexed player,
        uint256 indexed tokenId
    );

    /* ============ Errors ============ */

    error InvalidSignature();

    /* ============ Constructor ============ */

    constructor(address signer) ERC721("Score NFT", "SCORE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, signer);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks

    // @TODO move this to SPACE FACTORY
    // @TODO might want to implement custom token URI (not by increasing integer)
    function mintScore(
        uint8 category,
        uint88 score,
        Signature calldata signature
    ) external {
        // @TODO format of digest may change in the future
        bytes32 digest = keccak256(
            abi.encode("mintScore", score, msg.sender, address(this))
        );
        _checkSignature(digest, signature);
        _safeMint(msg.sender, totalSupply);
        _scores[totalSupply] = Score(category, score, msg.sender);
        emit ScoreMinted(category, score, msg.sender, totalSupply);
        unchecked {
            ++totalSupply;
        }
    }

    function mintScoreByAdmin(
        address to,
        uint8 category,
        uint88 score
    ) external onlyRole(SIGNER_ROLE) {
        _safeMint(to, totalSupply);
        _scores[totalSupply] = Score(category, score, to);
        emit ScoreMintedByAdmin(category, score, to, totalSupply);
        unchecked {
            ++totalSupply;
        }
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "only owner can burn");
        _burn(tokenId);
    }

    /* ============ View Functions ============ */

    function getScore(
        uint256 tokenId
    )
        public
        view
        returns (uint8 category, uint88 score, address player, address owner)
    {
        return (
            _scores[tokenId].category,
            _scores[tokenId].score,
            _scores[tokenId].player,
            ownerOf(tokenId)
        );
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
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
