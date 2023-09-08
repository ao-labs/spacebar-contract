# Solidity API

## ISpaceFactoryV1

### getSpaceshipUniverse1TBA

```solidity
function getSpaceshipUniverse1TBA(uint256 tokenId) external view returns (address)
```

_Returns the TBA address of SpaceshipUniverse1_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | ID of the token |

### mintWhitelistBadgeUniverse1

```solidity
function mintWhitelistBadgeUniverse1(address tokenContract, uint256 tokenId, string tokenURI) external
```

Mints a whitelist badge (SBT) to the TBA address associated with the user's NFT.
During the whitelist period, a user must own a specific type of badge to mint a Protoship.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | The contract address of the user's NFT. |
| tokenId | uint256 | The token ID of the user's NFT. |
| tokenURI | string | The token URI of the badge. |

