import { HardhatUserConfig } from "hardhat/config"
import "@typechain/hardhat"
import "@nomicfoundation/hardhat-toolbox"
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import "@nomicfoundation/hardhat-foundry"
import "@openzeppelin/hardhat-upgrades"
import "@typechain/hardhat"
import "solidity-docgen"
import * as dotenv from "dotenv"

dotenv.config()

const config: HardhatUserConfig = {
	solidity: {
		version: "0.8.17",
		settings: {
			optimizer: { enabled: true, runs: 200 },
		},
	},
	docgen: {
		pages: "files",
	},
	networks: {
		goerli: {
			url: process.env.GOERLI_RPC || "",
			accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
		},
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_API_KEY,
	},
}

export default config
