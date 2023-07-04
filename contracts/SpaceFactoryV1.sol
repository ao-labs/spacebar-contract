// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ISpaceshipNFTUniverse1.sol";
import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Registry.sol";

/* ============ Errors ============ */
error OnlyOneProtoShipAtATime();
error OnlyNFTOwner();
error ReachedMaxSupply();
error InvalidProtoShip();

// @TODO implement upgradeability
/// @title Space Factory V1
/// @notice This contract is responsible for minting, upgrading, and burning assets for the Spacebar project.
/// These assets currently include Spaceship NFTs from Universe1, but can be extended to support many more.
/// This is because the contract utilizes the ERC1967 proxy standard, enabling it to be
/// upgraded in the future to support additional features and asset types.
contract SpaceFactoryV1 is AccessControl {
    /* ============ Variables ============ */

    /// @dev The constant for the service admin role
    bytes32 public constant SERVICE_ADMIN_ROLE =
        keccak256("SERVICE_ADMIN_ROLE");

    /// @dev Circulalting supply of Spaceship NFT from Universe1 is fixed
    uint16 public immutable MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY;
    uint16 public currentSupply;

    IERC6551Account public tokenBoundImplementation;
    IERC6551Registry public tokenBoundRegistry;
    ISpaceshipNFTUniverse1 public spaceshipNFTUniverse1;

    mapping(address => bool) public hasProtoShip;

    /* ============ Events ============ */

    event SetSpaceshipNFTUniverse1(address contractAddress);

    /* ============ Constructor ============ */

    constructor(
        address defaultAdmin,
        address serviceAdmin,
        uint16 maxSpaceshipUniverse1CirculatingSupply,
        IERC6551Registry _tokenBoundRegistry,
        IERC6551Account _tokenBoundImplementation
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(SERVICE_ADMIN_ROLE, serviceAdmin);
        tokenBoundRegistry = (_tokenBoundRegistry);
        tokenBoundImplementation = (_tokenBoundImplementation);
        MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY = maxSpaceshipUniverse1CirculatingSupply;
    }

    /* ============ External Functions ============ */

    /// @notice Deploys a new Token Bound Account (TBA) and mint a Proto-Ship to the address
    /// @dev If the address already has TBA, it will use the existing TBA, and if the TBA
    /// already has a Proto-Ship, it will revert(OnlyOneProtoShipAtATime).
    /// @param tokenContract TBA's contract address
    /// @param tokenId TBA's token ID
    function deployTBAAndMintProtoShip(
        address tokenContract,
        uint256 tokenId
    ) external returns (address) {
        if (IERC721(tokenContract).ownerOf(tokenId) != msg.sender) {
            revert OnlyNFTOwner();
        }
        address tba = _deployOrGetTokenBoundAccount(tokenContract, tokenId);
        _mintProtoShip(tba);
        return tba;
    }

    /// @notice Burns a Proto-Ship from the address when it fails to meet requirements.
    /// @dev Only service admin can call this function. The function will revert if the token is not a Proto-Ship.
    /// @param tokenId Token id to burn.
    function burnProtoShip(
        uint256 tokenId
    ) external onlyRole(SERVICE_ADMIN_ROLE) {
        _burnProtoShip(tokenId);
    }

    /// @notice Upgrades Proto-Ship to Owner-Ship(aka. unlock).
    /// @dev Only service admin can call this function. The function will revert if the token is not a Proto-Ship.
    /// @param tokenId Token id to upgrade
    function upgradeToOwnerShip(
        uint256 tokenId
    ) external onlyRole(SERVICE_ADMIN_ROLE) {
        _upgradeToOwnerShip(tokenId);
    }

    /* ============ Admin Functions ============ */

    function setSpaceshipNFTUniverse1(
        address contractAddress
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        spaceshipNFTUniverse1 = ISpaceshipNFTUniverse1(contractAddress);
        emit SetSpaceshipNFTUniverse1(contractAddress);
    }

    /* ============ Internal Functions ============ */

    function _deployOrGetTokenBoundAccount(
        address tokenContract,
        uint256 tokenId
    ) internal returns (address) {
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

    function _mintProtoShip(address to) internal {
        if (hasProtoShip[to]) revert OnlyOneProtoShipAtATime();
        if (currentSupply == MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY)
            revert ReachedMaxSupply();
        spaceshipNFTUniverse1.mint(to);
        hasProtoShip[to] = true;
        unchecked {
            ++currentSupply;
        }
    }

    function _burnProtoShip(uint256 tokenId) internal {
        address protoShipOwner = spaceshipNFTUniverse1.ownerOf(tokenId);
        if (!hasProtoShip[protoShipOwner]) revert InvalidProtoShip();

        spaceshipNFTUniverse1.burn(tokenId);
        delete hasProtoShip[protoShipOwner];

        unchecked {
            --currentSupply;
        }
    }

    function _upgradeToOwnerShip(uint256 tokenId) internal {
        address protoShipOwner = spaceshipNFTUniverse1.ownerOf(tokenId);
        if (!hasProtoShip[protoShipOwner]) revert InvalidProtoShip();

        spaceshipNFTUniverse1.unlock(tokenId);
        delete hasProtoShip[protoShipOwner];
    }
}
