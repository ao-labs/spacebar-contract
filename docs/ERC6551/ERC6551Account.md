# Solidity API

## OwnershipCycle

```solidity
error OwnershipCycle()
```

## ERC6551Account

### nonce

```solidity
uint256 nonce
```

### receive

```solidity
receive() external payable
```

### executeCall

```solidity
function executeCall(address to, uint256 value, bytes data) external payable returns (bytes result)
```

### token

```solidity
function token() external view returns (uint256, address, uint256)
```

### owner

```solidity
function owner() public view returns (address)
```

### isValidSignature

```solidity
function isValidSignature(bytes32 hash, bytes signature) external view returns (bytes4 magicValue)
```

_Should return whether the signature provided is valid for the provided data_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| hash | bytes32 | Hash of the data to be signed |
| signature | bytes | Signature byte array associated with _data |

### _authorizeUpgrade

```solidity
function _authorizeUpgrade(address newImplementation) internal virtual
```

_Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
{upgradeTo} and {upgradeToAndCall}.

Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.

```solidity
function _authorizeUpgrade(address) internal override onlyOwner {}
```_

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

_Returns true if a given interfaceId is supported by this account. This method can be
extended by an override._

### onERC721Received

```solidity
function onERC721Received(address, address, uint256 receivedTokenId, bytes) public view returns (bytes4)
```

_Allows ERC-721 tokens to be received so long as they do not cause an ownership cycle.
This function can be overriden._

### onERC1155Received

```solidity
function onERC1155Received(address, address, uint256, uint256, bytes) public view virtual returns (bytes4)
```

_Allows ERC-1155 tokens to be received. This function can be overriden._

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) public view virtual returns (bytes4)
```

_Allows ERC-1155 token batches to be received. This function can be overriden._

