
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

SpaceFactory : 0x0Ab816a12Ab461d8c6043dC887607a4E56367eDf  
BadgeSBT : 0xDDB4CF8aF5ECc9502bfbe5866315231dD31274b8  
BaseSpaceshipNFT : 0x89caf8EB8ab6dB68ef834e1975EFc62eE2AB199E  
PartsNFT : 0xbC48710e7906f7c2B60c85256040932bEA112a68  
ScoreNFT : 0x7bE5264e572c4E2c76d52Dda841e15AcC1613e51  
SpaceshipNFT : 0x29801AA4FF262BB430e5551047d3c89ab82f1414  

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
