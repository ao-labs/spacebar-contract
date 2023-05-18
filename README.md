
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

SpaceFactory : 0x83Ca27538603F92f4439C69D98723Ec9c63eb73f  
BadgeSBT : 0x0e3f85151aC859D28D613f3a04fC5c1b7dA5B15c  
BaseSpaceshipNFT : 0xd176d4D3066B0bEab62f605BB6ec688BbDD5677d  
PartsNFT : 0x9862EdB09b04A97302F7986260e3AeF86D9c5b19  
ScoreNFT : 0xa6B69311d8d57e85834290543566e1151EA3a0b7  
SpaceshipNFT : 0xb2c3768A040DBD7E2471c9c2873c09c7D5a9D2c8  

Deployed with the arguments below
```
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
QUANTYTY_PER_PARTS_TYPE=["50","50","50","50","50"]
PARTS_MINTING_SUCCESS_RATE="10000"
```