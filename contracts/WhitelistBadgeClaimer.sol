// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./interfaces/ISpaceFactoryV1.sol";
import "./helper/Error.sol";

/// @title WhitelistBadgeClaimer
/// @dev This contract allows whitelisted accounts to claim a whitelist badge (SBT)
/// to the TBA address associated with the user's NFT.
/// Since the whitelist is managed by the server, server-side signature is required to claim the badge.
contract WhitelistBadgeClaimer is Ownable {
    /* ============ Variables ============ */
    ISpaceFactoryV1 public spaceFactory;
    address public serviceAdmin;
    string public tokenURI;
    uint256 public maxNumberOfClaims = 1;
    mapping(address => uint256) public numberOfClaims;

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
    ) {
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
            getSigner(addressToString(msg.sender), signature) == serviceAdmin,
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

    /* ============ Helper Functions ============ */

    ///@dev Returns the signer of the signature
    ///@param message The message signed to produce the signature
    ///@param signature Signature in bytes
    function getSigner(
        string memory message,
        bytes memory signature
    ) public pure returns (address) {
        (address signer, ) = ECDSA.tryRecover(
            ECDSA.toEthSignedMessageHash(bytes(message)),
            signature
        );
        return signer;
    }

    ///@dev Returns the string representation of an address
    ///@param _address The address to convert to string
    function addressToString(
        address _address
    ) public pure returns (string memory) {
        bytes32 _bytes = bytes32(uint256(uint160(_address)));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = "0";
        _string[1] = "x";
        for (uint i = 0; i < 20; i++) {
            _string[2 + i * 2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3 + i * 2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }
}
