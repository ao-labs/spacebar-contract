// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./interfaces/IERC4907.sol";

contract Telescope {
    function getAvailableSpaceships(
        IERC4907 baseSpaceshipAddress
    ) public view returns (uint, uint[] memory) {
        uint totalNumber;
        uint[] memory availableSpaceshipIds = new uint[](1000);
        for (uint i = 0; i < 1000; i++) {
            if (baseSpaceshipAddress.userOf(i) == address(0)) {
                availableSpaceshipIds[totalNumber] = i;
                totalNumber++;
            }
        }
        return (totalNumber, availableSpaceshipIds);
    }

    function getOccupiedSpaceships(
        IERC4907 baseSpaceshipAddress
    ) public view returns (uint, uint[] memory) {
        uint totalNumber;
        uint[] memory occupiedSpaceshipIds = new uint[](1000);
        for (uint i = 0; i < 1000; i++) {
            if (baseSpaceshipAddress.userOf(i) != address(0)) {
                occupiedSpaceshipIds[totalNumber] = i;
                totalNumber++;
            }
        }
        return (totalNumber, occupiedSpaceshipIds);
    }
}
