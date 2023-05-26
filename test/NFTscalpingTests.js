const {assert, expect, use} = require("chai");
const {describe, utils, it} = require("mocha");
const {ethers,run,artifacts} = require("hardhat");

describe("NFT Scalping" , function () {

    const DEPLOYER = 0;
    const NOT_DEPLOYER = 1;
    let rewardContract = null;
    let scalpingContract = null;
    let accounts = null;

    beforeEach(async function (){

        accounts = await ethers.getSigners();
        
        const RewardContractFactory = await ethers.getContractFactory("RewardToken");
        rewardContract = await RewardContractFactory.connect(accounts[DEPLOYER]).deploy(100, 10);
        await rewardContract.deployed();

        const ScalpingContractFactory = await ethers.getContractFactory("NFTSCALPING");
        scalpingContract = await ScalpingContractFactory.connect(accounts[DEPLOYER]).deploy("RentableNFTS","RNFT",rewardContract.address);
        await scalpingContract.deployed();
    });

    it("Should display the correct name of the NFT", 
    async function(){
        expect(await scalpingContract.name()).to.equal("RentableNFTS");
    });

    it("Should display the correct symbol of the NFT", 
    async function(){
        expect(await scalpingContract.symbol()).to.equal("RNFT");
    });

    it("Should let only owner of contact add Tiers", 
    async function(){
        await expect (scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.be.not.revertedWith("Tier is already added.");
    });

    it("Should throw error if the function caller is not contract owner",
    async function(){
        await expect(scalpingContract.connect(accounts[NOT_DEPLOYER])
        .addTier("TIER_1"))
        .to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should let owner add tier",
    async function(){
        await expect( scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1")).to.not.be.reverted;
    });

    it("Should not add same tier again",
    async function(){
        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1")).to.not.be.reverted;

        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.be.revertedWith("Tier is already added.");
    });

    it("Should not display the tiers details because the tier is not added yet",
     async function(){

        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .getTierDetails("TIER_1"))
        .to.be.revertedWith("This tier is not yet set by the owner, cannot view tier's details.")

    });

    it("Should not let owner add tier details if it is not added to the tier's list", async function(){
        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3))
        .to.be.revertedWith("To set details for this tier, the tier must be first added to the list of tiers.");
    });
    
    it("Should let owner set tier's details", async function(){
        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx = await scalpingContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,10,3);

        await tx.wait();
    });

    it("Should not add the same tier and details", async function(){
        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx = await scalpingContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,10,3);

        await tx.wait();

        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",12,10,2))
        .to.be.revertedWith("This tier is already filled with tier specific details.");
    });

    it("Should display the tier details", async function(){
        await expect(scalpingContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx = await scalpingContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,10,3);
        await tx.wait();

        const details = await scalpingContract.connect(accounts[DEPLOYER])
        .getTierDetails("TIER_1");
        
        expect(details[0]).to.equal("TIER_1");
        expect(details[1]).to.equal(10*86400);
        expect(details[2]).to.equal(ethers.utils.parseEther("10"));
        expect(details[3]).to.equal(ethers.utils.parseEther("3"));
    });

});
