// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "../Convergence.sol";

library BollingerBandslib {
  function getBollingerBands20(uint256[] memory sequence)
    internal
    pure
    returns (
      uint256 smaBand,
      uint256 lowerBand,
      uint256 upperBand
    )
  {
    uint256 sum = 0;
    for (uint256 j; j < sequence.length; j++) sum = sum + sequence[j];
    smaBand = sum / uint256(sequence.length);

    uint256 standardDeviation = getStandardDeviation(smaBand, sequence);
    if (smaBand > (standardDeviation * uint256(2)))
      lowerBand = smaBand - (standardDeviation * uint256(2));
    else lowerBand = (smaBand * 80) / 100;
    upperBand = smaBand + (standardDeviation * uint256(2));
  }

  function getStandardDeviation(uint256 sMA, uint256[] memory sequence)
    internal
    pure
    returns (uint256)
  {
    uint256 sum = 0;
    for (uint256 j; j < sequence.length; j++) {
      if (sMA == sequence[j]) continue;
      uint256 x = sMA > sequence[j] ? sMA - sequence[j] : sequence[j] - sMA;
      sum += (x * x);
    }
    return sqrt(sum / 20);
  }

  function sqrt(uint256 x) internal pure returns (uint256 y) {
    uint256 z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
    return y;
  }
}

abstract contract BollingerBands is Convergence {
  using SafeMath for uint256;

  uint256 internal lastLogTime;
  uint256 private bollsetoff;
  uint256[] internal history;
  bool public powerSwitches;
  uint256 public UNITTIME = 365;
  uint256 public BASECATE = 50;
  uint256 public MAXCATE = 90;
  uint256 public UPUNIT = 5;
  uint256 public catalysts = BASECATE;

  function showHistory() external view returns (uint256[] memory) {
    return history;
  }

  function showBollData()
    external
    view
    returns (
      uint256 price,
      uint256 sMABand,
      uint256 lowerBand,
      uint256 upperBand
    )
  {
    uint256 balance0 = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
    uint256 balance1 = IERC20(_token1).balanceOf(_swapV2Pair).mul(CONSTNumber);
    price = balance1.div(balance0);
    if (history.length >= 20) {
      (sMABand, lowerBand, upperBand) = BollingerBandslib.getBollingerBands20(
        history
      );
    }
  }

  function getShouldLogNewData() internal returns (uint256, bool) {
    if (block.timestamp - lastLogTime >= UNITTIME) {
      uint256 balance0 = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
      uint256 balance1 =
        IERC20(_token1).balanceOf(_swapV2Pair).mul(CONSTNumber);
      uint256 tmpSequence = balance1.div(balance0);

      (uint256 sMABand, uint256 lowerBand, uint256 upperBand) =
        BollingerBandslib.getBollingerBands20(history);

      if (tmpSequence >= upperBand) {
        if (powerSwitches) powerSwitches = false;
        else if (catalysts < MAXCATE) {
          catalysts += UPUNIT;
        }
      } else if (tmpSequence <= lowerBand) {
        if (!powerSwitches) powerSwitches = true;
        else if (catalysts < MAXCATE) {
          catalysts += UPUNIT;
        }
      } else if (!powerSwitches && tmpSequence <= sMABand) {
        if (catalysts != BASECATE) catalysts = BASECATE;
      } else if (powerSwitches && tmpSequence >= sMABand) {
        if (catalysts != BASECATE) catalysts = BASECATE;
      }

      history[bollsetoff] = tmpSequence;
      bollsetoff += 1;
      if (bollsetoff == 20) bollsetoff = 0;
      lastLogTime = block.timestamp;
    }
    return (catalysts, powerSwitches);
  }
}
