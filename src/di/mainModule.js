const { ethers } = require("hardhat");
const abi = require("../../artifacts/contracts/NFT.sol/NFT.json");
const exchangeAbi = require("../../artifacts/contracts/Exchange.sol/Exchange.json");
require("dotenv/config");

const url = process.env.RPC_URL;

exports.SecondWallet = (() => {
  let wallet;
  const createWallet = () => {
    wallet = new ethers.Wallet(
      process.env.private_key_2,
      this.Provider.getProvider()
    );
    return wallet;
  };

  return {
    getWallet: () => {
      if (!wallet) wallet = createWallet();
      return wallet;
    },
  };
})();

exports.Wallet = (() => {
  let wallet;
  const createWallet = () => {
    wallet = new ethers.Wallet(
      process.env.private_key,
      this.Provider.getProvider()
    );
    return wallet;
  };

  return {
    getWallet: () => {
      if (!wallet) wallet = createWallet();
      return wallet;
    },
  };
})();

exports.Provider = (() => {
  let provider;
  const createProvider = () => {
    provider = new ethers.providers.JsonRpcProvider(url);
    return provider;
  };

  return {
    getProvider: () => {
      if (!provider) provider = createProvider();
      return provider;
    },
  };
})();

exports.Token = (() => {
  let contract;
  const createContract = () => {
    contract = new ethers.Contract(
      process.env.TOKEN,
      abi.abi,
      this.Provider.getProvider()
    );
    return contract;
  };

  return {
    getContract: () => {
      if (!contract) {
        contract = createContract();
      }
      return contract;
    },
  };
})();

exports.Exchange = (() => {
  let contract;
  const createContract = () => {
    contract = new ethers.Contract(
      process.env.Exchange,
      exchangeAbi.abi,
      this.Provider.getProvider()
    );
    return contract;
  };

  return {
    getContract: () => {
      if (!contract) {
        contract = createContract();
      }
      return contract;
    },
  };
})();
