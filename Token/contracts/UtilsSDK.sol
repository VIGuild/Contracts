// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./Utils/BuyBack.sol";
import "./Utils/BollingerBands.sol";
import "./Utils/DelayedReturns.sol";

abstract contract UtilsSDK is 
BuyBack,
DelayedReturns,
BollingerBands
{}
