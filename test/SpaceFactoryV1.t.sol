// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helper/DefaultSetup.sol";
import "../contracts/helper/Error.sol";

contract SpaceFactoryV1Test is DefaultSetup, Error {
    function setUp() public override {
        super.setUp();
        for (uint256 i = 0; i < maxSupply + 1; i++) {
            externalERC721.mint(users[i], i);
        }
    }

    function testMintProtoshipUniverse1() public {
        address user1ProfileTBA = getTBAaddress(address(externalERC721), 0);
        address user1SpaceshipTBA = getTBAaddress(address(spaceship), 0);

        assertEq(user1SpaceshipTBA.code.length, 0);
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);
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

        address user2SpaceshipTBA = getTBAaddress(address(spaceship), 1);

        vm.prank(users[1]);
        address user2ProfileTBA = factory.mintProtoshipUniverse1(
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

    function testMintProtoshipWhenTBAIsAlreadyDeployed() public {
        uint256 _tokenId = 0;
        address user1ProfileTBA = getTBAaddress(
            address(externalERC721),
            _tokenId
        );

        address user1SpaceshipTBA = deployTBA(address(spaceship), _tokenId);

        assertGt(user1SpaceshipTBA.code.length, 0);
        vm.startPrank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);
        (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        ) = ERC6551Account(payable(user1SpaceshipTBA)).token();
        assertEq(chainId, block.chainid);
        assertEq(tokenContract, address(spaceship));
        assertEq(tokenId, _tokenId);
        assertEq(spaceship.ownerOf(tokenId), user1ProfileTBA);
    }

    function testDeployTBAAndMintWhenNotNFTOwner() public {
        vm.startPrank(users[0]);
        vm.expectRevert(OnlyNFTOwner.selector);
        factory.mintProtoshipUniverse1(address(externalERC721), 1);

        vm.expectRevert();
        // should revert with random token contract address
        factory.mintProtoshipUniverse1(address(vm.addr(333)), 1);
    }

    function testBurnProtoship() public {
        uint256 tokenId = 0;
        vm.prank(users[0]);
        address tba = factory.mintProtoshipUniverse1(
            address(externalERC721),
            tokenId
        );
        assertEq(spaceship.ownerOf(tokenId), tba);
        vm.prank(serviceAdmin);
        factory.burnProtoshipUniverse1(tokenId);
        vm.expectRevert("ERC721: invalid token ID");
        spaceship.ownerOf(tokenId);
    }

    function testBurnProtoshipRevert() public {
        uint256 tokenId = 0;
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), tokenId);
        vm.startPrank(serviceAdmin);
        factory.upgradeToOwnershipUniverse1(tokenId);
        vm.expectRevert(InvalidProtoship.selector);
        factory.burnProtoshipUniverse1(tokenId);

        vm.expectRevert("ERC721: invalid token ID");
        factory.burnProtoshipUniverse1(1);
    }

    function testMaxSupply() public {
        assertEq(
            spaceship.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY(),
            maxSupply
        );
        for (uint256 i = 0; i < maxSupply; i++) {
            vm.prank(users[i]);
            factory.mintProtoshipUniverse1(address(externalERC721), i);
        }
        assertEq(spaceship.currentSupply(), maxSupply);
        vm.prank(users[maxSupply]);
        vm.expectRevert(ReachedMaxSupply.selector);
        factory.mintProtoshipUniverse1(address(externalERC721), maxSupply);

        vm.prank(serviceAdmin);
        factory.burnProtoshipUniverse1(0);
        assertEq(spaceship.currentSupply(), maxSupply - 1);

        vm.prank(users[maxSupply]);
        factory.mintProtoshipUniverse1(address(externalERC721), maxSupply);
        assertEq(spaceship.currentSupply(), maxSupply);
    }

    function testOnlyOneProtoshipPerUser() public {
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        vm.prank(users[0]);
        vm.expectRevert(OnlyOneProtoshipAtATime.selector);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        vm.prank(serviceAdmin);
        factory.upgradeToOwnershipUniverse1(0);

        vm.prank(users[0]);
        // should not revert user doesn't have Protoship (cuz it's upgraded to Ownership)
        factory.mintProtoshipUniverse1(address(externalERC721), 0); // mints token id 1 to user

        vm.prank(serviceAdmin);
        factory.burnProtoshipUniverse1(1);

        vm.prank(users[0]);
        // should not revert because token id 1 is burned
        factory.mintProtoshipUniverse1(address(externalERC721), 0);
    }

    function testSettingSpaceshipUniverse1Revert() public {
        vm.prank(defaultAdmin);
        vm.expectRevert(); // should revert because it can be set only once
        factory.setSpaceshipUniverse1(vm.addr(20)); //random address
    }

    function testWhitelistBadge() public {
        string memory uri = "randomURI";
        vm.prank(defaultAdmin);
        factory.setIsUniverse1Whitelisted(true);

        // should revert if the NFT's tba doesn't have the badge
        vm.expectRevert(NotWhiteListed.selector);
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        vm.prank(minterAdmin);
        factory.mintWhitelistBadgeUniverse1(address(externalERC721), 0, uri);

        address user1ProfileTBA = getTBAaddress(address(externalERC721), 0);

        assertEq(badge.ownerOf(0), user1ProfileTBA);
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);
    }

    function testWhitelistBadgeRevert() public {
        string memory uri = "randomURI";
        vm.prank(defaultAdmin);
        factory.setIsUniverse1Whitelisted(true);

        vm.prank(address(factory));
        // mint wrong badge (primary type 0, secondary type 1)
        badge.mintBadge(address(externalERC721), 0, 1, uri);

        vm.expectRevert(NotWhiteListed.selector);
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        vm.prank(address(factory));
        // mint the right badge but to EOA, not TBA
        badge.mintBadge(users[0], 0, 0, uri);

        vm.expectRevert(NotWhiteListed.selector);
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);
    }

    function testTransferDefaultAdmin() public {
        vm.prank(users[0]);
        vm.expectRevert(); //only default admin can transfer default admin
        factory.transferDefaultAdmin(users[0]);

        assertTrue(factory.hasRole(DEFAULT_ADMIN_ROLE, defaultAdmin));
        vm.prank(defaultAdmin);
        factory.transferDefaultAdmin(users[0]);

        assertFalse(factory.hasRole(DEFAULT_ADMIN_ROLE, defaultAdmin));
        assertTrue(factory.hasRole(DEFAULT_ADMIN_ROLE, users[0]));

        vm.expectRevert();
        vm.prank(defaultAdmin);
        factory.setIsUniverse1Whitelisted(true);

        vm.prank(users[0]);
        factory.setIsUniverse1Whitelisted(true);
        assertTrue(factory.isUniverse1Whitelisted());
    }
}
