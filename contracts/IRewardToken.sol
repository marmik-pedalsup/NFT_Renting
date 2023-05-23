// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewardToken is IERC20{

    function _mintRewards(address _rewardsReceiver, uint256 rewards) external;
}