// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/ISpaceshipUniverse1.sol";
import "./interfaces/IBadgeUniverse1.sol";
import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/ISpaceFactoryV1.sol";

/* ============ Errors ============ */
error OnlyOneProtoShipAtATime();
error OnlyNFTOwner();
error InvalidProtoShip();
error AddressAlreadyRegistered();

/// @title Space Factory V1
/// @notice This contract is responsible for minting, upgrading, and burning assets for the Spacebar project.
/// These assets currently include Spaceship NFTs from Universe1, but can be extended to support many more.
/// This is because the contract utilizes the ERC1967 proxy + UUPSUpgradeable, enabling it to be
/// upgraded in the future to support additional features and asset types.
contract SpaceFactoryV1 is
    ISpaceFactoryV1,
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable
{
    /* ============ Variables ============ */

    /// @dev The constant for the service admin role
    bytes32 public constant SERVICE_ADMIN_ROLE =
        keccak256("SERVICE_ADMIN_ROLE");

    IERC6551Account public tokenBoundImplementation;
    IERC6551Registry public tokenBoundRegistry;
    ISpaceshipUniverse1 public spaceshipUniverse1;
    IBadgeUniverse1 public badgeUniverse1;
    bool public universe1WhitelistingPeriod;

    mapping(address => bool) public hasProtoShip;

    /* ============ Events ============ */

    event MintProtoShipUniverse1(
        address tokenContract,
        uint256 tokenId,
        uint256 spaceshipId
    );
    event SetSpaceshipUniverse1(address contractAddress);
    event SetBadgeUniverse1(address contractAddress);
    event SetUniverse1WhiteListingPeriod(bool isWhiteListingPeriod);

    /* ============ Constructor ============ */

    // @TODO uncomment this when we are ready to deploy
    // constructor() initializer {}

    function initialize(
        address defaultAdmin,
        address serviceAdmin,
        IERC6551Registry _tokenBoundRegistry,
        IERC6551Account _tokenBoundImplementation
    ) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(SERVICE_ADMIN_ROLE, serviceAdmin);
        tokenBoundRegistry = (_tokenBoundRegistry);
        tokenBoundImplementation = (_tokenBoundImplementation);
        universe1WhitelistingPeriod = true;
    }

    /// @dev spaceshipUniverse1 address should only be set once and never change
    function setSpaceshipUniverse1(address contractAddress) external {
        if (address(spaceshipUniverse1) != address(0))
            revert AddressAlreadyRegistered();
        spaceshipUniverse1 = ISpaceshipUniverse1(contractAddress);
        emit SetSpaceshipUniverse1(contractAddress);
    }

    /// @dev badgeUniverse1 address should only be set once and never change
    function setBadgeUniverse1(address contractAddress) external {
        if (address(badgeUniverse1) != address(0))
            revert AddressAlreadyRegistered();
        badgeUniverse1 = IBadgeUniverse1(contractAddress);
        emit SetBadgeUniverse1(contractAddress);
    }

    /* ============ External Functions ============ */

    /// @notice Deploys a new Token Bound Account (TBA) and mint a Proto-Ship to the address
    /// @dev If the address already has TBA, it will use the existing TBA, and if the TBA
    /// already has a Proto-Ship, it will revert(OnlyOneProtoShipAtATime).
    /// @param tokenContract TBA's contract address
    /// @param tokenId TBA's token ID
    function mintProtoShipUniverse1(
        address tokenContract,
        uint256 tokenId
    ) external virtual returns (address) {
        if (IERC721(tokenContract).ownerOf(tokenId) != msg.sender) {
            revert OnlyNFTOwner();
        }
        uint256 spaceshipTokenId = spaceshipUniverse1.nextTokenId();
        address spaceshipTBA = _deployOrGetTokenBoundAccount(
            address(spaceshipUniverse1),
            spaceshipTokenId
        );

        address profileTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            tokenContract,
            tokenId,
            0
        );

        _mintProtoShipUniverse1(profileTBA);

        // @TODO update after details are fixed
        if (spaceshipTokenId < 300) {
            badgeUniverse1.mintBadge(spaceshipTBA, 0, 0);
        }

        emit MintProtoShipUniverse1(tokenContract, tokenId, spaceshipTokenId);
        return profileTBA;
    }

    /// @notice Burns a Proto-Ship from the address when it fails to meet requirements.
    /// @dev Only service admin can call this function. The function will revert if the token is not a Proto-Ship.
    /// @param tokenId Token id to burn.
    function burnProtoShipUniverse1(
        uint256 tokenId
    ) external virtual onlyRole(SERVICE_ADMIN_ROLE) {
        _burnProtoShipUniverse1(tokenId);
    }

    /// @notice Upgrades Proto-Ship to Owner-Ship(aka. unlock).
    /// @dev Only service admin can call this function. The function will revert if the token is not a Proto-Ship.
    /// @param tokenId Token id to upgrade
    function upgradeToOwnerShipUniverse1(
        uint256 tokenId
    ) external virtual onlyRole(SERVICE_ADMIN_ROLE) {
        _upgradeToOwnerShipUniverse1(tokenId);
    }

    /* ============ View Functions ============ */

    ///@dev Returns the TBA address of SpaceshipUniverse1
    ///@param tokenId ID of the token
    function getSpaceshipUniverse1TBA(
        uint256 tokenId
    ) external view returns (address) {
        return
            tokenBoundRegistry.account(
                address(tokenBoundImplementation),
                block.chainid,
                address(spaceshipUniverse1),
                tokenId,
                0
            );
    }

    /* ============ Internal Functions ============ */

    function _authorizeUpgrade(
        address
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    function _deployOrGetTokenBoundAccount(
        address tokenContract,
        uint256 tokenId
    ) internal virtual returns (address) {
        // If account has already been created, returns the account address without calling create2.
        return
            tokenBoundRegistry.createAccount(
                address(tokenBoundImplementation),
                block.chainid,
                tokenContract,
                tokenId,
                0,
                abi.encodeWithSignature("initialize()")
            );
    }

    function _mintProtoShipUniverse1(address to) internal virtual {
        if (hasProtoShip[to]) revert OnlyOneProtoShipAtATime();
        spaceshipUniverse1.mint(to);
        hasProtoShip[to] = true;
    }

    function _burnProtoShipUniverse1(uint256 tokenId) internal virtual {
        address protoShipOwner = spaceshipUniverse1.ownerOf(tokenId);
        if (!hasProtoShip[protoShipOwner]) revert InvalidProtoShip();

        spaceshipUniverse1.burn(tokenId);
        delete hasProtoShip[protoShipOwner];
    }

    function _upgradeToOwnerShipUniverse1(uint256 tokenId) internal virtual {
        address protoShipOwner = spaceshipUniverse1.ownerOf(tokenId);
        if (!hasProtoShip[protoShipOwner]) revert InvalidProtoShip();

        spaceshipUniverse1.unlock(tokenId);
        delete hasProtoShip[protoShipOwner];
    }
}
