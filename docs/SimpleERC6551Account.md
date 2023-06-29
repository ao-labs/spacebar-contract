# Solidity API

## SimpleERC6551Account

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

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public pure returns (bool)
```

_Returns true if this contract implements the interface defined by
`interfaceId`. See the corresponding
https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
to learn more about how these ids are created.

This function call must use less than 30 000 gas._

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

