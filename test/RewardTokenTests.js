const {assert, expect, use} = require("chai");
const {describe, utils, it} = require("mocha");
const {ethers,run,artifacts} = require("hardhat");

describe("Reward Token" , function () {

    const DEPLOYER = 0;
    const NOT_DEPLOYER = 1;
    const USER = 3;
    let contract = null;
    let accounts = null;

    beforeEach(async function (){

        accounts = await ethers.getSigners();
        
        const ContractFactory = await ethers.getContractFactory("RewardToken");
        contract = await ContractFactory.connect(accounts[DEPLOYER]).deploy(100, 10);
        await contract.deployed();
    });

    it("Should have correct cap tokens",
    async function () {
        expect(await contract.Cap()).to.equal(ethers.utils.parseEther("100"));
    });


    it("Should have the correct reward supply", 
    async function (){
        expect(await contract.rewardSupply()).to.be.equal(ethers.utils.parseEther("10"));
    });


    it("Should have to correct total supply", 
    async function (){
        expect(await contract.totalSupply()).to.be.equal(ethers.utils.parseEther("90"));
    });


    it("Should allow only the owner to add the minter, rejecting the caller if not owner", 
    async function (){
        await expect(contract.connect(accounts[NOT_DEPLOYER])
            .addMinter(accounts[USER].address))
            .to.be.revertedWith("Ownable: caller is not the owner");
    });


    it("Should allow only the owner of the contract perform the addMinter() function", 
    async function (){
        await expect(contract.connect(accounts[DEPLOYER])
        .addMinter(accounts[USER].address))
        .to.be.not.reverted;
    });


    it("Should not let a minter not added by the contract owner, mint the rewards", 
    async function(){
        await expect(contract.connect(accounts[USER])
        ._mintRewards(accounts[USER].address, ethers.utils.parseEther("1")))
        .to.be.revertedWith("You cannot mint the tokens because you are not authorized, please contact token owner to get authorized");
    });


    it("Should revert if the rewards + totalSupply is exceeding the cap", 
    async function (){
        await expect(contract.connect(accounts[DEPLOYER])
        .addMinter(accounts[USER].address)).to.be.not.reverted;
        
        await expect(contract.connect(accounts[DEPLOYER])
        ._mintRewards(accounts[USER].address, ethers.utils.parseEther("11")))
        .to.be.revertedWith("Exceeding the cap, please check!");
    });

    it("Should let the minter added by the contract owner mint the tokens", 
    async function(){
        await expect(contract.connect(accounts[DEPLOYER])
        .addMinter(accounts[USER].address)).to.be.not.reverted;

        expect(await contract.connect(accounts[USER])
        ._mintRewards(accounts[USER].address, ethers.utils.parseEther("1")))
        .to.emit(contract,"RewardsMined")
        .withArgs(accounts[USER].address, ethers.utils.parseEther("1"));
    });

    it("Should let contract owner mint rewards for any user they wish", 
    async function(){
        await expect(contract.connect(accounts[DEPLOYER])
            ._mintRewards(accounts[USER].address, ethers.utils.parseEther("1")))
            .to.emit(contract,"RewardsMined")
            .withArgs(accounts[USER].address, ethers.utils.parseEther("1"));
    });
});