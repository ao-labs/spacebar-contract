# Solidity API

## ScoreNFT

ERC-721 contract for recording user scores. Users can mint their scores as NFTs.

### SPACE_FACTORY

```solidity
bytes32 SPACE_FACTORY
```

_The constant for the space factory role_

### totalSupply

```solidity
uint256 totalSupply
```

_The total number of score NFTs existing_

### Score

```solidity
struct Score {
  uint8 category;
  uint88 score;
  address player;
}
```

### MintScore

```solidity
event MintScore(uint8 category, uint88 score, address player, uint256 tokenId)
```

### constructor

```solidity
constructor(address spaceFactory) public
```

### mintScore

```solidity
function mintScore(address to, uint8 category, uint88 score) external
```

Mints a new score NFT

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the score NFT to. This is the user who played the game. |
| category | uint8 | The category of the score (ex. Singleplayer, Multiplayer, etc.) |
| score | uint88 | User's score |

### burn

```solidity
function burn(uint256 tokenId) public
```

Burns a score NFT

_Only the owner of the NFT can burn_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the NFT to burn |

### getScore

```solidity
function getScore(uint256 tokenId) public view returns (uint8 category, uint88 score, address player, address owner)
```

Gets the score of a score NFT

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the NFT to get the score of |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | uint8 | Category of the score (ex. Singleplayer, Multiplayer, etc.) |
| score | uint88 | User's score |
| player | address | The initial minter who played the game |
| owner | address | Current owner of the NFT |

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

