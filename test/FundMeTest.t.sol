// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
   FundMe fundMe;

   function setUp() external {
      // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
   }

   function testMinimumDollarIsFive() public view {
      assertEq(fundMe.MINIMUN_USD(), 5e18);
   }

   function testOwnerIsSender() public view {
      assertEq(fundMe.i_owner(), msg.sender);
   }

   function testPriceFeedVersionIsAccurate() public view {
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
   }
}