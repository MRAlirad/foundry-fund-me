// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18;

    // we want to keep track of all the people who send us money
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;

    address public i_owner;

    constructor(){
        i_owner = msg.sender; // owner is however deployed the contract
    }

    function fund() public payable {
        // Want to be able to set a minimum fund amount in USD
        // 1. How do we send ETH to this contract
        // we have to convert msg.value to usd equivalent in order to figure out if it is greate thant minimumUsd
        // require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough");
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough"); // msg.value acts like the first parameter of getConversionRate mehtod
        // msg.value has 18 decimal.

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner { 
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset the array
        funders = new address[](0);

        // send eth
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, 'Call Fails');
    }

    modifier onlyOwner {
        // only the owner of the contract can withdraw
        // require(msg.sender == i_owner, "Sender is not the owner!");

        // more gas efficient way
        if(msg.sender != i_owner) revert NotOwner();
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
