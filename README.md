
## How to install
Install dependencies
```
yarn
```
Make `.env` file
```
cp .env.example .env
```
Fill in the arguments in the `.env` file. 

## How to deploy
```
yarn deploy
```

## DEPLOYED ADDRESSES

### Polygon - Mumbai testnet

SpaceFactory : 0x75d8282eEcfB89786bD2384a74CEED50D349dDAe  
BadgeSBT : 0x9b70137fe6f7ff8cbB148E26A75aA46d73E365bf  
BaseSpaceshipNFT : 0xb4Afd0Ecb77460f0d8F93E7Fba93D7c18491f7a3  
PartsNFT : 0x63b42ba12C9c61DD2381742744D7533114b68600  
ScoreNFT : 0x684a6b3F58cA41dAEA953aD77e08a65D450F0682  
SpaceshipNFT : 0x09f83d087B93CeE815A446D566fd7B0f4216eA4D  

Deployed with the arguments below
```
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
QUANTYTY_PER_PARTS_TYPE=["50","50","50","50","50"]
PARTS_MINTING_SUCCESS_RATE="10000"
```

## Error Signatures

### SpaceFactory
f5805b24: AlreadyUserOfBaseSpaceship()
f9e97157: ContractNotAvailable()
ef776216: ExceedsMaximumLength()
e6c4247b: InvalidAddress()
2c5211c6: InvalidAmount()
dfa1a408: InvalidId()
ad67865d: InvalidListLength()
b99ac7d3: InvalidPartsLength()
6a43f8d1: InvalidRate()
8baa579f: InvalidSignature()
314286d9: InvalidTypeOrder()
cb7eee8f: NotTokenOnwer()
0ed8054f: NotUserOfBaseSpaceship(uint256,address)
7e12c974: NotWithinExtensionPeriod(uint256,uint256)
635c0284: UnavailableBaseSpaceship(uint256,address)
