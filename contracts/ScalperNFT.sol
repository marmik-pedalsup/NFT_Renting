// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSCALPING.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ScalperNFT is NFTSCALPING {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 internal newTokenId; //added for testing...

    constructor(RewardToken _rewardTokens) NFTSCALPING("RentableNFTs", "RN", _rewardTokens) {}

    function mint() public {
      _tokenIds.increment();
      newTokenId = _tokenIds.current();
      ERC721._safeMint(msg.sender, newTokenId);
  }


  //added this for testing.... can be removed later.
  function getCurrentMintedTokenId() public view returns(uint256){
    return newTokenId;
  }

  function set(uint256 _tokenId) public {
    if(NFTSCALPING._users[_tokenId].expiersOn < block.timestamp){
      NFTSCALPING.TerminateRental(_tokenId);
    }else{
      revert("This token is still on rent");
    }
  }
}