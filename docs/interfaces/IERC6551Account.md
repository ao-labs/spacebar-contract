# Solidity API

## IERC6551AccountProxy

### implementation

```solidity
function implementation() external view returns (address)
```

## IERC6551Account

_the ERC-165 identifier for this interface is `0xeff4d378`_

### TransactionExecuted

```solidity
event TransactionExecuted(address target, uint256 value, bytes data)
```

### receive

```solidity
receive() external payable
```

### executeCall

```solidity
function executeCall(address to, uint256 value, bytes data) external payable returns (bytes)
```

### token

```solidity
function token() external view returns (uint256 chainId, address tokenContract, uint256 tokenId)
```

### owner

```solidity
function owner() external view returns (address)
```

### nonce

```solidity
function nonce() external view returns (uint256)
```

