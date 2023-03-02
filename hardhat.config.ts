import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import * as dotenv from "dotenv"

dotenv.config()

const config: HardhatUserConfig = {
	solidity: "0.8.17",
	networks: {
		arbitrum: {
			url: `https://arb1.arbitrum.io/rpc`,
			accounts: [process.env.ARBITRUM_MAINNET_ACCOUNT || ""],
		},
		optimism: {
			url: `https://mainnet.optimism.io`,
			accounts: [process.env.OPTIMISM_MAINNET_ACCOUNT || ""],
		},
		"arbitrum-goerli": {
			url: `https://goerli-rollup.arbitrum.io/rpc	`,
			accounts: [process.env.ARBITRUM_GOERLI_ACCOUNT || ""],
		},
		"optimism-goerli": {
			url: `https://goerli.optimism.io`,
			accounts: [process.env.OPTIMISM_GOERLI_ACCOUNT || ""],
		},
	},
}

export default config
