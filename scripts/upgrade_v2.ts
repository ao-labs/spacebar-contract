import { ethers, upgrades } from "hardhat"

const PROXY = "0x8603a2B3037BdB4f23CE6DBb01A652694E8627fa"

///@dev this is for testing only
async function main() {
	const SpaceFactoryV2 = await ethers.getContractFactory("SpaceFactoryV2")
	console.log("Upgrading to SpaceFactoryV2...")
	await upgrades.upgradeProxy(PROXY, SpaceFactoryV2)
	console.log("Upgrade done!")
}

main()
