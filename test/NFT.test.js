const { expect } = require("chai");
const { ethers } = require("hardhat");
const hre = require("hardhat");

describe("NFT COntract: ", () => {
  let nft, deployer, account_1, account_2;

  beforeEach(async () => {
    [deployer, account_1, account_2] = await hre.ethers.getSigners();

    const NFT = await hre.ethers.getContractFactory("NFT");
    nft = await NFT.deploy();
    await nft.deployed();
  });

  describe("Testing NFT token basics ", () => {
    it("Should test the name: ", async () => {
      const name = await nft.name();
      expect(name).to.equal("MyToken");
    });

    it("Should test the symbol: ", async () => {
      const symbol = await nft.symbol();
      expect(symbol).to.equal("MTK");
    });
  });

  describe("Testing Minting ", () => {
    let tx, receipt, events;
    beforeEach(async () => {
      tx = await nft.connect(deployer).safeMint();
      receipt = await tx.wait();
      events = receipt.events;
    });
    it("Should mint and emit Transfer Event: ", async () => {
      expect(events.length).to.equal(1);
      expect(await events[0].event).to.equal("Transfer");
    });

    it("Should Transfer Minted NFT's to deployer", async () => {
      expect(events[0].args[1]).to.equal(deployer.address);
      expect(events[0].args[2]).to.equal(0);
    });

    it("Should ensure the owner of NFT is deployer", async () => {
      const owner = await nft.ownerOf(events[0].args[2]);
      expect(owner).to.equal(deployer.address);
    });
  });
});
