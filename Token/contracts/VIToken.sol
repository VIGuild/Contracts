// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./ERC20.sol";
import "./Basic/ReceiveEther.sol";

/***

 __      _______    _____ _    _ _____ _      _____  
 \ \    / /_   _|  / ____| |  | |_   _| |    |  __ \ 
  \ \  / /  | |   | |  __| |  | | | | | |    | |  | |
   \ \/ /   | |   | | |_ | |  | | | | | |    | |  | |
    \  /   _| |_  | |__| | |__| |_| |_| |____| |__| |
     \/   |_____|  \_____|\____/|_____|______|_____/ 
                                                                                            
*/

contract Vi is ERC20, ReceiveEther {
  constructor(
    address V,
    address i,
    uint256 G,
    uint256 U,
    uint8 L,
    uint256 D
  ) ERC20("VI GUILD", "VI", L, D * 10**4) {
    JUDGE = V;
    DAPP = i;
    initTransferByRatio(_msgSender(), G);
    initTransferByRatio(JUDGE, U);

    _token1 = WBNB;
    _swapV2Router = IUniswapV2Router02(ROUTER);
    _swapV2Pair = IUniswapV2Factory(_swapV2Router.factory()).createPair(
      _tokenSelf,
      _token1
    );

    _approve(_tokenSelf, address(_swapV2Router), totalSupply());
    _approve(_msgSender(), address(_swapV2Router), totalSupply());
    _approve(_msgSender(), _tokenSelf, totalSupply());
    _approve(JUDGE, _tokenSelf, totalSupply());
    _managementMap[JUDGE] = true;
    _managementMap[DAPP] = true;
    REFLEXE(DAPP).setFristReceiveAddress(_tokenSelf);
  }
}
