// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// token references
// reserves
// getReserves
// updateReserves
// swap

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "./LPToken.sol";

contract Pair is ERC20 {
    using SafeMath for uint256;

    address public factory;
    address public tokenA;
    address public tokenB;

    uint256 private reserveTokenA;
    uint256 private reserveTokenB;

    LPToken lpToken;

    constructor(address _tokenA, address _tokenB) ERC20("LPToken", "LPT") {
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

    function mint(address account, uint256 amount) public onlyFactory {
        _mint(account, amount);
        updateReserves();
    }

    function burn(address _to, uint256 _liquidity) public onlyFactory {
        uint256 totalSupply = reserveTokenA.add(reserveTokenB);
        console.log("totalSupply %s", totalSupply);
        require(_liquidity <= totalSupply, "Pair: Invalid amount burned");

        uint256 amountAToTransfer = _liquidity.mul(reserveTokenA).div(totalSupply);
        uint256 amountBToTransfer = _liquidity.mul(reserveTokenB).div(totalSupply);

        IERC20(tokenA).approve(address(this), amountAToTransfer);
        IERC20(tokenB).approve(address(this), amountBToTransfer);

        IERC20(tokenA).transferFrom(address(this), _to, amountAToTransfer);
        IERC20(tokenB).transferFrom(address(this), _to, amountBToTransfer);
        _burn(_to, _liquidity);
        updateReserves();
    }

    function swap(uint256 _amountTokenAOut, uint256 _amountTokenBOut, address _to) public {
        require(_amountTokenAOut > 0 || _amountTokenBOut > 0, "Pair: Invalid amount");
        require(_amountTokenAOut < reserveTokenA || _amountTokenBOut < reserveTokenB, "Pair: Insufficient reserve");

        if (_amountTokenAOut > 0) {
            IERC20(tokenA).transfer(_to, _amountTokenAOut);
        }
        if (_amountTokenBOut > 0) {
            IERC20(tokenB).transfer(_to, _amountTokenBOut);
        }

        uint256 balanceTokenA = IERC20(tokenA).balanceOf(address(this));
        uint256 balanceTokenB = IERC20(tokenB).balanceOf(address(this));

        //verify product constant formula, >= because the product won't be exactly equal due to precision loss
        require(balanceTokenA.mul(balanceTokenB) >= reserveTokenA.mul(reserveTokenB), "Product constant failed");

        updateReserves();
    }

    function getProductConstant() public view returns(uint256) {
        return reserveTokenA.mul(reserveTokenB);
    }
 
    modifier onlyFactory {
        require(msg.sender == factory, "Pair: Invalid caller");
        _;
    }
 }