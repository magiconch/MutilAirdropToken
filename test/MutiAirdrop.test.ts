import { expect } from "chai";
import { Contract, Signer } from "ethers";
import { ethers } from "hardhat";

const EVALUE = ethers.utils.parseEther("1");

describe("MutiAirdrop", async function () {
  let mutiAirdrop: Contract;
  let deployer: Signer;
  let accounts: Signer[];
  beforeEach("Deploy", async () => {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    const MutiAirdrop = await ethers.getContractFactory("MultAirdrop", deployer);
    mutiAirdrop = await MutiAirdrop.deploy();
  });

  describe("Access", async function () {
    // const adminRole = mutiAirdrop.DAO_ADMIN();
    // const agentRole = mutiAirdrop.DAO_AGENT();
    it("Deployer should have admin role", async function () {
      const result = await mutiAirdrop.hasRole(mutiAirdrop.DAO_ADMIN(), deployer.getAddress());
      expect(result).to.be.true;
    });

    it("Admin should have access to add admin role", async function () {
      const otherUser = accounts[1].getAddress();
      await mutiAirdrop.grantRole(mutiAirdrop.DAO_ADMIN(), otherUser);
      const result = await mutiAirdrop.hasRole(mutiAirdrop.DAO_ADMIN(), deployer.getAddress());
      expect(result).to.be.true;
    });
  });

  describe("Invest & withdraw", async function () {
    // const adminRole = mutiAirdrop.DAO_ADMIN();
    // const agentRole = mutiAirdrop.DAO_AGENT();
    it("Contract should invested eth", async function () {
      
      await deployer.sendTransaction({
        to: mutiAirdrop.address,
        value: EVALUE,
      });

      const result = await mutiAirdrop.getBalance();
      expect(result.toString()).to.be.equal(EVALUE.toString());

      await mutiAirdrop.withdraw();

      const result2 = await mutiAirdrop.getBalance();
      expect(result2.toString()).to.be.equal("0");

    });

    it("Contract should invested coin", async function () {
      // const otherUser = accounts[1].getAddress();
      // await mutiAirdrop.grantRole(mutiAirdrop.DAO_ADMIN(), otherUser);
      // const result = await mutiAirdrop.hasRole(mutiAirdrop.DAO_ADMIN(), deployer.getAddress());
      // expect(result).to.be.true;
      // Hi there!
      
      // 
    });
  });


});
