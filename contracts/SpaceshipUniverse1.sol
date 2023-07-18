// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ISpaceshipUniverse1.sol";
import "./interfaces/IERC4906.sol";

/* ============ Errors ============ */
error TokenLocked();
error OnlyLockedToken();
error ReachedMaxSupply();

/*
...........................................//............................................
.........................................//...//.........................................
......................................./@//...@/@#.......................................
......................................//(//...@////......................................
..................................../@/@@//...@/@@/@.....................................
...................................@//@/@//...@/@@@@//...................................
................................../(@@/@@//...@/@@/@@/@%.................................
................................./@(@@/@@//...@/@@/@@/@%.................................
...............................&@(@@@@@/@//...@/@/@@@@@//................................
............................../@@@@@@/@/@@/...@/@/@@@@@@@@/..............................
.............................@/////////////////////////////@.............................
.........................../(///////////////////////////////@/...........................
.........................(@@////........................./////@&.........................
........................//@@////.......,,...,.....,......///(/@@/........................
....................../@/@@@////....................@....///(/@@@@&......................
.....................//@@@@@////..,..... .../.,..........///(/@@@@//.....................
.................../@(@@@@@@////..@,,......@./..@........///(/@@@@@/@%...................
..................@/@@@@@@@@/@//....,... @.,.....,.......///(/@@@@@@@//..................
...............@/@@@@@/@@@@@/@//.........,...............///(/@@@@@@@@@@/................
..............&@/@@@@@/@@@@@/@//.........,...............///(/@@@@@@@@@@//...............
............./@(@@@@@(@@@@@@////.............,...........///(/@@@@@/@@@@@/@/.............
...........%@/@@@@@@/@@@@@@@////.........................///(/@@@@@@@@@@@@@/@............
..........///@@@@@/@@@@@@@@/@//////////////////////////////(((@@@@@@@@/@@@@@/@/..........
......../@//@@@@@/@@@@@@@@@@@@/((((((((((#(...(#(((((((((((/@@@@@@@@@@@/@@@@@//@.........
.......///@@@////(/@//(....//@@@@@/@@@@@@//...@/@@@@@@(@@@@@(/....///@/(////@@@/@/.......
.......///@@@////(/@//(....//@@@@@/@@@@@@//...@/@@@@@@(@@@@@(/....///@/(////@@@/@/.......
...../@(@@///................/@/@@/@@@@@@//...@/@@@@@@/@@(@%................///@@(@%.....
................................/@/@@@@@@//...@/@@@@@@/@/................................
..................................%@//@@@//...@/@@@/(/...................................
...................................../@////...@///@%.....................................
......................................../@/...@//........................................
.........................................@/...@/.........................................
..........................................@...@..........................................
 ::::::::  :::::::::      :::      ::::::::  :::::::::: :::::::::      :::     :::::::::  
:+:    :+: :+:    :+:   :+: :+:   :+:    :+: :+:        :+:    :+:   :+: :+:   :+:    :+:
+:+        +:+    +:+  +:+   +:+  +:+        +:+        +:+    +:+  +:+   +:+  +:+    +:+
+#++:++#++ +#++:++#+  +#++:++#++: +#+        +#++:++#   +#++:++#+  +#++:++#++: +#++:++#: 
       +#+ +#+        +#+     +#+ +#+        +#+        +#+    +#+ +#+     +#+ +#+    +#+
#+#    #+# #+#        #+#     #+# #+#    #+# #+#        #+#    #+# #+#     #+# #+#    #+#
 ########  ###        ###     ###  ########  ########## #########  ###     ### ###    ###
*/

/// @title SpaceshipUniverse1
/// @notice Spaceship NFT for Spacebar Universe 1
/// This contract introduces the concept of "Active Ownership", where the user must fulfill
/// certain conditions to gain full ownership of a spaceship NFT.
/// Until these conditions are met, the spaceship is locked and cannot be transferred.
/// For above purpose, this contract implements ERC5192.
/// Additionally, the Space Factory reserves the right to burn the spaceship under specific conditions (to be defined).
/// The total circulating supply (minted - burned) is limited, and this limit is maintained in the Space Factory contract.
contract SpaceshipUniverse1 is
    ISpaceshipUniverse1,
    ERC721,
    IERC4906,
    AccessControl
{
    /* ============ Variables ============ */

    /// @dev Circulalting supply of Spaceship NFT from Universe1 is fixed
    uint16 public immutable MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY;
    uint16 public currentSupply;
    uint256 public nextTokenId;

    /// @dev constant for the space factory role
    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");

    // @dev mapping from token ID to whether it is fully owned Owner-Ship
    mapping(uint256 => bool) public unlocked;

    // Optional token URIs for decentralized storage
    mapping(uint256 => string) private _decentralizedTokenURIs;
    string decentralizedTokenURIBase = "https://www.arweave.net/";

    /* ============ Constructor ============ */

    constructor(
        address spaceFactory,
        uint16 maxSpaceshipUniverse1CirculatingSupply
    ) ERC721("Spaceship Universe1", "SPACESHIP-U1") {
        _grantRole(SPACE_FACTORY, spaceFactory);
        MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY = maxSpaceshipUniverse1CirculatingSupply;
    }

    /* ============ External Functions ============ */

    /// @inheritdoc ISpaceshipUniverse1
    function mint(
        address to
    ) external onlyRole(SPACE_FACTORY) returns (uint256) {
        if (currentSupply == MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY)
            revert ReachedMaxSupply();
        unchecked {
            ++currentSupply;
        }

        _mint(to, nextTokenId);
        emit Locked(nextTokenId);

        unchecked {
            ++nextTokenId;
        }
        return nextTokenId - 1; //return tokenId
    }

    /// @inheritdoc ISpaceshipUniverse1
    function unlock(uint256 tokenId) external onlyRole(SPACE_FACTORY) {
        if (unlocked[tokenId]) revert OnlyLockedToken();
        unlocked[tokenId] = true;
        emit Unlocked(tokenId);
    }

    /// @inheritdoc ISpaceshipUniverse1
    function burn(uint256 tokenId) external onlyRole(SPACE_FACTORY) {
        if (unlocked[tokenId]) revert OnlyLockedToken();
        _burn(tokenId);
        unchecked {
            --currentSupply;
        }
    }

    /// @inheritdoc ISpaceshipUniverse1
    function updateMetadata(uint256 tokenId) external onlyRole(SPACE_FACTORY) {
        emit MetadataUpdate(tokenId);
    }

    /// @dev override approve to prevent locked tokens from being approved
    function approve(
        address to,
        uint256 tokenId
    ) public override(ERC721, IERC721) {
        if (!unlocked[tokenId]) revert TokenLocked();
        super.approve(to, tokenId);
    }

    function setDecentralizedTokenURIBase(
        string memory _decentralizedTokenURIBase_
    ) external onlyRole(SPACE_FACTORY) {
        decentralizedTokenURIBase = _decentralizedTokenURIBase_;
    }

    function setDecentralizedTokenURI(
        uint256 tokenId,
        string memory decentralizedTokenURI
    ) external onlyRole(SPACE_FACTORY) {
        _decentralizedTokenURIs[tokenId] = decentralizedTokenURI;
        emit MetadataUpdate(tokenId);
    }

    /* ============ Internal Functions ============ */

    /// @dev override approve to prevent locked tokens from being transferred to other addresses
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal virtual override {
        if (to != address(0) && from != address(0) && !unlocked[tokenId]) {
            revert TokenLocked();
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "https://api.spacebar.xyz/metadata/spaceship_universe1/";
    }

    /* ============ View Functions ============ */
    function locked(uint256 tokenId) external view override returns (bool) {
        return !unlocked[tokenId];
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _decentralizedTokenURI = _decentralizedTokenURIs[tokenId];

        if (bytes(_decentralizedTokenURI).length > 0) {
            return
                string(
                    abi.encodePacked(
                        decentralizedTokenURIBase,
                        _decentralizedTokenURI
                    )
                );
        }
        return super.tokenURI(tokenId);
    }

    /* ============ ERC-165 ============ */

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, IERC165, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}