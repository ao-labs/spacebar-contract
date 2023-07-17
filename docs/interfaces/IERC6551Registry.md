# Solidity API

## IERC6551Registry

### AccountCreated

```solidity
event AccountCreated(address account, address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt)
```

### createAccount

```solidity
function createAccount(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 seed, bytes initData) external returns (address)
```

### account

```solidity
function account(address implementation, uint256 chainId, address tokenContract, uint256 tokenId, uint256 salt) external view returns (address)
```

