
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

SpaceFactory : 0xc9D4cEC2A22Da38b5d0ED8FC7edB3Ef35E59d942  
BadgeSBT : 0x1A0Ca7835D66b501E33a62C20035d15a1DC58997  
BaseSpaceshipNFT : 0xe3320c44ac0A7BC4904C50a862b3cC4F5c0b642c  
PartsNFT : 0xCC7aBd809ac9f9f020C7F138131655423a151Db8  
ScoreNFT : 0x7fC4dE25c43D7f3dEeEDc7002dA380963fcA1c94  
SpaceshipNFT : 0x78f3db4826864F8035DEfA327da3790fF2EDa2e3
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
