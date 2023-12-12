// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./helper/DefaultSetup.sol";
import "../contracts/helper/Error.sol";
import "../contracts/KeyMinterV1.sol";
import "../contracts/KeyUniverse1.sol";
import "../contracts/SampleKeyMinterV2.sol";

contract KeyMinterV1Test is DefaultSetup, Error {
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

    KeyMinterV1 public keyMinter;
    KeyUniverse1 public key;

    bytes32 keyMinterDomainSeparator;
    bytes32 keyMintParamsTypeHash;
    bytes32 keyBatchMintParamsTypeHash;

    address vault = vm.addr(1000);
    address operator = vm.addr(1001);

    uint256[] keyTokenIds = [1010, 1020, 1030, 1040];
    string[] keyURIs = ["aaa", "bbb", "ccc", "ddd"];

    function setUp() public override {
        super.setUp();
        // user 0 and user 1 has nft
        for (uint256 i = 0; i < 2; i++) {
            externalERC721.mint(users[i], i);
        }
        // user 0 has spaceship
        vm.prank(users[0]);
        factory.mintProtoshipUniverse1(address(externalERC721), 0);

        // deploy KeyMinterV1 as a proxy
        keyMinter = KeyMinterV1(
            payable(address(new ERC1967Proxy(address(new KeyMinterV1()), "")))
        );
        key = new KeyUniverse1(defaultAdmin, operator, address(keyMinter));
        keyMinter.initialize(
            payable(vault),
            defaultAdmin,
            operator,
            serviceAdmin,
            spaceship,
            IKeyUniverse1(address(key)),
            registry,
            implementation
        );

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
        assertEq(keyMinter.currentTotalContribution(), 1 ether);
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
        uint256 spaceshipTokenId = 0;
        uint maxContributionPerUser = keyMinter.maxContributionPerUser();
        uint128[] memory maxContributionSchedulePerMint = new uint128[](1);
        maxContributionSchedulePerMint[0] = uint128(maxContributionPerUser + 1); // make it big enough
        vm.prank(operator);
        keyMinter.setMaxContributionSchedulePerMint(
            maxContributionSchedulePerMint
        );

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

    function testdefaultContributionSchedulePerMint() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;

        vm.deal(users[0], 100 ether);
        vm.startPrank(users[0]);

        // default is up to 10 ether per mint
        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            11 ether
        );

        // this should work
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            9 ether
        );

        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            4 ether
        );

        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[2],
            15 ether
        );
    }

    function testMaxContributionSchedulePerMint() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;
        uint128[] memory maxContributionSchedulePerMint = new uint128[](3);
        maxContributionSchedulePerMint[0] = 1 ether;
        maxContributionSchedulePerMint[1] = 2 ether;
        maxContributionSchedulePerMint[2] = 3 ether;
        vm.prank(operator);
        keyMinter.setMaxContributionSchedulePerMint(
            maxContributionSchedulePerMint
        );
        vm.stopPrank();

        vm.startPrank(users[0]);
        vm.deal(users[0], 100 ether);

        // first mint can contribute up to 1 ether
        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            2 ether
        );

        // this should work
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            1 ether
        );

        // second mint can contribute up to 2 ether
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            1.5 ether
        );

        // third mint can contribute up to 3 ether
        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[2],
            4 ether
        );

        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[2],
            3 ether
        );

        // it stays the same for the rest of the mints
        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[3],
            4 ether
        );

        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[3],
            3 ether
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

        vm.deal(users[0], 1000 ether);
        // should revert because current default contribution is 10 ether per mint
        uint256 contributionAmount = keyTokenIds.length * 10 ether + 1 ether;
        vm.expectRevert(ExceedMaxContributionPerMint.selector);
        vm.startPrank(users[0]);
        makeSigAndBatchMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds,
            contributionAmount
        );

        uint beforeBalance = users[0].balance;
        // should work
        contributionAmount = keyTokenIds.length * 10 ether;
        makeSigAndBatchMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds,
            contributionAmount
        );
        uint afterBalance = users[0].balance;

        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[0]), 1);
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[1]), 1);
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[2]), 1);
        assertEq(key.balanceOf(spaceshipTBA, keyTokenIds[3]), 1);

        assertEq(keyMinter.getUserContribution(users[0]), contributionAmount);
        assertEq(keyMinter.getUserMintCount(users[0]), keyTokenIds.length);
        assertEq(beforeBalance - afterBalance, contributionAmount);
    }

    function testVaultBalance() public {
        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;
        vm.deal(users[0], 10 ether);
        vm.startPrank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[0],
            0.5 ether
        );

        assertEq(address(keyMinter).balance, 0 ether);
        assertEq(address(vault).balance, 0.5 ether);

        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            0.5 ether
        );
        assertEq(address(keyMinter).balance, 0 ether);
        assertEq(address(vault).balance, 1 ether);

        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[2],
            1.5 ether
        );
        assertEq(address(keyMinter).balance, 0 ether);
        assertEq(address(vault).balance, 2.5 ether);
    }

    function testRefund() public {
        address profileContractAddress = address(externalERC721);
        vm.deal(users[1], 1 ether);
        vm.deal(users[2], 3 ether);
        vm.prank(users[0]);
        makeSigAndMintKey(
            profileContractAddress,
            0,
            0,
            keyTokenIds[0],
            0 ether
        );
        vm.startPrank(users[1]);
        factory.mintProtoshipUniverse1(address(externalERC721), 1);
        makeSigAndMintKey(
            profileContractAddress,
            1,
            1,
            keyTokenIds[0],
            1 ether
        );
        vm.stopPrank();
        vm.startPrank(users[2]);
        externalERC721.mint(users[2], 2);
        factory.mintProtoshipUniverse1(address(externalERC721), 2);
        makeSigAndMintKey(
            profileContractAddress,
            2,
            2,
            keyTokenIds[0],
            2 ether
        );
        // user 1 and user 2 has 1 ether and 2 ether contribution
        assertEq(address(vault).balance, 3 ether);

        // cannot send ether to key minter during normal period
        vm.expectRevert(OnlyDuringRefundPeriod.selector);
        payable(address(keyMinter)).transfer(1 ether);

        // cannot refund during normal period
        vm.expectRevert(OnlyDuringRefundPeriod.selector);
        keyMinter.refund();

        vm.expectRevert();
        // only default admin can refund
        keyMinter.setIsRefundEnabled(true);

        vm.stopPrank();
        vm.prank(defaultAdmin);
        keyMinter.setIsRefundEnabled(true);

        // cannot contribute during refund period
        vm.expectRevert(NotDuringRefundPeriod.selector);
        vm.prank(users[2]);
        makeSigAndMintKey(
            profileContractAddress,
            2,
            2,
            keyTokenIds[1],
            1 ether
        );

        // first, send the contribution back to key minter
        vm.prank(vault);
        payable(address(keyMinter)).transfer(
            keyMinter.currentTotalContribution()
        );
        assertEq(address(keyMinter).balance, 3 ether);

        // users call refund function
        vm.prank(users[0]);
        keyMinter.refund();
        assertEq(users[0].balance, 0 ether);

        vm.prank(users[1]);
        keyMinter.refund();
        assertEq(users[1].balance, 1 ether);

        vm.prank(users[2]);
        keyMinter.refund();
        assertEq(users[2].balance, 3 ether);

        // it won't send ether twice
        vm.prank(users[2]);
        keyMinter.refund();
        assertEq(users[2].balance, 3 ether);

        // it won't send ether to the user who didn't contribute
        vm.prank(users[3]);
        keyMinter.refund();
        assertEq(users[3].balance, 0 ether);
    }

    function testUpgradeability() public {
        // cannot initialize twice
        vm.expectRevert();
        keyMinter.initialize(
            payable(vault),
            defaultAdmin,
            operator,
            serviceAdmin,
            spaceship,
            IKeyUniverse1(address(key)),
            registry,
            implementation
        );

        SampleKeyMinterV2 newImplementation = new SampleKeyMinterV2();
        SampleKeyMinterV2 newImplementation2 = new SampleKeyMinterV2();

        address profileContractAddress = address(externalERC721);
        uint256 profileTokenId = 0;
        uint256 spaceshipTokenId = 0;
        vm.startPrank(users[1]);

        // Before upgrade, this should revert because user 1 doesn't have profile 0
        vm.expectRevert(OnlyNFTOwner.selector);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            0
        );

        // try upgrading
        vm.expectRevert(); // only default admin can change the implementation
        keyMinter.upgradeTo(address(newImplementation));
        vm.stopPrank();

        // now it should work
        vm.prank(defaultAdmin);
        keyMinter.upgradeTo(address(newImplementation));

        // if the upgrade is successful, it can be upgraded by anyone
        vm.prank(users[0]);
        keyMinter.upgradeTo(address(newImplementation2));

        // also this should not revert since _checkNFTOwnership is overridden
        vm.prank(users[1]);
        makeSigAndMintKey(
            profileContractAddress,
            profileTokenId,
            spaceshipTokenId,
            keyTokenIds[1],
            0
        );
    }

    /* ============ Util Functions ============ */

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
                        keccak256(abi.encodePacked(_keyTokenIds)),
                        contribution
                    )
                )
            )
        );
        return abi.encodePacked(r, s, v);
    }
}
