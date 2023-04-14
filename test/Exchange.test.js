const { expect } = require("chai");
const { ethers } = require("hardhat");
const hre = require("hardhat");
const toWei = (num) => ethers.utils.parseEther(num.toString());

describe("Exchange contract: ", () => {
  let deployer, account_1, account_2, exchange, nft;
  let startTime = 1;
  let endTime = 2;
  const baseValue = toWei(0.1);

  beforeEach(async () => {
    [deployer, account_1, account_2] = await hre.ethers.getSigners();

    const Exchange = await hre.ethers.getContractFactory("Exchange");
    exchange = await Exchange.deploy();
    await exchange.deployed();

    const NFT = await hre.ethers.getContractFactory("NFT");
    nft = await NFT.deploy();
    await nft.deployed();
  });

  describe("Testing Creation of Sale", () => {
    let tx, receipt, events;
    beforeEach(async () => {
      await nft.connect(deployer).safeMint();
      await nft.approve(exchange.address, 0);
      tx = await exchange.createSale(
        nft.address,
        0,
        startTime,
        endTime,
        baseValue
      );
      receipt = await tx.wait();
      events = receipt.events;
    });

    it("Should emit events", async () => {
      expect(events.length).to.equal(2);
      expect(events[1].event).to.equal("CreateSale");
    });

    it("Should make sale exist true", async () => {
      expect(await exchange.returnIfSaleExist(0)).to.equal(true);
    });

    it("Should transfer nft to exchange contract", async () => {
      expect(await nft.ownerOf(0)).to.equal(exchange.address);
    });

    describe("Revert conditions: ", () => {
      it("Shoud revert if creater is not token owner ", async () => {
        expect(
          exchange
            .connect(account_1)
            .createSale(nft.address, 0, startTime, endTime, baseValue)
        ).to.be.revertedWith("Exchange: Not your token");
      });

      it("Should revert if the sale already exist", async () => {
        expect(
          exchange.createSale(nft.address, 0, startTime, endTime, baseValue)
        ).to.be.revertedWith("Exchange: Sale already exist");
      });
    });
  });

  describe("Testing placiBids(): ", async () => {
    let trx;
    beforeEach(async () => {
      await nft.connect(deployer).safeMint();
      await nft.approve(exchange.address, 0);
      tx = await exchange.createSale(
        nft.address,
        0,
        startTime,
        endTime,
        baseValue
      );
      receipt = await tx.wait();
      events = receipt.events;
      trx = await exchange
        .connect(account_1)
        .placeBid(0, { value: toWei(0.2) });
    });

    it("User should be able to place a bid ", async () => {
      const rcpt = await trx.wait();
      const events = rcpt.events;
      expect(events.length).to.equal(1);
    });

    it("Should revert if the next bid is less then top bid", async () => {
      expect(
        await exchange.connect(account_2).placeBid(0, { value: toWei(0.2) })
      ).to.be.revertedWith("Exchange: sent value is less then last bid");
    });

    it("Should revert if bidder is Owner", async () => {
      expect(
        exchange.connect(deployer).placeBid(0, { value: toWei(1) })
      ).to.be.revertedWith("Exchange Owner can't bid");
    });
  });

  describe("Testing checkResult()", () => {
    beforeEach(async () => {
      await nft.connect(deployer).safeMint();
      await nft.approve(exchange.address, 0);
      tx = await exchange.createSale(
        nft.address,
        0,
        startTime,
        endTime,
        baseValue
      );
      receipt = await tx.wait();
      events = receipt.events;
    });

    it("Check result", async () => {
      await exchange.connect(account_1).placeBid(0, { value: toWei(2) });
      await exchange.connect(account_2).placeBid(0, { value: toWei(3) });
      await exchange.connect(account_1).checkResult(0);
      await exchange.connect(account_2).checkResult(0);

      expect(await nft.ownerOf(0)).to.equal(account_2.address);
    });

    it("Should return nft if no one bids", async () => {
      await exchange.connect(deployer).checkResult(0);
      expect(await nft.ownerOf(0)).to.equal(deployer.address);
    });
  });
});
