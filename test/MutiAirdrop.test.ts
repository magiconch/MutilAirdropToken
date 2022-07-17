import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";

describe("MutiAirdrop", async function () {
  let mutiAirdrop: Contract;
  let deployer: Signer;
  let accounts: Signer[];
  beforeEach("Deploy", async () => {
    console.log("Start Deploy");
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    const MutiAirdrop = await ethers.getContractFactory("MultAirdrop", deployer);
    mutiAirdrop = await MutiAirdrop.deploy();
    console.log("Deployed MutiAirdrop to:", mutiAirdrop.address);
  });

  describe("Access", async function () {
    // const adminRole = mutiAirdrop.DAO_ADMIN();
    // const agentRole = mutiAirdrop.DAO_AGENT();
    it("Deployer should get admin role", async function () {
      const result = await mutiAirdrop.hasRole(mutiAirdrop.DAO_ADMIN(), deployer.getAddress());
      expect(result).to.be.true;
    });
  });
});
