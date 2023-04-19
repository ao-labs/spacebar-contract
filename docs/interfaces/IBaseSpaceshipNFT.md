# Solidity API

## IBaseSpaceshipNFT

The owner of the tokens is space factory contract.
Space factory will rent this NFT to users, and will burn base spaceship and parts to mint a new spaceship.
User has to frequently extend the rent time to keep the spaceship. This logic is in SpaceFactory.sol.

_During construction, maximum amount of tokens are minted to the space factory contract._

### burn

```solidity
function burn(uint256 tokenId) external
```

Burns a base spaceship NFT.

_Space factory contract can call this function._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The id of the NFT |

