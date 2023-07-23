# Solidity API

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

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

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

### isUniverse1Whitelisted

```solidity
bool isUniverse1Whitelisted
```

### universe1WhitelistBadgeType

```solidity
struct IBadgeUniverse1.TokenType universe1WhitelistBadgeType
```

### hasProtoship

```solidity
mapping(address => bool) hasProtoship
```

### MintProtoshipUniverse1

```solidity
event MintProtoshipUniverse1(address tokenContract, uint256 tokenId, uint256 spaceshipId)
```

### SetSpaceshipUniverse1

```solidity
event SetSpaceshipUniverse1(address contractAddress)
```

### SetBadgeUniverse1

```solidity
event SetBadgeUniverse1(address contractAddress)
```

### SetIsUniverse1Whitelisted

```solidity
event SetIsUniverse1Whitelisted(bool isUniverse1Whitelisted)
```

### SetUniverse1WhitelistBadgeType

```solidity
event SetUniverse1WhitelistBadgeType(struct IBadgeUniverse1.TokenType badgeType)
```

### initialize

```solidity
function initialize(address defaultAdmin, address serviceAdmin, address minterAdmin, contract IERC6551Registry _tokenBoundRegistry, contract IERC6551Account _tokenBoundImplementation, bool _isUniverse1Whitelisted, struct IBadgeUniverse1.TokenType _universe1WhitelistBadgeType) public
```

### setSpaceshipUniverse1

```solidity
function setSpaceshipUniverse1(address contractAddress) external
```

### setBadgeUniverse1

```solidity
function setBadgeUniverse1(address contractAddress) external
```

### setIsUniverse1Whitelisted

```solidity
function setIsUniverse1Whitelisted(bool _isUniverse1Whitelisted) external
```

### setUniverse1WhitelistBadgeType

```solidity
function setUniverse1WhitelistBadgeType(struct IBadgeUniverse1.TokenType _universe1WhitelistBadgeType) external
```

### transferDefaultAdmin

```solidity
function transferDefaultAdmin(address admin) external
```

### mintProtoshipUniverse1

```solidity
function mintProtoshipUniverse1(address tokenContract, uint256 tokenId) external virtual returns (address)
```

Deploys a new Token Bound Account (TBA) and mint a Protoship to the address

_If the address already has TBA, it will use the existing TBA, and if the TBA
already has a Protoship, it will revert(OnlyOneProtoshipAtATime)._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | TBA's contract address |
| tokenId | uint256 | TBA's token ID |

### mintWhitelistBadgeUniverse1

```solidity
function mintWhitelistBadgeUniverse1(address tokenContract, uint256 tokenId, string tokenURI) external virtual
```

### burnProtoshipUniverse1

```solidity
function burnProtoshipUniverse1(uint256 tokenId) external virtual
```

Burns a Protoship from the address when it fails to meet requirements.

_Only service admin can call this function. The function will revert if the token is not a Protoship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Token id to burn. |

### upgradeToOwnershipUniverse1

```solidity
function upgradeToOwnershipUniverse1(uint256 tokenId) external virtual
```

Upgrades Protoship to Ownership(aka. unlock).

_Only service admin can call this function. The function will revert if the token is not a Protoship._

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

### _mintProtoshipUniverse1

```solidity
function _mintProtoshipUniverse1(address to) internal virtual
```

### _burnProtoshipUniverse1

```solidity
function _burnProtoshipUniverse1(uint256 tokenId) internal virtual
```

### _upgradeToOwnershipUniverse1

```solidity
function _upgradeToOwnershipUniverse1(uint256 tokenId) internal virtual
```

