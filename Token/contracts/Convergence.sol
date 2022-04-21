// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Basic/UniswapV2.sol";
import "./Basic/BasicVar.sol";

interface REFLEXE {
  function sendEx() external;
  function setFristReceiveAddress(address token) external;
}

abstract contract Convergence is BasicVar, IERC20, Context {
  using Address for address;

  mapping(address => uint256) internal _balances;
  mapping(address => bool) internal _managementMap;
  uint256 public _extrasSupply;
  uint256 internal _lpAmount;

  uint256 public _pairAmountLog;
  uint256 public _transferAmountLog = 0;

  address internal JUDGE;
  address internal DAPP;

  address public _viGAME;

  address internal _tokenSelf;
  address internal _token1;
  IUniswapV2Router02 internal _swapV2Router;
  address internal _swapV2Pair;

  uint256 public constant FEE = 900;
  uint256 public _defaultGAS = 500000;
  bool public _dividendSwitch;
  uint256 public _planSwap = 100;

  constructor() {
    _tokenSelf = address(this);
    _managementMap[_tokenSelf] = true;
    _managementMap[_msgSender()] = true;
    _managementMap[DEAD] = true;
  }
}
