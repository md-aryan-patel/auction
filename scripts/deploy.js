const hre = require("hardhat");
const ethers = hre.ethers;

const main = async () => {
  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();
  await nft.deployed();

  const Exchange = await ethers.getContractFactory("Exchange");
  const exchange = await Exchange.deploy();
  await exchange.deployed();

  console.log(`NFT deployed to ${nft.address}`);
  console.log(`Exchange deployed to ${exchange.address}`);
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
