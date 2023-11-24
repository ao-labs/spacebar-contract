# Solidity API

## WhitelistBadgeClaimer

_This contract allows whitelisted accounts to claim a whitelist badge (SBT)
to the TBA address associated with the user's NFT.
Since the whitelist is managed by the server, server-side signature is required to claim the badge._

### spaceFactory

```solidity
contract ISpaceFactoryV1 spaceFactory
```

### serviceAdmin

```solidity
address serviceAdmin
```

### tokenURI

```solidity
string tokenURI
```

### maxNumberOfClaims

```solidity
uint256 maxNumberOfClaims
```

### numberOfClaims

```solidity
mapping(address => uint256) numberOfClaims
```

### CLAIMER_TYPEHASH

```solidity
bytes32 CLAIMER_TYPEHASH
```

### SetMaxNumberOfClaims

```solidity
event SetMaxNumberOfClaims(uint256 maxNumberOfClaims)
```

### SetTokenURI

```solidity
event SetTokenURI(string tokenURI)
```

### SetServiceAdmin

```solidity
event SetServiceAdmin(address serviceAdmin)
```

### constructor

```solidity
constructor(contract ISpaceFactoryV1 _spaceFactory, address _owner, address _serviceAdmin, string _tokenURI) public
```

### setMaxNumberOfClaims

```solidity
function setMaxNumberOfClaims(uint256 _maxNumberOfClaims) external
```

_Sets the maximum number of claims per account. Default is 1._

### setTokenURI

```solidity
function setTokenURI(string _tokenURI) external
```

_Sets the token URI of the badge to be minted._

### setServiceAdmin

```solidity
function setServiceAdmin(address _serviceAdmin) external
```

_Sets the service admin address._

### claimBadge

```solidity
function claimBadge(bytes signature, address tokenContract, uint256 tokenId) external
```

Claims a whitelist badge (SBT) to the TBA address associated with the user's NFT.
Server keeps the whiltelisted EOA addresses and makes a signature with EOA address
if that address is whitelisted.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| signature | bytes | The signature signed by the service admin. |
| tokenContract | address | The contract address of the user's NFT. |
| tokenId | uint256 | The token ID of the user's NFT. |

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view virtual returns (bytes32)
```

### getSigner

```solidity
function getSigner(address account, bytes signature) public view returns (address)
```

_Returns the signer of the signature_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | The claimer account |
| signature | bytes | Signature in bytes |

