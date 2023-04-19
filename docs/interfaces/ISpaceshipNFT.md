# Solidity API

## ISpaceshipNFT

ERC-721 contract for spaceship NFTs. Spaceships are minted by burning parts and a base spaceship.

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

