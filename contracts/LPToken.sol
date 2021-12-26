// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract LPToken is ERC20{

    constructor() ERC20("Liquidity Provider Token", "LP") {
    }

    //TODO: Add modifier for permission
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    //TODO: Add modifier for permission
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }

}