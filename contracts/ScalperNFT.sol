// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSCALPING.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ScalperNFT is NFTSCALPING {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(RewardToken _rewardTokens) NFTSCALPING("RentableNFTs", "RN", _rewardTokens) {}

    function mint() public {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _safeMint(msg.sender, newTokenId);
  }

  function set(uint256 _tokenId) public {
    if(NFTSCALPING._users[_tokenId].expiersOn < block.timestamp){
      NFTSCALPING.TerminateRental(_tokenId);
    }else{
      revert("This token is still on rent");
    }
  }

  



}