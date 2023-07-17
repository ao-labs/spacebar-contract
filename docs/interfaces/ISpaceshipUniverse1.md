# Solidity API

## ISpaceshipUniverse1

Spaceship NFT for Spacebar Universe 1
This contract introduces the concept of "Active Ownership", where the user must fulfill
certain conditions to gain full ownership of a spaceship NFT.
Until these conditions are met, the spaceship is locked and cannot be transferred.
For above purpose, this contract implements ERC5192.
Additionally, the Space Factory reserves the right to burn the spaceship under specific conditions (to be defined).
The total circulating supply (minted - burned) is limited, and this limit is maintained in the Space Factory contract.

### mint

```solidity
function mint(address to) external returns (uint256 tokenId)
```

Mints a new Spaceship. Spaceships are locked by default (aka. Proto-Ship)

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the Proto-Ship to. This should be TBA's address as the Proto-Ship is initially bound to the TBA. |

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

### nextTokenId

```solidity
function nextTokenId() external returns (uint256)
```

_Returns the next token id to be minted_

