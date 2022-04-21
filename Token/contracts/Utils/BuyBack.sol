// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "../Convergence.sol";

abstract contract BuyBack is Convergence {
  using SafeMath for uint256;
  function swapBackB(uint256 amountToSwap) internal{
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = WBNB;
    _swapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
      amountToSwap,
      0,
      path,
      DAPP,
      block.timestamp + 120
    );

    REFLEXE(DAPP).sendEx();
  }
}
