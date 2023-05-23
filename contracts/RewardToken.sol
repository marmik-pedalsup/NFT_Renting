// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "./IRewardToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, IRewardToken,Ownable{

    //The deployer adds the total supply of tokens and % of tokens reserved for rewards, the remaining token 
    //will be minted to contract owner.
   constructor(uint256 _cap, uint256 _rewardPercentage) ERC20("Reward Token", "RT") ERC20Capped(_cap * (10 ** decimals())) {
        
        uint256 tokenForOwner = _cap - (_cap*_rewardPercentage/100);
        tokenForOwner *= (10 ** decimals());
        _mint(msg.sender , tokenForOwner);

    }

    //The owner of the contract can mint the rewards to the NFT holder and NFT Tenant.
    function _mintRewards(address _rewardsReceiver, uint256 rewards) public virtual override onlyOwner{
        _mint(_rewardsReceiver, rewards);
    }

}

