# Solidity API

## TokenLocked

```solidity
error TokenLocked()
```

## OnlyLockedToken

```solidity
error OnlyLockedToken()
```

## SpaceshipNFTUniverse1

Spaceship NFT for Spacebar Universe 1
This contract introduces the concept of "Active Ownership", where the user must fulfill
certain conditions to gain full ownership of a spaceship NFT.
Until these conditions are met, the spaceship is locked and cannot be transferred.
Additionally, the Space Factory reserves the right to burn the spaceship under specific conditions (to be defined).
The total circulating supply (minted - burned) is limited, and this limit is maintained in the Space Factory contract.

### nextTokenId

```solidity
uint256 nextTokenId
```

### SPACE_FACTORY

```solidity
bytes32 SPACE_FACTORY
```

_constant for the space factory role_

### unlocked

```solidity
mapping(uint256 => bool) unlocked
```

### constructor

```solidity
constructor(address spaceFactory) public
```

### mint

```solidity
function mint(address to) external returns (uint256)
```

Mints a new Spaceship. Spaceships are locked by default (aka. Proto-Ship)

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the Proto-Ship to. This should be TBA's address as the Proto-Ship is initially bound to the TBA. |

### unlock

```solidity
function unlock(uint256 tokenId) external
```

Unlocks a Spaceship (aka. Proto-Ship becomes Owner-Ship)

_Only space factory contract can call this function, and from this point on,
user fully owns the Spaceship and can transfer it to other users._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | of the Spaceship to unlock. |

### burn

```solidity
function burn(uint256 tokenId) external
```

Burns a Spaceship

_Only space factory contract can call this function, and only Proto-Ship can be burned._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | of the Spaceship to burn. |

### updateMetadata

```solidity
function updateMetadata(uint256 tokenId) external
```

Called when metadata of a Spaceship is updated

_This function will only emit an event (ERC4906)_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | of the Spaceship to update metadata |

### approve

```solidity
function approve(address to, uint256 tokenId) public
```

_override approve to prevent locked tokens from being approved_

### _beforeTokenTransfer

```solidity
function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal virtual
```

_override approve to prevent locked tokens from being transferred to other addresses_

### _baseURI

```solidity
function _baseURI() internal pure returns (string)
```

_Base URI for computing {tokenURI}. If set, the resulting URI for each
token will be the concatenation of the `baseURI` and the `tokenId`. Empty
by default, can be overridden in child contracts._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

