import { ethers, upgrades } from "hardhat"
import {
	SpaceFactoryV1,
	SpaceshipUniverse1,
	BadgeUniverse1,
} from "../typechain-types"

async function main() {
	const runVerify = true

	/// @dev Deploying SpaceFactoryV1
	console.log("Deploying SpaceFactoryV1...")
	const SpaceFactoryV1 = await ethers.getContractFactory("SpaceFactoryV1")

	const [deployer] = await ethers.getSigners()

	if (deployer.address == process.env.DEFAULT_ADMIN_ADDRESS) {
		throw Error(
			"Deployer address should not be the same as default admin address"
		)
	}

	const spaceFactoryV1 = (await upgrades.deployProxy(
		SpaceFactoryV1,
		[
			deployer.address,
			process.env.SERVICE_ADMIN_ADDRESS,
			process.env.MINTER_ADMIN_ADDRESS,
			process.env.TBA_REGISTRY_ADDRESS,
			process.env.TBA_IMPLEMENTATION_ADDRESS,
			true,
			[0, 0],
		],
		{
			initializer: "initialize",
		}
	)) as SpaceFactoryV1

	await spaceFactoryV1.deployed()
	console.log("SpaceFactoryV1 is deployed to:", spaceFactoryV1.address)

	/// @dev Deploying SpaceshipUniverse1
	console.log("Deploying SpaceshipUniverse1...")
	const SpaceshipUniverse1 = await ethers.getContractFactory(
		"SpaceshipUniverse1"
	)

	const spaceshipUniverse1 = (await SpaceshipUniverse1.deploy(
		spaceFactoryV1.address,
		process.env.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY,
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.ROYALTY_RECEIVER_ADDRESS
	)) as SpaceshipUniverse1

	await spaceshipUniverse1.deployed()

	console.log(
		"SpaceshipUniverse1 is deployed to:",
		spaceshipUniverse1.address
	)

	/// @dev Deploying BadgeUniverse1
	console.log("Deploying BadgeUniverse1...")
	const BadgeUniverse1 = await ethers.getContractFactory("BadgeUniverse1")

	const badgeUniverse1 = (await BadgeUniverse1.deploy(
		spaceFactoryV1.address,
		process.env.DEFAULT_ADMIN_ADDRESS
	)) as BadgeUniverse1

	await badgeUniverse1.deployed()
	console.log("BadgeUniverse1 is deployed to:", badgeUniverse1.address)

	/// @dev set SpaceshipUniverse1 address to SpaceFactoryV1
	console.log("Setting SpaceshipUniverse1 address to SpaceFactoryV1...")

	await spaceFactoryV1.setSpaceshipUniverse1(spaceshipUniverse1.address)

	/// @dev set BadgeUniverse1 address to SpaceFactoryV1
	console.log("Setting BadgeUniverse1 address to SpaceFactoryV1...")

	await spaceFactoryV1.setBadgeUniverse1(badgeUniverse1.address)

	console.log(
		"Transfering default admin of SpaceFactoryV1 to :",
		process.env.DEFAULT_ADMIN_ADDRESS
	)

	await spaceFactoryV1.transferDefaultAdmin(
		process.env.DEFAULT_ADMIN_ADDRESS || ""
	)

	if (runVerify) {
		console.log("----------------Verification---------------")
		const WAIT_BLOCK_CONFIRMATIONS = 5
		/// @dev Verify SpaceFactoryV1
		console.log("Verifying SpaceFactory implementation on etherscan...")
		const implementationAddress =
			await upgrades.erc1967.getImplementationAddress(
				spaceFactoryV1.address
			)
		await spaceFactoryV1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)
		// @ts-ignore
		await run(`verify:verify`, {
			address: implementationAddress,
		})

		/// @dev Verify SpaceshipUniverse1
		console.log("Verifying SpaceshipUniverse1 on etherscan...")

		await spaceshipUniverse1.deployTransaction.wait(
			WAIT_BLOCK_CONFIRMATIONS
		)
		// @ts-ignore
		await run(`verify:verify`, {
			address: spaceshipUniverse1.address,
			constructorArguments: [
				spaceFactoryV1.address,
				process.env.MAX_SPACESHIP_UNIVERSE1_CIRCULATING_SUPPLY,
				process.env.DEFAULT_ADMIN_ADDRESS,
				process.env.ROYALTY_RECEIVER_ADDRESS,
			],
		})
		/// @dev Verify BadgeUniverse1
		console.log("Verifying BadgeUniverse1 on etherscan...")

		await badgeUniverse1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)
		// @ts-ignore
		await run(`verify:verify`, {
			address: badgeUniverse1.address,
			constructorArguments: [
				spaceFactoryV1.address,
				process.env.DEFAULT_ADMIN_ADDRESS,
			],
		})
	}

	console.log("Done!")
}

main()
