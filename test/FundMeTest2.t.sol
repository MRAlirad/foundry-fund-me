// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test, console } from "forge-std/Test.sol";
import { FundMe2 } from "../src/FundMe2.sol";
import { DeployFundMe2 } from "../script/DeployFundMe2.s.sol";


contract FundMeTest2 is Test {
    FundMe2 fundMe2;

    function setUp() external {
        // fundMe2 = new FundMe2('0x694AA1769357215DE4FAC081bf1f309aDC325306');
        DeployFundMe2 deployer = new DeployFundMe2();
        fundMe2 = deployer.run();
    }

    function testMinimumDollarIsFive2 () public view {
        assertEq(fundMe2.MINIMUM_USD() , 5e18);
    }

    function testOwnerIsMsgSender2() public view {
        assertEq(fundMe2.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate2() public view {
        if (block.chainid == 11155111) {
            uint256 version = fundMe2.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe2.getVersion();
            assertEq(version, 6);
        }
    }
}