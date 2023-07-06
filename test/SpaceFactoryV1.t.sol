// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/ERC6551Registry.sol";
import "../contracts/SpaceFactoryV1.sol";
import "../contracts/SpaceshipNFTUniverse1.sol";
import "./mocks/MockERC6551Account.sol";
import "./mocks/MockERC721.sol";

contract SpaceFactoryV1Test is Test {
    ERC6551Registry public registry;
    MockERC6551Account public implementation;
    SpaceFactoryV1 public factory;
    SpaceshipNFTUniverse1 public spaceship;
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
        implementation = new MockERC6551Account();
        factory = new SpaceFactoryV1();
        factory.initialize(
            defaultAdmin,
            serviceAdmin,
            registry,
            implementation
        );
        spaceship = new SpaceshipNFTUniverse1(address(factory), maxSupply);
        vm.prank(defaultAdmin);
        factory.setSpaceshipNFTUniverse1(address(spaceship));
    }

    function testDeployTBAAndMintProtoShip() public {
        address user1TBA = registry.account(
            address(implementation),
            block.chainid,
            address(externalERC721),
            0, // token id
            0 // salt
        );
        assertEq(user1TBA.code.length, 0);
        vm.startPrank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);
        assertGt(user1TBA.code.length, 0);
        (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        ) = MockERC6551Account(payable(user1TBA)).token();
        assertEq(chainId, block.chainid);
        assertEq(tokenContract, address(externalERC721));
        assertEq(tokenId, 0);
        assertEq(spaceship.ownerOf(tokenId), user1TBA);
    }

    function testMintProtoShipWhenTBAIsAlreadyDeployed() public {
        address user1TBA = registry.createAccount(
            address(implementation),
            block.chainid,
            address(externalERC721),
            0,
            0,
            abi.encodeWithSignature("initialize()")
        );
        assertGt(user1TBA.code.length, 0);
        vm.startPrank(users[0]);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 0);
        (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        ) = MockERC6551Account(payable(user1TBA)).token();
        assertEq(chainId, block.chainid);
        assertEq(tokenContract, address(externalERC721));
        assertEq(tokenId, 0);
        assertEq(spaceship.ownerOf(tokenId), user1TBA);
    }

    function testDeployTBAAndMintWhenNotNFTOwner() public {
        vm.startPrank(users[0]);
        vm.expectRevert(OnlyNFTOwner.selector);
        factory.deployTBAAndMintProtoShip(address(externalERC721), 1);

        vm.expectRevert();
        // random token contract address
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
