import { HardhatUserConfig } from "hardhat/config"
import "@typechain/hardhat"
import "@nomicfoundation/hardhat-toolbox"
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan"
import "@nomicfoundation/hardhat-foundry"
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
		"polygon-mumbai": {
			url: process.env.POLYGON_MUMBAI_RPC || "",
			accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
		},
	},
	// networks: {
	// 	arbitrum: {
	// 		url: `https://arb1.arbitrum.io/rpc`,
	// 		accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
	// 	},
	// 	optimism: {
	// 		url: `https://mainnet.optimism.io`,
	// 		accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
	// 	},
	// 	"arbitrum-goerli": {
	// 		url: `https://goerli-rollup.arbitrum.io/rpc	`,
	// 		accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
	// 	},
	// 	"optimism-goerli": {
	// 		url: `https://goerli.optimism.io`,
	// 		accounts: [process.env.DEPLOYER_PRIVATE_KEY || ""],
	// 	},
	// },
}

export default config
