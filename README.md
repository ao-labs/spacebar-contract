
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

SpaceFactory : 0x7e00bC28b1966B1150a50481e518139cE18f4112  
BadgeSBT : 0xE63b2Df39cFF9E39A9e7CBA8d27a5456048b1A0D  
BaseSpaceshipNFT : 0x65c6910D52534dEa4f98eD5F939D5976f1667Df6  
PartsNFT : 0x974C1C57304C2E8B0978785cc4309e82A2c828aB  
ScoreNFT : 0xc3f7f646B9e967fb7CFE1bc64683d0A68DD2e823  
SpaceshipNFT : 0x12135d973AB07c935C4d9D58c361f0dd280Fe6c3
Telescope : 0x297FF380901Ba9b12AE36B7a36513ce8046F2E5b

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
