// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/ERC6551/ERC6551Registry.sol";
import "../contracts/SpaceFactoryV1.sol";
import "../contracts/SpaceshipUniverse1.sol";
import "./mocks/MockERC6551Account.sol";
import "../contracts/helper/Error.sol";

contract SpaceshipUniverse1Test is Test, Error {
    SpaceshipUniverse1 public spaceship;
    address factory;
    address admin;
    address royaltyReceiver;
    address[] users;
    uint256 totalUser = 5;
    uint16 maxSupply = 100;

    function setUp() public {
        factory = vm.addr(1);
        admin = vm.addr(2);
        royaltyReceiver = vm.addr(3);
        for (uint256 i = 0; i < totalUser; i++) {
            users.push(vm.addr(i + 4));
        }
        spaceship = new SpaceshipUniverse1(
            factory,
            maxSupply,
            admin,
            royaltyReceiver
        );
    }

    function testMint() public {
        // only factory can mint
        vm.expectRevert();
        spaceship.mint(users[0]);

        vm.startPrank(factory);
        uint256 tokenId = spaceship.mint(users[0]);
        assertEq(spaceship.ownerOf(tokenId), users[0]);
        assertEq(spaceship.nextTokenId(), tokenId + 1);

        uint256 tokenId2 = spaceship.mint(users[1]);
        assertEq(spaceship.ownerOf(tokenId2), users[1]);
        assertEq(spaceship.nextTokenId(), tokenId2 + 1);
    }

    function testBurn() public {
        vm.startPrank(factory);
        uint256 tokenId = spaceship.mint(users[0]);
        uint256 tokenId2 = spaceship.mint(users[1]);
        spaceship.unlock(tokenId2);

        // factory can burn locked token
        spaceship.burn(tokenId);
        vm.expectRevert();
        spaceship.ownerOf(tokenId);
        vm.stopPrank();
    }

    function testBurnRevert() public {
        vm.startPrank(factory);
        uint256 tokenId = spaceship.mint(users[0]);
        uint256 tokenId2 = spaceship.mint(users[1]);
        spaceship.unlock(tokenId2);
        vm.stopPrank();

        // user cannot burn token
        vm.prank(users[0]);
        vm.expectRevert();
        spaceship.burn(tokenId);
        assertEq(spaceship.ownerOf(tokenId), users[0]);

        // factory cannot burn unlocked token
        vm.prank(factory);
        vm.expectRevert(OnlyLockedToken.selector);
        spaceship.burn(tokenId2);
    }

    function testUnlock() public {
        vm.startPrank(factory);
        uint256 tokenId = spaceship.mint(users[0]);
        assertEq(spaceship.unlocked(tokenId), false);
        spaceship.unlock(tokenId);
        assertEq(spaceship.unlocked(tokenId), true);

        // cannot unlock unlocked token
        vm.expectRevert(OnlyLockedToken.selector);
        spaceship.unlock(tokenId);
    }

    function testLockedToken() public {
        vm.prank(factory);
        uint256 tokenId = spaceship.mint(users[0]);
        assertEq(spaceship.unlocked(tokenId), false);

        vm.startPrank(users[0]);
        vm.expectRevert(TokenLocked.selector);
        spaceship.approve(users[1], tokenId);

        vm.expectRevert(TokenLocked.selector);
        spaceship.transferFrom(users[0], users[1], tokenId);

        spaceship.setApprovalForAll(users[1], true);
        vm.stopPrank();
        vm.startPrank(users[1]);
        vm.expectRevert(TokenLocked.selector);
        spaceship.transferFrom(users[0], users[1], tokenId);
    }

    function testSupportsInterface() public {
        assertEq(spaceship.supportsInterface(type(IERC165).interfaceId), true);
        assertEq(spaceship.supportsInterface(type(IERC721).interfaceId), true);
    }

    function testDecentralizedTokenURI() public {
        vm.startPrank(factory);
        spaceship.mint(users[0]);
        assertEq(
            spaceship.tokenURI(0),
            "https://api.spacebar.xyz/metadata/spaceship_universe1/0"
        );

        spaceship.setDecentralizedTokenURI(0, "random");

        assertEq(spaceship.tokenURI(0), "https://www.arweave.net/random");
    }
}
