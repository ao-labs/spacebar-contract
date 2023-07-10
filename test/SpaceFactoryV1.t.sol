// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/ERC6551/ERC6551Registry.sol";
import "../contracts/ERC6551/ERC6551Account.sol";
import "../contracts/ERC6551/AccountProxy.sol";
import "../contracts/SpaceshipNFTUniverse1.sol";
import "../contracts/SpaceFactoryV1.sol";
import "../contracts/BadgeSBTUniverse1.sol";
import "./mocks/MockERC721.sol";
import "../contracts/interfaces/IERC6551Account.sol";

contract SpaceFactoryV1Test is Test {
    ERC6551Registry public registry;
    ERC6551Account public erc6551Account;
    IERC6551Account public implementation;
    SpaceFactoryV1 public factory;
    SpaceshipNFTUniverse1 public spaceship;
    BadgeSBTUniverse1 public badge;
    MockERC721 public externalERC721;

    address defaultAdmin;
    address serviceAdmin;
    address[] users;
    uint16 maxSupply = 10;

    function setUp() public {
        defaultAdmin = vm.addr(1);
        serviceAdmin = vm.addr(2);
        externalERC721 = new MockERC721();
        for (uint256 i = 0; i < maxSupply + 1; i++) {
            users.push(vm.addr(i + 3));
            externalERC721.mint(users[i], i);
        }

        registry = new ERC6551Registry();
        erc6551Account = new ERC6551Account();
        // implementation is also a proxy to ERC6551Account
        implementation = IERC6551Account(
            payable(address(new AccountProxy(address(erc6551Account))))
        );
        factory = new SpaceFactoryV1();
        factory.initialize(
            defaultAdmin,
            serviceAdmin,
            registry,
            implementation
        );
        spaceship = new SpaceshipNFTUniverse1(address(factory), maxSupply);
        badge = new BadgeSBTUniverse1(address(factory));
        vm.startPrank(defaultAdmin);
        factory.setSpaceshipNFTUniverse1(address(spaceship));
        factory.setBadgeSBTUniverse1(address(badge));
        vm.stopPrank();
    }

    function testDeployTBAAndMintProtoShip() public {
        address user1ProfileTBA = registry.account(
            address(implementation),
            block.chainid,
            address(externalERC721),
            0, // token id
            0 // salt
        );
        address user1SpaceshipTBA = registry.account(
            address(implementation),
            block.chainid,
            address(spaceship),
            0, // token id
            0 // salt
        );
        assertEq(user1SpaceshipTBA.code.length, 0);
        vm.prank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);
        assertGt(user1SpaceshipTBA.code.length, 0);
        (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        ) = ERC6551Account(payable(user1SpaceshipTBA)).token();
        assertEq(chainId, block.chainid);
        assertEq(tokenContract, address(spaceship));
        assertEq(tokenId, 0);
        assertEq(spaceship.ownerOf(tokenId), user1ProfileTBA);

        address user2SpaceshipTBA = registry.account(
            address(implementation),
            block.chainid,
            address(spaceship),
            1, // token id
            0 // salt
        );
        vm.prank(users[1]);
        address user2ProfileTBA = factory.deployTBAAndMintProtoShip(
            address(externalERC721),
            1
        );
        (
            uint256 chainId2,
            address tokenContract2,
            uint256 tokenId2
        ) = ERC6551Account(payable(user2SpaceshipTBA)).token();
        assertEq(chainId2, block.chainid);
        assertEq(tokenContract2, address(spaceship));
        assertEq(tokenId2, 1);
        assertEq(spaceship.ownerOf(tokenId2), user2ProfileTBA);
    }

    function testMintProtoShipWhenTBAIsAlreadyDeployed() public {
        address user1ProfileTBA = registry.account(
            address(implementation),
            block.chainid,
            address(externalERC721),
            0, // token id
            0 // salt
        );
        address user1SpaceshipTBA = registry.createAccount(
            address(implementation),
            block.chainid,
            address(spaceship),
            0,
            0,
            abi.encodeWithSignature("initialize()")
        );
        assertGt(user1SpaceshipTBA.code.length, 0);
        vm.startPrank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);
        (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        ) = ERC6551Account(payable(user1SpaceshipTBA)).token();
        assertEq(chainId, block.chainid);
        assertEq(tokenContract, address(spaceship));
        assertEq(tokenId, 0);
        assertEq(spaceship.ownerOf(tokenId), user1ProfileTBA);
    }

    function testDeployTBAAndMintWhenNotNFTOwner() public {
        vm.startPrank(users[0]);
        vm.expectRevert(OnlyNFTOwner.selector);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 1);

        vm.expectRevert();
        // should revert with random token contract address
        factory.deployTBAAndMintProtoShip(address(vm.addr(333)), 1);
    }

    function testBurnProtoShip() public {
        uint256 tokenId = 0;
        vm.prank(users[0]);
        address tba = factory.deployTBAAndMintProtoShip(
            address(externalERC721),
            tokenId
        );
        assertEq(spaceship.ownerOf(tokenId), tba);
        vm.prank(serviceAdmin);
        factory.burnProtoShip(tokenId);
        vm.expectRevert("ERC721: invalid token ID");
        spaceship.ownerOf(tokenId);
    }

    function testBurnProtoShipRevert() public {
        uint256 tokenId = 0;
        vm.prank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), tokenId);
        vm.startPrank(serviceAdmin);
        factory.upgradeToOwnerShip(tokenId);
        vm.expectRevert(InvalidProtoShip.selector);
        factory.burnProtoShip(tokenId);

        vm.expectRevert("ERC721: invalid token ID");
        factory.burnProtoShip(1);
    }

    function testMaxSupply() public {
        assertEq(
            spaceship.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY(),
            maxSupply
        );
        for (uint256 i = 0; i < maxSupply; i++) {
            vm.prank(users[i]);
            factory.deployTBAAndMintProtoShip(address(externalERC721), i);
        }
        assertEq(spaceship.currentSupply(), maxSupply);
        vm.prank(users[maxSupply]);
        vm.expectRevert(ReachedMaxSupply.selector);
        factory.deployTBAAndMintProtoShip(address(externalERC721), maxSupply);

        vm.prank(serviceAdmin);
        factory.burnProtoShip(0);
        assertEq(spaceship.currentSupply(), maxSupply - 1);

        vm.prank(users[maxSupply]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), maxSupply);
        assertEq(spaceship.currentSupply(), maxSupply);
    }

    function testOnlyOneProtoShipPerUser() public {
        vm.prank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);

        vm.prank(users[0]);
        vm.expectRevert(OnlyOneProtoShipAtATime.selector);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);

        vm.prank(serviceAdmin);
        factory.upgradeToOwnerShip(0);

        vm.prank(users[0]);
        // should not revert user doesn't have Proto-Ship (cuz it's upgraded to Owner-Ship)
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0); // mints token id 1 to user

        vm.prank(serviceAdmin);
        factory.burnProtoShip(1);

        vm.prank(users[0]);
        // should not revert because token id 1 is burned
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);
    }

    function testSettingSpaceshipNFTUniverse1Revert() public {
        vm.prank(defaultAdmin);
        vm.expectRevert(); // should revert because it can be set only once
        factory.setSpaceshipNFTUniverse1(vm.addr(20)); //random address
    }
}
