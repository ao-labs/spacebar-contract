// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {ScoreNFT} from "contracts/ScoreNFT.sol";

contract ScoreNFTTest is Test {
    ScoreNFT scoreNFT;
    address spaceFactory;
    address userA;
    address userB;

    event MintScore(
        uint8 indexed category,
        uint88 score,
        address indexed player,
        uint256 indexed tokenId
    );

    function setUp() public {
        spaceFactory = vm.addr(1);
        userA = vm.addr(2);
        userB = vm.addr(3);
        scoreNFT = new ScoreNFT(spaceFactory);
        vm.startPrank(spaceFactory);
    }

    function test_mintScore() public {
        uint8 category = 1;
        uint88 score = 100;
        vm.expectEmit(true, true, true, true);
        emit MintScore(category, score, userA, 0);
        scoreNFT.mintScore(userA, category, score);
        (
            uint8 _category,
            uint88 _score,
            address player,
            address owner
        ) = scoreNFT.getScore(0);
        assertEq(category, _category);
        assertEq(score, _score);
        assertEq(player, userA);
        assertEq(owner, userA);

        assertEq(scoreNFT.totalSupply(), 1);
        assertEq(scoreNFT.ownerOf(0), userA);

        string memory uri = scoreNFT.tokenURI(0);
        assertEq(uri, "https://www.spacebar.xyz/score/0");
    }

    function test_mintScoreOnlySpaceFactory() public {
        uint8 category = 1;
        uint88 score = 100;
        vm.stopPrank();
        vm.prank(userA);
        vm.expectRevert();
        scoreNFT.mintScore(userA, category, score);
    }

    function test_transferScore() public {
        uint8 category = 1;
        uint88 score = 100;
        vm.expectEmit(true, true, true, true);
        emit MintScore(category, score, userA, 0);
        scoreNFT.mintScore(userA, category, score);
        assertEq(scoreNFT.ownerOf(0), userA);

        vm.stopPrank();
        vm.prank(userA);
        scoreNFT.transferFrom(userA, userB, 0);
        assertEq(scoreNFT.ownerOf(0), userB);

        (
            uint8 _category,
            uint88 _score,
            address player,
            address owner
        ) = scoreNFT.getScore(0);
        assertEq(category, _category);
        assertEq(score, _score);
        assertEq(player, userA);
        assertEq(owner, userB);
    }

    function test_burnScore() public {
        uint8 category = 1;
        uint88 score = 100;
        vm.expectEmit(true, true, true, true);
        emit MintScore(category, score, userA, 0);
        scoreNFT.mintScore(userA, category, score);

        vm.stopPrank();
        vm.prank(userA);
        scoreNFT.burn(0);
        assertEq(scoreNFT.totalSupply(), 0);
        vm.expectRevert("ERC721: invalid token ID");
        scoreNFT.ownerOf(0);
    }

    function test_burnScoreOnlyOwner() public {
        uint8 category = 1;
        uint88 score = 100;
        scoreNFT.mintScore(userA, category, score);
        vm.stopPrank();
        vm.prank(userB);
        vm.expectRevert("ERC721: caller is not token owner or approved");
        scoreNFT.burn(0);
    }
}
