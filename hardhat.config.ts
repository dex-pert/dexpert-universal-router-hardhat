import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { ethers } from "hardhat";
import * as dotenv from 'dotenv';
dotenv.config();

const DEFAULT_COMPILER_SETTINGS = {
  version: '0.8.17',
  settings: {
    viaIR: true,
    evmVersion: 'istanbul',
    optimizer: {
      enabled: true,
      runs: 1_000_000,
    },
    metadata: {
      bytecodeHash: 'none',
    },
  },
}

export default {
  paths: {
    sources: './contracts',
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      forking: {
        url: `https://rpc.bitlayer.org`,
      },
    },
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/kNPJaYqMx7BA9TcDDJQ8pS5WcLqXGiG7`,
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/ssx9MyUJ6pow311FQlrwjYWGmn7o_Zuj`,
      accounts: ["b8ba5bdad45f4308b3f8574a57a8bdb61a76e691226feb635d33484916737f35"]
    },
    base: {
      url: `https://base.llamarpc.com`,
      accounts: ["2f750870f474e1af076f10160b50daf05d948942e5a22eff28b483795de33550"]
    },
    bitlayerTestnet: {
      url: `https://testnet-rpc.bitlayer.org`,
      accounts: ["ddf0d87c8364f888ce8cea57995781797bbd954441deae412ae7922ad0813a9f"],
    },
    bitlayer: {
      url: `https://rpc.bitlayer.org`,
      accounts: ["ddf0d87c8364f888ce8cea57995781797bbd954441deae412ae7922ad0813a9f"]
    },
    confluxTestnet: {
      url: `https://evmtestnet.confluxrpc.com`,
      accounts: ["8dbc9d7b924b00532e6fc1295fd120886d3d3576ef9ac9de78335de33c28b095"]
    },
    confluxMainnet: {
      url: `https://evm.confluxrpc.com`,
      accounts: ["13ed357d9bbf58b2d57ce27c4129f159600a91131e4eac5cee911e6aef735d12"]
    },
    neox: {
      url: 'https://mainnet-1.rpc.banelabs.org',
      accounts: [process.env.deployKey]
    },
  },
  namedAccounts: {
    deployer: 0,
  },
  solidity: {
    compilers: [DEFAULT_COMPILER_SETTINGS],
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  mocha: {
    timeout: 60000,
  },
  etherscan: {
    apiKey: {
      goerli: 'QEAE2M96IB94MVPUN7ESQEBNI416F1EWRR',
      sepolia: 'QEAE2M96IB94MVPUN7ESQEBNI416F1EWRR',
      bitlayertestnet: "1234",
      bitlayer: "123",
      ire: "ire",
      confluxTestnet: 'espace',
      confluxMainnet: 'espace',
      neox: "neox"
    },
    customChains: [
      {
        network: "bitlayertestnet",
        chainId: 200810,
        urls: {
          apiURL: "https://api-testnet.btrscan.com/scan/api",
          browserURL: "https://testnet.btrscan.com/"
        }
      },
      {
        network: "bitlayer",
        chainId: 200901,
        urls: {
          apiURL: "https://api.btrscan.com/scan/api",
          browserURL: "https://www.btrscan.com/"
        }
      },
      {
        network: "ire",
        chainId: 997,
        urls: {
          apiURL: "https://contract.evm.scan.qa.5ire.network/5ire/verify",
          browserURL: "https://scan.qa.5ire.network",
        }
      },
      {
        network: 'confluxTestnet',
        chainId: 71,
        urls: {
          apiURL: 'https://evmapi-testnet.confluxscan.io/api/',
          browserURL: 'https://evmtestnet.confluxscan.io/',
        },
      },
      {
        network: 'confluxMainnet',
        chainId: 1030,
        urls: {
          apiURL: 'https://evmapi.confluxscan.io/api/',
          browserURL: 'https://evm.confluxscan.io/',
        },
      },
      {
        network: "neox",
        chainId: 47763,
        urls: {
          apiURL: "https://xexplorer.neo.org/api",
          browserURL: "https://xexplorer.neo.org/"
        }
      },
    ]
  },
}

