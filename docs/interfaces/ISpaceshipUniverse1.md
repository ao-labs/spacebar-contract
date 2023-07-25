# Solidity API

## ISpaceshipUniverse1

Spaceship NFT for Spacebar Universe 1
This contract introduces the concept of "Active Ownership", wherein the user must fulfill
certain conditions to gain full ownership of a spaceship NFT.
Until these conditions are met, the spaceship is locked and cannot be transferred.
For the above purpose, this contract implements ERC5192.
Additionally, the Space Factory reserves the right to burn the spaceship under specific conditions (to be defined later).
The total circulating supply (minted minus burned) is limited.

### mint

```solidity
function mint(address to) external returns (uint256 tokenId)
```

Mints a new Spaceship. Spaceships are locked by default (also known as Protoships).

_Only the space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to which the Protoship will be minted. This should be TBA's address, as the Protoship is initially bound to the TBA. |

### burn

```solidity
function burn(uint256 tokenId) external
```

Burns a Spaceship.

_Only the space factory contract can call this function, and only a Protoship can be burned._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the Spaceship to burn. |

### unlock

```solidity
function unlock(uint256 tokenId) external
```

Unlocks a Spaceship (i.e., a Protoship becomes Ownership).

_Only the space factory contract can call this function. From this point on,
the user fully owns the Spaceship and can transfer it to other users._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the Spaceship to unlock. |

### updateMetadata

```solidity
function updateMetadata(uint256 tokenId) external
```

Called when the metadata of a Spaceship is updated.

_This function will only emit an event (ERC4906)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the Spaceship for which to update metadata. |

### nextTokenId

```solidity
function nextTokenId() external returns (uint256)
```

_Returns the ID of the next token to be minted._

