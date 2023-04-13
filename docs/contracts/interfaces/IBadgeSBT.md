# IBadgeSBT



> Badge soulbound token.



*A soulbound token that can be burned by the issuer or the owner. Token cannot be transferred and its burn authorization is determined by the issuer.*

## Methods

### burnAuth

```solidity
function burnAuth(uint256 tokenId) external view returns (enum IERC5484.BurnAuth)
```

provides burn authorization of the token id.

*unassigned tokenIds are invalid, and queries do throw*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | The identifier for a token. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | enum IERC5484.BurnAuth | undefined |

### mintBadge

```solidity
function mintBadge(address to, uint8 category, enum IERC5484.BurnAuth _burnAuth) external nonpayable
```

Mints a new badge

*For burn authorization, refer to IERC5484.sol Only space factory contract can call this function.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | The address to mint the badge to |
| category | uint8 | The category of the badge |
| _burnAuth | enum IERC5484.BurnAuth | The burn authorization for the badge |



## Events

### Issued

```solidity
event Issued(address indexed from, address indexed to, uint256 indexed tokenId, enum IERC5484.BurnAuth burnAuth)
```

Emitted when a soulbound token is issued.



#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| burnAuth  | enum IERC5484.BurnAuth | undefined |



