# Solidity API

## BaseSpaceshipNFT

The owner of the tokens is space factory contract.
Space factory will rent this NFT to users, and will burn base spaceship and parts to mint a new spaceship.
User has to frequently extend the rent time to keep the spaceship. This logic is in SpaceFactory.sol.

_During construction, maximum amount of tokens are minted to the space factory contract._

### totalSupply

```solidity
uint256 totalSupply
```

_The current supply of tokens_

### MAXIMUM_SUPPLY

```solidity
uint16 MAXIMUM_SUPPLY
```

_The maximum supply of tokens. They are minted during construction._

### UserInfo

```solidity
struct UserInfo {
  address user;
  uint64 expires;
}
```

### constructor

```solidity
constructor(address spaceFactory) public
```

### setUser

```solidity
function setUser(uint256 tokenId, address user, uint64 expires) public virtual
```

set the user and expires of a NFT

_The zero address indicates there is no user
Throws if `tokenId` is not valid NFT_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 |  |
| user | address | The new user of the NFT |
| expires | uint64 | UNIX timestamp, The new user could use the NFT before expires |

### burn

```solidity
function burn(uint256 tokenId) external
```

Burns a base spaceship NFT.

_Space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the NFT |

### userOf

```solidity
function userOf(uint256 tokenId) public view virtual returns (address)
```

Get the user address of an NFT

_The zero address indicates that there is no user or the user is expired_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The NFT to get the user address for |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | The user address for this NFT |

### userExpires

```solidity
function userExpires(uint256 tokenId) public view virtual returns (uint256)
```

Get the user expires of an NFT

_The zero value indicates that there is no user_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The NFT to get the user expires for |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | The user expires for this NFT |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

_See {IERC165-supportsInterface}._

### _baseURI

```solidity
function _baseURI() internal pure returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual
```

