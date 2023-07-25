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

Mints a Protoship to the TBA address associated with the user's NFT and deploys the TBA of the spaceship.

_If the address already has a TBA, it will use the existing TBA. If the TBA already has a Protoship,
it will revert with the error 'OnlyOneProtoshipAtATime'._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | The contract address of the TBA. |
| tokenId | uint256 | The token ID of the TBA. |

