# Solidity API

## SpaceFactoryV1

This contract is responsible for the minting, upgrading, and burning of assets for the Spacebar project.
While currently supporting Spaceship NFTs from Universe1, it has the potential to support a wider variety of assets.
Thanks to its use of the ERC1967 proxy and UUPSUpgradeable, this contract can be upgraded in the future
to accommodate additional features and asset types.

### SERVICE_ADMIN_ROLE

```solidity
bytes32 SERVICE_ADMIN_ROLE
```

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

### SetTokenBoundImplementation

```solidity
event SetTokenBoundImplementation(address contractAddress)
```

### SetTokenBoundRegistry

```solidity
event SetTokenBoundRegistry(address contractAddress)
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

### setTokenBoundImplementation

```solidity
function setTokenBoundImplementation(contract IERC6551Account contractAddress) external virtual
```

### setTokenBoundRegistry

```solidity
function setTokenBoundRegistry(contract IERC6551Registry contractAddress) external virtual
```

### setSpaceshipUniverse1

```solidity
function setSpaceshipUniverse1(address contractAddress) external virtual
```

### setBadgeUniverse1

```solidity
function setBadgeUniverse1(address contractAddress) external virtual
```

### setIsUniverse1Whitelisted

```solidity
function setIsUniverse1Whitelisted(bool _isUniverse1Whitelisted) external virtual
```

### setUniverse1WhitelistBadgeType

```solidity
function setUniverse1WhitelistBadgeType(struct IBadgeUniverse1.TokenType _universe1WhitelistBadgeType) external virtual
```

### transferDefaultAdmin

```solidity
function transferDefaultAdmin(address admin) external virtual
```

### mintProtoshipUniverse1

```solidity
function mintProtoshipUniverse1(address tokenContract, uint256 tokenId) external virtual returns (address)
```

Mints a Protoship to the TBA address associated with the user's NFT and deploys the TBA of the spaceship.

_If the address already has a TBA, it will use the existing TBA. If the TBA already has a Protoship,
it will revert with the error 'OnlyOneProtoshipAtATime'._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | The contract address of the TBA. |
| tokenId | uint256 | The token ID of the TBA. |

### mintWhitelistBadgeUniverse1

```solidity
function mintWhitelistBadgeUniverse1(address tokenContract, uint256 tokenId, string tokenURI) public virtual
```

Mints a whitelist badge (SBT) to the TBA address associated with the user's NFT.
During the whitelist period, a user must own a specific type of badge to mint a Protoship.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContract | address | The contract address of the user's NFT. |
| tokenId | uint256 | The token ID of the user's NFT. |
| tokenURI | string | The token URI of the badge. |

### batchMintWhitelistBadgeUniverse1

```solidity
function batchMintWhitelistBadgeUniverse1(address[] tokenContracts, uint256[] tokenIds, string[] tokenURIs) external virtual
```

Batch mints whitelist badges (SBT).

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenContracts | address[] | The list of NFT contract addresses. |
| tokenIds | uint256[] | The list of token IDs. |
| tokenURIs | string[] | The list of token URIs. |

### burnProtoshipUniverse1

```solidity
function burnProtoshipUniverse1(uint256 tokenId) external virtual
```

Burns a Protoship from an address when it fails to meet the required conditions.

_Only a service admin can call this function. The function will revert if the specified token is not a Protoship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token to burn. |

### upgradeToOwnershipUniverse1

```solidity
function upgradeToOwnershipUniverse1(uint256 tokenId) external virtual
```

Upgrades a Protoship to Ownership status (unlock).

_Only a service admin can call this function. The function will revert if the specified token is not a Protoship._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | The ID of the token to upgrade. |

### getSpaceshipUniverse1TBA

```solidity
function getSpaceshipUniverse1TBA(uint256 tokenId) external view returns (address)
```

_Returns the TBA address of SpaceshipUniverse1_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | Spaceship token id |

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

