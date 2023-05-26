// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IRewardToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

    /// @title A Reward token contract.
    /// @notice You can use this contract if you want to use ERC20 tokens for rewards purpose.
    /// @dev all functions are implemented.

contract RewardToken is ERC20, IRewardToken,Ownable{



    address payable public contractOwner;
    uint256 internal cap;

    mapping(address => bool) minters;


    /// @notice will set the cap and rewards supply
    /// @dev will set the cap and rewards based on inputs.

   constructor(uint256 _cap, uint256 _rewardPercentage) ERC20("Reward Token", "RT") {
        require(_rewardPercentage <= 100, "Cant mint more than 100%");
        contractOwner = payable(msg.sender);
        cap = _cap * (10 ** decimals());
        uint256 tokensForOwner = cap - ((cap*_rewardPercentage)/100);
        _mint(contractOwner , tokensForOwner);
        minters[msg.sender] = true; // contract owner can also mint with this line of code for other user.
    }

    /// @dev will return the cap of the tokens

    function Cap() public view virtual override returns(uint256){
        return cap;
    }

    /// @dev will return the rewards supply
    function rewardSupply() public view virtual override returns(uint256){
        return (Cap() - totalSupply());
    }

    /// @dev will let the owner of the contracts add the minter.
    function addMinter(address _minter) public onlyOwner{
        minters[_minter] = true;
    }

    
    /// @dev will let the minters mint rewards 
    function _mintRewards(address _rewardsReceiver, uint256 rewards) public virtual override{
        require(minters[msg.sender], "You cannot mint the tokens because you are not authorized, please contact token owner to get authorized.");
        require(totalSupply() + rewards <= cap, "Exceeding the cap, please check!");
        _mint(_rewardsReceiver, rewards);
        emit RewardsMined(_rewardsReceiver, rewards);
    }

}

