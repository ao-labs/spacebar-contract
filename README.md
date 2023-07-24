
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

SpaceFactoryV1Proxy : 0x6EE8397C6AB3553E1be05bE7dFCC372082Ec7413  
SpaceshipUniverse1 : 0x45AD23532eeaE2Cf8537b4F863F71Ed96a0A3F6c  
BadgeUniverse1: 0xe03C0f2B81E23C8142c7773B64E8E210a7F6c545  

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
ROYALTY_RECEIVER_ADDRESS="0x48715b9451C3FE79D176A86AE227714ce85a7072"
MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY=1024
```
* whitelisting is currently turned off

## Error Signatures

2d42c772: AddressAlreadyRegistered()  
a6c022e1: CanNotApprove()  
1b5722f5: CanNotTransfer()  
3d7555a9: InvalidProtoship()  
3f6cc768: InvalidTokenId()  
13f04adb: InvalidTokenURI()  
6a9a57a5: NotWhiteListed()  
de20ed63: OnlyLockedToken()  
d48af246: OnlyNFTOwner()  
4913ed38: OnlyOneProtoshipAtATime()  
d59ec5f1: OnlySpaceFactory()  
ba378aba: OnlySpaceFactoryOrOwner()  
794bb39b: ReachedMaxSupply()  
5a8181f7: TokenLocked()  
