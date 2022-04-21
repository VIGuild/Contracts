// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ReceiveEther {
  receive() external payable {}

  fallback() external payable {}

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
}