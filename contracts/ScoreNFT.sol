// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IScoreNFT.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO add natspec comments
contract ScoreNFT is ERC721, AccessControl, IScoreNFT {
    /* ============ Variables ============ */

    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");
    uint256 public totalSupply;

    mapping(uint256 => Score) private _scores;

    /* ============ Structs ============ */

    struct Score {
        uint8 category;
        uint88 score; // MAX SCORE = 309,485,009,821,345,068,724,781,055
        address player;
    }

    /* ============ Events ============ */

    event MintScore(
        uint8 indexed category,
        uint88 score,
        address indexed player,
        uint256 indexed tokenId
    );

    /* ============ Constructor ============ */

    constructor(address spaceFactory) ERC721("Score NFT", "SCORE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks

    // @TODO this might has to go to Sp
    // @TODO might want to implement custom token URI (not by increasing integer)
    function mintScore(
        address to,
        uint8 category,
        uint88 score
    ) external onlyRole(SPACE_FACTORY) {
        _safeMint(to, totalSupply);
        _scores[totalSupply] = Score(category, score, to);
        emit MintScore(category, score, to, totalSupply);
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
