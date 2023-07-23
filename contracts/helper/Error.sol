// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* ============ Errors ============ */
contract Error {
    error CanNotTransfer();
    error CanNotApprove();
    error OnlySpaceFactory();
    error OnlySpaceFactoryOrOwner();
    error InvalidTokenId();
    error OnlyOneProtoshipAtATime();
    error OnlyNFTOwner();
    error InvalidProtoship();
    error AddressAlreadyRegistered();
    error NotWhiteListed();
    error TokenLocked();
    error OnlyLockedToken();
    error ReachedMaxSupply();
}
