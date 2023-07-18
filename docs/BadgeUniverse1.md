# Solidity API

## CanNotTransfer

```solidity
error CanNotTransfer()
```

## CanNotApprove

```solidity
error CanNotApprove()
```

## OnlySpaceFactory

```solidity
error OnlySpaceFactory()
```

## InvalidTokenId

```solidity
error InvalidTokenId()
```

## BadgeUniverse1

_Souldbound Tokens(SBT) are non-transferable tokens._

### totalSupply

```solidity
uint256 totalSupply
```

_The total supply of tokens_

### spaceFactory

```solidity
address spaceFactory
```

### MintBadge

```solidity
event MintBadge(address to, uint128 primaryType, uint128 secondaryType, uint256 tokenId, string tokenURI)
```

### constructor

```solidity
constructor(address _spaceFactory) public
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

### approve

```solidity
function approve(address, uint256) public virtual
```

_This function is not implemented._

### setApprovalForAll

```solidity
function setApprovalForAll(address, bool) public virtual
```

_This function is not implemented._

### getTokenType

```solidity
function getTokenType(uint256 tokenId) external view returns (struct IBadgeUniverse1.TokenType)
```

_Returns the type of the badge (primary type, secondary type)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token |

### isOwnerOfTokenType

```solidity
function isOwnerOfTokenType(address user, uint128 primaryType, uint128 secondaryType) external view returns (bool)
```

_Returns whether the user owns a specific token type_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| user | address | user address |
| primaryType | uint128 | Primary type of token |
| secondaryType | uint128 | Secondary type of token |

### _setTokenURI

```solidity
function _setTokenURI(uint256 tokenId, string _tokenURI) internal virtual
```

_Sets `_tokenURI` as the tokenURI of `tokenId`.

Requirements:

- `tokenId` must exist._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual
```

_Users cannot transfer SBTs._

### _baseURI

```solidity
function _baseURI() internal pure returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._
