// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./IRewardToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20Capped, IRewardToken,Ownable{

    address payable public contractOwner;

    //The deployer adds the total supply of tokens and % of tokens reserved for rewards, the remaining token 
    //will be minted to contract owner.
   constructor(uint256 cap, uint256 _rewardPercentage) ERC20("Reward Token", "RT") ERC20Capped(cap * (10 ** decimals())) {

        contractOwner = payable(msg.sender);
        uint256 tokenForOwner = ERC20Capped.cap() - (ERC20Capped.cap()*_rewardPercentage/100);
        tokenForOwner *= (10 ** decimals());
        _mint(contractOwner , tokenForOwner);

    }

    // To check this.
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


    //The owner of the contract can mint the rewards to the NFT holder and NFT Tenant.
    function _mintRewards(address _rewardsReceiver, uint256 rewards) public virtual override onlyOwner{
        _mint(_rewardsReceiver, rewards);
    }

}

