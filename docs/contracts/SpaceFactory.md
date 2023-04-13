# SpaceFactory



> Space Factory contract.

This contract is responsible for minting and burning various NFTs and SBTs. Functions with ByAdmin suffix are designed to be called by the admin(SIGNER), so that users don&#39;t have to pay for gas fees.



## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### SIGNER_ROLE

```solidity
function SIGNER_ROLE() external view returns (bytes32)
```



*The constant for the signer role*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### airTokenContract

```solidity
function airTokenContract() external view returns (contract IERC20)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IERC20 | undefined |

### badgeMintingFee

```solidity
function badgeMintingFee(uint8) external view returns (uint256)
```

badge and special parts minting fees can vary depending on the type of badge or part



#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### badgeSBT

```solidity
function badgeSBT() external view returns (contract IBadgeSBT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IBadgeSBT | undefined |

### baseSpaceshipAccessPeriod

```solidity
function baseSpaceshipAccessPeriod() external view returns (uint64)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint64 | undefined |

### baseSpaceshipExtensionFee

```solidity
function baseSpaceshipExtensionFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### baseSpaceshipNFT

```solidity
function baseSpaceshipNFT() external view returns (contract IBaseSpaceshipNFT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IBaseSpaceshipNFT | undefined |

### baseSpaceshipRentalFee

```solidity
function baseSpaceshipRentalFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### extendBaseSpaceship

```solidity
function extendBaseSpaceship(uint256 tokenId, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| signature | SpaceFactory.Signature | undefined |

### extendBaseSpaceshipByAdmin

```solidity
function extendBaseSpaceshipByAdmin(uint256 tokenId, address user) external nonpayable
```

admin function for extending the rental period of a base spaceship



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | base spaceship token id |
| user | address | user address |

### feeCollector

```solidity
function feeCollector() external view returns (address)
```



*Collected fee ($AIR) is immediately sent to this address*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getRoleAdmin

```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32)
```



*Returns the admin role that controls `role`. See {grantRole} and {revokeRole}. To change a role&#39;s admin, use {_setRoleAdmin}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### grantRole

```solidity
function grantRole(bytes32 role, address account) external nonpayable
```



*Grants `role` to `account`. If `account` had not been already granted `role`, emits a {RoleGranted} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleGranted} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```



*Returns `true` if `account` has been granted `role`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### mintBadge

```solidity
function mintBadge(uint8 category, enum IERC5484.BurnAuth burnAuth, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| category | uint8 | undefined |
| burnAuth | enum IERC5484.BurnAuth | undefined |
| signature | SpaceFactory.Signature | undefined |

### mintBadgeByAdmin

```solidity
function mintBadgeByAdmin(uint8 category, enum IERC5484.BurnAuth burnAuth, address user) external nonpayable
```

admin function for minting badge SBT to user



#### Parameters

| Name | Type | Description |
|---|---|---|
| category | uint8 | category of the badge (ex. 1: Elite, 2: Creative etc) |
| burnAuth | enum IERC5484.BurnAuth | burn authorization of the badge. See IERC5484 |
| user | address | user address to mint badge SBT to |

### mintNewSpaceship

```solidity
function mintNewSpaceship(uint256 baseSpaceshipTokenId, bytes32 nickname, uint24[] parts, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| baseSpaceshipTokenId | uint256 | undefined |
| nickname | bytes32 | undefined |
| parts | uint24[] | undefined |
| signature | SpaceFactory.Signature | undefined |

### mintNewSpaceshipByAdmin

```solidity
function mintNewSpaceshipByAdmin(uint256 baseSpaceshipTokenId, bytes32 nickname, uint24[] parts, address user) external nonpayable
```

admin function for minting new spaceship



#### Parameters

| Name | Type | Description |
|---|---|---|
| baseSpaceshipTokenId | uint256 | base spaceship token id |
| nickname | bytes32 | nickname of the new spaceship |
| parts | uint24[] | list of the parts to use |
| user | address | user address to mint spaceship to |

### mintRandomParts

```solidity
function mintRandomParts(uint256 amount, SpaceFactory.Signature signature) external nonpayable returns (uint256[] ids)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |
| signature | SpaceFactory.Signature | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| ids | uint256[] | undefined |

### mintRandomPartsByAdmin

```solidity
function mintRandomPartsByAdmin(uint256 amount, address user) external nonpayable returns (uint256[] ids)
```

Admin function for minting random parts



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | amount of parts to mint |
| user | address | user address |

#### Returns

| Name | Type | Description |
|---|---|---|
| ids | uint256[] | undefined |

### mintScore

```solidity
function mintScore(uint8 category, uint88 score, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| category | uint8 | undefined |
| score | uint88 | undefined |
| signature | SpaceFactory.Signature | undefined |

### mintScoreByAdmin

```solidity
function mintScoreByAdmin(uint8 category, uint88 score, address user) external nonpayable
```

admin function for minting score NFT to user



#### Parameters

| Name | Type | Description |
|---|---|---|
| category | uint8 | category of the score (ex. 1: Single Player, 2: Multiplayer etc) |
| score | uint88 | user&#39;s score |
| user | address | user address to mint score NFT to |

### mintSpecialParts

```solidity
function mintSpecialParts(uint256 id, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| signature | SpaceFactory.Signature | undefined |

### mintSpecialPartsByAdmin

```solidity
function mintSpecialPartsByAdmin(uint256 id, address user) external nonpayable
```

admin function for minting special parts



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | token id |
| user | address | user to mint special parts to |

### partsMintingFee

```solidity
function partsMintingFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### partsMintingSuccessRate

```solidity
function partsMintingSuccessRate() external view returns (uint16)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint16 | undefined |

### partsNFT

```solidity
function partsNFT() external view returns (contract IPartsNFT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IPartsNFT | undefined |

### quantityPerPartsType

```solidity
function quantityPerPartsType(uint256) external view returns (uint24)
```



*How many parts of each type are available for example, [100, 200, 300] means that there are 100 parts of type 1, 200 parts of type 2, and 300 parts of type 3*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

### renounceRole

```solidity
function renounceRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from the calling account. Roles are often managed via {grantRole} and {revokeRole}: this function&#39;s purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (such as when a trusted device is misplaced). If the calling account had been revoked `role`, emits a {RoleRevoked} event. Requirements: - the caller must be `account`. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### rentBaseSpaceship

```solidity
function rentBaseSpaceship(uint256 tokenId, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| signature | SpaceFactory.Signature | undefined |

### rentBaseSpaceshipByAdmin

```solidity
function rentBaseSpaceshipByAdmin(uint256 tokenId, address user) external nonpayable
```

admin function for renting a base spaceship



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | base spaceship token id |
| user | address | user address |

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from `account`. If `account` had been granted `role`, emits a {RoleRevoked} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### scoreMintingFee

```solidity
function scoreMintingFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### scoreNFT

```solidity
function scoreNFT() external view returns (contract IScoreNFT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IScoreNFT | undefined |

### setAirTokenAddress

```solidity
function setAirTokenAddress(contract IERC20 _airTokenContract) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _airTokenContract | contract IERC20 | undefined |

### setBadgeMintingFee

```solidity
function setBadgeMintingFee(uint8 category, uint256 _badgeMintingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| category | uint8 | undefined |
| _badgeMintingFee | uint256 | undefined |

### setBadgeSBTAddress

```solidity
function setBadgeSBTAddress(contract IBadgeSBT _badgeSBT) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _badgeSBT | contract IBadgeSBT | undefined |

### setBaseSpaceshipAccessPeriod

```solidity
function setBaseSpaceshipAccessPeriod(uint64 _baseSpaceshipAccessPeriod) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _baseSpaceshipAccessPeriod | uint64 | undefined |

### setBaseSpaceshipExtensionFee

```solidity
function setBaseSpaceshipExtensionFee(uint256 _baseSpaceshipExtensionFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _baseSpaceshipExtensionFee | uint256 | undefined |

### setBaseSpaceshipNFTAddress

```solidity
function setBaseSpaceshipNFTAddress(contract IBaseSpaceshipNFT _baseSpaceshipNFT) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _baseSpaceshipNFT | contract IBaseSpaceshipNFT | undefined |

### setBaseSpaceshipRentalFee

```solidity
function setBaseSpaceshipRentalFee(uint256 _baseSpaceshipRentalFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _baseSpaceshipRentalFee | uint256 | undefined |

### setFeeCollectorAddress

```solidity
function setFeeCollectorAddress(address _feeCollector) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _feeCollector | address | undefined |

### setPartsMintingFee

```solidity
function setPartsMintingFee(uint256 _partsMintingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _partsMintingFee | uint256 | undefined |

### setPartsMintingSuccessRate

```solidity
function setPartsMintingSuccessRate(uint16 _partsMintingSuccessRate) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _partsMintingSuccessRate | uint16 | undefined |

### setPartsNFTAddress

```solidity
function setPartsNFTAddress(contract IPartsNFT _partsNFT) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _partsNFT | contract IPartsNFT | undefined |

### setQuantityPerPartsType

```solidity
function setQuantityPerPartsType(uint24[] _quantityPerPartsType) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _quantityPerPartsType | uint24[] | undefined |

### setScoreMintingFee

```solidity
function setScoreMintingFee(uint256 _scoreMintingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _scoreMintingFee | uint256 | undefined |

### setScoreNFTAddress

```solidity
function setScoreNFTAddress(contract IScoreNFT _scoreNFT) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _scoreNFT | contract IScoreNFT | undefined |

### setSpaceshipMintingFee

```solidity
function setSpaceshipMintingFee(uint256 _spaceshipMintingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _spaceshipMintingFee | uint256 | undefined |

### setSpaceshipNFTAddress

```solidity
function setSpaceshipNFTAddress(contract ISpaceshipNFT _spaceshipNFT) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _spaceshipNFT | contract ISpaceshipNFT | undefined |

### setSpaceshipNicknameUpdatingFee

```solidity
function setSpaceshipNicknameUpdatingFee(uint256 _spaceshipNicknameUpdatingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _spaceshipNicknameUpdatingFee | uint256 | undefined |

### setSpaceshipUpdatingFee

```solidity
function setSpaceshipUpdatingFee(uint256 _spaceshipUpdatingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _spaceshipUpdatingFee | uint256 | undefined |

### setSpecialPartsMintingFee

```solidity
function setSpecialPartsMintingFee(uint256 id, uint256 _partsMintingFee) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| _partsMintingFee | uint256 | undefined |

### spaceshipMintingFee

```solidity
function spaceshipMintingFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### spaceshipNFT

```solidity
function spaceshipNFT() external view returns (contract ISpaceshipNFT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ISpaceshipNFT | undefined |

### spaceshipNicknameUpdatingFee

```solidity
function spaceshipNicknameUpdatingFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### spaceshipUpdatingFee

```solidity
function spaceshipUpdatingFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### specialPartsMintingFee

```solidity
function specialPartsMintingFee(uint256) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### updateSpaceshipNickname

```solidity
function updateSpaceshipNickname(uint256 tokenId, bytes32 nickname, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| nickname | bytes32 | undefined |
| signature | SpaceFactory.Signature | undefined |

### updateSpaceshipNicknameByAdmin

```solidity
function updateSpaceshipNicknameByAdmin(uint256 tokenId, bytes32 nickname, address user) external nonpayable
```

admin function for updating spaceship nickname



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | spaceship token id |
| nickname | bytes32 | new nickname |
| user | address | user who owns the spaceship |

### updateSpaceshipParts

```solidity
function updateSpaceshipParts(uint256 tokenId, uint24[] newParts, SpaceFactory.Signature signature) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| newParts | uint24[] | undefined |
| signature | SpaceFactory.Signature | undefined |

### updateSpaceshipPartsByAdmin

```solidity
function updateSpaceshipPartsByAdmin(uint256 tokenId, uint24[] newParts, address user) external nonpayable
```

admin function for updating spaceship parts



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | spaceship token id |
| newParts | uint24[] | list of the new parts |
| user | address | user who owns the spaceship |



## Events

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| previousAdminRole `indexed` | bytes32 | undefined |
| newAdminRole `indexed` | bytes32 | undefined |

### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |

### SetAirTokenContractAddress

```solidity
event SetAirTokenContractAddress(contract IERC20 indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract IERC20 | undefined |

### SetBadgeMintingFee

```solidity
event SetBadgeMintingFee(uint8 indexed category, uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| category `indexed` | uint8 | undefined |
| fee  | uint256 | undefined |

### SetBadgeSBTAddress

```solidity
event SetBadgeSBTAddress(contract IBadgeSBT indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract IBadgeSBT | undefined |

### SetBaseSpaceshipAccessPeriod

```solidity
event SetBaseSpaceshipAccessPeriod(uint256 period)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| period  | uint256 | undefined |

### SetBaseSpaceshipExtensionFee

```solidity
event SetBaseSpaceshipExtensionFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetBaseSpaceshipNFTAddress

```solidity
event SetBaseSpaceshipNFTAddress(contract IBaseSpaceshipNFT indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract IBaseSpaceshipNFT | undefined |

### SetBaseSpaceshipRentalFee

```solidity
event SetBaseSpaceshipRentalFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetFeeCollectorAddress

```solidity
event SetFeeCollectorAddress(address indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | address | undefined |

### SetPartsMintingFee

```solidity
event SetPartsMintingFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetPartsMintingSuccessRate

```solidity
event SetPartsMintingSuccessRate(uint16 rate)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| rate  | uint16 | undefined |

### SetPartsNFTAddress

```solidity
event SetPartsNFTAddress(contract IPartsNFT indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract IPartsNFT | undefined |

### SetQuantityPerPartsType

```solidity
event SetQuantityPerPartsType(uint24[] quantityPerPartsType)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| quantityPerPartsType  | uint24[] | undefined |

### SetScoreMintingFee

```solidity
event SetScoreMintingFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetScoreNFTAddress

```solidity
event SetScoreNFTAddress(contract IScoreNFT indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract IScoreNFT | undefined |

### SetSpaceshipMintingFee

```solidity
event SetSpaceshipMintingFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetSpaceshipNFTAddress

```solidity
event SetSpaceshipNFTAddress(contract ISpaceshipNFT indexed newAddress)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newAddress `indexed` | contract ISpaceshipNFT | undefined |

### SetSpaceshipNicknameUpdatingFee

```solidity
event SetSpaceshipNicknameUpdatingFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetSpaceshipUpdatingFee

```solidity
event SetSpaceshipUpdatingFee(uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| fee  | uint256 | undefined |

### SetSpecialPartsMintingFee

```solidity
event SetSpecialPartsMintingFee(uint256 indexed id, uint256 fee)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id `indexed` | uint256 | undefined |
| fee  | uint256 | undefined |



## Errors

### AlreadyUserOfBaseSpaceship

```solidity
error AlreadyUserOfBaseSpaceship()
```






### ContractNotAvailable

```solidity
error ContractNotAvailable()
```






### ExceedsMaximumLength

```solidity
error ExceedsMaximumLength()
```






### InvalidAddress

```solidity
error InvalidAddress()
```






### InvalidAmount

```solidity
error InvalidAmount()
```






### InvalidId

```solidity
error InvalidId()
```






### InvalidListLength

```solidity
error InvalidListLength()
```






### InvalidPartsLength

```solidity
error InvalidPartsLength()
```






### InvalidRate

```solidity
error InvalidRate()
```






### InvalidSignature

```solidity
error InvalidSignature()
```






### InvalidTypeOrder

```solidity
error InvalidTypeOrder()
```






### NotTokenOnwer

```solidity
error NotTokenOnwer()
```






### NotUserOfBaseSpaceship

```solidity
error NotUserOfBaseSpaceship(uint256 tokenId, address currentUser)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| currentUser | address | undefined |

### NotWithinExtensionPeriod

```solidity
error NotWithinExtensionPeriod(uint256 tokenId, uint256 currentExpires)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| currentExpires | uint256 | undefined |

### UnavailableBaseSpaceship

```solidity
error UnavailableBaseSpaceship(uint256 tokenId, address currentUser)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |
| currentUser | address | undefined |


