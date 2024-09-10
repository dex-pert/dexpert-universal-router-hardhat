// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

struct RouterParameters {
    address uniswapV2Router02;
    address feeRecipient;
    uint256 feeBaseBps;
    address permit2;
    address weth9;
    address v2Factory;
}
