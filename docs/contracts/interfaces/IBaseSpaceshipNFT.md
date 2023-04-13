# IBaseSpaceshipNFT



> Base spaceship NFT.

The owner of the tokens is space factory contract. Space factory will rent this NFT to users, and will burn base spaceship and parts to mint a new spaceship. User has to frequently extend the rent time to keep the spaceship. This logic is in SpaceFactory.sol.

*During construction, maximum amount of tokens are minted to the space factory contract.*

## Methods

### burn

```solidity
function burn(uint256 tokenId) external nonpayable
```

Burns a base spaceship NFT.

*Space factory contract can call this function.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | The id of the NFT |

### setUser

```solidity
function setUser(uint256 tokenId, address user, uint64 expires) external nonpayable
```

set the user and expires of a NFT

*The zero address indicates there is no user Throws if `tokenId` is not valid NFT*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| user | address | The new user of the NFT |
| expires | uint64 | UNIX timestamp, The new user could use the NFT before expires |

### userExpires

```solidity
function userExpires(uint256 tokenId) external view returns (uint256)
```

Get the user expires of an NFT

*The zero value indicates that there is no user*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | The NFT to get the user expires for |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The user expires for this NFT |

### userOf

```solidity
function userOf(uint256 tokenId) external view returns (address)
```

Get the user address of an NFT

*The zero address indicates that there is no user or the user is expired*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | The NFT to get the user address for |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | The user address for this NFT |



## Events

### UpdateUser

```solidity
event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires)
```

Emitted when the `user` of an NFT or the `expires` of the `user` is changed The zero address for user indicates that there is no user address



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId `indexed` | uint256 | undefined |
| user `indexed` | address | undefined |
| expires  | uint64 | undefined |


