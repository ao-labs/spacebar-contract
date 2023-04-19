# Solidity API

## IPartsNFT

ERC-1155 contract for spaceship parts. Parts are burned along with base spaceship to mint a new spaceship.
Parts can be also burned to update existing spaceship.

### mintParts

```solidity
function mintParts(address to, uint256 id) external
```

Mints a new part.

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The user address to mint the part to |
| id | uint256 | The id of the part (id contains the type and the design of the part) |

### batchMintParts

```solidity
function batchMintParts(address to, uint256[] ids, uint256[] amounts) external
```

Mints new parts.

_Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The user address to mint the parts to |
| ids | uint256[] | The ids of the parts (id contains the type and the design of the part) |
| amounts | uint256[] | The amounts of the parts |

### burnParts

```solidity
function burnParts(address from, uint256 id, uint256 amount) external
```

Burns a part.

_Only space factory contract can call this function to create or update a spaceship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The user address to burn the part from |
| id | uint256 | The id of the part |
| amount | uint256 | The amount of the part (should be 1) |

### batchBurnParts

```solidity
function batchBurnParts(address from, uint256[] ids, uint256[] amounts) external
```

Burns several parts at the same time.

_Only space factory contract can call this function to create or update a spaceship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | The user address to burn the parts from |
| ids | uint256[] | The ids of the parts |
| amounts | uint256[] | The amounts of the parts (should be an array of 1s) |

