
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

## How to test
### Install foundry  
https://book.getfoundry.sh/getting-started/installation
### Run test  
```
yarn test
```


## DEPLOYED ADDRESSES

### Goerli testnet

SpaceFactoryV1Proxy : 0x54f18e1C4105343792BF0829C8Fbf95a1c4607a6  
SpaceshipNFTUniverse1 : 0x13D583120E95CC8263EefF9E7F9623FEbc8a903a  

Deployed with the arguments below
```
TBA_REGISTRY_ADDRESS="0x02101dfB77FDE026414827Fdc604ddAF224F0921"
TBA_IMPLEMENTATION_ADDRESS="0x2d25602551487c3f3354dd80d76d54383a243358"

DEFAULT_ADMIN_ADDRESS="0x48715b9451C3FE79D176A86AE227714ce85a7072"
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY=1000
```

## Error Signatures

### SpaceFactoryV1
2089db36: AlreadyHaveSpaceshipNFTUniverse1()  
55c9b514: InvalidProtoShip()  
d48af246: OnlyNFTOwner()  
b06430b6: OnlyOneProtoShipAtATime()  

### SpaceshipNFTUniverse1
de20ed63: OnlyLockedToken()  
794bb39b: ReachedMaxSupply()  
5a8181f7: TokenLocked()  
