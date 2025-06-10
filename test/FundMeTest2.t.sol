// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe2} from "../src/FundMe2.sol";


contract FundMeTest2 is Test {
    FundMe2 fundMe2;

    function setUp() external {
        fundMe2 = new FundMe2();
    }
    
    function testMinimumDollarIsFive2 () public view {
        assertEq(fundMe2.MINIMUM_USD() , 5e18);
    }
}