# Solidity API

## IBadgeSBT

_A soulbound token that can be burned by the issuer or the owner.
Token cannot be transferred and its burn authorization is determined by the issuer._

### mintBadge

```solidity
function mintBadge(address to, uint8 category, enum IERC5484.BurnAuth _burnAuth) external
```

Mints a new badge

_For burn authorization, refer to IERC5484.sol
Only space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address to mint the badge to |
| category | uint8 | The category of the badge |
| _burnAuth | enum IERC5484.BurnAuth | The burn authorization for the badge |

