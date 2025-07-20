// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { HelperConfig2 } from "./HelperConfig2.s.sol";
import { FundMe2 } from "../src/FundMe2.sol";

contract DeployFundMe2 is Script {
    function run() external returns (FundMe2) {
        HelperConfig2 helperConfig = new HelperConfig2();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        FundMe2 fundMe2 = new FundMe2(ethUsdPriceFeed);
        vm.stopBroadcast() ;

        return fundMe2;
    }
}