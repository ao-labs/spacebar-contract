
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

SpaceFactoryV1Proxy : 0x6e96E6798Ca27f820418012ea994C49D210f30ef  
SpaceshipUniverse1 : 0x2E1d80F1F7b1c8956ccD81B790AF468B738044bf  
BadgeUniverse1: 0xBE5AA22B4382D335E6Ff569c33aBc2dF037431a9  

Deployed with the arguments below
```
TBA_REGISTRY_ADDRESS="0x02101dfB77FDE026414827Fdc604ddAF224F0921"
TBA_IMPLEMENTATION_ADDRESS="0x2d25602551487c3f3354dd80d76d54383a243358"

DEFAULT_ADMIN_ADDRESS="0x48715b9451C3FE79D176A86AE227714ce85a7072"
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"
MINTER_ADMIN_ADDRESS="0x48715b9451C3FE79D176A86AE227714ce85a7072"
MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY=1024
```

## Error Signatures

### SpaceFactoryV1
2d42c772: AddressAlreadyRegistered()  
55c9b514: InvalidProtoShip()  
6a9a57a5: NotWhiteListed()  
d48af246: OnlyNFTOwner()  
b06430b6: OnlyOneProtoShipAtATime()  

### SpaceshipUniverse1
de20ed63: OnlyLockedToken()  
794bb39b: ReachedMaxSupply()  
5a8181f7: TokenLocked()  

### BadgeUniverse1
a6c022e1: CanNotApprove()  
1b5722f5: CanNotTransfer()  
3f6cc768: InvalidTokenId()  
d59ec5f1: OnlySpaceFactory()  
