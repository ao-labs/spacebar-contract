# Solidity API

## SpaceshipNFT

ERC-721 contract for spaceship NFTs. Spaceships are minted by burning parts and a base spaceship.

### SPACE_FACTORY

```solidity
bytes32 SPACE_FACTORY
```

_The constant for the space factory role_

### totalSupply

```solidity
uint256 totalSupply
```

_The total supply of tokens_

### Traits

```solidity
struct Traits {
  bytes32 nickname;
  uint24[] parts;
}
```

### MintSpaceship

```solidity
event MintSpaceship(address to, uint256 id, uint24[] parts, bytes32 nickname)
```

### UpdateSpaceship

```solidity
event UpdateSpaceship(uint256 id, uint24[] parts, bytes32 nickname)
```

_Emitted when spaceship parts are updated.
If parts is a zero array, nickname is updated. If nickname is empty, parts are updated._

### InvalidParts

```solidity
error InvalidParts()
```

### onlyValidPartsList

```solidity
modifier onlyValidPartsList(uint24[] parts)
```

### constructor

```solidity
constructor(address spaceFactory) public
```

### mintSpaceship

```solidity
function mintSpaceship(address to, bytes32 nickname, uint24[] parts) external
```

Mints a new spaceship

_Only space factory contract can call this function. The factory will burn
spaceship parts and a base spaceship to mint a new spaceship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | Address to mint the spaceship to |
| nickname | bytes32 | Nickname of the spaceship |
| parts | uint24[] | Parts that are burned during creation |

### updateSpaceshipParts

```solidity
function updateSpaceshipParts(uint256 tokenId, uint24[] parts) external
```

Updates spaceship parts

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Id of the spaceship to update |
| parts | uint24[] | Parts to update |

### updateSpaceshipNickname

```solidity
function updateSpaceshipNickname(uint256 tokenId, bytes32 nickname) external
```

Updates spaceship nickname

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Id of the spaceship to update |
| nickname | bytes32 | Nickname to update |

### burn

```solidity
function burn(uint256 tokenId) external
```

_Burn a spaceship NFT. only owner can burn_

### getParts

```solidity
function getParts(uint256 tokenId) external view returns (uint24[])
```

Gets the list of the parts of a spaceship

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Id of the spaceship to get the parts of |

### getNickname

```solidity
function getNickname(uint256 tokenId) external view returns (bytes32)
```

Gets nickname of a spaceship

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Id of the spaceship to get the nickname of |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

### _baseURI

```solidity
function _baseURI() internal pure returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

