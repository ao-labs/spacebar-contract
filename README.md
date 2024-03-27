# 🌌 Spacebar

Welcome to Spacebar - Playground for Onchain Identities and Communities. 
For a detailed overview about our service, visit our [Gitbook](https://ao0-1.gitbook.io/spacebar-universe-1/).

## 🚀 Getting Started

### Prerequisites
- Make sure you have `yarn` installed on your machine.

### Installation
1. **Clone the repository**:
    ```bash
    git clone https://github.com/ao-labs/spacebar-contract
    ```

2. **Install the dependencies**:
    ```bash
    yarn
    ```

3. **Setup environment variables**:
   - Copy the environment example file:
     ```bash
     cp .env.example .env
     ```
   - Fill in the appropriate arguments in the `.env` file.

### Testing
1. **Install Foundry**:
   - Check out the installation guide [here](https://book.getfoundry.sh/getting-started/installation).

2. **Run tests**:
    ```bash
    yarn test
    ```

### Deployment
Deploying is a breeze! Just use the following command:
```bash
yarn deploy
```

## 🌐 Deployed Addresses

### Ethereum Mainnet

- **SpaceFactoryV1Proxy**: `0x11968381af76943b4B0F96f6BA7d1E42c1356c7E`
- **SpaceFactoryV1Implementation**: `0x7000457a51eccacf241ad9286903ac46498bd01d`
- **SpaceshipUniverse1**: `0xA2D34c2752Dd9843A9b45CD7D39909f00D839efe`
- **BadgeUniverse1**: `0xc06a40F25e7aF8C9576B3ef76Ac881A322Fd3dfE`

🔧 **Deployment arguments**:

```bash
TBA_REGISTRY_ADDRESS="0x02101dfB77FDE026414827Fdc604ddAF224F0921"
TBA_IMPLEMENTATION_ADDRESS="0x2d25602551487c3f3354dd80d76d54383a243358"
DEFAULT_ADMIN_ADDRESS="0x6459eB82943E71b5e4fAb4F8C32d7E92A3042524"
SERVICE_ADMIN_ADDRESS="0x1725F627391ba2bFd87b5d2DE58e1a794DAca853"
MINTER_ADMIN_ADDRESS="0xBAee3869D33075ff31cD46c3Af083733c12A7213"
ROYALTY_RECEIVER_ADDRESS="0x6459eB82943E71b5e4fAb4F8C32d7E92A3042524"
MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY=1024
```

## 🔍 Error Signatures

For developers looking to troubleshoot, here's a list of error signatures:
Here's the updated table with the new data:

| Signature  | Description                        |
|------------|------------------------------------|
| `2d42c772` | AddressAlreadyRegistered()         |
| `a6c022e1` | CanNotApprove()                    |
| `1b5722f5` | CanNotTransfer()                   |
| `bcbb81a3` | ExceedMaxContributionPerMint()     |
| `54254200` | ExceedMaxContributionPerUser()     |
| `0b788403` | ExceedMaxTotalContribution()       |
| `e6c4247b` | InvalidAddress()                   |
| `ad67865d` | InvalidListLength()                |
| `3d7555a9` | InvalidProtoship()                 |
| `8baa579f` | InvalidSignature()                 |
| `3f6cc768` | InvalidTokenId()                   |
| `13f04adb` | InvalidTokenURI()                  |
| `63a9c86c` | NotDuringRefundPeriod()            |
| `6a9a57a5` | NotWhiteListed()                   |
| `a6b4476c` | OnlyDuringRefundPeriod()           |
| `87800a11` | OnlyExistingToken()                |
| `de20ed63` | OnlyLockedToken()                  |
| `d48af246` | OnlyNFTOwner()                     |
| `4913ed38` | OnlyOneProtoshipAtATime()          |
| `d59ec5f1` | OnlySpaceFactory()                 |
| `ba378aba` | OnlySpaceFactoryOrOwner()          |
| `462c468b` | OnlySpaceshipOwner()               |
| `794bb39b` | ReachedMaxSupply()                 |
| `00a5a1f5` | TokenAlreadyMinted()               |
| `5a8181f7` | TokenLocked()                      |

## ERC-6551 Tokenbound Implementation 

We have incorporated an implementation of the ERC-6551 "tokenbound" standard in this repository.
The ERC-6551 implementation here is purely for testing and experimental purposes. It may not provide a complete or accurate representation of the ERC-6551 standard.
For a comprehensive and accurate representation of the ERC-6551 standard, please refer to the official [tokenbound contracts repository](https://github.com/tokenbound/contracts).

For more detailed information, refer to the [official documentation](https://docs.tokenbound.org/).
