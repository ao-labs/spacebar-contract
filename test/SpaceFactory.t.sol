// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {SpaceFactory} from "contracts/SpaceFactory.sol";
import {BaseSpaceshipNFT} from "contracts/BaseSpaceshipNFT.sol";
import {SpaceshipNFT} from "contracts/SpaceshipNFT.sol";
import {PartsNFT} from "contracts/PartsNFT.sol";
import {ScoreNFT} from "contracts/ScoreNFT.sol";
import {BadgeSBT} from "contracts/BadgeSBT.sol";
import {AirToken} from "./AirToken.sol";
import {IERC5484} from "contracts/interfaces/IERC5484.sol";

contract SpaceFactoryTest is Test {
    SpaceFactory spaceFactory;
    BaseSpaceshipNFT baseSpaceshipNFT;
    SpaceshipNFT spaceshipNFT;
    PartsNFT partsNFT;
    ScoreNFT scoreNFT;
    BadgeSBT badgeSBT;
    AirToken airToken;
    address signer;
    address feeCollector;
    address userA;
    address userB;

    uint24[] quantityPerPartsType = [30, 40, 50, 60, 70];
    uint16 partsMintingSuccessRate = 10000; // 100%

    mapping(uint => uint) partsIdToAmount;

    event UpdateSpaceship(uint indexed id, uint24[] parts, bytes32 nickname);

    function setUp() public {
        signer = vm.addr(1);
        feeCollector = vm.addr(2);
        userA = vm.addr(3);
        userB = vm.addr(4);
        spaceFactory = new SpaceFactory(
            signer,
            quantityPerPartsType,
            partsMintingSuccessRate
        );
        airToken = new AirToken();
        baseSpaceshipNFT = new BaseSpaceshipNFT(address(spaceFactory));
        spaceshipNFT = new SpaceshipNFT(address(spaceFactory));
        partsNFT = new PartsNFT(address(spaceFactory));
        scoreNFT = new ScoreNFT(address(spaceFactory));
        badgeSBT = new BadgeSBT(address(spaceFactory), signer);
        spaceFactory.setBaseSpaceshipNFTAddress(baseSpaceshipNFT);
        spaceFactory.setSpaceshipNFTAddress(spaceshipNFT);
        spaceFactory.setPartsNFTAddress(partsNFT);
        spaceFactory.setScoreNFTAddress(scoreNFT);
        spaceFactory.setBadgeSBTAddress(badgeSBT);
        spaceFactory.setAirTokenAddress(airToken);
        spaceFactory.setFeeCollectorAddress(feeCollector);
    }

    function generateSignatrue()
        public
        pure
        returns (SpaceFactory.Signature memory)
    {
        return SpaceFactory.Signature("", "", 0);
    }

    function test_rentBaseSpaceship(uint tokenId) public {
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        tokenId = bound(tokenId, 0, maxSupply - 1);
        vm.prank(userA);
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        assertEq(baseSpaceshipNFT.ownerOf(tokenId), address(spaceFactory));
    }

    function test_rentBaseSpaceshipByAdmin(uint tokenId) public {
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        tokenId = bound(tokenId, 0, maxSupply - 1);
        vm.prank(signer);
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        assertEq(baseSpaceshipNFT.ownerOf(tokenId), address(spaceFactory));
    }

    function test_rentBaseSpaceshipWithAir() public {
        uint256 tokenId = 0;
        uint256 tokenAmount = 100;
        uint256 baseSpaceshipRentalFee = 10;
        spaceFactory.setBaseSpaceshipRentalFee(baseSpaceshipRentalFee);
        airToken.transfer(userA, tokenAmount);
        assertEq(airToken.balanceOf(userA), tokenAmount);
        vm.startPrank(userA);
        airToken.approve(address(spaceFactory), baseSpaceshipRentalFee);
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        assertEq(baseSpaceshipNFT.ownerOf(tokenId), address(spaceFactory));
        assertEq(
            airToken.balanceOf(userA),
            tokenAmount - baseSpaceshipRentalFee
        );
    }

    function test_rentBaseSpaceshipWithAirByAdmin() public {
        uint256 tokenId = 0;
        uint256 tokenAmount = 100;
        uint256 baseSpaceshipRentalFee = 10;
        spaceFactory.setBaseSpaceshipRentalFee(baseSpaceshipRentalFee);
        airToken.transfer(userA, tokenAmount);
        assertEq(airToken.balanceOf(userA), tokenAmount);
        vm.prank(userA);
        airToken.approve(address(spaceFactory), baseSpaceshipRentalFee);
        vm.startPrank(signer);
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        assertEq(baseSpaceshipNFT.ownerOf(tokenId), address(spaceFactory));
        assertEq(
            airToken.balanceOf(userA),
            tokenAmount - baseSpaceshipRentalFee
        );
    }

    function test_rentBaseSpaceshipWithoutAir() public {
        uint256 tokenId = 0;
        uint256 tokenAmount = 100;
        uint256 baseSpaceshipRentalFee = 10;
        spaceFactory.setBaseSpaceshipRentalFee(baseSpaceshipRentalFee);
        airToken.transfer(userA, tokenAmount);

        vm.startPrank(userA);
        vm.expectRevert("ERC20: insufficient allowance");
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
    }

    function test_rentBaseSpaceshipWhenNotAvailable() public {
        uint tokenId = 0;
        vm.startPrank(signer);
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        vm.expectRevert(
            abi.encodeWithSelector(
                SpaceFactory.UnavailableBaseSpaceship.selector,
                tokenId,
                userA
            )
        );
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userB);
    }

    function test_rentBaseSpaceshipWhenAlreadyHaveOne(
        uint tokenId,
        uint tokenId2
    ) public {
        uint256 maxSupply = baseSpaceshipNFT.MAXIMUM_SUPPLY();
        tokenId = bound(tokenId, 0, maxSupply - 1);
        tokenId2 = bound(tokenId, 0, maxSupply - 1);
        vm.startPrank(signer);
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(baseSpaceshipNFT.userOf(tokenId), userA);
        if (tokenId == tokenId2) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    SpaceFactory.UnavailableBaseSpaceship.selector,
                    tokenId,
                    userA
                )
            );
        } else {
            vm.expectRevert(SpaceFactory.AlreadyUserOfBaseSpaceship.selector);
        }
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId2, userA);
    }

    function test_extendBaseSpaceship() public {
        uint tokenId = 0;
        uint64 baseSpaceshipAccessPeriod = spaceFactory
            .baseSpaceshipAccessPeriod();
        vm.startPrank(userA);
        uint currentTime = block.timestamp;
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod + currentTime
        );

        vm.warp(baseSpaceshipAccessPeriod + currentTime);
        spaceFactory.extendBaseSpaceship(tokenId, generateSignatrue());
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod * 2 + currentTime
        );
    }

    function test_extendBaseSpaceshipByAdmin() public {
        uint tokenId = 0;
        uint64 baseSpaceshipAccessPeriod = spaceFactory
            .baseSpaceshipAccessPeriod();
        vm.startPrank(signer);
        uint currentTime = block.timestamp;
        spaceFactory.rentBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod + currentTime
        );

        vm.warp(baseSpaceshipAccessPeriod + currentTime);
        spaceFactory.extendBaseSpaceshipByAdmin(tokenId, userA);
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod * 2 + currentTime
        );
    }

    function test_extendBaseSpaceshipAfterExpires() public {
        uint tokenId = 0;
        uint64 baseSpaceshipAccessPeriod = spaceFactory
            .baseSpaceshipAccessPeriod();
        vm.startPrank(userA);
        uint currentTime = block.timestamp;
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod + currentTime
        );

        vm.warp(baseSpaceshipAccessPeriod + currentTime + 1);
        vm.expectRevert();
        spaceFactory.extendBaseSpaceship(tokenId, generateSignatrue());
    }

    function test_extendBaseSpaceshipNotOwner() public {
        uint tokenId = 0;
        uint64 baseSpaceshipAccessPeriod = spaceFactory
            .baseSpaceshipAccessPeriod();
        vm.prank(userA);
        uint currentTime = block.timestamp;
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        vm.warp(baseSpaceshipAccessPeriod + currentTime);
        vm.prank(userB);
        vm.expectRevert();
        spaceFactory.extendBaseSpaceship(tokenId, generateSignatrue());
    }

    function test_extendBaseSpaceshipBeforeExtensionPeriod(
        uint secondsToWarp
    ) public {
        uint tokenId = 0;
        uint64 baseSpaceshipAccessPeriod = spaceFactory
            .baseSpaceshipAccessPeriod();
        secondsToWarp = bound(secondsToWarp, 0, baseSpaceshipAccessPeriod);

        vm.startPrank(userA);
        uint currentTime = block.timestamp;
        console.log(currentTime);
        spaceFactory.rentBaseSpaceship(tokenId, generateSignatrue());
        assertEq(
            baseSpaceshipNFT.userExpires(tokenId),
            baseSpaceshipAccessPeriod + currentTime
        );
        vm.warp(currentTime + 1);
        spaceFactory.extendBaseSpaceship(tokenId, generateSignatrue());

        vm.warp(currentTime + secondsToWarp);
        vm.expectRevert();
        spaceFactory.extendBaseSpaceship(tokenId, generateSignatrue());
    }

    function test_mintRandomParts(uint64 timestamp, uint256 amount) public {
        amount = bound(amount, 1, 1000);
        vm.warp(timestamp);
        vm.prank(userA);
        uint[] memory ids = spaceFactory.mintRandomParts(
            amount,
            generateSignatrue()
        );

        for (uint i = 0; i < ids.length; i++) {
            partsIdToAmount[ids[i]] += 1;
        }

        for (uint i = 0; i < amount; i++) {
            assertEq(
                partsIdToAmount[ids[i]],
                partsNFT.balanceOf(userA, ids[i])
            );

            //parts id starts from 100001, up to 500070
            assertGt(ids[i], 100000);
            assertLt(ids[i], 500071);
        }
    }

    function test_mintRandomPartsByAdmin(
        uint64 timestamp,
        uint256 amount
    ) public {
        amount = bound(amount, 1, 1000);
        vm.warp(timestamp);
        vm.prank(signer);
        uint[] memory ids = spaceFactory.mintRandomPartsByAdmin(amount, userA);

        for (uint i = 0; i < ids.length; i++) {
            partsIdToAmount[ids[i]] += 1;
        }

        for (uint i = 0; i < amount; i++) {
            assertEq(
                partsIdToAmount[ids[i]],
                partsNFT.balanceOf(userA, ids[i])
            );
            assertGt(ids[i], 100000);
            assertLt(ids[i], 500071);
        }
    }

    function test_mintRandomPartsSuccessRate(
        uint64 timestamp,
        uint amount
    ) public {
        amount = bound(amount, 100, 1000);
        vm.warp(timestamp);

        spaceFactory.setPartsMintingSuccessRate(partsMintingSuccessRate / 2); //50%

        vm.prank(signer);
        uint[] memory ids = spaceFactory.mintRandomPartsByAdmin(amount, userA);

        for (uint i = 0; i < ids.length; i++) {
            partsIdToAmount[ids[i]] += 1;
        }

        for (uint i = 0; i < amount; i++) {
            if (ids[i] == 0) {
                continue;
            }
            assertEq(
                partsIdToAmount[ids[i]],
                partsNFT.balanceOf(userA, ids[i])
            );
        }

        // since the success rate is 50%, the amount of parts failed should be in this range (30~70)
        assertGt(partsIdToAmount[0], (amount * 3) / 10);
        assertLt(partsIdToAmount[0], (amount * 7) / 10);
    }

    function test_mintRandomPartsSuccessRate2(
        uint64 timestamp,
        uint amount
    ) public {
        amount = bound(amount, 100, 1000);
        vm.warp(timestamp);

        spaceFactory.setPartsMintingSuccessRate(partsMintingSuccessRate / 10); //10%

        vm.prank(signer);
        uint[] memory ids = spaceFactory.mintRandomPartsByAdmin(amount, userA);

        for (uint i = 0; i < ids.length; i++) {
            partsIdToAmount[ids[i]] += 1;
        }

        for (uint i = 0; i < amount; i++) {
            if (ids[i] == 0) {
                continue;
            }
            assertEq(
                partsIdToAmount[ids[i]],
                partsNFT.balanceOf(userA, ids[i])
            );
        }

        // since the success rate is 10%, the amount of parts failed
        // should roughtly be in this range (70~100)
        assertGt(partsIdToAmount[0], (amount * 7) / 10);
        assertLt(partsIdToAmount[0], (amount));
    }

    function test_mintRandomPartsSuccessRate3(
        uint64 timestamp,
        uint amount
    ) public {
        amount = bound(amount, 100, 1000);
        vm.warp(timestamp);

        spaceFactory.setPartsMintingSuccessRate(partsMintingSuccessRate); //100%

        vm.prank(signer);
        uint[] memory ids = spaceFactory.mintRandomPartsByAdmin(amount, userA);

        for (uint i = 0; i < ids.length; i++) {
            partsIdToAmount[ids[i]] += 1;
        }

        for (uint i = 0; i < amount; i++) {
            if (ids[i] == 0) {
                continue;
            }
            assertEq(
                partsIdToAmount[ids[i]],
                partsNFT.balanceOf(userA, ids[i])
            );
        }

        // since the success rate is 100%, the amount of parts failed should be 0
        assertEq(partsIdToAmount[0], 0);
    }

    function test_mintSpecialParts() public {
        uint id1 = 1000001;
        uint fee1 = 100;

        spaceFactory.setSpecialPartsMintingFee(id1, fee1);

        airToken.transfer(userA, fee1);
        vm.startPrank(userA);
        airToken.approve(address(spaceFactory), fee1);

        spaceFactory.mintSpecialParts(id1, generateSignatrue());

        assertEq(airToken.balanceOf(spaceFactory.feeCollector()), fee1);
        assertEq(partsNFT.balanceOf(userA, id1), 1);
    }

    function test_mintSpecialPartsByAdmin() public {
        uint id1 = 1000001;
        uint id2 = 2000002;
        uint id3 = 3000003;
        uint id4 = 4000004;
        uint id5 = 5000005;

        uint fee1 = 100;
        uint fee2 = 200;
        uint fee3 = 300;
        uint fee4 = 400;
        uint fee5 = 500;

        spaceFactory.setSpecialPartsMintingFee(id1, fee1);
        spaceFactory.setSpecialPartsMintingFee(id2, fee2);
        spaceFactory.setSpecialPartsMintingFee(id3, fee3);
        spaceFactory.setSpecialPartsMintingFee(id4, fee4);
        spaceFactory.setSpecialPartsMintingFee(id5, fee5);

        airToken.transfer(userA, fee1 + fee2 + fee3 + fee4 + fee5);
        vm.prank(userA);
        airToken.approve(
            address(spaceFactory),
            fee1 + fee2 + fee3 + fee4 + fee5
        );

        vm.startPrank(signer);
        spaceFactory.mintSpecialPartsByAdmin(id1, userA);
        assertEq(airToken.balanceOf(spaceFactory.feeCollector()), fee1);
        spaceFactory.mintSpecialPartsByAdmin(id2, userA);
        assertEq(airToken.balanceOf(spaceFactory.feeCollector()), fee1 + fee2);
        spaceFactory.mintSpecialPartsByAdmin(id3, userA);
        assertEq(
            airToken.balanceOf(spaceFactory.feeCollector()),
            fee1 + fee2 + fee3
        );
        spaceFactory.mintSpecialPartsByAdmin(id4, userA);
        assertEq(
            airToken.balanceOf(spaceFactory.feeCollector()),
            fee1 + fee2 + fee3 + fee4
        );
        spaceFactory.mintSpecialPartsByAdmin(id5, userA);
        assertEq(
            airToken.balanceOf(spaceFactory.feeCollector()),
            fee1 + fee2 + fee3 + fee4 + fee5
        );
        assertEq(airToken.balanceOf(userA), 0);
        assertEq(partsNFT.balanceOf(userA, id1), 1);
        assertEq(partsNFT.balanceOf(userA, id2), 1);
        assertEq(partsNFT.balanceOf(userA, id3), 1);
        assertEq(partsNFT.balanceOf(userA, id4), 1);
        assertEq(partsNFT.balanceOf(userA, id5), 1);
    }

    function test_mintNewSpaceship() public {
        uint baseSpaceshipId = 0;
        bytes32 nickname = "test";
        uint parts1 = 1000001;
        uint parts2 = 2000002;
        uint parts3 = 3000003;
        uint parts4 = 4000004;
        uint parts5 = 5000005;

        uint fee1 = 100;
        uint fee2 = 200;
        uint fee3 = 300;
        uint fee4 = 400;
        uint fee5 = 500;

        spaceFactory.setSpecialPartsMintingFee(parts1, fee1);
        spaceFactory.setSpecialPartsMintingFee(parts2, fee2);
        spaceFactory.setSpecialPartsMintingFee(parts3, fee3);
        spaceFactory.setSpecialPartsMintingFee(parts4, fee4);
        spaceFactory.setSpecialPartsMintingFee(parts5, fee5);

        airToken.transfer(userA, fee1 + fee2 + fee3 + fee4 + fee5);
        vm.startPrank(userA);
        airToken.approve(
            address(spaceFactory),
            fee1 + fee2 + fee3 + fee4 + fee5
        );
        spaceFactory.mintSpecialParts(parts1, generateSignatrue());
        spaceFactory.mintSpecialParts(parts2, generateSignatrue());
        spaceFactory.mintSpecialParts(parts3, generateSignatrue());
        spaceFactory.mintSpecialParts(parts4, generateSignatrue());
        spaceFactory.mintSpecialParts(parts5, generateSignatrue());

        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());

        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(parts1);
        partsArray[1] = uint24(parts2);
        partsArray[2] = uint24(parts3);
        partsArray[3] = uint24(parts4);
        partsArray[4] = uint24(parts5);

        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        assertEq(partsNFT.balanceOf(userA, parts1), 0);
        assertEq(partsNFT.balanceOf(userA, parts2), 0);
        assertEq(partsNFT.balanceOf(userA, parts3), 0);
        assertEq(partsNFT.balanceOf(userA, parts4), 0);
        assertEq(partsNFT.balanceOf(userA, parts5), 0);
        vm.expectRevert();
        baseSpaceshipNFT.ownerOf(baseSpaceshipId);

        assertEq(spaceshipNFT.balanceOf(userA), 1);
        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        assertEq(spaceshipNFT.getParts(0)[0], partsArray[0]);
        assertEq(spaceshipNFT.getParts(0)[1], partsArray[1]);
        assertEq(spaceshipNFT.getParts(0)[2], partsArray[2]);
        assertEq(spaceshipNFT.getParts(0)[3], partsArray[3]);
        assertEq(spaceshipNFT.getParts(0)[4], partsArray[4]);
    }

    function test_mintNewSpaceshipByAdmin() public {
        uint baseSpaceshipId = 0;
        bytes32 nickname = "test";
        uint parts1 = 1000001;
        uint parts2 = 2000002;
        uint parts3 = 3000003;
        uint parts4 = 4000004;
        uint parts5 = 5000005;

        uint fee1 = 100;
        uint fee2 = 200;
        uint fee3 = 300;
        uint fee4 = 400;
        uint fee5 = 500;

        spaceFactory.setSpecialPartsMintingFee(parts1, fee1);
        spaceFactory.setSpecialPartsMintingFee(parts2, fee2);
        spaceFactory.setSpecialPartsMintingFee(parts3, fee3);
        spaceFactory.setSpecialPartsMintingFee(parts4, fee4);
        spaceFactory.setSpecialPartsMintingFee(parts5, fee5);

        airToken.transfer(userA, fee1 + fee2 + fee3 + fee4 + fee5);
        vm.startPrank(userA);
        airToken.approve(
            address(spaceFactory),
            fee1 + fee2 + fee3 + fee4 + fee5
        );
        spaceFactory.mintSpecialParts(parts1, generateSignatrue());
        spaceFactory.mintSpecialParts(parts2, generateSignatrue());
        spaceFactory.mintSpecialParts(parts3, generateSignatrue());
        spaceFactory.mintSpecialParts(parts4, generateSignatrue());
        spaceFactory.mintSpecialParts(parts5, generateSignatrue());

        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());

        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(parts1);
        partsArray[1] = uint24(parts2);
        partsArray[2] = uint24(parts3);
        partsArray[3] = uint24(parts4);
        partsArray[4] = uint24(parts5);

        vm.stopPrank();
        vm.prank(signer);
        spaceFactory.mintNewSpaceshipByAdmin(
            baseSpaceshipId,
            nickname,
            partsArray,
            userA
        );

        assertEq(partsNFT.balanceOf(userA, parts1), 0);
        assertEq(partsNFT.balanceOf(userA, parts2), 0);
        assertEq(partsNFT.balanceOf(userA, parts3), 0);
        assertEq(partsNFT.balanceOf(userA, parts4), 0);
        assertEq(partsNFT.balanceOf(userA, parts5), 0);
        vm.expectRevert();
        baseSpaceshipNFT.ownerOf(baseSpaceshipId);

        assertEq(spaceshipNFT.balanceOf(userA), 1);
        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        assertEq(spaceshipNFT.getParts(0)[0], partsArray[0]);
        assertEq(spaceshipNFT.getParts(0)[1], partsArray[1]);
        assertEq(spaceshipNFT.getParts(0)[2], partsArray[2]);
        assertEq(spaceshipNFT.getParts(0)[3], partsArray[3]);
        assertEq(spaceshipNFT.getParts(0)[4], partsArray[4]);
    }

    function _mintPartsToUser(
        address user,
        uint24[] memory partsArray
    ) internal {
        uint fee = 100;
        for (uint i = 0; i < partsArray.length; i++) {
            spaceFactory.setSpecialPartsMintingFee(partsArray[i], fee);
        }

        airToken.transfer(user, fee * partsArray.length);
        vm.startPrank(user);
        airToken.approve(address(spaceFactory), fee * partsArray.length);

        for (uint i = 0; i < partsArray.length; i++) {
            spaceFactory.mintSpecialParts(partsArray[i], generateSignatrue());
        }
        vm.stopPrank();
    }

    function test_mintSpaceshipWithWrongPartsOrder() public {
        uint baseSpaceshipId = 10;
        bytes32 nickname = "test123123";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(4000001);
        partsArray[3] = uint24(3000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());

        vm.expectRevert(SpaceshipNFT.InvalidParts.selector);
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );
    }

    function test_updateSpaceshipParts() public {
        uint baseSpaceshipId = 1;
        bytes32 nickname = "testnickname";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        partsArray[3] = uint24(4000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        uint24[] memory newPartsArray = new uint24[](2);
        newPartsArray[0] = uint24(1000011);
        newPartsArray[1] = uint24(2000021);

        vm.stopPrank();
        _mintPartsToUser(userA, newPartsArray);
        vm.startPrank(userA);

        partsArray[0] = newPartsArray[0];
        partsArray[1] = newPartsArray[1];

        vm.expectEmit(true, true, true, true);
        emit UpdateSpaceship(0, partsArray, "");
        spaceFactory.updateSpaceshipParts(0, partsArray, generateSignatrue());

        assertEq(spaceshipNFT.balanceOf(userA), 1);
        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        assertEq(spaceshipNFT.getParts(0)[0], partsArray[0]);
        assertEq(spaceshipNFT.getParts(0)[1], partsArray[1]);
        assertEq(spaceshipNFT.getParts(0)[2], partsArray[2]);
        assertEq(spaceshipNFT.getParts(0)[3], partsArray[3]);
        assertEq(spaceshipNFT.getParts(0)[4], partsArray[4]);
    }

    function test_updateSpaceshipPartsByAdmin() public {
        uint baseSpaceshipId = 1;
        bytes32 nickname = "testnickname";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        partsArray[3] = uint24(4000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        uint24[] memory newPartsArray = new uint24[](4);
        newPartsArray[0] = uint24(1000011);
        newPartsArray[1] = uint24(2000021);
        newPartsArray[2] = uint24(3000021);
        newPartsArray[3] = uint24(4000021);

        vm.stopPrank();
        _mintPartsToUser(userA, newPartsArray);

        partsArray[0] = newPartsArray[0];
        partsArray[1] = newPartsArray[1];
        partsArray[2] = newPartsArray[2];
        partsArray[3] = newPartsArray[3];

        vm.prank(signer);
        vm.expectEmit(true, true, true, true);
        emit UpdateSpaceship(0, partsArray, "");
        spaceFactory.updateSpaceshipPartsByAdmin(0, partsArray, userA);

        assertEq(spaceshipNFT.balanceOf(userA), 1);
        assertEq(spaceshipNFT.ownerOf(0), userA);
        assertEq(spaceshipNFT.getNickname(0), nickname);
        assertEq(spaceshipNFT.getParts(0)[0], partsArray[0]);
        assertEq(spaceshipNFT.getParts(0)[1], partsArray[1]);
        assertEq(spaceshipNFT.getParts(0)[2], partsArray[2]);
        assertEq(spaceshipNFT.getParts(0)[3], partsArray[3]);
        assertEq(spaceshipNFT.getParts(0)[4], partsArray[4]);
    }

    function test_updateSpaceshipWithInvalidParts() public {
        uint baseSpaceshipId = 1;
        bytes32 nickname = "testnickname";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        partsArray[3] = uint24(4000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        uint24[] memory newPartsArray = new uint24[](2);
        newPartsArray[0] = uint24(1000011);
        newPartsArray[1] = uint24(2000021);

        vm.stopPrank();
        _mintPartsToUser(userA, newPartsArray);
        vm.startPrank(userA);

        partsArray[0] = uint24(2000001);
        partsArray[1] = newPartsArray[1];

        vm.expectRevert();
        spaceFactory.updateSpaceshipParts(0, partsArray, generateSignatrue());

        partsArray[0] = uint24(1000001);
        partsArray[1] = newPartsArray[0];
        partsArray[2] = newPartsArray[1];

        vm.expectRevert(SpaceshipNFT.InvalidParts.selector);
        spaceFactory.updateSpaceshipParts(0, partsArray, generateSignatrue());

        vm.expectRevert(SpaceFactory.InvalidPartsLength.selector);
        spaceFactory.updateSpaceshipParts(
            0,
            newPartsArray,
            generateSignatrue()
        );

        // valid parts list but the request is not from token hodler
        partsArray[0] = newPartsArray[0];
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        vm.stopPrank();
        vm.prank(userB);
        vm.expectRevert(SpaceFactory.NotTokenOnwer.selector);
        spaceFactory.updateSpaceshipParts(0, partsArray, generateSignatrue());
    }

    function test_updateSpaceshipNickname() public {
        uint baseSpaceshipId = 1;
        bytes32 nickname = "testnickname";
        bytes32 newNickname = "testnickname22";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        partsArray[3] = uint24(4000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        spaceFactory.updateSpaceshipNickname(
            0,
            newNickname,
            generateSignatrue()
        );
        assertEq(spaceshipNFT.getNickname(0), newNickname);
    }

    function test_updateSpaceshipNicknameByAdmin() public {
        uint baseSpaceshipId = 1;
        bytes32 nickname = "testnickname";
        bytes32 newNickname = "testnickname22";
        uint24[] memory partsArray = new uint24[](5);
        partsArray[0] = uint24(1000001);
        partsArray[1] = uint24(2000001);
        partsArray[2] = uint24(3000001);
        partsArray[3] = uint24(4000001); // not ascending order
        partsArray[4] = uint24(5000001);

        _mintPartsToUser(userA, partsArray);

        vm.startPrank(userA);
        spaceFactory.rentBaseSpaceship(baseSpaceshipId, generateSignatrue());
        spaceFactory.mintNewSpaceship(
            baseSpaceshipId,
            nickname,
            partsArray,
            generateSignatrue()
        );

        vm.stopPrank();
        vm.startPrank(signer);
        spaceFactory.updateSpaceshipNicknameByAdmin(0, newNickname, userA);
        assertEq(spaceshipNFT.getNickname(0), newNickname);
    }

    function test_mintScore() public {
        uint8 category = 1;
        uint88 score = 100;

        vm.startPrank(userA);
        spaceFactory.mintScore(category, score, generateSignatrue());

        assertEq(scoreNFT.balanceOf(userA), 1);

        uint8 _category;
        uint88 _score;
        address _player;
        address _owner;
        (_category, _score, _player, _owner) = scoreNFT.getScore(0);
        assertEq(_category, category);
        assertEq(_score, score);
        assertEq(_player, userA);
        assertEq(_owner, userA);
    }

    function test_mintScoreByAdmin() public {
        uint8 category = 1;
        uint88 score = 100;

        vm.startPrank(signer);
        spaceFactory.mintScoreByAdmin(category, score, userA);

        assertEq(scoreNFT.balanceOf(userA), 1);

        uint8 _category;
        uint88 _score;
        address _player;
        address _owner;
        (_category, _score, _player, _owner) = scoreNFT.getScore(0);
        assertEq(_category, category);
        assertEq(_score, score);
        assertEq(_player, userA);
        assertEq(_owner, userA);
    }

    function test_mintScoreTransfer() public {
        uint8 category = 1;
        uint88 score = 100;

        vm.startPrank(userA);
        spaceFactory.mintScore(category, score, generateSignatrue());
        scoreNFT.safeTransferFrom(userA, userB, 0);

        assertEq(scoreNFT.balanceOf(userA), 0);
        assertEq(scoreNFT.balanceOf(userB), 1);

        uint8 _category;
        uint88 _score;
        address _player;
        address _owner;
        (_category, _score, _player, _owner) = scoreNFT.getScore(0);
        assertEq(_category, category);
        assertEq(_score, score);
        assertEq(_player, userA);
        assertEq(_owner, userB);
    }

    function test_mintBadge() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;

        vm.startPrank(userA);
        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());

        assertEq(badgeSBT.balanceOf(userA), 1);
        assertEq(badgeSBT.getCategory(0), category);
        assertEq(uint(badgeSBT.burnAuth(0)), uint(burnAuth));
    }

    function test_mintBadgeByAdmin() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;

        vm.startPrank(signer);
        spaceFactory.mintBadgeByAdmin(category, burnAuth, userA);

        assertEq(badgeSBT.balanceOf(userA), 1);
        assertEq(badgeSBT.getCategory(0), category);
        assertEq(uint(badgeSBT.burnAuth(0)), uint(burnAuth));
    }

    function test_mintBadgeFee() public {
        uint8 category1 = 1;
        uint fee1 = 100;
        uint8 category2 = 2;
        uint fee2 = 200;

        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;

        spaceFactory.setBadgeMintingFee(category1, fee1);
        spaceFactory.setBadgeMintingFee(category2, fee2);

        vm.prank(userA);
        vm.expectRevert();
        spaceFactory.mintBadge(category1, burnAuth, generateSignatrue());

        airToken.transfer(userA, fee1 + fee2);
        vm.startPrank(userA);
        airToken.approve(address(spaceFactory), fee1 + fee2);
        spaceFactory.mintBadge(category1, burnAuth, generateSignatrue());
        assertEq(airToken.balanceOf(userA), fee2);
        spaceFactory.mintBadge(category2, burnAuth, generateSignatrue());
        assertEq(airToken.balanceOf(userA), 0);
        assertEq(airToken.balanceOf(feeCollector), fee1 + fee2);

        assertEq(badgeSBT.balanceOf(userA), 2);
    }

    function test_mintBadgeBurn() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Both;

        vm.startPrank(userA);
        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());

        badgeSBT.burn(0);
        assertEq(badgeSBT.balanceOf(userA), 0);

        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());
        vm.stopPrank();
        vm.startPrank(signer);
        badgeSBT.burn(1);
    }

    function test_mintBadgeShouldNotBurn() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.Neither;

        vm.startPrank(userA);
        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());

        vm.expectRevert();
        badgeSBT.burn(0);
        assertEq(badgeSBT.balanceOf(userA), 1);

        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());
        vm.stopPrank();
        vm.startPrank(signer);
        vm.expectRevert();
        badgeSBT.burn(1);
        assertEq(badgeSBT.balanceOf(userA), 2);
    }

    function test_mintBadgeShoulBurnOnlyIssuer() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.IssuerOnly;

        vm.startPrank(userA);
        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());

        vm.expectRevert();
        badgeSBT.burn(0);
        assertEq(badgeSBT.balanceOf(userA), 1);

        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());
        vm.stopPrank();
        vm.startPrank(signer);
        badgeSBT.burn(1);
        assertEq(badgeSBT.balanceOf(userA), 1);
    }

    function test_mintBadgeShoulBurnOnlyOwner() public {
        uint8 category = 1;
        IERC5484.BurnAuth burnAuth = IERC5484.BurnAuth.OwnerOnly;

        vm.startPrank(userA);
        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());

        badgeSBT.burn(0);
        assertEq(badgeSBT.balanceOf(userA), 0);

        spaceFactory.mintBadge(category, burnAuth, generateSignatrue());
        vm.stopPrank();
        vm.startPrank(signer);
        vm.expectRevert();
        badgeSBT.burn(1);
        assertEq(badgeSBT.balanceOf(userA), 1);
    }
}
