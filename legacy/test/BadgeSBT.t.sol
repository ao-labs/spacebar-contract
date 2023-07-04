// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {BadgeSBT} from "contracts/BadgeSBT.sol";
import "contracts/interfaces/IERC5484.sol";

contract BadgeSBTTest is Test {
    BadgeSBT badgeSBT;
    address spaceFactory;
    address burner;
    address userA;
    address userB;

    event MintBadge(
        address indexed to,
        uint8 indexed category,
        uint256 indexed tokenId,
        IERC5484.BurnAuth burnAuth
    );

    function setUp() public {
        spaceFactory = vm.addr(1);
        burner = vm.addr(2);
        userA = vm.addr(3);
        userB = vm.addr(4);
        badgeSBT = new BadgeSBT(spaceFactory, burner);
        vm.startPrank(spaceFactory, burner);
    }

    function test_mintBadge() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;
        vm.expectEmit(true, true, true, true);
        emit MintBadge(userA, category, 0, IERC5484.BurnAuth.Both);
        badgeSBT.mintBadge(userA, category, burnAuth);

        assertEq(category, badgeSBT.getCategory(0));
        assertEq(uint(burnAuth), uint(badgeSBT.burnAuth(0)));
        assertEq(userA, badgeSBT.ownerOf(0));

        string memory uri = badgeSBT.tokenURI(0);
        assertEq(uri, "https://www.spacebar.xyz/badge/0");
    }

    function test_mintBadgeOnlySpaceFactory() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;
        vm.stopPrank();
        vm.prank(userA);
        vm.expectRevert();
        badgeSBT.mintBadge(userA, category, burnAuth);
    }
}
