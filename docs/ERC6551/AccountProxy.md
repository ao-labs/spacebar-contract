# Solidity API

## AccountProxy

### defaultImplementation

```solidity
address defaultImplementation
```

### constructor

```solidity
constructor(address _defaultImplementation) public
```

### initialize

```solidity
function initialize() external
```

### _implementation

```solidity
function _implementation() internal view returns (address)
```

_This is a virtual function that should be overridden so it returns the address to which the fallback function
and {_fallback} should delegate._

