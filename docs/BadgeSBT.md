# Solidity API

## BadgeSBT

_A soulbound token that can be burned by the issuer or the owner.
Token cannot be transferred and its burn authorization is determined by the issuer._

### SPACE_FACTORY

```solidity
bytes32 SPACE_FACTORY
```

_The constant for the space factory role_

### BURNER_ROLE

```solidity
bytes32 BURNER_ROLE
```

_The constant for the burner role (issuer)_

### totalSupply

```solidity
uint256 totalSupply
```

_The total supply of tokens_

### TokenType

```solidity
struct TokenType {
  uint8 category;
  enum IERC5484.BurnAuth burnAuth;
}
```

### MintBadge

```solidity
event MintBadge(uint8 category, address to, uint256 tokenId)
```

### CanNotTransfer

```solidity
error CanNotTransfer()
```

### CanNotBurn

```solidity
error CanNotBurn(address burner, enum IERC5484.BurnAuth burnAuth, uint256 tokenId)
```

### constructor

```solidity
constructor(address spaceFactory, address burner) public
```

### mintBadge

```solidity
function mintBadge(address to, uint8 category, enum IERC5484.BurnAuth _burnAuth) external
```

Mints a new badge

_For burn authorization, refer to IERC5484.sol
Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the badge to |
| category | uint8 | The category of the badge |
| _burnAuth | enum IERC5484.BurnAuth | The burn authorization for the badge |

### burn

```solidity
function burn(uint256 tokenId) external
```

Burns a badge

_Burner account(issuer), owner, or both can burn depending on the burn authorization._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token to burn |

### getCategory

```solidity
function getCategory(uint256 tokenId) external view returns (uint8)
```

_Returns the category of the token_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token |

### burnAuth

```solidity
function burnAuth(uint256 tokenId) external view returns (enum IERC5484.BurnAuth)
```

_Returns the burn authorization of the token_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

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

