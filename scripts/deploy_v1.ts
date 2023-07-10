import { ethers, upgrades } from "hardhat"
import {
	SpaceFactoryV1,
	SpaceshipNFTUniverse1,
	BadgeSBTUniverse1,
} from "../typechain-types"

async function main() {
	/// @dev Deploying SpaceFactoryV1
	console.log("Deploying SpaceFactoryV1...")
	const SpaceFactoryV1 = await ethers.getContractFactory("SpaceFactoryV1")

	const spaceFactoryV1 = (await upgrades.deployProxy(
		SpaceFactoryV1,
		[
			process.env.DEFAULT_ADMIN_ADDRESS,
			process.env.SERVICE_ADMIN_ADDRESS,
			process.env.TBA_REGISTRY_ADDRESS,
			process.env.TBA_IMPLEMENTATION_ADDRESS,
		],
		{
			initializer: "initialize",
		}
	)) as SpaceFactoryV1

	await spaceFactoryV1.deployed()
	console.log("SpaceFactoryV1 is deployed to:", spaceFactoryV1.address)

	/// @dev Verify SpaceFactoryV1
	console.log("Verifying SpaceFactory implementation on etherscan...")
	const WAIT_BLOCK_CONFIRMATIONS = 5
	const implementationAddress =
		await upgrades.erc1967.getImplementationAddress(spaceFactoryV1.address)
	await spaceFactoryV1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)
	// @ts-ignore
	await run(`verify:verify`, {
		address: implementationAddress,
	})

	/// @dev Deploying SpaceshipNFTUniverse1
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

	/// @dev Verify SpaceshipNFTUniverse1
	console.log("Verifying SpaceshipNFTUniverse1 on etherscan...")

	await spaceshipNFTUniverse1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)
	// @ts-ignore
	await run(`verify:verify`, {
		address: spaceshipNFTUniverse1.address,
		constructorArguments: [
			spaceFactoryV1.address,
			process.env.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY,
		],
	})

	/// @dev Deploying BadgeSBTUniverse1
	console.log("Deploying BadgeSBTUniverse1...")
	const BadgeSBTUniverse1 = await ethers.getContractFactory(
		"BadgeSBTUniverse1"
	)

	const badgeSBTUniverse1 = (await BadgeSBTUniverse1.deploy(
		spaceFactoryV1.address
	)) as BadgeSBTUniverse1

	await badgeSBTUniverse1.deployed()
	console.log("BadgeSBTUniverse1 is deployed to:", badgeSBTUniverse1.address)

	/// @dev Verify BadgeSBTUniverse1
	console.log("Verifying BadgeSBTUniverse1 on etherscan...")

	await badgeSBTUniverse1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)
	// @ts-ignore
	await run(`verify:verify`, {
		address: badgeSBTUniverse1.address,
		constructorArguments: [spaceFactoryV1.address],
	})

	/// @dev set SpaceshipNFTUniverse1 address to SpaceFactoryV1
	console.log("Setting SpaceshipNFTUniverse1 address to SpaceFactoryV1...")

	await spaceFactoryV1.setSpaceshipNFTUniverse1(spaceshipNFTUniverse1.address)

	/// @dev set BadgeSBTUniverse1 address to SpaceFactoryV1
	console.log("Setting BadgeSBTUniverse1 address to SpaceFactoryV1...")

	await spaceFactoryV1.setBadgeSBTUniverse1(badgeSBTUniverse1.address)

	console.log("Done!")
}

main()
