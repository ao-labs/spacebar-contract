# Solidity API

## KeyUniverse1

_Keys are non-transferable semi-fungible tokens._

### OPERATOR_ROLE

```solidity
bytes32 OPERATOR_ROLE
```

### MINTER_ROLE

```solidity
bytes32 MINTER_ROLE
```

### constructor

```solidity
constructor(address defaultAdmin, address operator, address minter) public
```

### mint

```solidity
function mint(address to, uint256 tokenId) public
```

### mintBatch

```solidity
function mintBatch(address to, uint256[] ids) public
```

### setURIs

```solidity
function setURIs(uint256[] tokenIds, string[] tokenURIs) public
```

### setApprovalForAll

```solidity
function setApprovalForAll(address, bool) public virtual
```

_This function is not implemented._

### safeTransferFrom

```solidity
function safeTransferFrom(address, address, uint256, uint256, bytes) public virtual
```

_This function is not implemented._

### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address, address, uint256[], uint256[], bytes) public virtual
```

_This function is not implemented._

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view returns (bool)
```

