// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

contract TokenA is ERC20{

    constructor() ERC20("TokenA", "TKA") {
        _mint(msg.sender, 1000 * 10**18);
    }

}