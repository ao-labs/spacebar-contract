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

## BadgeSBTUniverse1

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
event MintBadge(address to, uint128 primaryType, uint128 secondaryType, uint256 tokenId)
```

### constructor

```solidity
constructor(address _spaceFactory) public
```

### mintBadge

```solidity
function mintBadge(address to, uint128 primaryType, uint128 secondaryType) external
```

Mints a new badge

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the badge to |
| primaryType | uint128 | The primary type of the badge |
| secondaryType | uint128 | The secondary type of the badge |

### approve

```solidity
function approve(address to, uint256 tokenId) public
```

_See {IERC721-approve}._

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) public virtual
```

_See {IERC721-setApprovalForAll}._

### getTokenType

```solidity
function getTokenType(uint256 tokenId) external view returns (struct IBadgeSBTUniverse1.TokenType)
```

_Returns the type of the badge (primary type, secondary type)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token |

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual
```

### _baseURI

```solidity
function _baseURI() internal pure returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

