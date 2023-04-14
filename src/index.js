const tokenRepo = require("./repository/tokenRepository.js");
const exchangeRespo = require("./repository/exchangeRepository.js");
const { Token, Exchange } = require("./di/mainModule.js");
const { toWei } = require("./utils/converters.js");

const tokenContract = Token.getContract();
const exchangeContract = Exchange.getContract();

const startTime = 1681453800; //12
const endTime = 1681457400; //01
const baseValue = toWei(0.01);

const createSale = async () => {
  const result = await exchangeRespo.createSale(
    tokenContract.address,
    1,
    startTime,
    endTime,
    baseValue
  );
  console.log(result);
};

const main = async () => {
  // tokenRepo.getDetail();
  // exchangeRespo.placeBid(0, toWei(3));
  createSale();
};

main();
