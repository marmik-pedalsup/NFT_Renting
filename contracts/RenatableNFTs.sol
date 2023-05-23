// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC4907.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RentableNFTs is ERC4907 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(RewardToken _rewardTokens) ERC4907("RentableNFTs", "RN", _rewardTokens) {}

    function mintNFT() public {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _safeMint(msg.sender, newTokenId);
  }



}