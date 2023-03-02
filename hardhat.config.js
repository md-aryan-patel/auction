require("@nomicfoundation/hardhat-toolbox");
require("solidity-coverage");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",

  defaultNetwork: "ganache",

  networks: {
    ganache: {
      url: "http://127.0.0.1:7545",
      gas: "auto",
    },
  },
};
