// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/Address.sol";

contract BasicVar{
  using Address for address;
  uint256 public constant MAX = ~uint256(0);
  uint256 public constant CONSTNumber = 10**18;
  address public constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
  address public constant DEAD = 0x000000000000000000000000000000000000dEaD;
  address public constant WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
}