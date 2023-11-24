// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helper/DefaultSetup.sol";
import "../contracts/helper/Error.sol";
import "../contracts/KeyMinterUniverse1.sol";
import "../contracts/KeyUniverse1.sol";

contract KeyMinterUniverse1Test is DefaultSetup, Error {
    // bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    // address defaultAdmin;
    // address serviceAdmin;
    // address minterAdmin;
    // ERC6551Registry public registry;
    // ERC6551Account public erc6551Account;
    // IERC6551Account public implementation;
    // SpaceFactoryV1 public factory;
    // SpaceFactoryV1 public factoryImplemenation;
    // SpaceshipUniverse1 public spaceship;
    // BadgeUniverse1 public badge;
    // MockERC721 public externalERC721;
    // uint16 maxSupply = 10;
    // address[] users;

    KeyMinterUniverse1 public keyMinter;
    KeyUniverse1 public key;

    bytes32 keyMinterDomainSeparator;
    bytes32 keyMintParamsTypeHash;
    bytes32 keyBatchMintParamsTypeHash;

    address operator = vm.addr(1001);

    uint256[] keyTokenIds = [1010, 1020];
    string[] keyURIs = ["aaa", "bbb"];

    function setUp() public override {
        super.setUp();
        // user 1 and user 2 has nft
        for (uint256 i = 0; i < 2; i++) {
            externalERC721.mint(users[i], i);
        }
        // user 1 has spaceship
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        keyMinter = new KeyMinterUniverse1(
            defaultAdmin,
            operator,
            serviceAdmin,
            spaceship,
            registry,
            implementation
        );

        key = keyMinter.keyUniverse1();
        keyMinterDomainSeparator = keyMinter.DOMAIN_SEPARATOR();
        keyMintParamsTypeHash = keyMinter.KEY_MINT_PARAMS_TYPEHASH();
        keyBatchMintParamsTypeHash = keyMinter.KEY_BATCH_MINT_PARAMS_TYPEHASH();
        vm.prank(operator);
        key.setURIs(keyTokenIds, keyURIs);
    }

    function testMintKey() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;
        address spaceshipTBA = getTBAaddress(
            address(spaceship),
            spaceshipTokenId
        );

        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 0);

        // minting without contribution
        vm.startPrank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            0
        );
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 1);
        assertEq(keyMinter.getUserContribution(users[0]), 0);
        assertEq(keyMinter.getUserMintCount(users[0]), 1);

        vm.deal(users[0], 10 ether);
        uint beforeBalance = users[0].balance;
        // minting with contribution
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            1 ether
        );
        uint afterBalance = users[0].balance;
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[1]), 1);
        assertEq(keyMinter.getUserContribution(users[0]), 1 ether);
        assertEq(keyMinter.getUserMintCount(users[0]), 2);
        assertEq(beforeBalance - afterBalance, 1 ether);
    }

    function testMintKeyRevert() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        address spaceshipContractAddress = address(spaceship);
        uint256 spaceshipTokenId = 0;
        address spaceshipTBA = getTBAaddress(
            spaceshipContractAddress,
            spaceshipTokenId
        );

        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 0);

        vm.startPrank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            0
        );

        // minting with the same key
        vm.expectRevert(TokenAlreadyMinted.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            0
        );

        // minting with wrong nft
        vm.expectRevert(OnlyNFTOwner.selector);
        makeSigAndMintKey(
            profileContractAddress,
            1,
            spaceshipTokenId,
            keyTokenIds[1],
            0
        );

        // minting with the key that doens't have uri
        vm.expectRevert(OnlyExistingToken.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            3030, // random number
            0
        );

        vm.stopPrank();

        vm.startPrank(users[1]);
        // minting without owning Spaceship that doens't have uri
        vm.expectRevert(OnlySpaceshipOwner.selector);
        makeSigAndMintKey(
            profileContractAddress,
            1,
            spaceshipTokenId,
            keyTokenIds[0],
            0
        );
    }

    function testMaxContribution() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        address spaceshipContractAddress = address(spaceship);
        uint256 spaceshipTokenId = 0;
        uint maxContributionPerUser = keyMinter.maxContributionPerUser();
        vm.deal(users[0], maxContributionPerUser + 1);
        // minting with the same key
        vm.expectRevert(ExceedMaxContributionPerUser.selector);
        vm.prank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            maxContributionPerUser + 1
        );

        vm.prank(operator);
        keyMinter.setMaxTotalContribution(maxContributionPerUser * 2 - 1);

        vm.prank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            maxContributionPerUser
        );

        vm.deal(users[1], maxContributionPerUser);
        vm.startPrank(users[1]);
        factory.mintProtoshipUniverse1(address(externalERC721), 1);
        vm.expectRevert(ExceedMaxTotalContribution.selector);
        makeSigAndMintKey(
            profileContractAddress,
            1,
            1,
            keyTokenIds[0],
            maxContributionPerUser
        );
    }

    function testBatchMintKey() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;
        address spaceshipTBA = getTBAaddress(
            address(spaceship),
            spaceshipTokenId
        );

        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 0);
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[1]), 0);

        vm.deal(users[0], 10 ether);
        vm.startPrank(users[0]);
        uint beforeBalance = users[0].balance;
        makeSigAndBatchMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds,
            1 ether
        );
        uint afterBalance = users[0].balance;

        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 1);
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[1]), 1);

        assertEq(keyMinter.getUserContribution(users[0]), 1 ether);
        assertEq(keyMinter.getUserMintCount(users[0]), 2);
        assertEq(beforeBalance - afterBalance, 1 ether);
    }

    function makeSigAndMintKey(
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256 keyTokenId,
        uint256 contribution
    ) internal {
        keyMinter.mintKey{value: contribution}(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenId,
            makeSignature(
                serviceAdminPk,
                profileContractAddress,
                profileTokenId,
                spaceshipTokenId,
                keyTokenId,
                contribution
            )
        );
    }

    function makeSigAndBatchMintKey(
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256[] memory _keyTokenIds,
        uint256 contribution
    ) internal {
        keyMinter.batchMintKey{value: contribution}(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            _keyTokenIds,
            makeSignature(
                serviceAdminPk,
                profileContractAddress,
                profileTokenId,
                spaceshipTokenId,
                _keyTokenIds,
                contribution
            )
        );
    }

    function makeSignature(
        uint256 pk,
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256 keyTokenId,
        uint256 contribution
    ) public view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            pk,
            ECDSA.toTypedDataHash(
                keyMinterDomainSeparator,
                keccak256(
                    abi.encode(
                        keyMintParamsTypeHash,
                        profileContractAddress,
                        profileTokenId,
                        spaceshipTokenId,
                        keyTokenId,
                        contribution
                    )
                )
            )
        );
        return abi.encodePacked(r, s, v);
    }

    function makeSignature(
        uint256 pk,
        address profileContractAddress,
        uint256 profileTokenId,
        uint256 spaceshipTokenId,
        uint256[] memory _keyTokenIds,
        uint256 contribution
    ) public view returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            pk,
            ECDSA.toTypedDataHash(
                keyMinterDomainSeparator,
                keccak256(
                    abi.encode(
                        keyBatchMintParamsTypeHash,
                        profileContractAddress,
                        profileTokenId,
                        spaceshipTokenId,
                        _keyTokenIds,
                        contribution
                    )
                )
            )
        );
        return abi.encodePacked(r, s, v);
    }
}
