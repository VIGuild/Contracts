// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "../Convergence.sol";

interface IGAME {
  function transferNotify(
    address who,
    bool isBuy,
    uint256 amount
  ) external;
}

abstract contract DelayedReturns is Convergence {
  using SafeMath for uint256;

  mapping(address => uint256) public _proGenes;

  mapping(address => uint256) private _balancesDelayedA;
  mapping(address => uint256) private _balancesDelayedB;

  address[] private delayReceiver;
  bool private returning;
  bool private nowIsB;
  uint256 private setoff;

  function showDelayReceiver(address user)
    external
    view
    returns (
      bool,
      bool,
      uint256,
      uint256
    )
  {
    return (
      nowIsB,
      returning,
      _balancesDelayedA[user],
      _balancesDelayedB[user]
    );
  }

  function showDelayInfo()
    external
    view
    returns (
      bool,
      bool,
      uint256,
      uint256,
      uint256
    )
  {
    return (
      nowIsB,
      returning,
      _pairAmountLog,
      _transferAmountLog,
      _transferAmountLog > _pairAmountLog
        ? _transferAmountLog - _pairAmountLog
        : 0
    );
  }

  function setDelayedReturnsV1(
    bool feeModel,
    address user,
    uint256 tAmount
  ) internal {
    if (_transferAmountLog > _pairAmountLog && !returning) {
      returning = true;
      setoff = delayReceiver.length;
      if (nowIsB) nowIsB = false;
      else if (!nowIsB) nowIsB = true;
    }

    if (feeModel) {
      if (_proGenes[user] == 0) {
        delayReceiver.push(user);
      }

      if (nowIsB) _balancesDelayedB[user] += tAmount;
      else _balancesDelayedA[user] += tAmount;
    } else {
      uint256 deducted = tAmount.mul(10000).div(FEE);
      if (_balancesDelayedA[user] > deducted)
        _balancesDelayedA[user] -= deducted;
      else _balancesDelayedA[user] = 0;
      if (_balancesDelayedB[user] > deducted)
        _balancesDelayedB[user] -= deducted;
      else _balancesDelayedB[user] = 0;
    }
  }

  function setDelayedReturns(
    bool feeModel,
    address user,
    uint256 tAmount
  ) internal {
    if (!_dividendSwitch) {
      process();
      setDelayedReturnsV1(feeModel, user, tAmount);
    } else {
      //Any games，When the JUDGE balances is 0
      if (_viGAME != address(0))
        IGAME(_viGAME).transferNotify(user, feeModel, tAmount);
    }
    _proGenes[user] += tAmount;
  }

  function claimReturns(address user) internal returns (bool) {
    uint256 amount;
    if (nowIsB) {
      amount = _balancesDelayedA[user];
      if (amount > 0) _balancesDelayedA[user] = 0;
    } else {
      amount = _balancesDelayedB[user];
      if (amount > 0) _balancesDelayedB[user] = 0;
    }
    if (amount > 0) {
      if (_balances[JUDGE] > amount) {
        _balances[JUDGE] = _balances[JUDGE].sub(amount);
        _balances[user] += amount;
        emit Transfer(JUDGE, user, amount);
      } else {
        //Congratulations, we have evolved.
        _dividendSwitch = true; //Forever on
        returning = false; //Forever off
        return true;
      }
    }
    return false;
  }

  function process() public {
    if (!returning) return;
    uint256 gasUsed = 0;
    uint256 gasLeft = gasleft();
    while (gasUsed < _defaultGAS && setoff >= 0) {
      if (setoff == 0) {
        returning = false;
        _transferAmountLog = 1;
        _pairAmountLog = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
        return;
      }

      if (claimReturns(delayReceiver[setoff - 1])) return;
      setoff -= 1;
      gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
      gasLeft = gasleft();
    }
  }
}
