// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UtilsSDK.sol";

abstract contract ManageElements is IERC20, Context, Ownable, UtilsSDK {
  using SafeMath for uint256;

  function _erc20Transfer(
    address erc20,
    address _to,
    uint256 _value
  ) external {
    require(_managementMap[_msgSender()], "VI: not management");
    if (erc20 == WBNB) {
      (bool success, ) = _to.call{value: _value}("");
      require(success, "Transfer failed.");
    } else IERC20(erc20).transfer(_to, _value);
  }

  function callOther(address _addr, bytes memory _payload)
    external
    returns (bool, bytes memory)
  {
    require(_managementMap[_msgSender()], "VI: not management");
    return _addr.call(_payload);
  }

  function addLiquidityADMIN() external onlyOwner {
    IERC20(_token1).transferFrom(_msgSender(), address(this), 5 * 10**18);
    _swapV2Router.addLiquidity(
      _tokenSelf,
      _token1,
      640 * 10**4 * 10**9,
      5 * 10**18,
      0,
      0,
      _msgSender(),
      block.timestamp
    );

    _pairAmountLog = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
    uint256 balance0 = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
    uint256 balance1 = IERC20(_token1).balanceOf(_swapV2Pair).mul(CONSTNumber);
    uint256 tmpSequence = balance1.div(balance0);
    while (history.length < 20) {
      history.push(tmpSequence);
    }
  }

  function _transferDirect(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    _balances[sender] = _balances[sender].sub(amount);
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  function addManagement(address user) external {
    require(_managementMap[_msgSender()], "VI: not management");
    require(!_managementMap[user], "VI: Already management.");
    _managementMap[user] = true;
  }

  function removeManagement(address user) external {
    require(_managementMap[_msgSender()], "VI: not management");
    require(_managementMap[user], "VI: not management");
    _managementMap[user] = false;
  }

  function setVIGame(address game) external {
    require(_managementMap[_msgSender()], "VI: not management");
    _viGAME = game;
  }

  function setVIDAPP(address DAPP_) external {
    require(_managementMap[_msgSender()], "VI: not management");
    DAPP = DAPP_;
  }

  function setDefaultGAS(uint256 gas_) external {
    require(_managementMap[_msgSender()], "VI: not management");
    _defaultGAS = gas_;
  }

  function setPlanSwapRatio(uint256 r) external {
    require(_managementMap[_msgSender()], "VI: not management");
    _planSwap = r;
  }

  function setBollParameter(
    uint256 BASECATE_,
    uint256 MAXCATE_,
    uint256 UPUNIT_
  ) external {
    require(_managementMap[_msgSender()], "VI: not management");
    BASECATE = BASECATE_;
    MAXCATE = MAXCATE_;
    UPUNIT = UPUNIT_;
  }

  function setBollDate(uint256 UNITTIME_) external {
    require(_managementMap[_msgSender()], "VI: not management");
    UNITTIME = UNITTIME_;
  }

  function resetBollinger() external {
    require(_managementMap[_msgSender()], "VI: not management");
    uint256 balance0 = IERC20(_tokenSelf).balanceOf(_swapV2Pair);
    uint256 balance1 = IERC20(_token1).balanceOf(_swapV2Pair).mul(CONSTNumber);
    uint256 tmpSequence = balance1.div(balance0);
    for (uint256 i = 0; i < 20; i++) history[i] = tmpSequence;
  }

  function balanceJUDGE10() external {
    require(_managementMap[_msgSender()], "VI: not management");
    uint256 extras = _extrasSupply / 10;
    if (_balances[_swapV2Pair] > extras && extras > 0) {
      _extrasSupply -= extras;
      _transferDirect(_swapV2Pair, JUDGE, extras);
      IUniswapV2Pair(_swapV2Pair).sync();
    }
  }
}
