import { ethers } from "hardhat"
import { WhitelistBadgeClaimer } from "../typechain-types"

async function main() {
	const runVerify = true
	/// @dev Deploying WhitelistBadgeClaimer
	console.log("Deploying WhitelistBadgeClaimer...")
	const WhitelistBadgeClaimer = await ethers.getContractFactory(
		"WhitelistBadgeClaimer"
	)

	const whitelistBadgeClaimer = (await WhitelistBadgeClaimer.deploy(
		process.env.SPACE_FACTORY_ADDRESS,
		process.env.DEFAULT_ADMIN_ADDRESS,
		process.env.SERVICE_ADMIN_ADDRESS,
		process.env.BADGE_TOKEN_URI
	)) as WhitelistBadgeClaimer

	await whitelistBadgeClaimer.deployed()

	console.log(
		"WhitelistBadgeClaimer is deployed to:",
		whitelistBadgeClaimer.address
	)

	if (runVerify) {
		console.log("----------------Verification---------------")
		const WAIT_BLOCK_CONFIRMATIONS = 5
		console.log("Verifying WhitelistBadgeClaimer on etherscan...")
		await whitelistBadgeClaimer.deployTransaction.wait(
			WAIT_BLOCK_CONFIRMATIONS
		)
		// @ts-ignore
		await run(`verify:verify`, {
			address: whitelistBadgeClaimer.address,
			constructorArguments: [
				process.env.SPACE_FACTORY_ADDRESS,
				process.env.DEFAULT_ADMIN_ADDRESS,
				process.env.SERVICE_ADMIN_ADDRESS,
				process.env.BADGE_TOKEN_URI,
			],
		})
	}

	console.log("Done!")
}

main()
