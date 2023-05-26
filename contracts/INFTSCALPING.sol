// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFTSCALPING {

    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    event RentPaid(uint256 indexed tokenId, address indexed user, uint256 rent);

    function checkWhoRentsNFT(uint256 tokenId) external view returns(address);

    function checkListedForRent(uint256 tokenId) external view returns(bool);

    function getTier() external view returns(string[] memory);

    // function addTier(string calldata _tier) external; this is onlyOwner
    
    function getTierDetails(string calldata _tier) external view returns(string memory, uint64, uint256, uint256);

    // function setTierDetails(string calldata _tier, uint64 _duration, uint256 _rewards, uint256 _rent) external; this function is onlyOwner

    function makeNFTAvailableForRent(uint256 tokenId, string calldata _tier) external;

    function detailsOfNFTListedForRent(uint256 tokenId) external view returns(uint256,string memory, uint64, uint256, uint256);

    // function withdrawEther() external payable; this function is onlyOwner.
    
    function payRent(uint256 tokenId) external payable;

    function forceEndTenure(uint256 tokenId) external;

    function RentNFT(uint256 tokenId, address tenant) external payable;

    function userOf(uint256 tokenId) external view returns(address, uint64);

    function TerminateRental(uint256 tokenId) external;

    function currentTime() external view returns(uint64);

    function claimRewardsForTenant(uint256 tokenId) external;

    function claimRewardsForOnwer(uint256 tokenId) external;




}
