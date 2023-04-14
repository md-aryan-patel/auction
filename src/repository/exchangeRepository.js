const { Exchange, Wallet, SecondWallet } = require("../di/mainModule.js");
require("dotenv/config.js");

const wallet = Wallet.getWallet();
const secondWallet = SecondWallet.getWallet();
const contract = Exchange.getContract();

contract.on("CreateSale", (owner, tokenId, startTime, endTime, status) => {
  console.log(
    `Owner: ${owner} \nTokenID: ${tokenId} \nStart Time: ${startTime} \nEnd Time: ${endTime} \nStatus: ${status}`
  );
});

contract.on("PlaceBid", (caller, value) => {
  console.log(`Caller: ${caller} \nValue: ${value}`);
});

const createSale = async (
  _tokenAddress,
  _tokenId,
  _startTime,
  _endTime,
  _baseValue
) => {
  const result = await contract
    .connect(wallet)
    .createSale(_tokenAddress, _tokenId, _startTime, _endTime, _baseValue);

  return result;
};

const placeBid = async (_tokenId, _value) => {
  const result = await contract
    .connect(secondWallet)
    .placeBid(_tokenId, { value: _value });
  console.log(result, "NBID PLACED");
  return result;
};

module.exports = {
  createSale,
  placeBid,
};
