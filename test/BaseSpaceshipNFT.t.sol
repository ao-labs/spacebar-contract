// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {BaseSpaceshipNFT} from "contracts/BaseSpaceshipNFT.sol";

contract BaseSpaceshipNFTTest is Test {
    BaseSpaceshipNFT baseSpaceshipNFT;
    address spaceFactory;
    address userA;
    address userB;

    event UpdateUser(
        uint256 indexed tokenId,
        address indexed user,
        uint64 expires
    );

    function setUp() public {
        spaceFactory = vm.addr(1);
        userA = vm.addr(2);
        userB = vm.addr(3);
        baseSpaceshipNFT = new BaseSpaceshipNFT(spaceFactory);
    }

    function test_initialMint(uint tokenId) public {
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        tokenId = bound(tokenId, 0, maxSupply - 1);
        assertEq(baseSpaceshipNFT.totalSupply(), maxSupply);
        assertEq(baseSpaceshipNFT.balanceOf(spaceFactory), maxSupply);
        assertEq(baseSpaceshipNFT.ownerOf(tokenId), spaceFactory);
    }

    function test_setUser() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.prank(spaceFactory);
        vm.expectEmit(true, true, true, true);
        emit UpdateUser(tokenId, userA, expires);
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        assertEq(baseSpaceshipNFT.userExpires(tokenId), expires);
    }

    function test_setUserByApprovedUser() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.prank(spaceFactory);
        baseSpaceshipNFT.approve(userA, tokenId);
        vm.prank(userA);
        baseSpaceshipNFT.setUser(tokenId, userB, expires);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userB);
    }

    function test_setUserOnlyOnwer() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.expectRevert("ERC4907: transfer caller is not owner nor approved");
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
    }

    function test_setUserExpires() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.prank(spaceFactory);
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        vm.warp(expires + 1);
        assertEq(baseSpaceshipNFT.userOf(tokenId), address(0));
    }

    function test_manuallyExpireUser() public {
        uint256 tokenId = 0;
        vm.warp(1);
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.startPrank(spaceFactory);
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        baseSpaceshipNFT.setUser(tokenId, userA, 0);
        assertEq(baseSpaceshipNFT.userOf(tokenId), address(0));
    }

    function test_burn() public {
        uint256 tokenId = 0;
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        vm.prank(spaceFactory);
        baseSpaceshipNFT.burn(tokenId);
        assertEq(baseSpaceshipNFT.totalSupply(), maxSupply - 1);
        assertEq(baseSpaceshipNFT.balanceOf(spaceFactory), maxSupply - 1);
    }

    function test_burnOnlyOwner() public {
        uint256 tokenId = 0;
        vm.expectRevert("ERC721: caller is not token owner or approved");
        baseSpaceshipNFT.burn(tokenId);
    }

    function test_userOfAfterBurn() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.startPrank(spaceFactory);
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
        baseSpaceshipNFT.burn(tokenId);
        assertEq(baseSpaceshipNFT.userOf(tokenId), address(0));
    }

    function test_burnOnlyOnce() public {
        uint256 tokenId = 0;
        vm.startPrank(spaceFactory);
        baseSpaceshipNFT.burn(tokenId);
        vm.expectRevert("ERC721: invalid token ID");
        baseSpaceshipNFT.burn(tokenId);
    }

    function test_userOfAfterTransfer() public {
        uint256 tokenId = 0;
        uint64 expires = uint64(block.timestamp + 7 days);
        vm.startPrank(spaceFactory);
        baseSpaceshipNFT.setUser(tokenId, userA, expires);
        vm.expectEmit(true, true, true, true);
        emit UpdateUser(tokenId, address(0), 0);
        baseSpaceshipNFT.transferFrom(spaceFactory, userB, tokenId);
        assertEq(baseSpaceshipNFT.userOf(tokenId), address(0));
    }

    function test_tokenUri() public {
        uint256 tokenId = 10;
        string memory uri = baseSpaceshipNFT.tokenURI(tokenId);
        assertEq(uri, "https://www.spacebar.xyz/base/10");
    }
}
