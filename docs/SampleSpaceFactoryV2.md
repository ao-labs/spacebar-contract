# Solidity API

## SpaceFactoryV2

This contract is just for testing upgradeability

### test

```solidity
uint256 test
```

### mintProtoshipUniverse1

```solidity
function mintProtoshipUniverse1(address tokenContract, uint256 tokenId) external returns (address)
```

mints a Protoship to the TBA address of user's NFT, and deploys the TBA of spaceship

_If the address already has TBA, it will use the existing TBA, and if the TBA
already has a Protoship, it will revert(OnlyOneProtoshipAtATime)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | TBA's contract address |
| tokenId | uint256 | TBA's token ID |

