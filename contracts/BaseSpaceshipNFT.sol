// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Consecutive.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IBaseSpaceshipNFT.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO add natspec comments
contract BaseSpaceshipNFT is
    ERC721Consecutive,
    AccessControl,
    IBaseSpaceshipNFT
{
    /* ============ Variables ============ */

    bytes32 public constant SPACE_FACTORY = keccak256("SPACE_FACTORY");
    uint16 public constant MAXIMUM = 1000;
    uint32 public constant ACCESS_PERIOD = 7 days;

    mapping(address => Access) private _accesses;
    mapping(uint256 => address) private _userAddresses;

    /* ============ Structs ============ */

    struct Access {
        uint256 tokenId;
        address user;
        uint64 expirationDate;
    }

    /* ============ Events ============ */

    event GrantAccess(address indexed user, uint256 indexed tokenId);
    event ExtendAccess(
        address indexed user,
        uint256 indexed tokenId,
        uint64 expirationDate
    );

    /* ============ Errors ============ */

    error AlreadyHaveAccess(address user, uint256 tokenId);
    error AlreadyClaimedToken(uint256 tokenId);
    error NotWithinExtensionPeriod(address user, uint256 tokenId);

    /* ============ Modifiers ============ */

    modifier onlyUserWithoutAccess(address user, uint256 tokenId) {
        if (
            _accesses[user].user == user &&
            _accesses[user].expirationDate - ACCESS_PERIOD > block.timestamp
        ) {
            revert AlreadyHaveAccess(user, tokenId);
        }
        _;
    }

    modifier onlyTokenWithoutAccess(uint256 tokenId) {
        if (
            _accesses[_userAddresses[tokenId]].expirationDate - ACCESS_PERIOD >
            block.timestamp
        ) {
            revert AlreadyClaimedToken(tokenId);
        }
        _;
    }

    modifier onlyTokenWithinExtensionPeriod(address user, uint256 tokenId) {
        if (
            _accesses[user].user == user ||
            _accesses[_userAddresses[tokenId]].expirationDate <
            block.timestamp ||
            _accesses[_userAddresses[tokenId]].expirationDate >
            block.timestamp + ACCESS_PERIOD
        ) {
            revert NotWithinExtensionPeriod(user, tokenId);
        }
        _;
    }

    /* ============ Constructor ============ */

    constructor(address spaceFactory) ERC721("Base Spaceship", "BASE") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SPACE_FACTORY, spaceFactory);
        _mintConsecutive(msg.sender, MAXIMUM);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks
    function grantAccess(
        address user,
        uint256 tokenId
    )
        external
        onlyRole(SPACE_FACTORY)
        onlyUserWithoutAccess(user, tokenId)
        onlyTokenWithoutAccess(tokenId)
    {
        _accesses[user] = Access(
            tokenId,
            user,
            uint64(block.timestamp + ACCESS_PERIOD)
        );
        _userAddresses[tokenId] = user;
        emit GrantAccess(user, tokenId);
    }

    function extendAccess(
        address user,
        uint256 tokenId
    )
        external
        onlyRole(SPACE_FACTORY)
        onlyTokenWithinExtensionPeriod(user, tokenId)
    {
        _accesses[user].expirationDate += ACCESS_PERIOD;
        emit ExtendAccess(user, tokenId, _accesses[user].expirationDate);
    }

    /// @notice Untitled spaceship is burned to create an ultimate spaceship
    function burn(uint256 tokenId) external onlyRole(SPACE_FACTORY) {
        _burn(tokenId);
    }

    /* ============ View Functions ============ */

    function getAccessStatusByUserAddress(
        address user
    ) external view returns (Access memory) {
        return _accesses[user];
    }

    function getAccessStatusByTokenId(
        uint256 tokenId
    ) external view returns (Access memory) {
        return _accesses[_userAddresses[tokenId]];
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
        return "https://www.spacebar.xyz/base/";
    }
}
