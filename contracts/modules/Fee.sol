// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {IWETH9} from '../interfaces/external/IWETH9.sol';
import {IAllowanceTransfer} from '../interfaces/IAllowanceTransfer.sol';
import {ERC20} from '../libraries/ERC20.sol';
import '../interfaces/IUniswapV2Router02.sol';
import '../interfaces/IUniswapV2Factory.sol';

struct FeeParameters {
    address feeRecipient;
    uint256 feeBaseBps;
    address uniswapV2Router02;
}

contract Fee {
    /// @dev fee recipient address
    address internal FEE_RECIPIENT;

    /// @dev fee bps
    mapping(uint256 => mapping(uint256 => uint256)) internal FEE_BPS;

    /// @dev fee base
    uint256 internal FEE_BASE_BPS;

    IUniswapV2Router02 internal _router;

    IUniswapV2Factory internal factory;

    event PaymentFee(
        address payer,
        address tokenIn,
        uint256 amountIn, 
        address feeToken,
        uint256 feeAmount, 
        uint256 level, 
        uint256 swapType, 
        uint256 feeBps, 
        uint256 feeBaseBps
    );

    constructor(FeeParameters memory params) {
        FEE_RECIPIENT = params.feeRecipient;
        FEE_BASE_BPS = params.feeBaseBps;
        _router = IUniswapV2Router02(params.uniswapV2Router02);
        factory = IUniswapV2Factory(_router.factory());
    }
}
