// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {PartsNFT} from "contracts/PartsNFT.sol";

contract PartsNFTTest is Test {
    PartsNFT partsNFT;
    address spaceFactory;
    address userA;
    address userB;

    function setUp() public {
        spaceFactory = vm.addr(1);
        userA = vm.addr(2);
        userB = vm.addr(3);
        partsNFT = new PartsNFT(spaceFactory);
        vm.startPrank(spaceFactory);
    }

    function test_mintParts() public {
        uint256 tokenId = 10;
        partsNFT.mintParts(userA, tokenId);
        assertEq(partsNFT.totalSupply(tokenId), 1);
        assertEq(partsNFT.balanceOf(userA, tokenId), 1);
        string memory uri = partsNFT.uri(tokenId);
        assertEq(uri, "https://www.spacebar.xyz/parts/10");
    }

    function test_batchMintParts() public {
        uint256[] memory ids = new uint256[](3);
        ids[0] = 5;
        ids[1] = 11;
        ids[2] = 1;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 12;
        amounts[1] = 2;
        amounts[2] = 131;

        partsNFT.batchMintParts(userA, ids, amounts);
        assertEq(partsNFT.balanceOf(userA, ids[0]), amounts[0]);
        assertEq(partsNFT.balanceOf(userA, ids[1]), amounts[1]);
        assertEq(partsNFT.balanceOf(userA, ids[2]), amounts[2]);
        assertEq(partsNFT.totalSupply(ids[0]), amounts[0]);
        assertEq(partsNFT.totalSupply(ids[1]), amounts[1]);
        assertEq(partsNFT.totalSupply(ids[2]), amounts[2]);

        partsNFT.batchMintParts(userB, ids, amounts);
        assertEq(partsNFT.balanceOf(userA, ids[0]), amounts[0]);
        assertEq(partsNFT.balanceOf(userA, ids[1]), amounts[1]);
        assertEq(partsNFT.balanceOf(userA, ids[2]), amounts[2]);
        assertEq(partsNFT.totalSupply(ids[0]), amounts[0] * 2);
        assertEq(partsNFT.totalSupply(ids[1]), amounts[1] * 2);
        assertEq(partsNFT.totalSupply(ids[2]), amounts[2] * 2);
    }

    function test_mintPartsOnlyLessThanMaximumTokenId() public {
        uint256 tokenId = uint256(type(uint24).max) + 1;
        vm.expectRevert(
            abi.encodeWithSelector(
                PartsNFT.ExceedMaximumTokenId.selector,
                tokenId
            )
        );
        partsNFT.mintParts(userA, tokenId);
    }

    function test_burnParts() public {
        uint256 tokenId = 10;
        partsNFT.mintParts(userA, tokenId);
        assertEq(partsNFT.totalSupply(tokenId), 1);
        assertEq(partsNFT.balanceOf(userA, tokenId), 1);
        partsNFT.burnParts(userA, tokenId, 1);
        assertEq(partsNFT.totalSupply(tokenId), 0);
        assertEq(partsNFT.balanceOf(userA, tokenId), 0);
    }

    function test_burnPartsBeforeMint() public {
        uint256 tokenId = 10;
        vm.expectRevert("ERC1155: burn amount exceeds totalSupply");
        partsNFT.burnParts(userA, tokenId, 1);

        partsNFT.mintParts(userA, tokenId);
        vm.expectRevert("ERC1155: burn amount exceeds totalSupply");
        partsNFT.burnParts(userA, tokenId + 1, 1);
    }

    function test_burnByOwner() public {
        uint256 tokenId = 10;
        partsNFT.mintParts(userA, tokenId);
        assertEq(partsNFT.totalSupply(tokenId), 1);
        assertEq(partsNFT.balanceOf(userA, tokenId), 1);
        vm.stopPrank();
        vm.prank(userA);
        partsNFT.burn(userA, tokenId, 1);
        assertEq(partsNFT.totalSupply(tokenId), 0);
        assertEq(partsNFT.balanceOf(userA, tokenId), 0);
    }

    function test_burnNotByOwner() public {
        uint256 tokenId = 10;
        partsNFT.mintParts(userA, tokenId);
        assertEq(partsNFT.totalSupply(tokenId), 1);
        assertEq(partsNFT.balanceOf(userA, tokenId), 1);
        vm.stopPrank();
        vm.prank(userB);
        vm.expectRevert("ERC1155: caller is not token owner or approved");
        partsNFT.burn(userA, tokenId, 1);
    }

    function test_batchBurnParts() public {
        uint256[] memory ids = new uint256[](5);
        ids[0] = 5;
        ids[1] = 11;
        ids[2] = 23;
        ids[3] = 322;
        ids[4] = 3421;

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 1;
        amounts[1] = 21;
        amounts[2] = 1112;
        amounts[3] = 142;
        amounts[4] = 13;

        partsNFT.batchMintParts(userA, ids, amounts);

        uint256[] memory burnAmounts = new uint256[](5);
        burnAmounts[0] = 1;
        burnAmounts[1] = 1;
        burnAmounts[2] = 132;
        burnAmounts[3] = 42;
        burnAmounts[4] = 3;
        partsNFT.batchBurnParts(userA, ids, burnAmounts);

        assertEq(
            partsNFT.balanceOf(userA, ids[0]),
            amounts[0] - burnAmounts[0]
        );
        assertEq(
            partsNFT.balanceOf(userA, ids[1]),
            amounts[1] - burnAmounts[1]
        );
        assertEq(
            partsNFT.balanceOf(userA, ids[2]),
            amounts[2] - burnAmounts[2]
        );
        assertEq(
            partsNFT.balanceOf(userA, ids[3]),
            amounts[3] - burnAmounts[3]
        );
        assertEq(
            partsNFT.balanceOf(userA, ids[4]),
            amounts[4] - burnAmounts[4]
        );
    }
}
