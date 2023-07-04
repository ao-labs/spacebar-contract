# Solidity API

## OnlyOneProtoShipAtATime

```solidity
error OnlyOneProtoShipAtATime()
```

## OnlyNFTOwner

```solidity
error OnlyNFTOwner()
```

## ReachedMaxSupply

```solidity
error ReachedMaxSupply()
```

## InvalidProtoShip

```solidity
error InvalidProtoShip()
```

## SpaceFactoryV1

This contract is responsible for minting, upgrading, and burning assets for the Spacebar project.
These assets currently include Spaceship NFTs from Universe1, but can be extended to support many more.
This is because the contract utilizes the ERC1967 proxy standard, enabling it to be
upgraded in the future to support additional features and asset types.

### SERVICE_ADMIN_ROLE

```solidity
bytes32 SERVICE_ADMIN_ROLE
```

_The constant for the service admin role_

### MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY

```solidity
uint16 MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY
```

_Circulalting supply of Spaceship NFT from Universe1 is fixed_

### currentSupply

```solidity
uint16 currentSupply
```

### tokenBoundImplementation

```solidity
contract IERC6551Account tokenBoundImplementation
```

### tokenBoundRegistry

```solidity
contract IERC6551Registry tokenBoundRegistry
```

### spaceshipNFTUniverse1

```solidity
contract ISpaceshipNFTUniverse1 spaceshipNFTUniverse1
```

### hasProtoShip

```solidity
mapping(address => bool) hasProtoShip
```

### SetSpaceshipNFTUniverse1

```solidity
event SetSpaceshipNFTUniverse1(address contractAddress)
```

### constructor

```solidity
constructor(address defaultAdmin, address serviceAdmin, uint16 maxSpaceshipUniverse1CirculatingSupply, contract IERC6551Registry _tokenBoundRegistry, contract IERC6551Account _tokenBoundImplementation) public
```

### deployTBAAndMintProtoShip

```solidity
function deployTBAAndMintProtoShip(address tokenContract, uint256 tokenId) external returns (address)
```

Deploys a new Token Bound Account (TBA) and mint a Proto-Ship to the address

_If the address already has TBA, it will use the existing TBA, and if the TBA
already has a Proto-Ship, it will revert(OnlyOneProtoShipAtATime)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | TBA's contract address |
| tokenId | uint256 | TBA's token ID |

### burnProtoShip

```solidity
function burnProtoShip(uint256 tokenId) external
```

Burns a Proto-Ship from the address when it fails to meet requirements.

_Only service admin can call this function. The function will revert if the token is not a Proto-Ship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Token id to burn. |

### upgradeToOwnerShip

```solidity
function upgradeToOwnerShip(uint256 tokenId) external
```

Upgrades Proto-Ship to Owner-Ship(aka. unlock).

_Only service admin can call this function. The function will revert if the token is not a Proto-Ship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Token id to upgrade |

### setSpaceshipNFTUniverse1

```solidity
function setSpaceshipNFTUniverse1(address contractAddress) external
```

### _deployOrGetTokenBoundAccount

```solidity
function _deployOrGetTokenBoundAccount(address tokenContract, uint256 tokenId) internal returns (address)
```

### _mintProtoShip

```solidity
function _mintProtoShip(address to) internal
```

### _burnProtoShip

```solidity
function _burnProtoShip(uint256 tokenId) internal
```

### _upgradeToOwnerShip

```solidity
function _upgradeToOwnerShip(uint256 tokenId) internal
```

