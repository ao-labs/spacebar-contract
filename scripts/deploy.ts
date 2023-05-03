import { ethers } from "hardhat"

async function main() {
	const [deployer] = await ethers.getSigners()

	console.log("Deploying contracts with the account:", deployer.address)

	console.log("Account balance:", (await deployer.getBalance()).toString())

	console.log(`Deploying SpaceFactory...`)
	const SpaceFactory = await ethers.getContractFactory("SpaceFactory")
	const spaceFactory = await SpaceFactory.deploy(
		process.env.SERVICE_ADMIN_ADDRESS,
		JSON.parse(process.env.QUANTYTY_PER_PARTS_TYPE || ""),
		process.env.PARTS_MINTING_SUCCESS_RATE
	)
	console.log(`SpaceFactory is deployed to ${spaceFactory.address}`)

	console.log(`Deploying BadgeSBT...`)
	const BadgeSBT = await ethers.getContractFactory("BadgeSBT")
	const badgeSBT = await BadgeSBT.deploy(
		spaceFactory.address,
		process.env.SERVICE_ADMIN_ADDRESS
	)

	await badgeSBT.deployed()
	console.log(`BadgeSBT is deployed to ${badgeSBT.address}`)

	console.log("Setting BadgeSBT address to Space Factory...")
	await spaceFactory.setBadgeSBTAddress(badgeSBT.address)

	console.log(`Deploying BaseSpaceshipNFT...`)

	const BaseSpaceshipNFT = await ethers.getContractFactory("BaseSpaceshipNFT")
	const baseSpaceshipNFT = await BaseSpaceshipNFT.deploy(spaceFactory.address)

	await baseSpaceshipNFT.deployed()
	console.log(`BaseSpaceshipNFT is deployed to ${baseSpaceshipNFT.address}`)

	console.log("Setting BaseSpaceshipNFT address to Space Factory...")
	await spaceFactory.setBadgeSBTAddress(baseSpaceshipNFT.address)

	console.log(`Deploying PartsNFT...`)

	const PartsNFT = await ethers.getContractFactory("PartsNFT")
	const partsNFT = await PartsNFT.deploy(spaceFactory.address)

	await partsNFT.deployed()
	console.log(`PartsNFT is deployed to ${partsNFT.address}`)

	console.log("Setting PartsNFT address to Space Factory...")
	await spaceFactory.setPartsNFTAddress(partsNFT.address)

	console.log(`Deploying ScoreNFT...`)

	const ScoreNFT = await ethers.getContractFactory("ScoreNFT")
	const scoreNFT = await ScoreNFT.deploy(spaceFactory.address)

	await scoreNFT.deployed()
	console.log(`ScoreNFT is deployed to ${scoreNFT.address}`)

	console.log("Setting ScoreNFT address to Space Factory...")
	await spaceFactory.setScoreNFTAddress(scoreNFT.address)

	console.log(`Deploying SpaceshipNFT...`)

	const SpaceshipNFT = await ethers.getContractFactory("SpaceshipNFT")
	const spaceshipNFT = await SpaceshipNFT.deploy(spaceFactory.address)

	await spaceshipNFT.deployed()
	console.log(`SpaceshipNFT is deployed to ${spaceshipNFT.address}`)

	console.log("Setting SpaceshipNFT address to Space Factory...")
	await spaceFactory.setSpaceshipNFTAddress(spaceshipNFT.address)

	console.log(
		"Success!! Account balance after deployment:",
		(await deployer.getBalance()).toString()
	)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error)
	process.exitCode = 1
})
