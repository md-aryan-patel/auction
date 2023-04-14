const { expect } = require("chai");
const hre = require("hardhat");
const toWei = (num) => hre.ethers.utils.parseEther(num.toString());

describe("ERC1155 Exchange", () => {
  let deployer, account_1, token, exchange;
  const minBid1 = toWei(0.01);
  const buyPrice1 = toWei(0.01);
  const ID_1 = 1;
  const ID_2 = 2;
  const ID_3 = 3;
  let createAmount = 2000;

  beforeEach(async () => {
    [deployer, account_1] = await hre.ethers.getSigners();

    const Token = await hre.ethers.getContractFactory("MyToken");
    token = await Token.deploy();
    await token.deployed();

    const Exchange = await hre.ethers.getContractFactory("ERC1155Exchange");
    exchange = await Exchange.deploy();
    await exchange.deployed();
  });

  describe("creating auction", () => {
    let tx;

    beforeEach(async () => {
      const ids = [1, 2, 3];
      const amount = [8421, 1752, 3290];
      await token.connect(deployer).mintBatch(ids, amount);
      await token.setApprovalForAll(exchange.address, true);
      tx = await exchange
        .connect(deployer)
        .createAuction(token.address, createAmount, ID_1, buyPrice1, minBid1);
    });

    it("Should create an auction for NFT's", async () => {
      const receipt = await tx.wait();
      const events = await receipt.events;
      expect(events.length).to.equal(1);
      const event = events[0];
      expect(event.args[0]).to.equal(token.address);
      expect(event.args[1]).to.equal(deployer.address);
      expect(event.args[2]).to.equal(createAmount);
      expect(event.args[3]).to.equal(buyPrice1);
      expect(event.args[4]).to.equal(minBid1);
    });

    it("Should revert if the sale already exist ", async () => {
      expect(
        exchange
          .connect(deployer)
          .createAuction(token.address, createAmount, ID_1, buyPrice1, minBid1)
      ).to.be.revertedWith("Sale already exist");
    });

    it("Should revert if the deposit amount is greater then the balance of creator", async () => {
      expect(
        exchange
          .connect(deployer)
          .createAuction(token.address, 2000, ID_2, buyPrice1, minBid1)
      ).to.be.revertedWith("User dont have enough to create auction");
    });
  });
  describe("Instent Buy NFTS", () => {
    let tx;
    beforeEach(async () => {
      const ids = [1, 2, 3];
      const amount = [8421, 1752, 3290];
      await token.connect(deployer).mintBatch(ids, amount);
      await token.setApprovalForAll(exchange.address, true);
      tx = await exchange
        .connect(deployer)
        .createAuction(token.address, createAmount, ID_1, buyPrice1, minBid1);
    });

    it("Should instantly buy the token", async () => {
      await exchange
        .connect(account_1)
        .instentBuy(ID_1, { value: toWei(0.02) });

      expect(await token.balanceOf(account_1.address, ID_1)).to.equal(1);
    });
  });
});
