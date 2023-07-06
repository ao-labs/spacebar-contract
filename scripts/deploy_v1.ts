import { ethers, upgrades } from "hardhat"
import { SpaceFactoryV1, SpaceshipNFTUniverse1 } from "../typechain-types"

async function main() {
	const [deployer] = await ethers.getSigners()

	console.log("Deploying SpaceFactoryV1...")
	const SpaceFactoryV1 = await ethers.getContractFactory("SpaceFactoryV1")

	const spaceFactoryV1 = (await upgrades.deployProxy(
		SpaceFactoryV1,
		[
			deployer.address,
			deployer.address,
			process.env.TBA_REGISTRY_ADDRESS,
			process.env.TBA_IMPLEMENTATION_ADDRESS,
		],
		{
			initializer: "initialize",
		}
	)) as SpaceFactoryV1

	await spaceFactoryV1.deployed()

	console.log("SpaceFactoryV1 is deployed to:", spaceFactoryV1.address)

	console.log("Deploying SpaceshipNFTUniverse1...")
	const SpaceshipNFTUniverse1 = await ethers.getContractFactory(
		"SpaceshipNFTUniverse1"
	)

	const spaceshipNFTUniverse1 = (await SpaceshipNFTUniverse1.deploy(
		spaceFactoryV1.address,
		process.env.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY
	)) as SpaceshipNFTUniverse1

	await spaceshipNFTUniverse1.deployed()

	console.log(
		"SpaceshipNFTUniverse1 is deployed to:",
		spaceshipNFTUniverse1.address
	)

	console.log("Setting SpaceshipNFTUniverse1 address to SpaceFactoryV1...")

	spaceFactoryV1.setSpaceshipNFTUniverse1(spaceshipNFTUniverse1.address)

	console.log("Done!")
}

main()
