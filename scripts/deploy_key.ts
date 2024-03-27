import { ethers, upgrades } from "hardhat"
import { KeyMinterUniverse1V1, KeyUniverse1 } from "../typechain-types"

async function main() {
	const runVerify = true
	/// @dev Deploying KeyMinterUniverse1V1
	console.log("Deploying KeyMinterUniverse1V1...")
	const KeyMinterUniverse1V1 = await ethers.getContractFactory(
		"KeyMinterUniverse1V1"
	)

	const keyMinterUniverse1V1 = (await upgrades.deployProxy(
		KeyMinterUniverse1V1,
		[],
		{
			initializer: false,
		}
	)) as KeyMinterUniverse1V1

	await keyMinterUniverse1V1.deployed()

	console.log(
		"KeyMinterUniverse1V1 is deployed to:",
		keyMinterUniverse1V1.address
	)

	/// @dev Deploying KeyUniverse1
	console.log("Deploying KeyUniverse1...")
	const KeyUniverse1 = await ethers.getContractFactory("KeyUniverse1")

	const keyUniverse1 = (await KeyUniverse1.deploy(
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.OPERATOR_ADDRESS,
		keyMinterUniverse1V1.address
	)) as KeyUniverse1

	await keyUniverse1.deployed()

	console.log("KeyUniverse1 is deployed to:", keyUniverse1.address)

	console.log("Intializing KeyMinterUniverse1V1...")
	await keyMinterUniverse1V1.initialize(
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
		await keyMinterUniverse1V1.deployTransaction.wait(
			WAIT_BLOCK_CONFIRMATIONS
		)

		console.log(
			"Verifying KeyMinterUniverse1V1 implementation on etherscan..."
		)
		const implementationAddress =
			await upgrades.erc1967.getImplementationAddress(
				keyMinterUniverse1V1.address
			)
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
				keyMinterUniverse1V1.address,
			],
		})
	}
	console.log("Done!")
}

main()
