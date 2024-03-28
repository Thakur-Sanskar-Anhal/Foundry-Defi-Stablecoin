// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract Handler is Test {
    DecentralizedStableCoin dsc;
    DSCEngine dsce;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 public timesMintIsCalled;
    address[] public userWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSITE_SIZE = type(uint96).max;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;
        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    function mintDsc(uint256 amount, uint256 addressSeed) public {
        if (userWithCollateralDeposited.length == 0) {
            return;
        }
        address sender = userWithCollateralDeposited[addressSeed % userWithCollateralDeposited.length];
        (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);
        int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);
        if (maxDscToMint < 0) {
            return;
        }
        amount = bound(amount, 0, uint256(maxDscToMint));
        if (amount == 0) {
            return;
        }
        vm.startPrank(sender);
        dsce.mintDsc(amount);
        vm.stopPrank();
        timesMintIsCalled++;
    }

    function depositCollateral(uint256 collateralSeed, uint256 ammountCollateral) public {
        // dsce.depositCollateral(collateral, ammountCollateral);
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);

        ammountCollateral = bound(ammountCollateral, 1, MAX_DEPOSITE_SIZE);
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, ammountCollateral);
        collateral.approve(address(dsce), ammountCollateral);
        dsce.depositCollateral(address(collateral), ammountCollateral);
        vm.stopPrank();
        userWithCollateralDeposited.push(msg.sender);
    }

    function redeemCollateral(uint256 collaterSeed, uint256 amountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collaterSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
        amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
        if (amountCollateral == 0) {
            return;
        }
        dsce.redeemCollateral(address(collateral), amountCollateral);
    }

    function updateCollateralPrice(uint256 newPrice) public {
        int256 newPriceInt = int256(uint256(newPrice));
        ethUsdPriceFeed.updateAnswer(newPriceInt);
    }

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
