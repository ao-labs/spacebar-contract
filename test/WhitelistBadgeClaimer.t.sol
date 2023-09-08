// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/WhitelistBadgeClaimer.sol";
import "../contracts/ERC6551/ERC6551Registry.sol";
import "../contracts/ERC6551/ERC6551Account.sol";
import "../contracts/ERC6551/AccountProxy.sol";
import "../contracts/SpaceFactoryV1.sol";
import "../contracts/BadgeUniverse1.sol";
import "./mocks/MockERC721.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract WhitelistBadgeClaimerTest is Test {
    ERC6551Registry public registry;
    ERC6551Account public erc6551Account;
    IERC6551Account public implementation;
    SpaceFactoryV1 public factory;
    SpaceFactoryV1 public factoryImplemenation;
    BadgeUniverse1 public badge;
    MockERC721 public externalERC721;
    WhitelistBadgeClaimer public whitelistBadgeClaimer;

    address defaultAdmin;
    address serviceAdmin;
    uint256 serviceAdminPk;
    address minterAdmin;
    address whitelistBadgeClaimerAdmin;
    address userA;
    address userB;
    string tokenURI = "randomString";

    function setUp() public {
        defaultAdmin = vm.addr(1);
        serviceAdminPk = 2;
        serviceAdmin = vm.addr(serviceAdminPk);
        minterAdmin = vm.addr(3);
        whitelistBadgeClaimerAdmin = vm.addr(4);
        userA = vm.addr(5);
        userB = vm.addr(6);
        externalERC721 = new MockERC721();
        registry = new ERC6551Registry();
        erc6551Account = new ERC6551Account();
        // implementation is also a proxy to ERC6551Account
        implementation = IERC6551Account(
            payable(address(new AccountProxy(address(erc6551Account))))
        );
        factoryImplemenation = new SpaceFactoryV1();
        factory = SpaceFactoryV1(
            address(
                new ERC1967Proxy(
                    address(factoryImplemenation),
                    abi.encodeWithSignature(
                        "initialize(address,address,address,address,address,bool,(uint128,uint128))",
                        defaultAdmin,
                        serviceAdmin,
                        minterAdmin,
                        registry,
                        implementation,
                        false,
                        IBadgeUniverse1.TokenType(0, 0)
                    )
                )
            )
        );
        badge = new BadgeUniverse1(address(factory), defaultAdmin);
        whitelistBadgeClaimer = new WhitelistBadgeClaimer(
            factory,
            whitelistBadgeClaimerAdmin,
            serviceAdmin,
            tokenURI
        );
        vm.startPrank(defaultAdmin);
        factory.setBadgeUniverse1(address(badge));
        factory.grantRole(
            factory.MINTER_ROLE(),
            address(whitelistBadgeClaimer)
        );
        vm.stopPrank();
    }

    function testAddressToString() public {
        address acoount = 0x48715b9451C3FE79D176A86AE227714ce85a7072;
        assertEq(
            whitelistBadgeClaimer.addressToString(acoount),
            "0x48715b9451c3fe79d176a86ae227714ce85a7072"
        );
    }

    function testGetSigner() public {
        address eoa = vm.addr(1000);
        uint256 pk = 1001;
        bytes memory signature = makeSignature(pk, eoa);
        address signer = whitelistBadgeClaimer.getSigner(
            whitelistBadgeClaimer.addressToString(eoa),
            signature
        );
        assertEq(signer, vm.addr(pk));
    }

    function testClaimBadge() public {
        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(serviceAdminPk, userA);

        vm.prank(userA);
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );

        address userATBA = registry.account(
            address(implementation),
            block.chainid,
            address(externalERC721),
            tokenId, // token id
            0 // salt
        );

        assertEq(
            badge.ownerOf(0), // badge token id starts from 0
            userATBA
        );

        assertEq(badge.tokenURI(0), string.concat("ipfs://", tokenURI));
    }

    function testClaimBadgeWithInvalidSignature() public {
        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(1000, userA); //random PK

        vm.prank(userA);
        vm.expectRevert("WhitelistBadgeClaimer: signer is not serviceAdmin");
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );
    }

    function testClaimBadgeWithInvalidToken() public {
        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(serviceAdminPk, userA);

        vm.prank(userA);
        vm.expectRevert("ERC721: invalid token ID");
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId + 1 // invalid token id
        );
    }

    function testClaimBadgeWithInvalidOwner() public {
        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(serviceAdminPk, userA);

        vm.prank(userB); // invalid owner
        vm.expectRevert("WhitelistBadgeClaimer: sender is not owner");
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );
    }

    function testClaimBadgeExceedsMaxNumberOfClaims() public {
        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(serviceAdminPk, userA);

        vm.startPrank(userA);
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );

        vm.expectRevert("WhitelistBadgeClaimer: exceeds maxNumberOfClaims");
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );
    }

    function testMaxNumberOfClaims() public {
        assertEq(whitelistBadgeClaimer.maxNumberOfClaims(), 1);
        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.setMaxNumberOfClaims(0);
        assertEq(whitelistBadgeClaimer.maxNumberOfClaims(), 0);

        uint256 tokenId = 0;
        externalERC721.mint(userA, tokenId);
        bytes memory signature = makeSignature(serviceAdminPk, userA);

        vm.prank(userA);
        vm.expectRevert("WhitelistBadgeClaimer: exceeds maxNumberOfClaims");
        whitelistBadgeClaimer.claimBadge(
            signature,
            address(externalERC721),
            tokenId
        );

        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.setMaxNumberOfClaims(2);
        assertEq(whitelistBadgeClaimer.maxNumberOfClaims(), 2);

        for (uint256 i = 0; i < 3; i++) {
            vm.prank(userA);
            if (i == 2) {
                vm.expectRevert(
                    "WhitelistBadgeClaimer: exceeds maxNumberOfClaims"
                );
            }
            whitelistBadgeClaimer.claimBadge(
                signature,
                address(externalERC721),
                tokenId
            );
        }
    }

    function testOwnerFunctions() public {
        assertEq(whitelistBadgeClaimer.owner(), whitelistBadgeClaimerAdmin);

        vm.expectRevert("Ownable: caller is not the owner");
        whitelistBadgeClaimer.setMaxNumberOfClaims(0);

        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.setMaxNumberOfClaims(0);
        assertEq(whitelistBadgeClaimer.maxNumberOfClaims(), 0);

        string memory newURI = "newURI";
        vm.expectRevert("Ownable: caller is not the owner");
        whitelistBadgeClaimer.setTokenURI(newURI);

        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.setTokenURI(newURI);
        assertEq(whitelistBadgeClaimer.tokenURI(), newURI);

        vm.expectRevert("Ownable: caller is not the owner");
        whitelistBadgeClaimer.setServiceAdmin(userA);

        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.setServiceAdmin(userA);
        assertEq(whitelistBadgeClaimer.serviceAdmin(), userA);

        vm.expectRevert("Ownable: caller is not the owner");
        whitelistBadgeClaimer.transferOwnership(userA);

        assertEq(whitelistBadgeClaimer.owner(), whitelistBadgeClaimerAdmin);
        vm.prank(whitelistBadgeClaimerAdmin);
        whitelistBadgeClaimer.transferOwnership(userA);
        assertEq(whitelistBadgeClaimer.owner(), userA);
    }

    function makeSignature(
        uint256 pk,
        address eoa
    ) public view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            pk,
            ECDSA.toEthSignedMessageHash(
                bytes(whitelistBadgeClaimer.addressToString(eoa))
            )
        );
        return abi.encodePacked(r, s, v);
    }
}
