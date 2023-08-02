
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

SpaceFactoryV1Proxy : 0x78f3db4826864F8035DEfA327da3790fF2EDa2e3  
SpaceshipUniverse1 : 0xEE887722f1D973C6800Bd63b4c234fB58c691d96  
BadgeUniverse1: 0x7e00bC28b1966B1150a50481e518139cE18f4112  

Deployed with the arguments below
```
TBA_REGISTRY_ADDRESS="0x02101dfB77FDE026414827Fdc604ddAF224F0921"
TBA_IMPLEMENTATION_ADDRESS="0x2d25602551487c3f3354dd80d76d54383a243358"

DEFAULT_ADMIN_ADDRESS="0x27c29364e5108ac9773aEDf4Aa6d3b9CC1a9E233"  
SERVICE_ADMIN_ADDRESS="0x9c800e9CD26B75E1538b7CD9668A127D07118A0C"  
MINTER_ADMIN_ADDRESS="0x7033a3527134bFd2Cbb22830eE2796f85E27Be0E"  
ROYALTY_RECEIVER_ADDRESS="0x27c29364e5108ac9773aEDf4Aa6d3b9CC1a9E233"  
MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY=1024  
```
* whitelisting is currently turned off

## Error Signatures

2d42c772: AddressAlreadyRegistered()  
a6c022e1: CanNotApprove()  
1b5722f5: CanNotTransfer()  
ad67865d: InvalidListLength()  
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
