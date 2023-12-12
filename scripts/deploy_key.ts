import { ethers, upgrades } from "hardhat"
import { KeyMinterV1, KeyUniverse1 } from "../typechain-types"

async function main() {
	const runVerify = true
	/// @dev Deploying KeyMinterV1
	console.log("Deploying KeyMinterV1...")
	const KeyMinterV1 = await ethers.getContractFactory("KeyMinterV1")

	const keyMinterV1 = (await upgrades.deployProxy(KeyMinterV1, [], {
		initializer: false,
	})) as KeyMinterV1

	await keyMinterV1.deployed()

	console.log("KeyMinterV1 is deployed to:", keyMinterV1.address)

	/// @dev Deploying KeyUniverse1
	console.log("Deploying KeyUniverse1...")
	const KeyUniverse1 = await ethers.getContractFactory("KeyUniverse1")

	const keyUniverse1 = (await KeyUniverse1.deploy(
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.OPERATOR_ADDRESS,
		keyMinterV1.address
	)) as KeyUniverse1

	await keyUniverse1.deployed()

	console.log("KeyUniverse1 is deployed to:", keyUniverse1.address)

	console.log("Intializing KeyMinterV1...")
	await keyMinterV1.initialize(
		// @ts-ignore
		process.env.VAULT_ADDRESS,
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.OPERATOR_ADDRESS,
		process.env.SERVICE_ADMIN_ADDRESS,
		process.env.SPACEBAR_UNIVERSE1_ADDRESS,
		keyUniverse1.address,
		process.env.TBA_REGISTRY_ADDRESS,
		process.env.TBA_IMPLEMENTATION_ADDRESS
	)

	if (runVerify) {
		console.log("----------------Verification---------------")
		console.log("Waiting for 5 block confirmations...")
		const WAIT_BLOCK_CONFIRMATIONS = 5
		await keyMinterV1.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS)

		console.log("Verifying KeyMinterV1 implementation on etherscan...")
		const implementationAddress =
			await upgrades.erc1967.getImplementationAddress(keyMinterV1.address)
		// @ts-ignore
		await run(`verify:verify`, {
			address: implementationAddress,
		})

		console.log("Verifying KeyUniverse1 on etherscan...")
		// @ts-ignore
		await run(`verify:verify`, {
			address: keyUniverse1,
			constructorArguments: [
				process.env.DEFAULT_ADMIN_ADDRESS,
				process.env.OPERATOR_ADDRESS,
				keyMinterV1.address,
			],
		})
	}
	console.log("Done!")
}

main()
