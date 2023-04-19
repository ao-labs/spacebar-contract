# Solidity API

## IScoreNFT

ERC-721 contract for recording user scores. Users can mint their scores as NFTs.

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

