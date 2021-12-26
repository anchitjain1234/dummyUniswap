// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

//pair references
// add liquidity
// remove liquidity
// tradeAForB

import "./Pair.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract Factory {
    using SafeMath for uint256;
    mapping(address => mapping(address => address)) public getPair;

    address[] public allPairs;

    uint256 public numPairs;

    function addLiquidity(address _tokenA, address _tokenB, uint256 _amountOfADesired, uint256 _amountOfBDesired) 
        public returns(uint256 amountA, uint256 amountB) {
        
        //validate if pair exists
        if (getPair[_tokenA][_tokenB] == address(0)) {
            //create pair if no such pair exists
            createPair(_tokenA, _tokenB);

            //if the pair is created first time, set the amounts as desried
            (amountA, amountB) = (_amountOfADesired, _amountOfBDesired);
        } else {
            (uint256 reserveA, uint256 reserveB) = getReserves(_tokenA, _tokenB);
            // pair already exists, quote the amount to be put
            uint256 amountOfBOptimal = quote(_amountOfADesired, reserveA, reserveB);

            if (amountOfBOptimal <= _amountOfBDesired) {
                (amountA, amountB) = (_amountOfADesired, amountOfBOptimal);
            } else {
                uint256 amountOfAOptimal = quote(_amountOfBDesired, reserveB, reserveA);
                (amountA, amountB) = (amountOfAOptimal, _amountOfBDesired);
            }
        }

        //transfer tokens to the pair
        address pair = getPair[_tokenA][_tokenB];
        IERC20(_tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(_tokenB).transferFrom(msg.sender, pair, amountB);

        //update reserves
        Pair(pair).updateReserves();
    }

    function tradeBForA(uint256 _amountOfTokenA, uint256 _minTokensBToGet, address _tokenA, address _tokenB) public {
        (uint256 reserveA, uint256 reserveB) = getReserves(_tokenA, _tokenB);

        uint256 numerator = _amountOfTokenA.mul(reserveB);
        uint256 denominator = reserveA.add(_amountOfTokenA);
        uint256 amountOfBOut = numerator.div(denominator);

        require(amountOfBOut >= _minTokensBToGet, "Factory: Unable to get minimum tokens");

        address pair = getPair[_tokenA][_tokenB];
        IERC20(_tokenA).transferFrom(msg.sender, pair, _amountOfTokenA);
        Pair(pair).swap(uint256(0), amountOfBOut, msg.sender);
    } 

    function createPair(address _tokenA, address _tokenB) internal returns(address pair) {
        require(_tokenA != _tokenB, "Factory: Token addresses are equal");

        pair = address(new Pair(_tokenA, _tokenB));
        getPair[_tokenA][_tokenB] = pair;
        numPairs++;
        allPairs.push(pair);
    }

    function getReserves(address _tokenA, address _tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        address pair = getPair[_tokenA][_tokenB];
        (reserveA, reserveB) = Pair(pair).getReserves();
    }

    function quote(uint256 _amountA, uint256 _reserveA, uint256 _reserveB) internal pure returns(uint256 amountB) {
        require(_amountA > 0, "Factory: Invalid amount");
        require(_reserveA > 0, "Factory: Insufficient Liquidity");

        amountB = _amountA.mul(_reserveB).div(_reserveA);
    }
}