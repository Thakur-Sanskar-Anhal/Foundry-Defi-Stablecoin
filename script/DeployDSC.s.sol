// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// imports
    import {Script} from "forge-std/Script.sol";
    import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
    import {DSCEngine} from "src/DSCEngine.sol";
    import {HelperConfig} from "script/HelperConfig.s.sol";

// contract
contract DeployDSC is Script {
    
// variables
    address[] public tokenAddresses;
    address[] public priceFeedAddresses;

// constructor

// functions
    function run() external returns (DecentralizedStableCoin, DSCEngine, HelperConfig) {
        HelperConfig config = new HelperConfig();
        (address wethUsdPriceFeed, address wbtcUsdPriceFeed, address weth, address wbtc, uint256 deployerkey) =
            config.activeNetworkConfig();

        tokenAddresses = [weth, wbtc];
        priceFeedAddresses = [wethUsdPriceFeed, wbtcUsdPriceFeed];

        vm.startBroadcast(deployerkey);
        DecentralizedStableCoin dsc = new DecentralizedStableCoin();
        DSCEngine engine = new DSCEngine(tokenAddresses, priceFeedAddresses, address(dsc));
        dsc.transferOwnership(address(engine));
        vm.stopBroadcast();
        
        return (dsc, engine, config);
    }
}
