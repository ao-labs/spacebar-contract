// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ISpaceFactoryV1.sol";
import "./helper/Error.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/// @title WhitelistBadgeClaimer
/// @dev This contract allows whitelisted accounts to claim a whitelist badge (SBT)
/// to the TBA address associated with the user's NFT.
/// Since the whitelist is managed by the server, server-side signature is required to claim the badge.
contract WhitelistBadgeClaimer is Ownable, EIP712 {
    /* ============ Variables ============ */
    ISpaceFactoryV1 public spaceFactory;
    address public serviceAdmin;
    string public tokenURI;
    uint256 public maxNumberOfClaims = 1;
    mapping(address => uint256) public numberOfClaims;

    bytes32 public constant CLAIMER_TYPEHASH =
        keccak256("Claimer(address account)");

    /* ============ Events ============ */

    event SetMaxNumberOfClaims(uint256 maxNumberOfClaims);
    event SetTokenURI(string tokenURI);
    event SetServiceAdmin(address serviceAdmin);

    /* ============ Constructor ============ */

    constructor(
        ISpaceFactoryV1 _spaceFactory,
        address _owner,
        address _serviceAdmin,
        string memory _tokenURI
    ) EIP712("Spacebar", "1") {
        spaceFactory = _spaceFactory;
        serviceAdmin = _serviceAdmin;
        tokenURI = _tokenURI;
        transferOwnership(_owner);
        emit SetTokenURI(_tokenURI);
        emit SetServiceAdmin(_serviceAdmin);
    }

    /* ============ Admin Functions ============ */

    /// @dev Sets the maximum number of claims per account. Default is 1.
    function setMaxNumberOfClaims(
        uint256 _maxNumberOfClaims
    ) external onlyOwner {
        maxNumberOfClaims = _maxNumberOfClaims;
        emit SetMaxNumberOfClaims(_maxNumberOfClaims);
    }

    /// @dev Sets the token URI of the badge to be minted.
    function setTokenURI(string memory _tokenURI) external onlyOwner {
        tokenURI = _tokenURI;
        emit SetTokenURI(_tokenURI);
    }

    /// @dev Sets the service admin address.
    function setServiceAdmin(address _serviceAdmin) external onlyOwner {
        serviceAdmin = _serviceAdmin;
        emit SetServiceAdmin(_serviceAdmin);
    }

    /* ============ External Functions ============ */

    /// @notice Claims a whitelist badge (SBT) to the TBA address associated with the user's NFT.
    /// Server keeps the whiltelisted EOA addresses and makes a signature with EOA address
    /// if that address is whitelisted.
    /// @param signature The signature signed by the service admin.
    /// @param tokenContract The contract address of the user's NFT.
    /// @param tokenId The token ID of the user's NFT.
    function claimBadge(
        bytes memory signature,
        address tokenContract,
        uint256 tokenId
    ) external {
        require(
            IERC721(tokenContract).ownerOf(tokenId) == msg.sender,
            "WhitelistBadgeClaimer: sender is not owner"
        );
        // check whether the service admin has signed to the EOA string of the sender
        require(
            getSigner((msg.sender), signature) == serviceAdmin,
            "WhitelistBadgeClaimer: signer is not serviceAdmin"
        );

        require(
            numberOfClaims[msg.sender] < maxNumberOfClaims,
            "WhitelistBadgeClaimer: exceeds maxNumberOfClaims"
        );
        numberOfClaims[msg.sender] += 1;

        spaceFactory.mintWhitelistBadgeUniverse1(
            tokenContract,
            tokenId,
            tokenURI
        );
    }

    /* ============ EIP712 Functions ============ */

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

    ///@dev Returns the signer of the signature
    ///@param account The claimer account
    ///@param signature Signature in bytes
    function getSigner(
        address account,
        bytes memory signature
    ) public view returns (address) {
        bytes32 structHash = keccak256(abi.encode(CLAIMER_TYPEHASH, account));
        return ECDSA.recover(_hashTypedDataV4(structHash), signature);
    }
}
