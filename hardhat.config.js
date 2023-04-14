require("@nomicfoundation/hardhat-toolbox");
require("solidity-coverage");
require("dotenv/config");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",

  defaultNetwork: "network",

  networks: {
    network: {
      url: process.env.RPC_URL,
      gas: "auto",
      accounts: [process.env.private_key],
    },
  },
};
