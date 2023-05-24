// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./IRewardToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, IRewardToken,Ownable{

    address payable public contractOwner;
    uint256 public cap;

    mapping(address => bool) minters;

    //The deployer adds the cap of tokens and % of tokens reserved for rewards, the remaining token 
    //will be minted to contract owner.
   constructor(uint256 _cap, uint256 _rewardPercentage) ERC20("Reward Token", "RT") {
        contractOwner = payable(msg.sender);
        cap = _cap * (10 ** decimals());
        uint256 tokensForOwner = cap*(1 - (_rewardPercentage/100));
        _mint(contractOwner , tokensForOwner);
    }

    // To check this with Vijay
    //     function _mint(address account, uint256 amount) internal virtual override(ERC20Capped) {
    //     require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
    //     super._mint(account, amount);
    // }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override{
        super._beforeTokenTransfer(from, to, amount);
        if(from != address(0) && to != address(0))
        {
            _mintRewards(to, amount);
        }
        
    }

    //this function will add minter to the mapping so they can mint rewards.
    function addMinter(address _minter) public onlyOwner{
        minters[_minter] = true;
    }

    //The owner of the contract can mint the rewards to the NFT holder and NFT Tenant.
    //Question: How to prevent other ppl from minting the rewards.
    //one way to do this is:
    //import the NFTSCALPING file for this work around.
    //How to do it without importing NFTSCALPING.

    function _mintRewards(address _rewardsReceiver, uint256 rewards) public virtual override{
        require(minters[msg.sender], "You cannot mint the tokens because you are not authorized, please contact token owner to get authorized");
        require(totalSupply() + rewards <= cap, "Exceeding the cap, please check!");
        _mint(_rewardsReceiver, rewards);
    }

}

