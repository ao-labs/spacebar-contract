import { ethers } from "hardhat"
import { KeyMinterUniverse1 } from "../typechain-types"

async function main() {
	const runVerify = true
	/// @dev Deploying KeyMinterUniverse1
	console.log("Deploying KeyMinterUniverse1...")
	const KeyMinterUniverse1 = await ethers.getContractFactory(
		"KeyMinterUniverse1"
	)

	const keyMinterUniverse1 = (await KeyMinterUniverse1.deploy(
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.OPERATOR_ADDRESS,
		process.env.SERVICE_ADMIN_ADDRESS,
		process.env.SPACESHIP_NFT_ADDRESS,
		process.env.TBA_REGISTRY_ADDRESS,
		process.env.TBA_IMPLEMENTATION_ADDRESS
	)) as KeyMinterUniverse1

	await keyMinterUniverse1.deployed()

	console.log(
		"KeyMinterUniverse1 is deployed to:",
		keyMinterUniverse1.address
	)

	const keyUniverse1 = await keyMinterUniverse1.keyUniverse1()
	await keyMinterUniverse1.keyUniverse1()
	console.log("KeyUniverse1 is deployed to:", keyUniverse1)

	if (runVerify) {
		console.log("----------------Verification---------------")
		console.log("Waiting for 5 block confirmations...")
		const WAIT_BLOCK_CONFIRMATIONS = 5

		await keyMinterUniverse1.deployTransaction.wait(
			WAIT_BLOCK_CONFIRMATIONS
		)
		console.log("Verifying KeyMinterUniverse1 on etherscan...")
		// @ts-ignore
		await run(`verify:verify`, {
			address: keyMinterUniverse1.address,
			constructorArguments: [
				process.env.DEFAULT_ADMIN_ADDRESS,
				process.env.OPERATOR_ADDRESS,
				process.env.SERVICE_ADMIN_ADDRESS,
				process.env.SPACESHIP_NFT_ADDRESS,
				process.env.TBA_REGISTRY_ADDRESS,
				process.env.TBA_IMPLEMENTATION_ADDRESS,
			],
		})
		console.log("Verifying KeyUniverse1 on etherscan...")
		// @ts-ignore
		await run(`verify:verify`, {
			address: keyUniverse1,
			constructorArguments: [
				process.env.DEFAULT_ADMIN_ADDRESS,
				process.env.OPERATOR_ADDRESS,
				keyMinterUniverse1.address,
			],
		})
	}
	console.log("Done!")
}

main()
