const { expect } = require("chai");
const hre = require("hardhat");

describe("ERC1155Token contract", () => {
  let deployer, account_1, token;
  let mintAmount = 100;

  beforeEach(async () => {
    [deployer, account_1] = await hre.ethers.getSigners();

    const Token = await hre.ethers.getContractFactory("MyToken");
    token = await Token.deploy();
    await token.deployed();
  });

  describe("Mint Tokens ", () => {
    it("Should mint tokens for caller", async () => {
      await token.connect(deployer).mint(1, mintAmount);
      expect(await token.balanceOf(deployer.address, 1)).to.equal(mintAmount);
    });

    it("Should mint token in batch", async () => {
      const ids = [1, 2, 3];
      const amounts = [3000, 2000, 5000];

      await token.connect(deployer).mintBatch(ids, amounts);
      expect(await token.balanceOf(deployer.address, 1)).to.equal(amounts[0]);
      expect(await token.balanceOf(deployer.address, 2)).to.equal(amounts[1]);
      expect(await token.balanceOf(deployer.address, 3)).to.equal(amounts[2]);
    });
  });
});
