// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {SpaceshipNFT} from "contracts/SpaceshipNFT.sol";

contract SpaceshipNFTTest is Test {
    SpaceshipNFT spaceshipNFT;
    address spaceFactory;
    address userA;
    address userB;

    uint24[] parts;
    bytes32 nickname = "Spacebar";

    event MintSpaceship(
        address indexed to,
        uint indexed id,
        uint24[] parts,
        bytes32 nickname
    );

    event MetadataUpdate(uint256 _tokenId);

    event UpdateSpaceship(uint indexed id, uint24[] parts, bytes32 nickname);

    function setUp() public {
        spaceFactory = vm.addr(1);
        userA = vm.addr(2);
        userB = vm.addr(3);
        spaceshipNFT = new SpaceshipNFT(spaceFactory);
        vm.startPrank(spaceFactory);
        // parts are 8 digit number where the first two digits are
        // the part type and the last six digits are the part id
        parts.push(1000001);
        parts.push(2000002);
        parts.push(3000003);
        parts.push(4000004);
        parts.push(5000005);
    }

    function test_mintSpaceship() public {
        vm.expectEmit(true, true, true, true);
        emit MintSpaceship(userA, 0, parts, nickname);
        spaceshipNFT.mintSpaceship(userA, nickname, parts);

        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.totalSupply(), 1);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        uint24[] memory _parts = spaceshipNFT.getParts(0);
        assertEq(_parts.length, parts.length);
        for (uint i = 0; i < parts.length; i++) {
            assertEq(_parts[i], parts[i]);
        }
        string memory uri = spaceshipNFT.tokenURI(0);
        assertEq(uri, "https://www.spacebar.xyz/spaceship/0");
    }

    function test_mintSpaceshipOnlySpaceFactory() public {
        vm.stopPrank();
        vm.prank(userA);
        vm.expectRevert();
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
    }

    function test_mintSpaceshipWrongPartsOrder() public {
        uint24 temp = parts[2];
        parts[2] = parts[3];
        parts[3] = temp;
        vm.expectRevert(SpaceshipNFT.InvalidParts.selector);
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
    }

    function test_mintSpaceshipWrongPartsTypes() public {
        parts[0] = 10003;
        parts[1] = 20003;
        parts[2] = 30003;
        parts[3] = 40003;
        parts[4] = 50003;

        vm.expectRevert(SpaceshipNFT.InvalidParts.selector);
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
    }

    function test_mintSpaceshipEmptyParts() public {
        vm.expectRevert(SpaceshipNFT.InvalidParts.selector);
        spaceshipNFT.mintSpaceship(userA, nickname, new uint24[](0));
    }

    function test_updateSpaceshipParts() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);

        uint24[] memory newParts = new uint24[](parts.length);
        for (uint i = 0; i < parts.length; i++) {
            newParts[i] = parts[i] + 1;
        }

        vm.expectEmit(true, true, true, true);
        emit UpdateSpaceship(0, newParts, "");
        vm.expectEmit(true, true, true, true);
        emit MetadataUpdate(0);
        spaceshipNFT.updateSpaceshipParts(0, newParts);

        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.totalSupply(), 1);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        uint24[] memory _parts = spaceshipNFT.getParts(0);
        assertEq(_parts.length, newParts.length);
        for (uint i = 0; i < newParts.length; i++) {
            assertEq(_parts[i], newParts[i]);
        }
    }

    function test_updateSpaceshipPartsOnlySpaceFactory() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
        vm.stopPrank();
        vm.prank(userA);
        vm.expectRevert();
        spaceshipNFT.updateSpaceshipParts(0, parts);
    }

    function test_updateSpaceshipNickname() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);

        bytes32 newNickname = "Spacebar2";

        vm.expectEmit(true, true, true, true);
        emit UpdateSpaceship(0, new uint24[](0), newNickname);
        vm.expectEmit(true, true, true, true);
        emit MetadataUpdate(0);

        spaceshipNFT.updateSpaceshipNickname(0, newNickname);

        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.totalSupply(), 1);
        assertEq(spaceshipNFT.getNickname(0), newNickname);
        uint24[] memory _parts = spaceshipNFT.getParts(0);
        assertEq(_parts.length, parts.length);
        for (uint i = 0; i < parts.length; i++) {
            assertEq(_parts[i], parts[i]);
        }
    }

    function test_updateSpaceshipNicknameOnlySpaceFactory() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
        vm.stopPrank();
        vm.prank(userA);
        vm.expectRevert();
        spaceshipNFT.updateSpaceshipNickname(0, nickname);
    }

    function test_burn() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
        vm.stopPrank();
        vm.prank(userA);
        spaceshipNFT.burn(0);
        assertEq(spaceshipNFT.totalSupply(), 0);
        vm.expectRevert("ERC721: invalid token ID");
        spaceshipNFT.ownerOf(0);
    }

    function test_transfer() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
        vm.stopPrank();
        vm.prank(userA);
        spaceshipNFT.transferFrom(userA, userB, 0);
        assertEq(spaceshipNFT.ownerOf(0), userB);
    }

    function test_transferOnlyOwner() public {
        spaceshipNFT.mintSpaceship(userA, nickname, parts);
        vm.stopPrank();
        vm.prank(userB);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        spaceshipNFT.transferFrom(userA, userB, 0);
    }
}
