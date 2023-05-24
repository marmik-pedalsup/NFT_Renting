// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./INFTSCALPING.sol";
import "./RewardToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTSCALPING is ERC721, INFTSCALPING, Ownable{
/*------------------------------------------------------------------------------------------------------------------------- */
    RewardToken rewardTokens;

    struct UserInfo 
    {
        uint256 tokenId;      // id of the NFT
        address tenant;      // address of user role
        string tier;        // tier name
        uint64 rentedOn;   // the day the nft was rented.
        uint64 expiersOn;  // duration for each tier,(expires after that)
        uint256 rewards; // rewards to get per-day, per-tier.
        uint256 rent;   // rent to be paid to rent the NFT, per-day, per-tier.
    }

    struct TierInfo{

        string tier;       // tier name
        uint64 duration;  // duration for each tier,(expires after that)
        uint256 rewards; // rewards to get per-day, per-tier.
        uint256 rent;   // rent to be paid to rent the NFT, per-day, per-tier.

    }

    string[] public Tiers;



    mapping (uint256 => UserInfo) internal _users;             // mapping of struct
    mapping (string => TierInfo) internal _tiersInfo;         // mapping of struct
    mapping (uint256 => string) internal _tierSelected;      //mapping to know which nft is under which tier.
    mapping (uint256 => address) internal _underRent;       // mapping to check which NFT is under rent by which tenant.
    mapping (uint256 => bool) internal _listedForRent;     // mapping to check id nft is listed for rent.
/*------------------------------------------------------------------------------------------------------------------------- */

    constructor(string memory name_, string memory symbol_, RewardToken _rewardTokens)

     ERC721(name_, symbol_)
     {
        rewardTokens = _rewardTokens; // this is the alias to the token contract.
     }

    
    
    //function to check who has rented the NFT
    function checkWhoRentsNFT(uint256 tokenId) public view  virtual override returns(address){
        return(_underRent[tokenId]);
    }

    //check if the NFT is listed for rent
    function checkListedForRent(uint256 tokenId) public view virtual override returns(bool){
        return(_listedForRent[tokenId]);
    }


    //This function is display all tiers available.
    function getTier() public view virtual override returns(string[] memory){
        return Tiers;
    }

    //This function will add tiers to the Tier array.
    function addTier(string calldata _tier) public onlyOwner{
        for(uint i = 0; i < Tiers.length; ++i)
        {
            if(keccak256(abi.encodePacked(_tier))!= keccak256(abi.encodePacked(Tiers[i]))){
                Tiers.push(_tier);
                break;
            }
            else{
                continue;
            }
        }
    }

    //This function will display the details of the tier, must input the name of the tier,
    function getTierDetails(string calldata _tier) public view virtual override returns(string memory, uint64, uint256, uint256){
        TierInfo memory tierinfo = _tiersInfo[_tier];

        return(tierinfo.tier, tierinfo.duration,tierinfo.rewards,tierinfo.rent);

    }


    //This function will set the details of the tier.
    function setTierDetails(string calldata _tier, uint64 _duration, uint256 _rewards, uint256 _rent) public onlyOwner
    {
        for(uint i = 0; i < Tiers.length; ++i)
        {
            if(keccak256(abi.encodePacked(_tier)) == keccak256(abi.encodePacked(Tiers[i])))
            {
                TierInfo storage tierinfo = _tiersInfo[_tier];
                tierinfo.tier = _tier;
                tierinfo.duration = uint64(_duration * 86400);
                tierinfo.rewards = _rewards * (10 ** 18);
                tierinfo.rent = _rent * (10 ** 18);
                break;
            }
            else{
                continue;
            }
        }
    }

    //This function will put the nft on rent, takes input from user, NFT id and tier name.
    function putOnRentNFT(uint256 tokenId, string calldata _tier) public virtual override{
        require(ERC721._exists(tokenId), "The NFT does not exist");
        require(_underRent[tokenId] == address(0), "The NFT is already under rent");
        require(!_listedForRent[tokenId], "The NFT is already listed");
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        for(uint i = 0; i < Tiers.length; ++i){
            if(keccak256(abi.encodePacked(_tier)) == keccak256(abi.encodePacked(Tiers[i]))){

                _listedForRent[tokenId] = true;
                _tierSelected[tokenId] = _tier;
                break;

            }
            else{
                continue;
            }
        }

    }

    //This function will display the details of NFTs on rent. 
    function detailsOfNFTListedForRent(uint256 tokenId) public view virtual override returns(string memory, uint64, uint256, uint256){
        require(ERC721._exists(tokenId), "The NFT does not exist");
        require(_listedForRent[tokenId], "This token Id is not on listed yet, try another one");
        TierInfo memory tierinfo = _tiersInfo[_tierSelected[tokenId]];

        return(tierinfo.tier, tierinfo.duration, tierinfo.rewards, tierinfo.rent);

    }

    function withdrawEther() public payable onlyOwner{
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send ether to the rightful owner");
    }

    fallback() external payable{}
    receive() external payable{}

    function _puttingUserOnRent(uint256 tokenId, address tenant) internal{

        TierInfo memory tierinfo = _tiersInfo[_tierSelected[tokenId]];
        UserInfo storage info =  _users[tokenId];
        
        info.tokenId = tokenId;
        info.tenant = tenant;
        info.tier = tierinfo.tier;
        info.rentedOn = uint64(block.timestamp);
        info.expiersOn = uint64(block.timestamp + tierinfo.duration - 1 days);
        //Question: What if the user rents the NFT at 23:59:59?
        info.rewards = tierinfo.rewards;
        info.rent = tierinfo.rent;

        _listedForRent[tokenId] = false;
        _underRent[tokenId] = tenant;

        
        emit UpdateUser(tokenId, tenant, info.expiersOn);
    }

    function _removeFromRent(uint256 tokenId) internal 
        {
         UserInfo storage info = _users[tokenId];

            info.tokenId = 0;
            info.tenant = address(0);
            info.tier = "";
            info.rentedOn = 0;
            info.expiersOn = 0;
            info.rewards = 0;
            info.rent = 0;          


            _listedForRent[tokenId] = true;
            _underRent[tokenId] = address(0);

            emit UpdateUser(tokenId, info.tenant, info.expiersOn);

    }

    //This function is used to pay rent, must be called by the person who wants to rent the NFT. Must be called to pay the rent everyday
    function payRent(uint256 tokenId) public payable virtual override{
        require(msg.sender == _underRent[tokenId],"Rent has to be paid by the tenant");
        require(_users[tokenId].expiersOn >= block.timestamp, "No need to play rent, tenure is over");
        require(msg.value == _users[tokenId].rent, "Not enough ETH sent");
        emit RentPaid(tokenId, _underRent[tokenId], msg.value);
    }

    //This function will remove the user from rent.
    function endTenure(uint256 tokenId) public  virtual override{
        require(_isApprovedOrOwner(msg.sender,tokenId), "Not the owner or approved individual");
        _removeFromRent(tokenId);
    }


    //This function will set the user on rent
    function RentNFT(uint256 tokenId, address tenant) public payable virtual override{
        //Question: If solidity function cannot execute automatically then, how to set rent payment to happen everyday.
        require(_listedForRent[tokenId], "This NFT is not listed for rent");
        require(_underRent[tokenId] == address(0),"This NFT is rented by someone");
        // require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        
        if(msg.sender == tenant){
            require(msg.value == _users[tokenId].rent, "Not enough ETH sent");
            _puttingUserOnRent(tokenId, tenant);
            emit RentPaid(tokenId, tenant, _users[tokenId].rent);
        }
        else{
            if(_isApprovedOrOwner(msg.sender, tokenId)){
                _puttingUserOnRent(tokenId, tenant);
            }
            else{
                revert("Not the appropriate user");
            }
        }

        
    }

    //This function will return the tenant the nft.
    function userOf(uint256 tokenId) public view virtual override returns(address, uint64){
        require(_underRent[tokenId] != address(0), "This NFT is not rented by anyone yet");
        if( uint256(_users[tokenId].expiersOn) >=  block.timestamp){
            return (_users[tokenId].tenant , _users[tokenId].expiersOn);
        }
        else{
            return (address(0), 0);
        }
    }

    //This is an internal function which updates the values upon expiry.
    function TerminateRental(uint256 tokenId) public virtual override{
            require(msg.sender == _users[tokenId].tenant || _isApprovedOrOwner(msg.sender, tokenId),"Cannot call this function");
            require(_users[tokenId].expiersOn <= block.timestamp,"This NFT is still on rent");
            _removeFromRent(tokenId);
        }
    //This function will return the current time.
    function currentTime() public view virtual override returns(uint64){
        return uint64(block.timestamp);
    }

    //This function will claim rewards for the tenant, only tenant can call.
    function claimRewardsForTenant(uint256 tokenId) public payable virtual override{
        require(msg.sender == _underRent[tokenId], "Not the tenant of the NFT");  
        require(_users[tokenId].expiersOn < block.timestamp, "Your tenure has expired, cannot claim rewards");

        if(_users[tokenId].expiersOn >= block.timestamp){
                uint256 rewards = _users[tokenId].rewards * (_users[tokenId].rentedOn - block.timestamp);
                rewardTokens._mintRewards(msg.sender , rewards);
        }
    }

    //This function will claim rewards for the owner of NFT, only the Owner and Approved user can claim the rewards.
    function claimRewardsForOnwer(uint256 tokenId) public payable virtual override{
        require(_isApprovedOrOwner(msg.sender,tokenId), "You are not the owner/approved person of this NFT");
        require(_users[tokenId].expiersOn < block.timestamp, "Your NFT has expired, cannot claim rewards");

        if(_users[tokenId].expiersOn >= block.timestamp){
            uint256 rewards = _users[tokenId].rewards * (_users[tokenId].rentedOn - block.timestamp);
            rewardTokens._mintRewards(ERC721.ownerOf(tokenId), rewards);
        }

    }


    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(INFTSCALPING).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual{
        super._beforeTokenTransfer(from, to, tokenId ,1);

        if (from != to && _users[tokenId].tenant != address(0)) {
            delete _users[tokenId];
            emit UpdateUser(tokenId, address(0), 0);
        }
    }
}