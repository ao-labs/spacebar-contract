// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/IERC6551Account.sol";
import "./interfaces/IERC6551Registry.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "./interfaces/ISpaceshipUniverse1.sol";

import "./KeyUniverse1.sol";
import "./helper/Error.sol";

/// @title KeyMinterUniverse1
/// @dev KeyMinterUniverse1 is a contract for minting Keys and collecting contributions.
contract KeyMinterUniverse1 is AccessControl, EIP712, Error {
    /* ============ Variables ============ */
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant KEY_MINT_PARAMS_TYPEHASH =
        keccak256(
            "KeyMintParams(address profileContractAddress,uint256 profileTokenId,uint256 spaceshipTokenId,uint256 keyTokenId,uint256 contribution)"
        );
    bytes32 public constant KEY_BATCH_MINT_PARAMS_TYPEHASH =
        keccak256(
            "KeyBatchMintParams(address profileContractAddress,uint256 profileTokenId,uint256 spaceshipTokenId,uint256[] keyTokenIds,uint256 contribution)"
        );

    address public serviceAdmin;
    KeyUniverse1 public immutable keyUniverse1;
    ISpaceshipUniverse1 public immutable spaceshipUniverse1;
    IERC6551Account public tokenBoundImplementation;
    IERC6551Registry public tokenBoundRegistry;
    uint128[] public maxContributionSchedulePerMint;
    uint128 public maxContributionPerUser = 1000000 ether;
    uint256 public maxTotalContribution = 1000 ether;
    bool public isRefundEnabled;

    mapping(address => User) private _userStatus;

    struct User {
        uint128 contribution;
        uint128 mintCount;
    }

    struct KeyMintParams {
        address profileContractAddress;
        uint256 profileTokenId;
        uint256 spaceshipTokenId;
        uint256 keyTokenId;
        uint256 contribution;
    }

    struct KeyBatchMintParams {
        address profileContractAddress;
        uint256 profileTokenId;
        uint256 spaceshipTokenId;
        uint256[] keyTokenIds;
        uint256 contribution;
    }

    event SetMaxContributionSchedulePerMint(
        uint128[] maxContributionSchedulePerMint
    );
    event SetMaxContributionPerUser(uint128 maxContributionPerUser);
    event SetMaxTotalContribution(uint256 maxTotalContribution);
    event SetIsRefundEnabled(bool isRefundEnabled);
    event SetServiceAdmin(address serviceAdmin);
    event Refund(address indexed user, uint256 amount);
    event SetTokenBoundImplementation(address contractAddress);
    event SetTokenBoundRegistry(address contractAddress);

    /* ============ Constructor ============ */

    constructor(
        address defaultAdmin,
        address operator,
        address _serviceAdmin,
        ISpaceshipUniverse1 _spaceshipUniverse1,
        IERC6551Registry _tokenBoundRegistry,
        IERC6551Account _tokenBoundImplementation
    ) EIP712("KeyMinterUniverse1", "1") {
        keyUniverse1 = new KeyUniverse1(defaultAdmin, operator, address(this));
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(OPERATOR_ROLE, operator);
        serviceAdmin = _serviceAdmin;
        tokenBoundRegistry = (_tokenBoundRegistry);
        tokenBoundImplementation = (_tokenBoundImplementation);
        spaceshipUniverse1 = _spaceshipUniverse1;
        emit SetServiceAdmin(_serviceAdmin);
        emit SetTokenBoundImplementation(address(_tokenBoundImplementation));
        emit SetTokenBoundRegistry(address(_tokenBoundRegistry));
    }

    /* ============ Operator Functions ============ */

    function setMaxContributionSchedulePerMint(
        uint128[] memory _maxContributionSchedulePerMint
    ) external onlyRole(OPERATOR_ROLE) {
        maxContributionSchedulePerMint = _maxContributionSchedulePerMint;
        emit SetMaxContributionSchedulePerMint(_maxContributionSchedulePerMint);
    }

    function setMaxContributionPerUser(
        uint128 _maxContributionPerUser
    ) external onlyRole(OPERATOR_ROLE) {
        maxContributionPerUser = _maxContributionPerUser;
        emit SetMaxContributionPerUser(_maxContributionPerUser);
    }

    function setMaxTotalContribution(
        uint256 _maxTotalContribution
    ) external onlyRole(OPERATOR_ROLE) {
        maxTotalContribution = _maxTotalContribution;
        emit SetMaxTotalContribution(_maxTotalContribution);
    }

    function setServiceAdmin(
        address _serviceAdmin
    ) external onlyRole(OPERATOR_ROLE) {
        serviceAdmin = _serviceAdmin;
        emit SetServiceAdmin(_serviceAdmin);
    }

    /* ============ Admin Functions ============ */

    function setIsRefundEnabled(
        bool _isRefundEnabled
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isRefundEnabled = _isRefundEnabled;
        emit SetIsRefundEnabled(_isRefundEnabled);
    }

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

    function withdraw(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(to).transfer(address(this).balance);
    }

    /* ============ External Functions ============ */

    function mintKey(
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256 keyTokenId,
        bytes memory signature
    ) external payable {
        address signer = getSigner(
            KeyMintParams(
                profileContractAddress,
                profileTokenId,
                spaceshipTokenId,
                keyTokenId,
                msg.value
            ),
            signature
        );

        if (signer != serviceAdmin) {
            revert InvalidSignature();
        }

        if (
            IERC721(profileContractAddress).ownerOf(profileTokenId) !=
            msg.sender
        ) {
            revert OnlyNFTOwner();
        }

        address nftTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            profileContractAddress,
            profileTokenId,
            0
        );

        if (spaceshipUniverse1.ownerOf(spaceshipTokenId) != nftTBA) {
            revert OnlySpaceshipOwner();
        }

        User storage user = _userStatus[msg.sender];
        if (msg.value > getMaxContributionPerMint(user.mintCount)) {
            revert ExceedMaxContributionPerMint();
        }
        user.contribution += uint128(msg.value);
        user.mintCount += 1;

        if (user.contribution > maxContributionPerUser) {
            revert ExceedMaxContributionPerUser();
        }
        if (address(this).balance > maxTotalContribution) {
            revert ExceedMaxTotalContribution();
        }

        address spaceshipTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            address(spaceshipUniverse1),
            spaceshipTokenId,
            0
        );

        keyUniverse1.mint(spaceshipTBA, keyTokenId);
    }

    function batchMintKey(
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256[] memory keyTokenIds,
        bytes memory signature
    ) external payable {
        address signer = getSigner(
            KeyBatchMintParams(
                profileContractAddress,
                profileTokenId,
                spaceshipTokenId,
                keyTokenIds,
                msg.value
            ),
            signature
        );

        if (signer != serviceAdmin) {
            revert InvalidSignature();
        }

        if (
            IERC721(profileContractAddress).ownerOf(profileTokenId) !=
            msg.sender
        ) {
            revert OnlyNFTOwner();
        }

        address nftTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            profileContractAddress,
            profileTokenId,
            0
        );

        if (spaceshipUniverse1.ownerOf(spaceshipTokenId) != nftTBA) {
            revert OnlySpaceshipOwner();
        }

        uint256 keyTokenIdsLength = keyTokenIds.length;
        User storage user = _userStatus[msg.sender];
        if (
            msg.value >
            getMaxContributionPerBatchMint(user.mintCount, keyTokenIdsLength)
        ) {
            revert ExceedMaxContributionPerMint();
        }

        user.contribution += uint128(msg.value);
        user.mintCount += uint128(keyTokenIdsLength);

        if (user.contribution > maxContributionPerUser) {
            revert ExceedMaxContributionPerUser();
        }
        if (address(this).balance > maxTotalContribution) {
            revert ExceedMaxTotalContribution();
        }

        address spaceshipTBA = tokenBoundRegistry.account(
            address(tokenBoundImplementation),
            block.chainid,
            address(spaceshipUniverse1),
            spaceshipTokenId,
            0
        );

        for (uint256 i = 0; i < keyTokenIdsLength; i++) {
            keyUniverse1.mint(spaceshipTBA, keyTokenIds[i]);
        }
    }

    function refund() external {
        if (!isRefundEnabled) {
            revert RefundNotEnabled();
        }
        User storage user = _userStatus[msg.sender];
        payable(msg.sender).transfer(user.contribution);
        emit Refund(msg.sender, user.contribution);
        user.contribution = 0;
    }

    /* ============ Internal Functions ============ */

    function getMaxContributionPerMint(
        uint256 currentMintCount
    ) internal view returns (uint128) {
        if (maxContributionSchedulePerMint.length == 0) {
            return type(uint128).max;
        }

        if (currentMintCount >= maxContributionSchedulePerMint.length) {
            return
                maxContributionSchedulePerMint[
                    maxContributionSchedulePerMint.length - 1
                ];
        }

        return maxContributionSchedulePerMint[currentMintCount];
    }

    function getMaxContributionPerBatchMint(
        uint256 currentMintCount,
        uint256 amount
    ) internal view returns (uint128) {
        if (maxContributionSchedulePerMint.length == 0) {
            return type(uint128).max;
        }

        uint128 maxContribution = 0;

        for (uint256 i = currentMintCount; i < currentMintCount + amount; i++) {
            if (i >= maxContributionSchedulePerMint.length) {
                maxContribution += maxContributionSchedulePerMint[
                    maxContributionSchedulePerMint.length - 1
                ];
            } else {
                maxContribution += maxContributionSchedulePerMint[i];
            }
        }

        return maxContribution;
    }

    /* ============ View Functions ============ */

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getUserContribution(address user) external view returns (uint128) {
        return _userStatus[user].contribution;
    }

    function getUserMintCount(address user) external view returns (uint128) {
        return _userStatus[user].mintCount;
    }

    function getSigner(
        KeyMintParams memory keyMintParams,
        bytes memory signature
    ) public view returns (address) {
        bytes32 structHash = keccak256(
            abi.encode(
                KEY_MINT_PARAMS_TYPEHASH,
                keyMintParams.profileContractAddress,
                keyMintParams.profileTokenId,
                keyMintParams.spaceshipTokenId,
                keyMintParams.keyTokenId,
                keyMintParams.contribution
            )
        );
        bytes32 digest = _hashTypedDataV4(structHash);

        (address signer, ) = ECDSA.tryRecover(digest, signature);
        return signer;
    }

    function getSigner(
        KeyBatchMintParams memory keyBatchMintParams,
        bytes memory signature
    ) public view returns (address) {
        bytes32 structHash = keccak256(
            abi.encode(
                KEY_BATCH_MINT_PARAMS_TYPEHASH,
                keyBatchMintParams.profileContractAddress,
                keyBatchMintParams.profileTokenId,
                keyBatchMintParams.spaceshipTokenId,
                keyBatchMintParams.keyTokenIds,
                keyBatchMintParams.contribution
            )
        );
        bytes32 digest = _hashTypedDataV4(structHash);

        (address signer, ) = ECDSA.tryRecover(digest, signature);
        return signer;
    }
}
