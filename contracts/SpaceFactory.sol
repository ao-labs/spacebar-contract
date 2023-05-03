// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBaseSpaceshipNFT.sol";
import "./interfaces/ISpaceshipNFT.sol";
import "./interfaces/IPartsNFT.sol";
import "./interfaces/IBadgeSBT.sol";
import "./interfaces/IScoreNFT.sol";

// @TODO implement upgradeability
/// @title Space Factory contract.
/// @notice This contract is responsible for minting and burning various NFTs and SBTs.
/// Functions with ByAdmin suffix are designed to be called by the admin(SERVICE_ADMIN_ROLE), so that users
/// don't have to pay for gas fees.
contract SpaceFactory is AccessControl {
    /* ============ Variables ============ */

    /// @dev The constant for the service admin role
    bytes32 public constant SERVICE_ADMIN_ROLE =
        keccak256("SERVICE_ADMIN_ROLE");

    uint public baseSpaceshipRentalFee;
    uint public baseSpaceshipExtensionFee;
    uint public spaceshipNicknameUpdatingFee;
    uint public scoreMintingFee;
    uint public spaceshipUpdatingFee;
    uint public spaceshipMintingFee;
    uint public partsMintingFee;

    /// @notice badge and special parts minting fees can vary depending on the type of badge or part
    mapping(uint8 => uint) public badgeMintingFee; // badgeMintingFee[category] = fee
    mapping(uint => uint) public specialPartsMintingFee; // specialPartsMintingFee[partsTokenId] = fee

    /// @dev How many parts of each type are available
    /// for example, [100, 200, 300] means that there are 100 parts of type 1, 200 parts of type 2, and 300 parts of type 3
    uint24[] public quantityPerPartsType;
    mapping(address => uint) private baseSpaceshipUserMap; // baseSpaceshipUserMap[user] = tokenId

    IBaseSpaceshipNFT public baseSpaceshipNFT;
    ISpaceshipNFT public spaceshipNFT;
    IPartsNFT public partsNFT;
    IBadgeSBT public badgeSBT;
    IScoreNFT public scoreNFT;
    IERC20 public airTokenContract;
    /// @dev Collected fee ($AIR) is immediately sent to this address
    address public feeCollector;

    uint8 constant MAX_PART_TYPE = 16;
    uint24 constant MAX_PART_QUANTITY = 777215;
    uint16 constant MAX_PARTS_MINTING_SUCCESS_RATE = 10000; // 100%
    uint24 constant MIN_PART_ID = 1000001;
    uint16 public partsMintingSuccessRate; // Basis points (Max: 10000)

    uint64 public baseSpaceshipAccessPeriod;

    /* ============ Structs ============ */

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /* ============ Events ============ */

    event SetBaseSpaceshipAccessPeriod(uint period);
    event SetBaseSpaceshipNFTAddress(IBaseSpaceshipNFT indexed newAddress);
    event SetSpaceshipNFTAddress(ISpaceshipNFT indexed newAddress);
    event SetPartsNFTAddress(IPartsNFT indexed newAddress);
    event SetBadgeSBTAddress(IBadgeSBT indexed newAddress);
    event SetScoreNFTAddress(IScoreNFT indexed newAddress);
    event SetAirTokenContractAddress(IERC20 indexed newAddress);
    event SetFeeCollectorAddress(address indexed newAddress);
    event SetPartsMintingSuccessRate(uint16 rate);
    event SetQuantityPerPartsType(uint24[] quantityPerPartsType);

    event SetBaseSpaceshipRentalFee(uint fee);
    event SetBaseSpaceshipExtensionFee(uint fee);
    event SetPartsMintingFee(uint fee);
    event SetSpecialPartsMintingFee(uint indexed id, uint fee);
    event SetSpaceshipMintingFee(uint fee);
    event SetSpaceshipUpdatingFee(uint fee);
    event SetSpaceshipNicknameUpdatingFee(uint fee);
    event SetBadgeMintingFee(uint8 indexed category, uint fee);
    event SetScoreMintingFee(uint fee);

    /* ============ Errors ============ */

    error UnavailableBaseSpaceship(uint256 tokenId, address currentUser);
    error AlreadyUserOfBaseSpaceship();
    error NotWithinExtensionPeriod(uint256 tokenId, uint256 currentExpires);
    error NotUserOfBaseSpaceship(uint256 tokenId, address currentUser);
    error InvalidSignature();
    error InvalidListLength();
    error InvalidTypeOrder();
    error ExceedsMaximumLength();
    error ContractNotAvailable();
    error InvalidAmount();
    error InvalidAddress();
    error NotTokenOnwer();
    error InvalidRate();
    error InvalidId();
    error InvalidPartsLength();

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

    modifier onlySpaceshipOwner(address user, uint tokenId) {
        if (spaceshipNFT.ownerOf(tokenId) != user) {
            revert NotTokenOnwer();
        }
        _;
    }

    /* ============ Constructor ============ */

    // @TODO upgradeable init function
    constructor(
        address _serviceAdmin,
        uint24[] memory _quantityPerPartsType,
        uint16 _partsMintingSuccessRate
    ) {
        if (_partsMintingSuccessRate > MAX_PARTS_MINTING_SUCCESS_RATE) {
            revert InvalidRate();
        }
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SERVICE_ADMIN_ROLE, _serviceAdmin);
        _setQuantityPerPartsType(_quantityPerPartsType);
        baseSpaceshipAccessPeriod = 7 days;
        partsMintingSuccessRate = _partsMintingSuccessRate;
        emit SetBaseSpaceshipAccessPeriod(baseSpaceshipAccessPeriod);
        emit SetPartsMintingSuccessRate(partsMintingSuccessRate);
    }

    /* ============ External Functions ============ */

    // @TODO use sign typed data + custom nonce (if necessary)
    // ex. @openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol
    /// @notice rent a base spaceship. User has to extend the rental period before it expires.
    /// @dev Rent expires at current time + baseSpaceshipAccessPeriod.
    /// It reverts if the base spaceship is already rented by someone else, or the address already has one.
    /// @param tokenId base spaceship token id
    /// @param signature signature from the service admin
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
        _rentBaseSpaceship(tokenId, msg.sender);
    }

    // @TODO should admin functions also provide user's signature?
    /// @notice admin function for renting a base spaceship
    /// @param tokenId base spaceship token id
    /// @param user user address
    function rentBaseSpaceshipByAdmin(
        uint tokenId,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, baseSpaceshipRentalFee)
    {
        _rentBaseSpaceship(tokenId, user);
    }

    /// @notice extend the rental period of a base spaceship
    /// @dev It extends period by baseSpaceshipAccessPeriod.
    /// @param tokenId base spaceship token id
    /// @param signature signature from the service admin
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
        _extendBaseSpaceshipAccess(tokenId, msg.sender);
    }

    /// @notice admin function for extending the rental period of a base spaceship
    /// @param tokenId base spaceship token id
    /// @param user user address
    function extendBaseSpaceshipByAdmin(
        uint tokenId,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, baseSpaceshipExtensionFee)
    {
        _extendBaseSpaceshipAccess(tokenId, user);
    }

    /// @notice minting random parts
    /// @dev based on the quantityPerPartsType, it will randomly choose a token id and mint token to user.
    /// Based on partsMintingSuccessRate (0-10000), it will mint successfully or not.
    /// For example, if partsMintingSuccessRate is 5000 and amount is 10, you can expect 5 parts will be minted.
    /// @param amount amount of parts to mint
    /// @param signature signature from the service admin
    function mintRandomParts(
        uint amount,
        Signature calldata signature
    )
        external
        collectFee(msg.sender, partsMintingFee)
        returns (uint[] memory ids)
    {
        if (amount == 0) {
            revert InvalidAmount();
        }
        bytes32 digest = keccak256(
            abi.encode("mintParts", msg.sender, partsNFT, amount)
        );
        _checkSignature(digest, signature);

        if (amount == 1) {
            uint[] memory id = new uint[](1);
            id[0] = _mintRandomParts(msg.sender, 0);
            return id;
        }
        if (amount > 1) {
            return _batchMintRandomParts(msg.sender, amount);
        }
    }

    /// @notice Admin function for minting random parts
    /// @param amount amount of parts to mint
    /// @param user user address
    function mintRandomPartsByAdmin(
        uint amount,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, partsMintingFee)
        returns (uint[] memory ids)
    {
        if (amount == 0) {
            revert InvalidAmount();
        }
        if (amount == 1) {
            uint[] memory id = new uint[](1);
            id[0] = _mintRandomParts(user, 0);
            return id;
        }
        if (amount > 1) {
            return _batchMintRandomParts(user, amount);
        }
    }

    /// @notice mint special parts
    /// @dev specialPartsMintingFee must be set before minting
    /// @param id token id
    /// @param signature signature from the service admin
    function mintSpecialParts(
        uint id,
        Signature calldata signature
    ) external collectFee(msg.sender, specialPartsMintingFee[id]) {
        if (specialPartsMintingFee[id] == 0) {
            revert InvalidId();
        }

        bytes32 digest = keccak256(
            abi.encode("mintSpecialParts", msg.sender, id)
        );
        _checkSignature(digest, signature);

        partsNFT.mintParts(msg.sender, id);
    }

    /// @notice admin function for minting special parts
    /// @param id token id
    /// @param user user to mint special parts to
    function mintSpecialPartsByAdmin(
        uint id,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, specialPartsMintingFee[id])
    {
        if (specialPartsMintingFee[id] == 0) {
            revert InvalidId();
        }
        partsNFT.mintParts(user, id);
    }

    // @TODO should check the length of the parts list?
    /// @notice minting new spaceship
    /// @dev This will burn the base spaceship and parts, and mint a new spaceship to user.
    /// User must be user of base spaceship, and must own all the parts.
    /// @param baseSpaceshipTokenId base spaceship token id
    /// @param nickname nickname of the new spaceship
    /// @param parts list of the parts to use
    /// @param signature signature from the service admin
    function mintNewSpaceship(
        uint256 baseSpaceshipTokenId,
        bytes32 nickname,
        uint24[] calldata parts,
        Signature calldata signature
    ) external collectFee(msg.sender, spaceshipMintingFee) {
        bytes32 digest = keccak256(
            abi.encode(
                "mintNewSpaceship",
                baseSpaceshipTokenId,
                nickname,
                msg.sender,
                parts
            )
        );
        _checkSignature(digest, signature);
        _mintNewSpaceship(msg.sender, baseSpaceshipTokenId, nickname, parts);
    }

    /// @notice admin function for minting new spaceship
    /// @param baseSpaceshipTokenId base spaceship token id
    /// @param nickname nickname of the new spaceship
    /// @param parts list of the parts to use
    /// @param user user address to mint spaceship to
    function mintNewSpaceshipByAdmin(
        uint256 baseSpaceshipTokenId,
        bytes32 nickname,
        uint24[] calldata parts,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, spaceshipMintingFee)
    {
        _mintNewSpaceship(user, baseSpaceshipTokenId, nickname, parts);
    }

    /// @notice update spaceship parts
    /// @dev User has to provide the full list of the parts. And this function will compare the current parts
    /// with the new parts, and burn the parts that are not in the new list.
    /// ex. current parts: [A, B, C, D, E], new parts: [A, B, C, F, G], than this function will burn F and G from user
    /// It will revert if user doesn't own F and G.
    /// @param tokenId spaceship token id
    /// @param newParts list of the new parts
    /// @param signature signature from the service admin
    function updateSpaceshipParts(
        uint tokenId,
        uint24[] calldata newParts,
        Signature calldata signature
    )
        external
        collectFee(msg.sender, spaceshipUpdatingFee)
        onlySpaceshipOwner(msg.sender, tokenId)
    {
        bytes32 digest = keccak256(
            abi.encode("updateSpaceshipParts", msg.sender, tokenId, newParts)
        );
        _checkSignature(digest, signature);
        _updateSpaceshipParts(msg.sender, tokenId, newParts);
    }

    /// @notice admin function for updating spaceship parts
    /// @param tokenId spaceship token id
    /// @param newParts list of the new parts
    /// @param user user who owns the spaceship
    function updateSpaceshipPartsByAdmin(
        uint tokenId,
        uint24[] calldata newParts,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        onlySpaceshipOwner(user, tokenId)
        collectFee(user, spaceshipUpdatingFee)
    {
        _updateSpaceshipParts(user, tokenId, newParts);
    }

    /// @notice updates spaceship nickname
    /// @param tokenId spaceship token id
    /// @param nickname new nickname
    function updateSpaceshipNickname(
        uint tokenId,
        bytes32 nickname,
        Signature calldata signature
    )
        external
        onlySpaceshipOwner(msg.sender, tokenId)
        collectFee(msg.sender, spaceshipNicknameUpdatingFee)
    {
        bytes32 digest = keccak256(
            abi.encode("updateSpaceshipNickname", msg.sender, tokenId, nickname)
        );
        _checkSignature(digest, signature);
        spaceshipNFT.updateSpaceshipNickname(tokenId, nickname);
    }

    /// @notice admin function for updating spaceship nickname
    /// @param tokenId spaceship token id
    /// @param nickname new nickname
    /// @param user user who owns the spaceship
    function updateSpaceshipNicknameByAdmin(
        uint tokenId,
        bytes32 nickname,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        onlySpaceshipOwner(user, tokenId)
        collectFee(user, spaceshipNicknameUpdatingFee)
    {
        spaceshipNFT.updateSpaceshipNickname(tokenId, nickname);
    }

    /// @notice mint score NFT to user
    /// @param category category of the score (ex. 1: Single Player, 2: Multiplayer etc)
    /// @param score user's score
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

    /// @notice admin function for minting score NFT to user
    /// @param category category of the score (ex. 1: Single Player, 2: Multiplayer etc)
    /// @param score user's score
    /// @param user user address to mint score NFT to
    function mintScoreByAdmin(
        uint8 category,
        uint88 score,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, scoreMintingFee)
    {
        scoreNFT.mintScore(user, category, score);
    }

    /// @notice mint badge SBT to user
    /// @param category category of the badge (ex. 1: Elite, 2: Creative etc)
    /// @param burnAuth burn authorization of the badge. See IERC5484
    /// @param signature signature from the service admin
    function mintBadge(
        uint8 category,
        IBadgeSBT.BurnAuth burnAuth,
        Signature calldata signature
    ) external collectFee(msg.sender, badgeMintingFee[category]) {
        bytes32 digest = keccak256(
            abi.encode("mintBadge", category, burnAuth, msg.sender)
        );
        _checkSignature(digest, signature);
        badgeSBT.mintBadge(msg.sender, category, burnAuth);
    }

    /// @notice admin function for minting badge SBT to user
    /// @param category category of the badge (ex. 1: Elite, 2: Creative etc)
    /// @param burnAuth burn authorization of the badge. See IERC5484
    /// @param user user address to mint badge SBT to
    function mintBadgeByAdmin(
        uint8 category,
        IBadgeSBT.BurnAuth burnAuth,
        address user
    )
        external
        addressCheck(user)
        onlyRole(SERVICE_ADMIN_ROLE)
        collectFee(user, badgeMintingFee[category])
    {
        badgeSBT.mintBadge(user, category, burnAuth);
    }

    /* ============ Admin Functions ============ */

    function setBaseSpaceshipAccessPeriod(
        uint64 _baseSpaceshipAccessPeriod
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseSpaceshipAccessPeriod = _baseSpaceshipAccessPeriod;
        emit SetBaseSpaceshipAccessPeriod(baseSpaceshipAccessPeriod);
    }

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

    function setPartsNFTAddress(
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

    function setQuantityPerPartsType(
        uint24[] calldata _quantityPerPartsType
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setQuantityPerPartsType(_quantityPerPartsType);
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
        emit SetPartsMintingFee(_partsMintingFee);
    }

    function setSpecialPartsMintingFee(
        uint id,
        uint _partsMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (id < MIN_PART_ID) {
            revert InvalidAmount();
        }
        specialPartsMintingFee[id] = _partsMintingFee;
        emit SetSpecialPartsMintingFee(id, _partsMintingFee);
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
        uint8 category,
        uint _badgeMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        badgeMintingFee[category] = _badgeMintingFee;
        emit SetBadgeMintingFee(category, _badgeMintingFee);
    }

    function setScoreMintingFee(
        uint _scoreMintingFee
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        scoreMintingFee = _scoreMintingFee;
        emit SetScoreMintingFee(scoreMintingFee);
    }

    function setPartsMintingSuccessRate(
        uint16 _partsMintingSuccessRate
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_partsMintingSuccessRate > MAX_PARTS_MINTING_SUCCESS_RATE) {
            revert InvalidRate();
        }
        partsMintingSuccessRate = _partsMintingSuccessRate;
        emit SetPartsMintingSuccessRate(partsMintingSuccessRate);
    }

    /* ============ Internal Functions ============ */

    function _rentBaseSpaceship(uint256 tokenId, address user) internal {
        if (baseSpaceshipNFT.userOf(tokenId) != address(0)) {
            revert UnavailableBaseSpaceship(
                tokenId,
                baseSpaceshipNFT.userOf(tokenId)
            );
        }
        if (baseSpaceshipNFT.userOf(baseSpaceshipUserMap[user]) != address(0)) {
            revert AlreadyUserOfBaseSpaceship(); // Can only rent one base spaceship at a time
        }
        baseSpaceshipUserMap[user] = tokenId;
        baseSpaceshipNFT.setUser(
            tokenId,
            user,
            uint64(block.timestamp + baseSpaceshipAccessPeriod)
        );
    }

    function _extendBaseSpaceshipAccess(
        uint256 tokenId,
        address user
    ) internal {
        if (baseSpaceshipNFT.userOf(tokenId) != user) {
            revert NotUserOfBaseSpaceship(
                tokenId,
                baseSpaceshipNFT.userOf(tokenId)
            );
        }

        uint currentExpires = baseSpaceshipNFT.userExpires(tokenId);

        if (currentExpires >= block.timestamp + baseSpaceshipAccessPeriod) {
            revert NotWithinExtensionPeriod(tokenId, currentExpires);
        }

        baseSpaceshipNFT.setUser(
            tokenId,
            user,
            uint64(currentExpires + baseSpaceshipAccessPeriod)
        );
    }

    function _setQuantityPerPartsType(
        uint24[] memory _quantityPerPartsType
    ) internal {
        if (
            _quantityPerPartsType.length == 0 ||
            _quantityPerPartsType.length > MAX_PART_TYPE
        ) {
            revert ExceedsMaximumLength();
        }

        for (uint i = 0; i < _quantityPerPartsType.length; ) {
            if (_quantityPerPartsType[i] > MAX_PART_QUANTITY) {
                revert ExceedsMaximumLength();
            }
            unchecked {
                ++i;
            }
        }

        quantityPerPartsType = _quantityPerPartsType;
        emit SetQuantityPerPartsType(_quantityPerPartsType);
    }

    // get pseudo random number between 1~max
    // @TODO replace with Chainlink or something equivalent
    function _getRandomNumber(
        uint max,
        uint randomNonce
    ) internal view returns (uint) {
        return
            1 +
            (uint(keccak256(abi.encodePacked(block.timestamp, randomNonce))) %
                max);
    }

    function _getRandomPartsId(
        uint randomNonce
    ) internal view returns (uint24) {
        uint8 partType = uint8(
            _getRandomNumber(uint256(quantityPerPartsType.length), randomNonce)
        );
        uint24 partNumber = uint24(
            _getRandomNumber(
                uint256(quantityPerPartsType[partType - 1]),
                randomNonce
            )
        );
        return uint24(partType * 100000) + partNumber;
    }

    function _mintRandomParts(
        address to,
        uint randomNonce
    ) internal returns (uint) {
        if (_getRandomNumber(9999, randomNonce) < partsMintingSuccessRate) {
            uint id = _getRandomPartsId(randomNonce);
            partsNFT.mintParts(to, id);
            return id;
        }
        return 0;
    }

    function _batchMintRandomParts(
        address to,
        uint amount
    ) internal returns (uint[] memory) {
        uint256[] memory ids = new uint256[](amount);
        for (uint i = 0; i < amount; ) {
            ids[i] = _mintRandomParts(to, i);
            unchecked {
                ++i;
            }
        }
        return ids;
    }

    function _mintNewSpaceship(
        address to,
        uint256 baseSpaceshipTokenId,
        bytes32 nickname,
        uint24[] calldata parts
    ) internal {
        if (baseSpaceshipNFT.userOf(baseSpaceshipTokenId) != to) {
            revert NotUserOfBaseSpaceship(
                baseSpaceshipTokenId,
                baseSpaceshipNFT.userOf(baseSpaceshipTokenId)
            );
        }

        uint[] memory ids = new uint[](parts.length);
        uint[] memory amounts = new uint[](parts.length);

        for (uint i = 0; i < parts.length; ) {
            ids[i] = uint(parts[i]);
            amounts[i] = 1;
            unchecked {
                ++i;
            }
        }
        baseSpaceshipNFT.burn(baseSpaceshipTokenId);
        partsNFT.batchBurnParts(to, ids, amounts);
        spaceshipNFT.mintSpaceship(to, nickname, parts);
    }

    function _updateSpaceshipParts(
        address owner,
        uint tokenId,
        uint24[] calldata newParts
    ) internal {
        uint24[] memory currentParts = spaceshipNFT.getParts(tokenId);

        if (currentParts.length != newParts.length) {
            revert InvalidPartsLength();
        }

        uint24[] memory parts = new uint24[](currentParts.length);

        for (uint i = 0; i < currentParts.length; ) {
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
        // address serviceAdmin = ecrecover(
        //     digest,
        //     signature.v,
        //     signature.r,
        //     signature.s
        // );
        // if (!hasRole(SERVICE_ADMIN_ROLE, serviceAdmin)) {
        //     revert InvalidSignature();
        // }
    }
}
