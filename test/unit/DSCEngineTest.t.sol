// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// imports
    import {Test} from "forge-std/Test.sol";
    import {DeployDSC} from "script/DeployDSC.s.sol";
    import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
    import {DSCEngine} from "src/DSCEngine.sol";
    import {HelperConfig} from "script/HelperConfig.s.sol";

// contracts
contract DSCEngineTest is Test {

// variables
    DeployDSC deployer;
    DecentralizedStableCoin dsc;
    DSCEngine dsce;
    HelperConfig config;
    
// constructor
    constructor() {
        
    }

// functions
    function setUp() public {
        deployer = new DeployDSC();
        (dsc,dsce,config) = deployer.run();
    }

// price feed tests
    function testGetUsdValue() public {

    }
}