// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;

interface IScoreNFT {
    function mintScore(address to, uint8 category, uint88 score) external;
}
