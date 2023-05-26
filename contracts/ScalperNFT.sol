// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTSCALPING.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ScalperNFT is NFTSCALPING {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 internal newTokenId;

    constructor(RewardToken _rewardTokens) NFTSCALPING("RentableNFTs", "RN", _rewardTokens) {}

    /// @dev this function will let the minter mint the NFT, the minting starts from 1 instead of 0, meaning the first NFT will have the id of 1.
    function mint() public {
      _tokenIds.increment();
      newTokenId = _tokenIds.current();
      ERC721._safeMint(msg.sender, newTokenId);
  }


  /// @dev this funciton will return the current minted token.
  function getCurrentMintedTokenId() public view returns(uint256){
    return newTokenId;
  }

  /// @dev this function wil check if the NFT is on rent or not, if not will remove the NFT from tenure, but is only called by the NFT owner.
  /// which is checked in the NFTSCALPING contract.
  function set(uint256 _tokenId) public {
    if(NFTSCALPING._users[_tokenId].expiersOn < block.timestamp){
      NFTSCALPING.TerminateRental(_tokenId);
    }else{
      revert("This token is still on rent");
    }
  }
}