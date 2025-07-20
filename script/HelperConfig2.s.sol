// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { MockV3Aggregator } from "../test/mock/MockV3Aggregator.sol";
import {Script, console2} from "forge-std/Script.sol";

contract HelperConfig2 is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    NetworkConfig public activeNetworkConfig;
    
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }
    
    constructor() {
        if(block.chainid == 11155111)
            activeNetworkConfig = getSepoliaEthConfig();
        else
            activeNetworkConfig = getAnvilEthConfig();
    }
    
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH / USD
        });
    }
    
    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
    }
}