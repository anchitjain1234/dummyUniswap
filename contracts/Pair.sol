// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// token references
// reserves
// getReserves
// updateReserves
// swap

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
contract Pair {

    address public factory;
    address public tokenA;
    address public tokenB;

    uint256 private reserveTokenA;
    uint256 private reserveTokenB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        factory = msg.sender;
    }

    function getReserves() public view returns(uint256 reserveA, uint256 reserveB) {
        reserveA = reserveTokenA;
        reserveB = reserveTokenB;
    }

    function updateReserves() public onlyFactory {
        reserveTokenA = IERC20(tokenA).balanceOf(address(this));
        reserveTokenB = IERC20(tokenB).balanceOf(address(this));
    }

    function swap() public {
        //TODO
    }
 
    modifier onlyFactory {
        require(msg.sender == factory, "Pair: Invalid caller");
        _;
    }
 }