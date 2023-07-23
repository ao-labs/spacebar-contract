# Solidity API

## SpaceFactoryV2

This contract is just for testing purposes

### test

```solidity
uint256 test
```

### mintProtoshipUniverse1

```solidity
function mintProtoshipUniverse1(address tokenContract, uint256 tokenId) external returns (address)
```

Deploys a new Token Bound Account (TBA) and mint a Protoship to the address

_If the address already has TBA, it will use the existing TBA, and if the TBA
already has a Protoship, it will revert(OnlyOneProtoshipAtATime)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | TBA's contract address |
| tokenId | uint256 | TBA's token ID |

