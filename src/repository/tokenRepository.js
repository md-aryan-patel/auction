const { Token, Wallet } = require("../di/mainModule.js");
const { toWei } = require("../utils/converters.js");
require("dotenv/config");

const wallet = Wallet.getWallet();
const contract = Token.getContract();

contract.on("Transfer", (from, to, tokenId) => {
  console.log(`from: ${from} \nto: ${to} \namount: ${tokenId}`);
});

const getDetail = async () => {
  const result = await contract.name();
  console.log(result);
};

const mintNft = async () => {
  const result = await contract.connect(wallet).safeMint();
  console.log(result);
};

const getOwnerOf = async (_tokenID) => {
  const result = await contract.ownerOf(_tokenID);
  return result;
};

const approve = async (_to, _tokenId) => {
  const result = await contract.connect(wallet).approve(_to, _tokenId);
  return result;
};

module.exports = {
  getDetail,
  mintNft,
  getOwnerOf,
  approve,
};
