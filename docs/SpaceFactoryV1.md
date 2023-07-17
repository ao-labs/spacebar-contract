# Solidity API

## OnlyOneProtoShipAtATime

```solidity
error OnlyOneProtoShipAtATime()
```

## OnlyNFTOwner

```solidity
error OnlyNFTOwner()
```

## InvalidProtoShip

```solidity
error InvalidProtoShip()
```

## AddressAlreadyRegistered

```solidity
error AddressAlreadyRegistered()
```

## SpaceFactoryV1

This contract is responsible for minting, upgrading, and burning assets for the Spacebar project.
These assets currently include Spaceship NFTs from Universe1, but can be extended to support many more.
This is because the contract utilizes the ERC1967 proxy + UUPSUpgradeable, enabling it to be
upgraded in the future to support additional features and asset types.

### SERVICE_ADMIN_ROLE

```solidity
bytes32 SERVICE_ADMIN_ROLE
```

_The constant for the service admin role_

### tokenBoundImplementation

```solidity
contract IERC6551Account tokenBoundImplementation
```

### tokenBoundRegistry

```solidity
contract IERC6551Registry tokenBoundRegistry
```

### spaceshipUniverse1

```solidity
contract ISpaceshipUniverse1 spaceshipUniverse1
```

### badgeUniverse1

```solidity
contract IBadgeUniverse1 badgeUniverse1
```

### universe1WhitelistingPeriod

```solidity
bool universe1WhitelistingPeriod
```

### hasProtoShip

```solidity
mapping(address => bool) hasProtoShip
```

### MintProtoShipUniverse1

```solidity
event MintProtoShipUniverse1(address tokenContract, uint256 tokenId, uint256 spaceshipId)
```

### SetSpaceshipUniverse1

```solidity
event SetSpaceshipUniverse1(address contractAddress)
```

### SetBadgeUniverse1

```solidity
event SetBadgeUniverse1(address contractAddress)
```

### SetUniverse1WhiteListingPeriod

```solidity
event SetUniverse1WhiteListingPeriod(bool isWhiteListingPeriod)
```

### initialize

```solidity
function initialize(address defaultAdmin, address serviceAdmin, contract IERC6551Registry _tokenBoundRegistry, contract IERC6551Account _tokenBoundImplementation) public
```

### setSpaceshipUniverse1

```solidity
function setSpaceshipUniverse1(address contractAddress) external
```

_spaceshipUniverse1 address should only be set once and never change_

### setBadgeUniverse1

```solidity
function setBadgeUniverse1(address contractAddress) external
```

_badgeUniverse1 address should only be set once and never change_

### mintProtoShipUniverse1

```solidity
function mintProtoShipUniverse1(address tokenContract, uint256 tokenId) external virtual returns (address)
```

Deploys a new Token Bound Account (TBA) and mint a Proto-Ship to the address

_If the address already has TBA, it will use the existing TBA, and if the TBA
already has a Proto-Ship, it will revert(OnlyOneProtoShipAtATime)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | TBA's contract address |
| tokenId | uint256 | TBA's token ID |

### burnProtoShipUniverse1

```solidity
function burnProtoShipUniverse1(uint256 tokenId) external virtual
```

Burns a Proto-Ship from the address when it fails to meet requirements.

_Only service admin can call this function. The function will revert if the token is not a Proto-Ship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Token id to burn. |

### upgradeToOwnerShipUniverse1

```solidity
function upgradeToOwnerShipUniverse1(uint256 tokenId) external virtual
```

Upgrades Proto-Ship to Owner-Ship(aka. unlock).

_Only service admin can call this function. The function will revert if the token is not a Proto-Ship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Token id to upgrade |

### getSpaceshipUniverse1TBA

```solidity
function getSpaceshipUniverse1TBA(uint256 tokenId) external view returns (address)
```

_Returns the TBA address of SpaceshipUniverse1_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | ID of the token |

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address) internal
```

### _deployOrGetTokenBoundAccount

```solidity
function _deployOrGetTokenBoundAccount(address tokenContract, uint256 tokenId) internal virtual returns (address)
```

### _mintProtoShipUniverse1

```solidity
function _mintProtoShipUniverse1(address to) internal virtual
```

### _burnProtoShipUniverse1

```solidity
function _burnProtoShipUniverse1(uint256 tokenId) internal virtual
```

### _upgradeToOwnerShipUniverse1

```solidity
function _upgradeToOwnerShipUniverse1(uint256 tokenId) internal virtual
```

