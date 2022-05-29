pragma solidity 0.8.7;

import "./Ownable.sol";

contract plasmalab is Ownable {

   uint chamber;

   uint256 private constant allPlasmaCirculating = 120_096_000_000;
   uint16 constant private newChamber = 1;
   uint32 constant private plasmaDailyRate = 86400;
   uint32 constant private chamberCost = 1209600;
   uint16 private constant CALONE = 10000;
   uint16 private constant CALTWO = 5000;
   uint256 private realRate;
   uint256 private lastRun;

   address plasmaaddress;

   mapping(address => uint256) balance;
   mapping(address => uint256) chambers;
   mapping(address => uint256) storedplasma;
   mapping(address => uint256) plasmapending;
   mapping(address => address) referrals;

   
   function createChamber() public onlyOwner {
      chambers[msg.sender] += newChamber;
   }

   function referralChamber(address referrer) public {
   // referral system bones
   }

   function buyChamber(uint256 quantity) public {
      require(storedplasma[msg.sender] >= 1209600);
      
      uint256 chamberPurchase = (quantity * chamberCost);
      storedplasma[msg.sender] -= chamberPurchase;
      chambers[msg.sender] += quantity;

   }
   function createPlasma(uint256 amount) public onlyOwner {
      storedplasma[msg.sender] = storedplasma[msg.sender] += amount;

   }
   function deposit () public payable {
   
   }

   function checkPlasma(address target) public view returns (uint256) {
    return storedplasma[target];
   }
   function checkChambers(address target) public view returns (uint256) {
    return chambers[target];
   }

   function AllPlasmaInAddress(address adr) public view returns (uint256) {
      return storedplasma[adr] + pendingPlasma(adr);
   }
   function calculatePlasma(uint256 rt, uint256 rs, uint256 bs) private pure returns (uint256) {
      return (CALONE * bs) / (CALTWO + (((rs * CALONE ) + (rt + CALTWO)) / rt ));

      }


   function pendingPlasma(address adr) public view returns (uint256) { // Store timestamp when I want user to start accumulate plasma
      return min(chamberCost, block.timestamp - plasmapending[adr]) * chambers[adr];
      //This isn't necessarily the most efficient solution. First of all, 
      //there is no way to run a piece of code at any given time, it's the nature of evm development.
       //Secondly, as you have more users owning more chambers, thus more plasma to distribute, 
       //you are going to have an infinitely growing gas cost of actually doing the distribution. 
       //Eventually, you'll reach a gas limit.

      //The better way is to store the time stamp of when you want the user to start accumulating plasma, 
      //then make them call a redeem function that takes another timestamp, finds the difference between 
      //the two, and does a calculation off of that
   }

   function redeemPlasma() external {
      uint256 allOwnedPlasma = AllPlasmaInAddress(msg.sender);
      uint256 plasmaValue = plasmaOut(allOwnedPlasma);
      plasmapending[msg.sender] = block.timestamp;
      payable(msg.sender).transfer(plasmaValue);
   }
   function plasmaOut(uint256 plasma) public view returns (uint256) {
      return calculatePlasma(plasma, allPlasmaCirculating, address(this).balance);
   
   }
   function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}