const { ethers } = require("hardhat");

exports.toWei = (num) => ethers.utils.parseEther(num.toString());
exports.toEth = (num) => ethers.utils.formatEther(num);
