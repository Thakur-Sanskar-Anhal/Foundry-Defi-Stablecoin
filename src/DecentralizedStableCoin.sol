// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title DecentralizedStableCoin
 * @author Sanskar Anhal
 * Collateral: Exogenous (ETH & BTC)
 * Minting: Algorithmic
 * Relative Stability: Pegged to USD (1:1)
 */

// imports
import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// contract
contract DecentralizedStableCoin is ERC20Burnable, Ownable {
    // constants

    // variables

    // errors
    error DecentralizedStableCoin__MustBeMoreThanZera();
    error DecentralizedStableCoin__BurnAmountExceedsBalance();
    error DecentralizedStableCoin__NotZeroAddress();

    // constructor
    constructor() ERC20("Decentralized Stable Coin", "DSC") {}

    // functions
    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZera();
        }
        if (balance < _amount) {
            revert DecentralizedStableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert DecentralizedStableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert DecentralizedStableCoin__MustBeMoreThanZera();
        }
        _mint(_to, _amount);
        return true;
    }
}
