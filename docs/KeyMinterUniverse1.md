# Solidity API

## KeyMinterUniverse1

_KeyMinterUniverse1 is a contract for minting Keys and collecting contributions._

### OPERATOR_ROLE

```solidity
bytes32 OPERATOR_ROLE
```

### KEY_MINT_PARAMS_TYPEHASH

```solidity
bytes32 KEY_MINT_PARAMS_TYPEHASH
```

### KEY_BATCH_MINT_PARAMS_TYPEHASH

```solidity
bytes32 KEY_BATCH_MINT_PARAMS_TYPEHASH
```

### serviceAdmin

```solidity
address serviceAdmin
```

### keyUniverse1

```solidity
contract KeyUniverse1 keyUniverse1
```

### spaceshipUniverse1

```solidity
contract ISpaceshipUniverse1 spaceshipUniverse1
```

### tokenBoundImplementation

```solidity
contract IERC6551Account tokenBoundImplementation
```

### tokenBoundRegistry

```solidity
contract IERC6551Registry tokenBoundRegistry
```

### maxContributionSchedulePerMint

```solidity
uint128[] maxContributionSchedulePerMint
```

### maxContributionPerUser

```solidity
uint128 maxContributionPerUser
```

### maxTotalContribution

```solidity
uint256 maxTotalContribution
```

### isRefundEnabled

```solidity
bool isRefundEnabled
```

### User

```solidity
struct User {
  uint128 contribution;
  uint128 mintCount;
}
```

### KeyMintParams

```solidity
struct KeyMintParams {
  address profileContractAddress;
  uint256 profileTokenId;
  uint256 spaceshipTokenId;
  uint256 keyTokenId;
  uint256 contribution;
}
```

### KeyBatchMintParams

```solidity
struct KeyBatchMintParams {
  address profileContractAddress;
  uint256 profileTokenId;
  uint256 spaceshipTokenId;
  uint256[] keyTokenIds;
  uint256 contribution;
}
```

### SetMaxContributionSchedulePerMint

```solidity
event SetMaxContributionSchedulePerMint(uint128[] maxContributionSchedulePerMint)
```

### SetMaxContributionPerUser

```solidity
event SetMaxContributionPerUser(uint128 maxContributionPerUser)
```

### SetMaxTotalContribution

```solidity
event SetMaxTotalContribution(uint256 maxTotalContribution)
```

### SetIsRefundEnabled

```solidity
event SetIsRefundEnabled(bool isRefundEnabled)
```

### SetServiceAdmin

```solidity
event SetServiceAdmin(address serviceAdmin)
```

### Refund

```solidity
event Refund(address user, uint256 amount)
```

### SetTokenBoundImplementation

```solidity
event SetTokenBoundImplementation(address contractAddress)
```

### SetTokenBoundRegistry

```solidity
event SetTokenBoundRegistry(address contractAddress)
```

### constructor

```solidity
constructor(address defaultAdmin, address operator, address _serviceAdmin, contract ISpaceshipUniverse1 _spaceshipUniverse1, contract IERC6551Registry _tokenBoundRegistry, contract IERC6551Account _tokenBoundImplementation) public
```

### setMaxContributionSchedulePerMint

```solidity
function setMaxContributionSchedulePerMint(uint128[] _maxContributionSchedulePerMint) external
```

### setMaxContributionPerUser

```solidity
function setMaxContributionPerUser(uint128 _maxContributionPerUser) external
```

### setMaxTotalContribution

```solidity
function setMaxTotalContribution(uint256 _maxTotalContribution) external
```

### setServiceAdmin

```solidity
function setServiceAdmin(address _serviceAdmin) external
```

### setIsRefundEnabled

```solidity
function setIsRefundEnabled(bool _isRefundEnabled) external
```

### setTokenBoundImplementation

```solidity
function setTokenBoundImplementation(contract IERC6551Account contractAddress) external virtual
```

### setTokenBoundRegistry

```solidity
function setTokenBoundRegistry(contract IERC6551Registry contractAddress) external virtual
```

### withdraw

```solidity
function withdraw(address to) external
```

### mintKey

```solidity
function mintKey(address profileContractAddress, uint256 profileTokenId, uint256 spaceshipTokenId, uint256 keyTokenId, bytes signature) external payable
```

### batchMintKey

```solidity
function batchMintKey(address profileContractAddress, uint256 profileTokenId, uint256 spaceshipTokenId, uint256[] keyTokenIds, bytes signature) external payable
```

### refund

```solidity
function refund() external
```

### getMaxContributionPerMint

```solidity
function getMaxContributionPerMint(uint256 currentMintCount) internal view returns (uint128)
```

### getMaxContributionPerBatchMint

```solidity
function getMaxContributionPerBatchMint(uint256 currentMintCount, uint256 amount) internal view returns (uint128)
```

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view virtual returns (bytes32)
```

### getUserContribution

```solidity
function getUserContribution(address user) external view returns (uint128)
```

### getUserMintCount

```solidity
function getUserMintCount(address user) external view returns (uint128)
```

### getSigner

```solidity
function getSigner(struct KeyMinterUniverse1.KeyMintParams keyMintParams, bytes signature) public view returns (address)
```

### getSigner

```solidity
function getSigner(struct KeyMinterUniverse1.KeyBatchMintParams keyBatchMintParams, bytes signature) public view returns (address)
```

