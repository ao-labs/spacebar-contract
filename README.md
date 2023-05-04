
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

SpaceFactory : 0x9C9ed8a0A1A3459d7BdE4930A06C6a0468ACC01d  
BadgeSBT : 0xa45F7Bc0d4BED515B5359760e6c0fBf005aa8E0C  
BaseSpaceshipNFT : 0xa4c5dac9c2ca621f4Dde51E11591ddE675A0f182  
PartsNFT : 0xDE0a401E76C63C32480Fdb308B96E11814a59937  
ScoreNFT : 0x2461d96acF9Ee94c9Ac6f455470b54D0D604E109  
SpaceshipNFT : 0x0A4b7030eAfECc3800732a422EEF978597CF9a8E  

Deployed with the arguments below
```
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
QUANTYTY_PER_PARTS_TYPE=["50","50","50","50","50"]
PARTS_MINTING_SUCCESS_RATE="10000"
```