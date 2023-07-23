// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/ERC6551/ERC6551Registry.sol";
import "../contracts/SpaceFactoryV1.sol";
import "../contracts/BadgeUniverse1.sol";
import "./mocks/MockERC6551Account.sol";
import "./mocks/MockERC721.sol";
import "../contracts/helper/Error.sol";

contract BadgeUniverse1Test is Test, Error {
    address admin;
    address factory;
    BadgeUniverse1 badge;
    address user1;
    address user2;
    string tokenURI = "randomString";

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event MintBadge(
        address indexed to,
        uint128 indexed primaryType,
        uint128 indexed secondaryType,
        uint256 tokenId,
        string tokenURI
    );

    function setUp() public {
        admin = vm.addr(1);
        factory = vm.addr(2);
        user1 = vm.addr(3);
        user2 = vm.addr(4);
        badge = new BadgeUniverse1(factory, admin);
    }

    function testMint() public {
        uint256 tokenId = 0;
        uint128 primaryType = 1;
        uint128 secondaryType = 2;

        vm.expectRevert(OnlySpaceFactory.selector);
        badge.mintBadge(user1, primaryType, secondaryType, tokenURI);

        vm.expectRevert(InvalidTokenId.selector);
        badge.getTokenType(tokenId);

        assertEq(badge.balanceOf(user1), 0);

        vm.prank(factory);
        vm.expectEmit(true, true, true, true);
        emit MintBadge(user1, primaryType, secondaryType, tokenId, tokenURI);
        badge.mintBadge(user1, primaryType, secondaryType, tokenURI);

        BadgeUniverse1.TokenType memory tokenType = badge.getTokenType(tokenId);

        assertEq(badge.ownerOf(tokenId), user1);
        assertEq(badge.totalSupply(), 1);
        assertEq(badge.balanceOf(user1), 1);
        assertEq(tokenType.primaryType, primaryType);
        assertEq(tokenType.secondaryType, secondaryType);
    }

    function testBurn() public {
        uint128 primaryType = 1;
        uint128 secondaryType = 2;
        vm.prank(factory);
        badge.mintBadge(user1, primaryType, secondaryType, tokenURI);
        assertEq(badge.balanceOf(user1), 1);
        vm.prank(user1);
        badge.burnBadge(0);
        assertEq(badge.balanceOf(user1), 0);

        vm.expectRevert("ERC721: invalid token ID");
        badge.ownerOf(0);

        vm.prank(factory);
        badge.mintBadge(user2, primaryType, secondaryType, tokenURI);

        // only factory or token owner can burn
        vm.prank(user1);
        vm.expectRevert(OnlySpaceFactoryOrOwner.selector);
        badge.burnBadge(1);

        vm.prank(factory);
        badge.burnBadge(1);
        assertEq(badge.balanceOf(user2), 0);

        vm.expectRevert("ERC721: invalid token ID");
        badge.ownerOf(1);
    }

    function testTransferRevert() public {
        uint256 tokenId = 0;
        uint128 primaryType = 1;
        uint128 secondaryType = 2;

        vm.prank(factory);
        badge.mintBadge(user1, primaryType, secondaryType, tokenURI);

        vm.startPrank(user1);
        vm.expectRevert(CanNotApprove.selector);
        badge.approve(user2, tokenId);
        vm.expectRevert(CanNotApprove.selector);
        badge.setApprovalForAll(user2, true);
        vm.expectRevert(CanNotTransfer.selector);
        badge.transferFrom(user1, user2, tokenId);
    }
}
