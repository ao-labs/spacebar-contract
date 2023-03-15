// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Consecutive.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

// @TODO add natspec comments
contract UntitledSpaceship is ERC721Consecutive, AccessControl {
    /* ============ Variables ============ */

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    uint16 public constant MAX_UNTITLED_SPACESHIP = 1000;
    uint32 public constant ACCESS_PERIOD = 7 days;

    mapping(address => Access) private _accesses;
    mapping(uint256 => address) private _userAddresses;

    /* ============ Structs ============ */

    struct Access {
        uint256 tokenId;
        address user;
        uint64 expirationDate;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    /* ============ Events ============ */

    event AccessGranted(address indexed user, uint256 indexed tokenId);
    event AccessClaimed(address indexed user, uint256 indexed tokenId);
    event AccessExtended(
        address indexed user,
        uint256 indexed tokenId,
        uint64 expirationDate
    );
    event AccessExtendedByAdmin(
        address indexed user,
        uint256 indexed tokenId,
        uint64 expirationDate
    );

    /* ============ Errors ============ */

    error AlreadyHaveAccess(address user, uint256 tokenId);
    error AlreadyClaimedToken(uint256 tokenId);
    error NotWithinExtensionPeriod(address user, uint256 tokenId);
    error InvalidSignature();

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

    constructor(
        address _signer,
        address _burner
    ) ERC721("Untitled Spaceship", "US") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(SIGNER_ROLE, _signer);
        _grantRole(BURNER_ROLE, _burner);
        _mintConsecutive(msg.sender, MAX_UNTITLED_SPACESHIP);
    }

    /* ============ External Functions ============ */

    // @TODO add parameter checks

    // @TODO may require signature check in the future
    function grantTemporaryAccess(
        address user,
        uint256 tokenId
    )
        external
        onlyRole(SIGNER_ROLE)
        onlyUserWithoutAccess(user, tokenId)
        onlyTokenWithoutAccess(tokenId)
    {
        _accesses[user] = Access(
            tokenId,
            user,
            uint64(block.timestamp + ACCESS_PERIOD)
        );
        _userAddresses[tokenId] = user;
        emit AccessGranted(user, tokenId);
    }

    function claimTemporaryAccess(
        uint256 tokenId,
        Signature calldata signature
    )
        external
        onlyUserWithoutAccess(msg.sender, tokenId)
        onlyTokenWithoutAccess(tokenId)
    {
        // @TODO format of digest may change in the future
        bytes32 digest = keccak256(
            abi.encode(
                "claimTemporaryAccess",
                tokenId,
                msg.sender,
                address(this)
            )
        );
        _checkSignature(digest, signature);

        _accesses[msg.sender] = Access(
            tokenId,
            msg.sender,
            uint64(block.timestamp + ACCESS_PERIOD)
        );
        _userAddresses[tokenId] = msg.sender;
        emit AccessClaimed(msg.sender, tokenId);
    }

    function extendAccessPeriod(
        uint256 tokenId,
        Signature calldata signature
    ) external onlyTokenWithinExtensionPeriod(msg.sender, tokenId) {
        bytes32 digest = keccak256(
            abi.encode("extendAccessPeriod", tokenId, msg.sender, address(this))
        );
        _checkSignature(digest, signature);
        _accesses[msg.sender].expirationDate += ACCESS_PERIOD;
        emit AccessExtended(
            msg.sender,
            tokenId,
            _accesses[msg.sender].expirationDate
        );
    }

    function extendAccessPeriodByAdmin(
        address user,
        uint256 tokenId
    )
        external
        onlyRole(SIGNER_ROLE)
        onlyTokenWithinExtensionPeriod(user, tokenId)
    {
        _accesses[user].expirationDate += ACCESS_PERIOD;
        emit AccessExtendedByAdmin(
            user,
            tokenId,
            _accesses[user].expirationDate
        );
    }

    /// @notice Untitled spaceship is burned to create an ultimate spaceship
    function burn(uint256 tokenId) external onlyRole(BURNER_ROLE) {
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

    function _checkSignature(
        bytes32 digest,
        Signature calldata signature
    ) internal view {
        address signer = ecrecover(
            digest,
            signature.v,
            signature.r,
            signature.s
        );
        if (!hasRole(SIGNER_ROLE, signer)) {
            revert InvalidSignature();
        }
    }

    // @TODO URI may change in the future
    function _baseURI() internal pure override returns (string memory) {
        return "https://www.spacebar.xyz/untitled/";
    }
}
