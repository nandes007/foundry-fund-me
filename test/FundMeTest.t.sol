// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
   FundMe fundMe;

   address USER = makeAddr("user");
   uint256 constant SEND_VALUE = 0.1 ether; // 1000000000000000000
   uint256 constant STARTING_VALUE = 10 ether;

   function setUp() external {
      // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(USER, STARTING_VALUE);
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

   function testFundFailsWithoutEnoughETH() public {
      vm.expectRevert(); // This will revert next line
      fundMe.fund();
   }

   function testFundUpdatesFundedDataStructure() public {
      vm.prank(USER); // The next TX will be sent by USER
      fundMe.fund{value: SEND_VALUE}();

      uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
      assertEq(amountFunded, SEND_VALUE);
   }

   function testAddsFunderToArrayOfFunders() public {
      vm.prank(USER);
      fundMe.fund{value: SEND_VALUE}();

      address funder = fundMe.getFunder(0);
      assertEq(funder, USER);
   }

   modifier funded() {
      vm.prank(USER);
      fundMe.fund{value: SEND_VALUE}();
      _;
   }
   
   function testOnlyOwnerCanWithdraw() public funded {
      vm.expectRevert();
      fundMe.withdraw();
   }
}