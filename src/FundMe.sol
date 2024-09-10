// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// 721,761
// 701,388

// custom error
error FundME__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUN_USD = 5e18;
    // 303 gas - constant
    // 2402 gas - non constant

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent
        // 1. How do we send ETH to this contract
        // require(getConversionRate(msg.value) >= minimunUsd, "didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUN_USD, "didn't send enough ETH"); // Using library
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);
        // actually withdraw the funds

        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");
        // // call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner!");
        // require(msg.sender == i_owner, NotOwner());
        if (msg.sender != i_owner) { revert FundME__NotOwner(); }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable { 
        fund();
    }
}