
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

SpaceFactoryV1Proxy : 0x55b3B7ac58272bbA7Ac933f64c43d9C9d25934d6  
SpaceshipUniverse1 : 0xb0eF18c40576F30eA1fCfc339A940bA3FEa82945  
BadgeUniverse1: 0x21394A7e49df5cDdD47E58b9839443678C5f0dd8  

### Mumbai testnet

SpaceFactoryV1Proxy : 0xdBf57aE30C60694E780BaeACCa86F0b3Cf4055D6  
SpaceshipUniverse1 : 0x85d850294B26E87c00Ca10fCa522536a8186EB68  
BadgeUniverse1: 0x7d309760Bfe2C29563b1E4fEbBDaDbb6b18Dd88A  

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
55c9b514: InvalidProtoship()  
6a9a57a5: NotWhiteListed()  
d48af246: OnlyNFTOwner()  
b06430b6: OnlyOneProtoshipAtATime()  

### SpaceshipUniverse1
de20ed63: OnlyLockedToken()  
794bb39b: ReachedMaxSupply()  
5a8181f7: TokenLocked()  

### BadgeUniverse1
a6c022e1: CanNotApprove()  
1b5722f5: CanNotTransfer()  
3f6cc768: InvalidTokenId()  
d59ec5f1: OnlySpaceFactory()  
