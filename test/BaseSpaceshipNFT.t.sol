// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {BaseSpaceshipNFT} from "contracts/BaseSpaceshipNFT.sol";

contract BaseSpaceshipNFTTest is Test {
    BaseSpaceshipNFT baseSpaceshipNFT;
    address spaceFactory;
    address userA;

    function setUp() public {
        spaceFactory = vm.addr(1);
        userA = vm.addr(2);
        baseSpaceshipNFT = new BaseSpaceshipNFT(spaceFactory);
    }

    function test_initialMint() public {
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        assertEq(baseSpaceshipNFT.totalSupply(), maxSupply);
        assertEq(baseSpaceshipNFT.balanceOf(spaceFactory), maxSupply);
    }
}
