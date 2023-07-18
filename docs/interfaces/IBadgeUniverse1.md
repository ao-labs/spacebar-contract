# Solidity API

## IBadgeUniverse1

_Souldbound Tokens(SBT) are non-transferable tokens._

### TokenType

```solidity
struct TokenType {
  uint128 primaryType;
  uint128 secondaryType;
}
```

### mintBadge

```solidity
function mintBadge(address to, uint128 primaryType, uint128 secondaryType, string tokenURI) external
```

Mints a new badge

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the badge to |
| primaryType | uint128 | The primary type of the badge |
| secondaryType | uint128 | The secondary type of the badge |
| tokenURI | string |  |

### getTokenType

```solidity
function getTokenType(uint256 tokenId) external returns (struct IBadgeUniverse1.TokenType)
```

_Returns the type of the badge (primary type, secondary type)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token |

### isOwnerOfTokenType

```solidity
function isOwnerOfTokenType(address user, uint128 primaryType, uint128 secondaryType) external returns (bool)
```

_Returns whether the user owns a specific token type_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | user address |
| primaryType | uint128 | Primary type of token |
| secondaryType | uint128 | Secondary type of token |

