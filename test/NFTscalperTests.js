const {assert, expect, use} = require("chai");
const {describe, utils, it} = require("mocha");
const {ethers,run,artifacts} = require("hardhat");

describe("Scalper NFT", function(){

    const DEPLOYER = 0;
    const TENANT = 1;
    const USER = 3;
    const RANDOMUSER = 2;
    let rewardContract = null;
    let scalpingContract = null;
    let NFTscalperContract = null;
    let accounts = null;

    beforeEach(async function(){

        accounts = await ethers.getSigners();
        
        const RewardContractFactory = await ethers.getContractFactory("RewardToken");
        rewardContract = await RewardContractFactory.connect(accounts[DEPLOYER]).deploy(100, 10);
        await rewardContract.deployed();

        const ScalpingContractFactory = await ethers.getContractFactory("NFTSCALPING");
        scalpingContract = await ScalpingContractFactory.connect(accounts[DEPLOYER]).deploy("RentableNFTS","RNFT",rewardContract.address);
        await scalpingContract.deployed();

        const ScalperContractFactory = await ethers.getContractFactory("ScalperNFT");
        NFTscalperContract = await ScalperContractFactory.connect(accounts[DEPLOYER]).deploy(rewardContract.address);
        await NFTscalperContract.deployed();
    });

    it("Should let the user mint the NFT", 
    async function(){
        const tx = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx.wait();

        expect (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId()).to.equal(1);
    });

    it("Should let the user put their NFT on rent",
    async function(){
        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;
    });

    it("Should not let user put the same NFT on rent",
    async function(){
        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.be.revertedWith("The NFT is already listed.");

    });

    it("Should display details of the NFT listed",
    async function(){
        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        const details  = await NFTscalperContract.connect(accounts[USER])
        .detailsOfNFTListedForRent(tokenId);

        expect(details[0]).to.equal(tokenId);
        expect(details[1]).to.equal("TIER_1");
        expect(details[2]).to.equal(10*86400);
        expect(details[3]).to.equal(ethers.utils.parseEther("1"));
        expect(details[4]).to.equal(ethers.utils.parseEther("3"));

    });

    it("Should let the tenant rent the NFT",
    async function(){

        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;



        await expect(NFTscalperContract.connect(accounts[TENANT])
        .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
        .to.emit(NFTscalperContract,"RentPaid")
        .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

    
        // const currentTimestamp = (await ethers.provider.getBlock('latest')).timestamp;

        // await expect(NFTscalperContract.connect(accounts[TENANT])
        // .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
        // .to.emit(NFTscalperContract,"UpdateUser")
        // .withArgs(tokenId, accounts[TENANT].address, (currentTimestamp + (10*86400) + 1));


    });

    it("Should return the current tenant of the NFT is available",
    async function(){
        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        await expect(NFTscalperContract.connect(accounts[TENANT])
        .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
        .to.emit(NFTscalperContract,"RentPaid")
        .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

        const details = await NFTscalperContract.connect(accounts[RANDOMUSER])
        .userOf(tokenId);
            
        const currentTimestamp = (await ethers.provider.getBlock('latest')).timestamp;
        
        expect(details[0]).to.equal(accounts[TENANT].address);
        expect(details[1]).to.equal(currentTimestamp + (10*86400));
    });

    it("Should return 'This NFT is available for rent' when tenure has expired.",
    async function(){

        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        await expect(NFTscalperContract.connect(accounts[TENANT])
        .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")})) //Displays 'Not the appropriate user.' for non holders and non renters.
        .to.emit(NFTscalperContract,"RentPaid")
        .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

        await expect(NFTscalperContract.connect(accounts[USER])
        .forceEndTenure(tokenId))
        .to.emit(NFTscalperContract, "UpdateUser")
        .withArgs(tokenId,ethers.constants.AddressZero,0)

        await expect(NFTscalperContract.connect(accounts[RANDOMUSER])
        .userOf(tokenId)).to.be.revertedWith("This NFT is available for rent");
    });

   it("Should display the 'This NFT is still on rent' when the current time is less than the expiry time.",
    async function(){

        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        await expect(NFTscalperContract.connect(accounts[TENANT])
        .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
        .to.emit(NFTscalperContract,"RentPaid")
        .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

        async function advanceTimeAndBlock(timestamp) {
        await ethers.provider.send('evm_increaseTime', [timestamp]);
        await ethers.provider.send('evm_mine');
        }

        const futureTime = (10*86400) -1 ;

        await advanceTimeAndBlock(futureTime);  

        await expect(NFTscalperContract.connect(accounts[USER])
        .TerminateRental(tokenId)).to.be.revertedWith("This NFT is still on rent.");

    })
    it("Should terminate the rental when the time limit has reached.",
    async function(){

        const tx_1 = await NFTscalperContract.connect(accounts[USER])
        .mint();
        
        await tx_1.wait();

        const tokenId = (await NFTscalperContract.connect(accounts[USER])
        .getCurrentMintedTokenId());

        await expect(NFTscalperContract.connect(accounts[DEPLOYER])
        .addTier("TIER_1"))
        .to.not.be.reverted;

        const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
        .setTierDetails("TIER_1",10,1,3);

        await tx_2.wait();

        await expect(NFTscalperContract.connect(accounts[USER])
        .makeNFTAvailableForRent(tokenId,"TIER_1"))
        .to.not.be.reverted;

        await expect(NFTscalperContract.connect(accounts[TENANT])
        .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
        .to.emit(NFTscalperContract,"RentPaid")
        .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

        async function advanceTimeAndBlock(timestamp) {
        await ethers.provider.send('evm_increaseTime', [timestamp]);
        await ethers.provider.send('evm_mine');
        }

        const futureTime = (10*86400) + 1;

        await advanceTimeAndBlock(futureTime);  

        await expect(NFTscalperContract.connect(accounts[USER])
        .TerminateRental(tokenId)).to.not.be.reverted;

    });

    // it.only("Should let the minter mint the rewards", 
    // async function(){


    // Testing passes when addMinted() (in rewards token) is not used.
    //     //Testing for tenant as the logic for the NFT owner is same.
    //     const tx_1 = await NFTscalperContract.connect(accounts[USER])
    //     .mint();
        
    //     await tx_1.wait();

    //     const tokenId = (await NFTscalperContract.connect(accounts[USER])
    //     .getCurrentMintedTokenId());

    //     await expect(NFTscalperContract.connect(accounts[DEPLOYER])
    //     .addTier("TIER_1"))
    //     .to.not.be.reverted;

    //     const tx_2 = await NFTscalperContract.connect(accounts[DEPLOYER])
    //     .setTierDetails("TIER_1",10,1,3);

    //     await tx_2.wait();

    //     await expect(NFTscalperContract.connect(accounts[USER])
    //     .makeNFTAvailableForRent(tokenId,"TIER_1"))
    //     .to.not.be.reverted;

    //     await expect(NFTscalperContract.connect(accounts[TENANT])
    //     .RentNFT(tokenId, accounts[TENANT].address, {value : ethers.utils.parseEther("3")}))
    //     .to.emit(NFTscalperContract,"RentPaid")
    //     .withArgs(tokenId, accounts[TENANT].address,ethers.utils.parseEther("3"));

    //     expect (await rewardContract.connect(accounts[DEPLOYER])
    //     .rewardSupply()).to.be.equal(ethers.utils.parseEther("10"));

       // // await expect(rewardContract.connect(accounts[DEPLOYER])    
      //  // .addMinter(accounts[TENANT].address)).to.not.be.reverted;

    //     await expect(NFTscalperContract.connect(accounts[TENANT])
    //     .claimRewardsForTenant(tokenId)).to.not.be.reverted;
    // });

    

});