
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

SpaceFactory : 0x45AD23532eeaE2Cf8537b4F863F71Ed96a0A3F6c  
BadgeSBT : 0xe03C0f2B81E23C8142c7773B64E8E210a7F6c545  
BaseSpaceshipNFT : 0x7F37BC99aD18B3CAa7f8351aAf481B16BAF3dF2B  
PartsNFT : 0x369bc06A2D8ea34e02E1Bb7A5ACF1f10fCaB5272  
ScoreNFT : 0xb3EBb89cEAB9e2129b1690A87CD18ca60181EBA1  
SpaceshipNFT : 0xCba9C824293cEb822bc3385776FbF716764582e3  

Deployed with the arguments below
```
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
QUANTYTY_PER_PARTS_TYPE=["50","50","50","50","50"]
PARTS_MINTING_SUCCESS_RATE="10000"
```