# Solidity API

## SpaceFactory

This contract is responsible for minting and burning various NFTs and SBTs.
Functions with ByAdmin suffix are designed to be called by the admin(SIGNER), so that users
don't have to pay for gas fees.

### SIGNER_ROLE

```solidity
bytes32 SIGNER_ROLE
```

_The constant for the signer role_

### baseSpaceshipRentalFee

```solidity
uint256 baseSpaceshipRentalFee
```

### baseSpaceshipExtensionFee

```solidity
uint256 baseSpaceshipExtensionFee
```

### spaceshipNicknameUpdatingFee

```solidity
uint256 spaceshipNicknameUpdatingFee
```

### scoreMintingFee

```solidity
uint256 scoreMintingFee
```

### spaceshipUpdatingFee

```solidity
uint256 spaceshipUpdatingFee
```

### spaceshipMintingFee

```solidity
uint256 spaceshipMintingFee
```

### partsMintingFee

```solidity
uint256 partsMintingFee
```

### badgeMintingFee

```solidity
mapping(uint8 => uint256) badgeMintingFee
```

badge and special parts minting fees can vary depending on the type of badge or part

### specialPartsMintingFee

```solidity
mapping(uint256 => uint256) specialPartsMintingFee
```

### quantityPerPartsType

```solidity
uint24[] quantityPerPartsType
```

_How many parts of each type are available
for example, [100, 200, 300] means that there are 100 parts of type 1, 200 parts of type 2, and 300 parts of type 3_

### baseSpaceshipNFT

```solidity
contract IBaseSpaceshipNFT baseSpaceshipNFT
```

### spaceshipNFT

```solidity
contract ISpaceshipNFT spaceshipNFT
```

### partsNFT

```solidity
contract IPartsNFT partsNFT
```

### badgeSBT

```solidity
contract IBadgeSBT badgeSBT
```

### scoreNFT

```solidity
contract IScoreNFT scoreNFT
```

### airTokenContract

```solidity
contract IERC20 airTokenContract
```

### feeCollector

```solidity
address feeCollector
```

_Collected fee ($AIR) is immediately sent to this address_

### MAX_PART_TYPE

```solidity
uint8 MAX_PART_TYPE
```

### MAX_PART_QUANTITY

```solidity
uint24 MAX_PART_QUANTITY
```

### MAX_PARTS_MINTING_SUCCESS_RATE

```solidity
uint16 MAX_PARTS_MINTING_SUCCESS_RATE
```

### MIN_PART_ID

```solidity
uint24 MIN_PART_ID
```

### partsMintingSuccessRate

```solidity
uint16 partsMintingSuccessRate
```

### baseSpaceshipAccessPeriod

```solidity
uint64 baseSpaceshipAccessPeriod
```

### Signature

```solidity
struct Signature {
  bytes32 r;
  bytes32 s;
  uint8 v;
}
```

### SetBaseSpaceshipAccessPeriod

```solidity
event SetBaseSpaceshipAccessPeriod(uint256 period)
```

### SetBaseSpaceshipNFTAddress

```solidity
event SetBaseSpaceshipNFTAddress(contract IBaseSpaceshipNFT newAddress)
```

### SetSpaceshipNFTAddress

```solidity
event SetSpaceshipNFTAddress(contract ISpaceshipNFT newAddress)
```

### SetPartsNFTAddress

```solidity
event SetPartsNFTAddress(contract IPartsNFT newAddress)
```

### SetBadgeSBTAddress

```solidity
event SetBadgeSBTAddress(contract IBadgeSBT newAddress)
```

### SetScoreNFTAddress

```solidity
event SetScoreNFTAddress(contract IScoreNFT newAddress)
```

### SetAirTokenContractAddress

```solidity
event SetAirTokenContractAddress(contract IERC20 newAddress)
```

### SetFeeCollectorAddress

```solidity
event SetFeeCollectorAddress(address newAddress)
```

### SetPartsMintingSuccessRate

```solidity
event SetPartsMintingSuccessRate(uint16 rate)
```

### SetQuantityPerPartsType

```solidity
event SetQuantityPerPartsType(uint24[] quantityPerPartsType)
```

### SetBaseSpaceshipRentalFee

```solidity
event SetBaseSpaceshipRentalFee(uint256 fee)
```

### SetBaseSpaceshipExtensionFee

```solidity
event SetBaseSpaceshipExtensionFee(uint256 fee)
```

### SetPartsMintingFee

```solidity
event SetPartsMintingFee(uint256 fee)
```

### SetSpecialPartsMintingFee

```solidity
event SetSpecialPartsMintingFee(uint256 id, uint256 fee)
```

### SetSpaceshipMintingFee

```solidity
event SetSpaceshipMintingFee(uint256 fee)
```

### SetSpaceshipUpdatingFee

```solidity
event SetSpaceshipUpdatingFee(uint256 fee)
```

### SetSpaceshipNicknameUpdatingFee

```solidity
event SetSpaceshipNicknameUpdatingFee(uint256 fee)
```

### SetBadgeMintingFee

```solidity
event SetBadgeMintingFee(uint8 category, uint256 fee)
```

### SetScoreMintingFee

```solidity
event SetScoreMintingFee(uint256 fee)
```

### UnavailableBaseSpaceship

```solidity
error UnavailableBaseSpaceship(uint256 tokenId, address currentUser)
```

### AlreadyUserOfBaseSpaceship

```solidity
error AlreadyUserOfBaseSpaceship()
```

### NotWithinExtensionPeriod

```solidity
error NotWithinExtensionPeriod(uint256 tokenId, uint256 currentExpires)
```

### NotUserOfBaseSpaceship

```solidity
error NotUserOfBaseSpaceship(uint256 tokenId, address currentUser)
```

### InvalidSignature

```solidity
error InvalidSignature()
```

### InvalidListLength

```solidity
error InvalidListLength()
```

### InvalidTypeOrder

```solidity
error InvalidTypeOrder()
```

### ExceedsMaximumLength

```solidity
error ExceedsMaximumLength()
```

### ContractNotAvailable

```solidity
error ContractNotAvailable()
```

### InvalidAmount

```solidity
error InvalidAmount()
```

### InvalidAddress

```solidity
error InvalidAddress()
```

### NotTokenOnwer

```solidity
error NotTokenOnwer()
```

### InvalidRate

```solidity
error InvalidRate()
```

### InvalidId

```solidity
error InvalidId()
```

### InvalidPartsLength

```solidity
error InvalidPartsLength()
```

### collectFee

```solidity
modifier collectFee(address user, uint256 fee)
```

### addressCheck

```solidity
modifier addressCheck(address user)
```

### onlySpaceshipOwner

```solidity
modifier onlySpaceshipOwner(address user, uint256 tokenId)
```

### constructor

```solidity
constructor(address _signer, uint24[] _quantityPerPartsType, uint16 _partsMintingSuccessRate) public
```

### rentBaseSpaceship

```solidity
function rentBaseSpaceship(uint256 tokenId, struct SpaceFactory.Signature signature) external
```

rent a base spaceship. User has to extend the rental period before it expires.

_Rent expires at current time + baseSpaceshipAccessPeriod.
It reverts if the base spaceship is already rented by someone else, or the address already has one._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | base spaceship token id |
| signature | struct SpaceFactory.Signature | signature from the signer |

### rentBaseSpaceshipByAdmin

```solidity
function rentBaseSpaceshipByAdmin(uint256 tokenId, address user) external
```

admin function for renting a base spaceship

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | base spaceship token id |
| user | address | user address |

### extendBaseSpaceship

```solidity
function extendBaseSpaceship(uint256 tokenId, struct SpaceFactory.Signature signature) external
```

extend the rental period of a base spaceship

_It extends period by baseSpaceshipAccessPeriod._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | base spaceship token id |
| signature | struct SpaceFactory.Signature | signature from the signer |

### extendBaseSpaceshipByAdmin

```solidity
function extendBaseSpaceshipByAdmin(uint256 tokenId, address user) external
```

admin function for extending the rental period of a base spaceship

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | base spaceship token id |
| user | address | user address |

### mintRandomParts

```solidity
function mintRandomParts(uint256 amount, struct SpaceFactory.Signature signature) external returns (uint256[] ids)
```

minting random parts

_based on the quantityPerPartsType, it will randomly choose a token id and mint token to user.
Based on partsMintingSuccessRate (0-10000), it will mint successfully or not.
For example, if partsMintingSuccessRate is 5000 and amount is 10, you can expect 5 parts will be minted._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | amount of parts to mint |
| signature | struct SpaceFactory.Signature | signature from the signer |

### mintRandomPartsByAdmin

```solidity
function mintRandomPartsByAdmin(uint256 amount, address user) external returns (uint256[] ids)
```

Admin function for minting random parts

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | amount of parts to mint |
| user | address | user address |

### mintSpecialParts

```solidity
function mintSpecialParts(uint256 id, struct SpaceFactory.Signature signature) external
```

mint special parts

_specialPartsMintingFee must be set before minting_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | token id |
| signature | struct SpaceFactory.Signature | signature from the signer |

### mintSpecialPartsByAdmin

```solidity
function mintSpecialPartsByAdmin(uint256 id, address user) external
```

admin function for minting special parts

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| id | uint256 | token id |
| user | address | user to mint special parts to |

### mintNewSpaceship

```solidity
function mintNewSpaceship(uint256 baseSpaceshipTokenId, bytes32 nickname, uint24[] parts, struct SpaceFactory.Signature signature) external
```

minting new spaceship

_This will burn the base spaceship and parts, and mint a new spaceship to user.
User must be user of base spaceship, and must own all the parts._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseSpaceshipTokenId | uint256 | base spaceship token id |
| nickname | bytes32 | nickname of the new spaceship |
| parts | uint24[] | list of the parts to use |
| signature | struct SpaceFactory.Signature | signature from the signer |

### mintNewSpaceshipByAdmin

```solidity
function mintNewSpaceshipByAdmin(uint256 baseSpaceshipTokenId, bytes32 nickname, uint24[] parts, address user) external
```

admin function for minting new spaceship

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| baseSpaceshipTokenId | uint256 | base spaceship token id |
| nickname | bytes32 | nickname of the new spaceship |
| parts | uint24[] | list of the parts to use |
| user | address | user address to mint spaceship to |

### updateSpaceshipParts

```solidity
function updateSpaceshipParts(uint256 tokenId, uint24[] newParts, struct SpaceFactory.Signature signature) external
```

update spaceship parts

_User has to provide the full list of the parts. And this function will compare the current parts
with the new parts, and burn the parts that are not in the new list.
ex. current parts: [A, B, C, D, E], new parts: [A, B, C, F, G], than this function will burn F and G from user
It will revert if user doesn't own F and G._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | spaceship token id |
| newParts | uint24[] | list of the new parts |
| signature | struct SpaceFactory.Signature | signature from the signer |

### updateSpaceshipPartsByAdmin

```solidity
function updateSpaceshipPartsByAdmin(uint256 tokenId, uint24[] newParts, address user) external
```

admin function for updating spaceship parts

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | spaceship token id |
| newParts | uint24[] | list of the new parts |
| user | address | user who owns the spaceship |

### updateSpaceshipNickname

```solidity
function updateSpaceshipNickname(uint256 tokenId, bytes32 nickname, struct SpaceFactory.Signature signature) external
```

updates spaceship nickname

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | spaceship token id |
| nickname | bytes32 | new nickname |
| signature | struct SpaceFactory.Signature |  |

### updateSpaceshipNicknameByAdmin

```solidity
function updateSpaceshipNicknameByAdmin(uint256 tokenId, bytes32 nickname, address user) external
```

admin function for updating spaceship nickname

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenId | uint256 | spaceship token id |
| nickname | bytes32 | new nickname |
| user | address | user who owns the spaceship |

### mintScore

```solidity
function mintScore(uint8 category, uint88 score, struct SpaceFactory.Signature signature) external
```

mint score NFT to user

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | uint8 | category of the score (ex. 1: Single Player, 2: Multiplayer etc) |
| score | uint88 | user's score |
| signature | struct SpaceFactory.Signature |  |

### mintScoreByAdmin

```solidity
function mintScoreByAdmin(uint8 category, uint88 score, address user) external
```

admin function for minting score NFT to user

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | uint8 | category of the score (ex. 1: Single Player, 2: Multiplayer etc) |
| score | uint88 | user's score |
| user | address | user address to mint score NFT to |

### mintBadge

```solidity
function mintBadge(uint8 category, enum IERC5484.BurnAuth burnAuth, struct SpaceFactory.Signature signature) external
```

mint badge SBT to user

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | uint8 | category of the badge (ex. 1: Elite, 2: Creative etc) |
| burnAuth | enum IERC5484.BurnAuth | burn authorization of the badge. See IERC5484 |
| signature | struct SpaceFactory.Signature | signature from the signer |

### mintBadgeByAdmin

```solidity
function mintBadgeByAdmin(uint8 category, enum IERC5484.BurnAuth burnAuth, address user) external
```

admin function for minting badge SBT to user

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| category | uint8 | category of the badge (ex. 1: Elite, 2: Creative etc) |
| burnAuth | enum IERC5484.BurnAuth | burn authorization of the badge. See IERC5484 |
| user | address | user address to mint badge SBT to |

### setBaseSpaceshipAccessPeriod

```solidity
function setBaseSpaceshipAccessPeriod(uint64 _baseSpaceshipAccessPeriod) external
```

### setBaseSpaceshipNFTAddress

```solidity
function setBaseSpaceshipNFTAddress(contract IBaseSpaceshipNFT _baseSpaceshipNFT) external
```

### setSpaceshipNFTAddress

```solidity
function setSpaceshipNFTAddress(contract ISpaceshipNFT _spaceshipNFT) external
```

### setPartsNFTAddress

```solidity
function setPartsNFTAddress(contract IPartsNFT _partsNFT) external
```

### setBadgeSBTAddress

```solidity
function setBadgeSBTAddress(contract IBadgeSBT _badgeSBT) external
```

### setScoreNFTAddress

```solidity
function setScoreNFTAddress(contract IScoreNFT _scoreNFT) external
```

### setAirTokenAddress

```solidity
function setAirTokenAddress(contract IERC20 _airTokenContract) external
```

### setFeeCollectorAddress

```solidity
function setFeeCollectorAddress(address _feeCollector) external
```

### setQuantityPerPartsType

```solidity
function setQuantityPerPartsType(uint24[] _quantityPerPartsType) external
```

### setBaseSpaceshipRentalFee

```solidity
function setBaseSpaceshipRentalFee(uint256 _baseSpaceshipRentalFee) external
```

### setBaseSpaceshipExtensionFee

```solidity
function setBaseSpaceshipExtensionFee(uint256 _baseSpaceshipExtensionFee) external
```

### setPartsMintingFee

```solidity
function setPartsMintingFee(uint256 _partsMintingFee) external
```

### setSpecialPartsMintingFee

```solidity
function setSpecialPartsMintingFee(uint256 id, uint256 _partsMintingFee) external
```

### setSpaceshipMintingFee

```solidity
function setSpaceshipMintingFee(uint256 _spaceshipMintingFee) external
```

### setSpaceshipUpdatingFee

```solidity
function setSpaceshipUpdatingFee(uint256 _spaceshipUpdatingFee) external
```

### setSpaceshipNicknameUpdatingFee

```solidity
function setSpaceshipNicknameUpdatingFee(uint256 _spaceshipNicknameUpdatingFee) external
```

### setBadgeMintingFee

```solidity
function setBadgeMintingFee(uint8 category, uint256 _badgeMintingFee) external
```

### setScoreMintingFee

```solidity
function setScoreMintingFee(uint256 _scoreMintingFee) external
```

### setPartsMintingSuccessRate

```solidity
function setPartsMintingSuccessRate(uint16 _partsMintingSuccessRate) external
```

### _rentBaseSpaceship

```solidity
function _rentBaseSpaceship(uint256 tokenId, address user) internal
```

### _extendBaseSpaceshipAccess

```solidity
function _extendBaseSpaceshipAccess(uint256 tokenId, address user) internal
```

### _setQuantityPerPartsType

```solidity
function _setQuantityPerPartsType(uint24[] _quantityPerPartsType) internal
```

### _getRandomNumber

```solidity
function _getRandomNumber(uint256 max, uint256 randomNonce) internal view returns (uint256)
```

### _getRandomPartsId

```solidity
function _getRandomPartsId(uint256 randomNonce) internal view returns (uint24)
```

### _mintRandomParts

```solidity
function _mintRandomParts(address to, uint256 randomNonce) internal returns (uint256)
```

### _batchMintRandomParts

```solidity
function _batchMintRandomParts(address to, uint256 amount) internal returns (uint256[])
```

### _mintNewSpaceship

```solidity
function _mintNewSpaceship(address to, uint256 baseSpaceshipTokenId, bytes32 nickname, uint24[] parts) internal
```

### _updateSpaceshipParts

```solidity
function _updateSpaceshipParts(address owner, uint256 tokenId, uint24[] newParts) internal
```

### _checkSignature

```solidity
function _checkSignature(bytes32 digest, struct SpaceFactory.Signature signature) internal view
```

