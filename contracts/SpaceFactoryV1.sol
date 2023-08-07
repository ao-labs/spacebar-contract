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
import "./helper/Error.sol";

/// @title Space Factory V1
/// @notice This contract is responsible for the minting, upgrading, and burning of assets for the Spacebar project.
/// While currently supporting Spaceship NFTs from Universe1, it has the potential to support a wider variety of assets.
/// Thanks to its use of the ERC1967 proxy and UUPSUpgradeable, this contract can be upgraded in the future
/// to accommodate additional features and asset types.
contract SpaceFactoryV1 is
    ISpaceFactoryV1,
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    Error
{
    /* ============ Variables ============ */

    bytes32 public constant SERVICE_ADMIN_ROLE =
        keccak256("SERVICE_ADMIN_ROLE"); // spacebar's server key
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // whitelist badge minter

    IERC6551Account public tokenBoundImplementation;
    IERC6551Registry public tokenBoundRegistry;
    ISpaceshipUniverse1 public spaceshipUniverse1;
    IBadgeUniverse1 public badgeUniverse1;
    bool public isUniverse1Whitelisted;
    IBadgeUniverse1.TokenType universe1WhitelistBadgeType;

    mapping(address => bool) public hasProtoship;

    /* ============ Events ============ */

    event MintProtoshipUniverse1(
        address tokenContract,
        uint256 tokenId,
        uint256 spaceshipId
    );
    event SetTokenBoundImplementation(address contractAddress);
    event SetTokenBoundRegistry(address contractAddress);
    event SetSpaceshipUniverse1(address contractAddress);
    event SetBadgeUniverse1(address contractAddress);
    event SetIsUniverse1Whitelisted(bool isUniverse1Whitelisted);
    event SetUniverse1WhitelistBadgeType(IBadgeUniverse1.TokenType badgeType);

    /* ============ Constructor ============ */

    // @TODO uncomment this when we are ready to deploy
    /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() {
    //     _disableInitializers();
    // }

    function initialize(
        address defaultAdmin,
        address serviceAdmin,
        address minterAdmin,
        IERC6551Registry _tokenBoundRegistry,
        IERC6551Account _tokenBoundImplementation,
        bool _isUniverse1Whitelisted,
        IBadgeUniverse1.TokenType memory _universe1WhitelistBadgeType
    ) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(SERVICE_ADMIN_ROLE, serviceAdmin);
        _grantRole(MINTER_ROLE, minterAdmin);
        tokenBoundRegistry = (_tokenBoundRegistry);
        tokenBoundImplementation = (_tokenBoundImplementation);
        isUniverse1Whitelisted = _isUniverse1Whitelisted;
        universe1WhitelistBadgeType = _universe1WhitelistBadgeType;
        emit SetIsUniverse1Whitelisted(_isUniverse1Whitelisted);
        emit SetUniverse1WhitelistBadgeType(_universe1WhitelistBadgeType);
        /// @audit should invoke __UUPSUpgradeable_init() here?
    }

    /* ============ Admin Functions ============ */

    function setTokenBoundImplementation(
        IERC6551Account contractAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(contractAddress) == address(0)) revert InvalidAddress();
        tokenBoundImplementation = contractAddress;
        emit SetTokenBoundImplementation(address(contractAddress));
    }

    function setTokenBoundRegistry(
        IERC6551Registry contractAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(contractAddress) == address(0)) revert InvalidAddress();
        tokenBoundRegistry = contractAddress;
        emit SetTokenBoundRegistry(address(contractAddress));
    }

    function setSpaceshipUniverse1(
        address contractAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(spaceshipUniverse1) != address(0))
            revert AddressAlreadyRegistered();
        spaceshipUniverse1 = ISpaceshipUniverse1(contractAddress);
        emit SetSpaceshipUniverse1(contractAddress);
    }

    function setBadgeUniverse1(
        address contractAddress
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (address(badgeUniverse1) != address(0))
            revert AddressAlreadyRegistered();
        badgeUniverse1 = IBadgeUniverse1(contractAddress);
        emit SetBadgeUniverse1(contractAddress);
    }

    function setIsUniverse1Whitelisted(
        bool _isUniverse1Whitelisted
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        isUniverse1Whitelisted = _isUniverse1Whitelisted;
        emit SetIsUniverse1Whitelisted(_isUniverse1Whitelisted);
    }

    function setUniverse1WhitelistBadgeType(
        IBadgeUniverse1.TokenType memory _universe1WhitelistBadgeType
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        universe1WhitelistBadgeType = _universe1WhitelistBadgeType;
        emit SetUniverse1WhitelistBadgeType(_universe1WhitelistBadgeType);
    }

    function transferDefaultAdmin(
        address admin
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(DEFAULT_ADMIN_ROLE, admin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ============ External Functions ============ */

    /// @notice Mints a Protoship to the TBA address associated with the user's NFT and deploys the TBA of the spaceship.
    /// @dev If the address already has a TBA, it will use the existing TBA. If the TBA already has a Protoship,
    /// it will revert with the error 'OnlyOneProtoshipAtATime'.
    /// @param tokenContract The contract address of the TBA.
    /// @param tokenId The token ID of the TBA.
    function mintProtoshipUniverse1(
        address tokenContract,
        uint256 tokenId
    ) external virtual returns (address) {
        if (IERC721(tokenContract).ownerOf(tokenId) != msg.sender) {
            revert OnlyNFTOwner();
        }
        //@dev Protoship is minted to the TBA of the user's NFT
        // This is different from spaceship's TBA from the above lines
        address nftTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            tokenContract,
            tokenId,
            0
        );

        //@dev during whitelist period TBA must own the specific type of badge
        if (isUniverse1Whitelisted) {
            if (
                !badgeUniverse1.isOwnerOfTokenType(
                    nftTBA,
                    universe1WhitelistBadgeType.primaryType,
                    universe1WhitelistBadgeType.secondaryType
                )
            ) {
                revert NotWhiteListed();
            }
        }

        uint256 spaceshipTokenId = spaceshipUniverse1.nextTokenId();

        /// deploys TBA of spaceship (if not already deployed)
        /// TBA can be deployed before minting because the address is deterministic
        _deployOrGetTokenBoundAccount(
            address(spaceshipUniverse1),
            spaceshipTokenId
        );

        _mintProtoshipUniverse1(nftTBA);
        emit MintProtoshipUniverse1(tokenContract, tokenId, spaceshipTokenId);
        return nftTBA;
    }

    /// @notice Mints a whitelist badge (SBT) to the TBA address associated with the user's NFT.
    /// During the whitelist period, a user must own a specific type of badge to mint a Protoship.
    /// @param tokenContract The contract address of the user's NFT.
    /// @param tokenId The token ID of the user's NFT.
    function mintWhitelistBadgeUniverse1(
        address tokenContract,
        uint256 tokenId,
        string memory tokenURI
    ) external virtual onlyRole(MINTER_ROLE) {
        address profileTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            tokenContract,
            tokenId,
            0
        );

        badgeUniverse1.mintBadge(
            profileTBA,
            universe1WhitelistBadgeType.primaryType,
            universe1WhitelistBadgeType.secondaryType,
            tokenURI
        );
    }

    /// @notice Burns a Protoship from an address when it fails to meet the required conditions.
    /// @dev Only a service admin can call this function. The function will revert if the specified token is not a Protoship.
    /// @param tokenId The ID of the token to burn.
    function burnProtoshipUniverse1(
        uint256 tokenId
    ) external virtual onlyRole(SERVICE_ADMIN_ROLE) {
        _burnProtoshipUniverse1(tokenId);
    }

    /// @notice Upgrades a Protoship to Ownership status (unlock).
    /// @dev Only a service admin can call this function. The function will revert if the specified token is not a Protoship.
    /// @param tokenId The ID of the token to upgrade.
    function upgradeToOwnershipUniverse1(
        uint256 tokenId
    ) external virtual onlyRole(SERVICE_ADMIN_ROLE) {
        _upgradeToOwnershipUniverse1(tokenId);
    }

    /* ============ View Functions ============ */

    ///@dev Returns the TBA address of SpaceshipUniverse1
    ///@param tokenId Spaceship token id
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

    function _mintProtoshipUniverse1(address to) internal virtual {
        // If the address already has a Protoship, it will revert
        if (hasProtoship[to]) revert OnlyOneProtoshipAtATime();
        spaceshipUniverse1.mint(to);
        hasProtoship[to] = true;
    }

    function _burnProtoshipUniverse1(uint256 tokenId) internal virtual {
        address protoshipOwner = spaceshipUniverse1.ownerOf(tokenId);
        if (!hasProtoship[protoshipOwner]) revert InvalidProtoship();

        spaceshipUniverse1.burn(tokenId);
        delete hasProtoship[protoshipOwner];
    }

    function _upgradeToOwnershipUniverse1(uint256 tokenId) internal virtual {
        address protoshipOwner = spaceshipUniverse1.ownerOf(tokenId);
        if (!hasProtoship[protoshipOwner]) revert InvalidProtoship();

        // By unlocking the Protoship, it transitions to Ownership status, allowing users to transfer it freely.
        spaceshipUniverse1.unlock(tokenId);
        delete hasProtoship[protoshipOwner];
    }
}
