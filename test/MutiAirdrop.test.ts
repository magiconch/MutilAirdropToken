import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";

describe("MutiAirdrop", function () {
  let mutiAirdrop: Contract;
  let deployer: Signer;
  let accounts: Signer[];
  beforeEach("Deploy", async () => {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    const MutiAirdrop = await ethers.getContractFactory("MultAirdrop", deployer);
    mutiAirdrop = await MutiAirdrop.deploy();
  });

  describe("Access", function () {
    it("Deployer should get admin role", async function () {
      const flag = await mutiAirdrop.hasRole(mutiAirdrop.DAO_ADMIN(), deployer.getAddress());
      console.log(flag);
    });
  });
});
