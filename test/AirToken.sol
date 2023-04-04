// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AirToken is ERC20 {
    constructor() ERC20("AirToken", "AIR") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
