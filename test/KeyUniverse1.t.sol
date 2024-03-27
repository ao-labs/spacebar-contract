// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/KeyUniverse1.sol";
import "../contracts/helper/Error.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract KeyUniverse1Test is Test, Error {
    address admin;
    address operator;
    address minter;
    address user1;
    address user2;
    KeyUniverse1 key;

    uint256[] tokenIds;
    string[] tokenURIs;

    function setUp() public {
        admin = vm.addr(1);
        operator = vm.addr(2);
        minter = vm.addr(3);
        user1 = vm.addr(4);
        user2 = vm.addr(5);
        key = new KeyUniverse1(admin, operator, minter);

        tokenIds.push(0);
        tokenIds.push(1);
        tokenIds.push(2);
        tokenURIs.push("a");
        tokenURIs.push("b");
        tokenURIs.push("c");
    }

    function testURI() public {
        assertEq(key.uri(0), "");

        // only operator can set uri
        vm.prank(minter);
        vm.expectRevert();
        key.setURIs(tokenIds, tokenURIs);

        vm.prank(operator);
        key.setURIs(tokenIds, tokenURIs);

        assertEq(key.uri(0), "ipfs://a");
        assertEq(key.uri(1), "ipfs://b");
        assertEq(key.uri(2), "ipfs://c");
    }

    function testMint() public {
        uint256 tokenId = 0;
        assertEq(key.balanceOf(user1, tokenId), 0);

        // has to revert when msg.sender is not minter
        vm.prank(user1);
        vm.expectRevert();
        key.mint(user1, tokenId);

        // has to revert when tokenURI is not set
        vm.prank(minter);
        vm.expectRevert(OnlyExistingToken.selector);
        key.mint(user1, tokenId);

        vm.prank(operator);
        key.setURIs(tokenIds, tokenURIs);

        vm.prank(minter);
        key.mint(user1, tokenId);
        assertEq(key.balanceOf(user1, tokenId), 1);
    }

    function testMintBatch() public {
        vm.prank(operator);
        key.setURIs(tokenIds, tokenURIs);

        vm.prank(minter);
        key.mintBatch(user1, tokenIds);

        for (uint i = 0; i < tokenIds.length; i++) {
            assertEq(key.balanceOf(user1, tokenIds[i]), 1);
        }

        // has to revert when one of the tokenURI is not set
        uint256[] memory wrongTokenIds = new uint256[](2);
        wrongTokenIds[0] = 3;
        wrongTokenIds[1] = 1;
        vm.prank(minter);
        vm.expectRevert(OnlyExistingToken.selector);
        key.mintBatch(user1, wrongTokenIds);
    }

    function testTransferAndApproveRevert() public {
        uint256 tokenId = 0;
        vm.prank(operator);
        key.setURIs(tokenIds, tokenURIs);

        vm.prank(minter);
        key.mint(user1, tokenId);

        vm.startPrank(user1);
        vm.expectRevert(CanNotApprove.selector);
        key.setApprovalForAll(user2, true);

        vm.expectRevert(CanNotTransfer.selector);
        key.safeTransferFrom(user1, user2, tokenId, 1, "");

        vm.expectRevert(CanNotTransfer.selector);
        key.safeBatchTransferFrom(user1, user2, tokenIds, tokenIds, "");
    }

    function testSupportsInterface() public {
        assertEq(key.supportsInterface(type(IERC165).interfaceId), true);
        assertEq(key.supportsInterface(type(IERC1155).interfaceId), true);
        assertEq(
            key.supportsInterface(type(IERC1155MetadataURI).interfaceId),
            true
        );
        assertEq(key.supportsInterface(type(IERC721).interfaceId), false);
        assertEq(key.supportsInterface(type(IAccessControl).interfaceId), true);
    }

    function testBurn() public {
        vm.prank(operator);
        key.setURIs(tokenIds, tokenURIs);

        vm.prank(minter);
        key.mintBatch(user1, tokenIds);

        for (uint i = 0; i < tokenIds.length; i++) {
            assertEq(key.balanceOf(user1, tokenIds[i]), 1);
        }

        vm.prank(minter);
        vm.expectRevert(); // only operator
        key.burn(user1, 0);

        vm.prank(user1);
        vm.expectRevert(); // only operator
        key.burn(user1, 0);

        vm.startPrank(operator);
        key.burn(user1, 0);
        assertEq(key.balanceOf(user1, tokenIds[0]), 0);
        assertEq(key.balanceOf(user1, tokenIds[1]), 1); // shouldn't be burned

        vm.expectRevert(); // only operator
        key.burn(user1, 0); // cannot burn twice
    }
}
