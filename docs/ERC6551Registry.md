# Solidity API

## ERC6551Registry

### InitializationFailed

```solidity
error InitializationFailed()
```

### createAccount

```solidity
function createAccount(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt, bytes initData) external returns (address)
```

### account

```solidity
function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt) external view returns (address)
```

