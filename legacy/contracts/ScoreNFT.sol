// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IScoreNFT.sol";

/// @title Score NFT
/// @notice ERC-721 contract for recording user scores. Users can mint their scores as NFTs.
contract ScoreNFT is ERC721, ERC721Burnable, AccessControl, IScoreNFT {
    /* ============ Variables ============ */

    /// @dev The constant for the space factory role
    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");
    /// @dev The total number of score NFTs existing
    uint256 public totalSupply;

    mapping(uint256 => Score) private _scores;

    /* ============ Structs ============ */

    struct Score {
        uint8 category; // ex. 1 = Singleplayer, 2 = Multiplayer, etc.
        uint88 score; // MAX SCORE = 309,485,009,821,345,068,724,781,055
        address player; // the initial minter who played the game
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
    // @TODO might want to implement custom token URI (not by increasing integer)
    /// @inheritdoc IScoreNFT
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

    /// @notice Burns a score NFT
    /// @dev Only the owner of the NFT can burn
    /// @param tokenId The ID of the NFT to burn
    function burn(uint256 tokenId) public override {
        super.burn(tokenId);
        unchecked {
            --totalSupply;
        }
    }

    /* ============ View Functions ============ */

    /// @notice Gets the score of a score NFT
    /// @param tokenId The ID of the NFT to get the score of
    /// @return category Category of the score (ex. Singleplayer, Multiplayer, etc.)
    /// @return score User's score
    /// @return player The initial minter who played the game
    /// @return owner Current owner of the NFT
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
