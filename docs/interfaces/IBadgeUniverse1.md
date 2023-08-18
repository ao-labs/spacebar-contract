# Solidity API

## IBadgeUniverse1

_Soulbound Tokens (SBT) are non-transferable tokens._

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

Mints a new badge.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to which the badge will be minted. |
| primaryType | uint128 | The primary type of the badge. |
| secondaryType | uint128 | The secondary type of the badge. |
| tokenURI | string |  |

### getTokenType

```solidity
function getTokenType(uint256 tokenId) external returns (struct IBadgeUniverse1.TokenType)
```

_Returns the type of the badge (primary type, secondary type)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token. |

### isOwnerOfTokenType

```solidity
function isOwnerOfTokenType(address user, uint128 primaryType, uint128 secondaryType) external returns (bool)
```

_Determines whether the user owns a specific token type._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | The user's address. |
| primaryType | uint128 | The primary type of the token. |
| secondaryType | uint128 | The secondary type of the token. |

### balanceOfTokenType

```solidity
function balanceOfTokenType(address user, uint128 primaryType, uint128 secondaryType) external view returns (uint256)
```

_Returns the balance of a specific token type that user has._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | The user's address. |
| primaryType | uint128 | The primary type of the token. |
| secondaryType | uint128 | The secondary type of the token. |

