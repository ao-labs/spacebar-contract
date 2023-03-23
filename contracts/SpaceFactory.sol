// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBaseSpaceshipNFT.sol";
import "./interfaces/ISpaceshipNFT.sol";
import "./interfaces/IPartsNFT.sol";
import "./interfaces/IBadgeSBT.sol";
import "./interfaces/IScoreNFT.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO implement upgradeability
// @TODO add natspec comments
contract SpaceFactory is AccessControl {
    /* ============ Variables ============ */

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    // bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    mapping(uint8 => uint24) numberPerPartType;

    uint baseSpaceshipRentalFee;
    uint baseSpaceshipExtensionFee;
    uint partsMintingFee;
    uint spaceshipMintingFee;
    uint spaceshipUpdatingFee;
    uint spaceshipNicknameUpdatingFee;
    uint badgeMintingFee;
    uint scoreMintingFee;

    IBaseSpaceshipNFT public baseSpaceshipNFT;
    ISpaceshipNFT public spaceshipNFT;
    IPartsNFT public partsNFT;
    IBadgeSBT public badgeSBT;
    IScoreNFT public scoreNFT;
    IERC20 public airTokenContract;
    address public feeCollector;

    uint8 constant MAX_PART_TYPE = 16;
    uint24 constant MAX_PART_NUMBER = 777215;

    uint8 public numberOfPartTypes;

    /* ============ Structs ============ */

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /* ============ Events ============ */

    event SetBaseSpaceshipNFTAddress(IBaseSpaceshipNFT indexed newAddress);
    event SetSpaceshipNFTAddress(ISpaceshipNFT indexed newAddress);
    event SetPartsNFTAddress(IPartsNFT indexed newAddress);
    event SetBadgeSBTAddress(IBadgeSBT indexed newAddress);
    event SetScoreNFTAddress(IScoreNFT indexed newAddress);
    event SetAirTokenContractAddress(IERC20 indexed newAddress);
    event SetFeeCollectorAddress(address indexed newAddress);
    event SetNumbersPerPartType(uint24[] numbersPerPartType);

    event SetBaseSpaceshipRentalFee(uint fee);
    event SetBaseSpaceshipExtensionFee(uint fee);
    event SetPartsMintingFee(uint fee);
    event SetSpaceshipMintingFee(uint fee);
    event SetSpaceshipUpdatingFee(uint fee);
    event SetSpaceshipNicknameUpdatingFee(uint fee);
    event SetBadgeMintingFee(uint fee);
    event SetScoreMintingFee(uint fee);

    /* ============ Errors ============ */

    error InvalidSignature();
    error InvalidListLength();
    error InvalidTypeOrder();
    error ExceedsMaximumLength();
    error ContractNotAvailable();
    error InvalidAmount();
    error InvalidAddress();
    error NotTokenOnwer();

    /* ============ Modifiers ============ */

    modifier collectFee(address user, uint fee) {
        if (fee > 0) {
            airTokenContract.transferFrom(user, feeCollector, fee);
        }
        _;
    }

    modifier addressCheck(address user) {
        if (user == address(0)) {
            revert InvalidAddress();
        }
        _;
    }

    /* ============ Constructor ============ */

    // @TODO upgradeable init function
    constructor(address _signer) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, _signer);
    }

    /* ============ External Functions ============ */

    // @TODO use sign typed data + custom nonce (if necessary)
    // ex. @openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol
    function rentBaseSpaceship(
        uint tokenId,
        Signature calldata signature
    ) external collectFee(msg.sender, baseSpaceshipRentalFee) {
        // @TODO this must change, cuz this can be used twice
        bytes32 digest = keccak256(
            abi.encode(
                "rentBaseSpaceship",
                tokenId,
                msg.sender,
                baseSpaceshipNFT
            )
        );
        _checkSignature(digest, signature);
        baseSpaceshipNFT.grantAccess(msg.sender, tokenId);
    }

    // @TODO should admin functions also provide user's signature?
    function rentBaseSpaceshipByAdmin(
        uint tokenId,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, baseSpaceshipRentalFee)
    {
        baseSpaceshipNFT.grantAccess(msg.sender, tokenId);
    }

    function extendBaseSpaceship(
        uint tokenId,
        Signature calldata signature
    ) external collectFee(msg.sender, baseSpaceshipExtensionFee) {
        bytes32 digest = keccak256(
            abi.encode(
                "extendBaseSpaceship",
                tokenId,
                msg.sender,
                baseSpaceshipNFT
            )
        );
        _checkSignature(digest, signature);
        baseSpaceshipNFT.extendAccess(msg.sender, tokenId);
    }

    function extendBaseSpaceshipByAdmin(
        uint tokenId,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, baseSpaceshipExtensionFee)
    {
        baseSpaceshipNFT.extendAccess(user, tokenId);
    }

    function mintRandomParts(
        uint amount,
        Signature calldata signature
    ) external collectFee(msg.sender, partsMintingFee) {
        if (amount == 0) {
            revert InvalidAmount();
        }
        bytes32 digest = keccak256(
            abi.encode("mintParts", msg.sender, partsNFT, amount)
        );
        _checkSignature(digest, signature);
        if (amount == 1) {
            _mintRandomParts(msg.sender);
        }
        if (amount > 1) {
            _batchMintRandomParts(msg.sender, amount);
        }
    }

    function mintRandomPartsByAdmin(
        uint amount,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, partsMintingFee)
    {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (amount == 1) {
            _mintRandomParts(user);
        }
        if (amount > 1) {
            _batchMintRandomParts(user, amount);
        }
    }

    function mintNewSpaceship(
        bytes32 nickname,
        uint24[] calldata parts,
        Signature calldata signature
    ) external collectFee(msg.sender, spaceshipMintingFee) {
        bytes32 digest = keccak256(
            abi.encode("mintNewSpaceship", nickname, msg.sender, parts)
        );
        _checkSignature(digest, signature);
        _mintNewSpaceship(msg.sender, nickname, parts);
    }

    function mintNewSpaceshipByAdmin(
        bytes32 nickname,
        uint24[] calldata parts,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, spaceshipMintingFee)
    {
        _mintNewSpaceship(msg.sender, nickname, parts);
    }

    function updateSpaceshipParts(
        uint tokenId,
        uint24[] calldata parts,
        Signature calldata signature
    ) external collectFee(msg.sender, spaceshipUpdatingFee) {
        bytes32 digest = keccak256(
            abi.encode("updateSpaceshipParts", msg.sender, tokenId, parts)
        );
        _checkSignature(digest, signature);
        _updateSpaceshipParts(msg.sender, tokenId, parts);
    }

    function updateSpaceshipPartsByAdmin(
        uint tokenId,
        uint24[] calldata parts,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, spaceshipUpdatingFee)
    {
        _updateSpaceshipParts(user, tokenId, parts);
    }

    function updateSpaceshipNickname(
        uint tokenId,
        bytes32 nickname,
        Signature calldata signature
    ) external collectFee(msg.sender, spaceshipNicknameUpdatingFee) {
        bytes32 digest = keccak256(
            abi.encode("updateSpaceshipNickname", msg.sender, tokenId, nickname)
        );
        _checkSignature(digest, signature);
        spaceshipNFT.updateSpaceshipNickname(tokenId, nickname);
    }

    function updateSpaceshipNicknameByAdmin(
        uint tokenId,
        bytes32 nickname,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, spaceshipNicknameUpdatingFee)
    {
        spaceshipNFT.updateSpaceshipNickname(tokenId, nickname);
    }

    function mintScore(
        uint8 category,
        uint88 score,
        Signature calldata signature
    ) external collectFee(msg.sender, scoreMintingFee) {
        bytes32 digest = keccak256(
            abi.encode("mintScore", category, score, msg.sender)
        );
        _checkSignature(digest, signature);
        scoreNFT.mintScore(msg.sender, category, score);
    }

    function mintScoreByAdmin(
        uint8 category,
        uint88 score,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, scoreMintingFee)
    {
        scoreNFT.mintScore(user, category, score);
    }

    function mintBadge(
        uint8 category,
        IBadgeSBT.BurnAuth burnAuth,
        Signature calldata signature
    ) external collectFee(msg.sender, badgeMintingFee) {
        bytes32 digest = keccak256(
            abi.encode("mintBadge", category, burnAuth, msg.sender)
        );
        _checkSignature(digest, signature);
        badgeSBT.mintBadge(msg.sender, category, burnAuth);
    }

    function mintBadgeByAdmin(
        uint8 category,
        IBadgeSBT.BurnAuth burnAuth,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SIGNER_ROLE)
        collectFee(user, badgeMintingFee)
    {
        badgeSBT.mintBadge(user, category, burnAuth);
    }

    /* ============ Admin Functions ============ */

    function setBaseSpaceshipNFTAddress(
        IBaseSpaceshipNFT _baseSpaceshipNFT
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseSpaceshipNFT = _baseSpaceshipNFT;
        emit SetBaseSpaceshipNFTAddress(baseSpaceshipNFT);
    }

    function setSpaceshipNFTAddress(
        ISpaceshipNFT _spaceshipNFT
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        spaceshipNFT = _spaceshipNFT;
        emit SetSpaceshipNFTAddress(spaceshipNFT);
    }

    function setPartsNftAddress(
        IPartsNFT _partsNFT
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        partsNFT = _partsNFT;
        emit SetPartsNFTAddress(partsNFT);
    }

    function setBadgeSBTAddress(
        IBadgeSBT _badgeSBT
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        badgeSBT = _badgeSBT;
        emit SetBadgeSBTAddress(badgeSBT);
    }

    function setScoreNFTAddress(
        IScoreNFT _scoreNFT
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        scoreNFT = _scoreNFT;
        emit SetScoreNFTAddress(scoreNFT);
    }

    function setAirTokenAddress(
        IERC20 _airTokenContract
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        airTokenContract = _airTokenContract;
        emit SetAirTokenContractAddress(airTokenContract);
    }

    function setFeeCollectorAddress(
        address _feeCollector
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeCollector = _feeCollector;
        emit SetFeeCollectorAddress(feeCollector);
    }

    function setNumbersPerPartType(
        uint24[] calldata numbersPerPartType
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (
            numbersPerPartType.length == 0 ||
            numbersPerPartType.length > MAX_PART_TYPE
        ) {
            revert ExceedsMaximumLength();
        }

        for (uint i = 0; i < numbersPerPartType.length; ) {
            if (numbersPerPartType[i] > MAX_PART_NUMBER) {
                revert ExceedsMaximumLength();
            }

            numberPerPartType[uint8(i)] = numbersPerPartType[i];
            unchecked {
                ++i;
            }
        }
        numberOfPartTypes = uint8(numbersPerPartType.length);
        emit SetNumbersPerPartType(numbersPerPartType);
    }

    function setBaseSpaceshipRentalFee(
        uint _baseSpaceshipRentalFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseSpaceshipRentalFee = _baseSpaceshipRentalFee;
        emit SetBaseSpaceshipRentalFee(baseSpaceshipRentalFee);
    }

    function setBaseSpaceshipExtensionFee(
        uint _baseSpaceshipExtensionFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseSpaceshipExtensionFee = _baseSpaceshipExtensionFee;
        emit SetBaseSpaceshipExtensionFee(baseSpaceshipExtensionFee);
    }

    function setPartsMintingFee(
        uint _partsMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        partsMintingFee = _partsMintingFee;
        emit SetPartsMintingFee(partsMintingFee);
    }

    function setSpaceshipMintingFee(
        uint _spaceshipMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        spaceshipMintingFee = _spaceshipMintingFee;
        emit SetSpaceshipMintingFee(spaceshipMintingFee);
    }

    function setSpaceshipUpdatingFee(
        uint _spaceshipUpdatingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        spaceshipUpdatingFee = _spaceshipUpdatingFee;
        emit SetSpaceshipUpdatingFee(spaceshipUpdatingFee);
    }

    function setSpaceshipNicknameUpdatingFee(
        uint _spaceshipNicknameUpdatingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        spaceshipNicknameUpdatingFee = _spaceshipNicknameUpdatingFee;
        emit SetSpaceshipNicknameUpdatingFee(spaceshipNicknameUpdatingFee);
    }

    function setBadgeMintingFee(
        uint _badgeMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        badgeMintingFee = _badgeMintingFee;
        emit SetBadgeMintingFee(badgeMintingFee);
    }

    function setScoreMintingFee(
        uint _scoreMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        scoreMintingFee = _scoreMintingFee;
        emit SetScoreMintingFee(scoreMintingFee);
    }

    /* ============ Internal Functions ============ */

    // get pseudo random number between 0~max
    // @TODO replace with Chainlink or something equivalent
    function _getRandomNumber(
        uint max,
        uint randomNonce
    ) internal view returns (uint) {
        return
            uint(keccak256(abi.encodePacked(block.timestamp, randomNonce))) %
            (max + 1);
    }

    function _getRandomPartsId(
        uint randomNonce
    ) internal view returns (uint24) {
        uint8 partType = uint8(
            _getRandomNumber(uint256(numberOfPartTypes), randomNonce)
        );
        uint24 partNumber = uint24(
            _getRandomNumber(uint256(numberPerPartType[partType]), randomNonce)
        );
        return uint24(partType * 100000) + partNumber;
    }

    function _mintRandomParts(address to) internal {
        partsNFT.mintParts(to, _getRandomPartsId(0));
    }

    function _batchMintRandomParts(address to, uint amount) internal {
        uint256[] memory ids = new uint256[](amount);
        uint256[] memory amounts = new uint256[](amount);

        for (uint i = 0; i < amount; ) {
            ids[i] = _getRandomPartsId(i);
            amounts[i] = 1;
            unchecked {
                ++i;
            }
        }
        partsNFT.batchMintParts(to, ids, amounts);
    }

    function _mintNewSpaceship(
        address to,
        bytes32 nickname,
        uint24[] calldata parts
    ) internal {
        uint[] memory ids = new uint[](parts.length);
        uint[] memory amounts = new uint[](parts.length);

        for (uint i = 1; i < parts.length; ) {
            ids[i] = uint(parts[i]);
            amounts[i] = 1;
            unchecked {
                ++i;
            }
        }

        partsNFT.batchBurnParts(to, ids, amounts);
        spaceshipNFT.mintSpaceship(to, nickname, parts);
    }

    function _updateSpaceshipParts(
        address owner,
        uint tokenId,
        uint24[] calldata newParts
    ) internal {
        if (spaceshipNFT.ownerOf(tokenId) != owner) {
            revert NotTokenOnwer();
        }
        uint24[] memory currentParts = spaceshipNFT.getParts(tokenId);

        uint24[] memory parts = new uint24[](currentParts.length);

        for (uint i = 1; i < currentParts.length; ) {
            if (newParts[i] != uint(currentParts[i])) {
                partsNFT.burnParts(owner, newParts[i], 1);
            }
            parts[i] = newParts[i];
            unchecked {
                ++i;
            }
        }

        spaceshipNFT.updateSpaceshipParts(tokenId, parts);
    }

    function _checkSignature(
        bytes32 digest,
        Signature calldata signature
    ) internal view {
        // @TODO apply later with signed typed data
        // address signer = ecrecover(
        //     digest,
        //     signature.v,
        //     signature.r,
        //     signature.s
        // );
        // if (!hasRole(SIGNER_ROLE, signer)) {
        //     revert InvalidSignature();
        // }
    }
}
