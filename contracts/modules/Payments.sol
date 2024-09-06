// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {Constants} from '../libraries/Constants.sol';
import {PaymentsImmutables} from '../modules/PaymentsImmutables.sol';
import {SafeTransferLib} from '../libraries/SafeTransferLib.sol';
import {ERC20} from '../libraries/ERC20.sol';
import {ERC721} from '../libraries/ERC721.sol';
import {ERC1155} from '../libraries/ERC1155.sol';
import {Fee} from './Fee.sol';
import '../interfaces/IRouter02.sol';
import '../interfaces/IFactory.sol';

/// @title Payments contract
/// @notice Performs various operations around the payment of ETH and tokens
abstract contract Payments is PaymentsImmutables, Fee {
    using SafeTransferLib for ERC20;
    using SafeTransferLib for address;

    error InsufficientToken();
    error InsufficientETH();
    error InvalidBips();
    error InvalidSpender();
    error InvalidFeeType(uint256 feeType);
    error InvalidValue(uint256 value);

    uint256 internal constant FEE_BIPS_BASE = 10_000;

    function swapTokensForEth(address token, uint256 amount, uint256 feeAmount, uint256 level, uint256 swapType, uint256 feeBps) internal {
        if (feeAmount == 0) {
            return;
        }
        address feeToken = token;
        if (token == address(WETH9)) {
            ERC20(token).safeTransfer(FEE_RECIPIENT, feeAmount);
        } else {
            address _pair = factory.getPair(token, _router.WBTC());
            if (_pair == address(0x0)) {
                ERC20(token).safeTransfer(FEE_RECIPIENT, feeAmount);
            } else {
                ERC20(token).safeTransfer(address(this), feeAmount);
                uint256 beforeBalance = FEE_RECIPIENT.balance;
                address[] memory path = new address[](2);
                path[0] = token;
                path[1] = address(WETH9);
                ERC20(token).approve(address(_router), feeAmount);
                _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    feeAmount, 
                    0, 
                    path, 
                    FEE_RECIPIENT,
                    block.timestamp
                );
                uint256 afterBalance = FEE_RECIPIENT.balance;
                feeAmount = afterBalance - beforeBalance;
                feeToken = address(0);
            }
        }
        emit PaymentFee(msg.sender, token, amount, feeToken, feeAmount, level, swapType, feeBps, FEE_BASE_BPS);
    }

    /// @notice Pays an amount of ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive the payment
    /// @param value The amount to pay
    function pay(address token, address recipient, uint256 value, uint256 level, uint256 swapType) internal {
        if (token == Constants.ETH) {
            // Get the fee amount.
            // Note that the fee amount is rounded down in favor of the creator.
            uint256 feeBps = FEE_BPS[level][swapType];
            uint256 feeAmount;
            if (feeBps > 0) {
                feeAmount = (value * feeBps) / FEE_BASE_BPS;
            }
            uint256 payoutAmount;
            unchecked {
                payoutAmount = value - feeAmount;
            }

            // Transfer the fee amount to the fee recipient.
            if (feeAmount > 0) {
                FEE_RECIPIENT.safeTransferETH(feeAmount);
            }
            recipient.safeTransferETH(payoutAmount);
        } else {
            if (value == Constants.CONTRACT_BALANCE) {
                value = ERC20(token).balanceOf(address(this));
            }

            uint256 feeBps = FEE_BPS[level][swapType];
            uint256 feeAmount;
            if (feeBps > 0) {
                feeAmount = (value * feeBps) / FEE_BASE_BPS;
            }
            uint256 payoutAmount;
            unchecked {
                payoutAmount = value - feeAmount;
            }

            // Transfer the fee amount to the fee recipient.
            if (feeAmount > 0) {
                swapTokensForEth(token, value, feeAmount, level, swapType, feeBps);
            }

            ERC20(token).safeTransfer(recipient, payoutAmount);
        }
    }

    /// @notice Pays an amount of ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive the payment
    /// @param value The amount to pay fee
    function payFee(
        address token,
        address recipient,
        uint256 value,
        uint256 level, 
        uint256 swapType
    ) internal returns (uint256) {
        if (token == Constants.ETH) {
            uint256 feeBps = FEE_BPS[level][swapType];
            uint256 feeAmount;
            if (feeBps > 0) {
                feeAmount = (value * feeBps) / FEE_BASE_BPS;
            }

            uint256 payoutAmount;
            unchecked {
                payoutAmount = value - feeAmount;
            }

            if (feeAmount > 0) {
                FEE_RECIPIENT.safeTransferETH(feeAmount);
            }

            return payoutAmount;
        } else {
            if (value == Constants.CONTRACT_BALANCE) {
                value = ERC20(token).balanceOf(address(this));
            }

            uint256 feeBps = FEE_BPS[level][swapType];
            uint256 feeAmount;
            if (feeBps > 0) {
                feeAmount = (value * feeBps) / FEE_BASE_BPS;
            }

            uint256 payoutAmount;
            unchecked {
                payoutAmount = value - feeAmount;
            }

            if (feeAmount > 0) {
                swapTokensForEth(token, value, feeAmount, level, swapType, feeBps);
            }

            return payoutAmount;
        }
    }

    /// @notice TransferFrom an amount of ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param payer The address to pay for the transfer
    /// @param recipient The address that will receive the payment
    /// @param value The amount to pay
    function payFrom(address token, address payer, address recipient, uint256 value) internal {
        if (value <= 0) {
            revert InvalidValue(0);
        }

        ERC20(token).transferFrom(payer, recipient, value);
    }

    /// @notice Approves a protocol to spend ERC20s in the router
    /// @param token The token to approve
    /// @param spender Which protocol to approve
    function approveERC20(address token, address spender) internal {
        // check spender is one of our approved spenders
        if (spender == address(0)) {
            revert InvalidSpender();
        }
        // set approval
        ERC20(token).safeApprove(spender, type(uint256).max);
    }

    /// @notice Pays a proportion of the contract's ETH or ERC20 to a recipient
    /// @param token The token to pay (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive payment
    /// @param bips Portion in bips of whole balance of the contract
    function payPortion(address token, address recipient, uint256 bips) internal {
        if (bips == 0 || bips > FEE_BIPS_BASE) revert InvalidBips();
        if (token == Constants.ETH) {
            uint256 balance = address(this).balance;
            uint256 amount = (balance * bips) / FEE_BIPS_BASE;
            recipient.safeTransferETH(amount);
        } else {
            uint256 balance = ERC20(token).balanceOf(address(this));
            uint256 amount = (balance * bips) / FEE_BIPS_BASE;
            ERC20(token).safeTransfer(recipient, amount);
        }
    }

    /// @notice Sweeps all of the contract's ERC20 or ETH to an address
    /// @param token The token to sweep (can be ETH using Constants.ETH)
    /// @param recipient The address that will receive payment
    /// @param amountMinimum The minimum desired amount
    function sweep(address token, address recipient, uint256 amountMinimum) internal {
        uint256 balance;
        if (token == Constants.ETH) {
            balance = address(this).balance;
            if (balance < amountMinimum) revert InsufficientETH();
            if (balance > 0) recipient.safeTransferETH(balance);
        } else {
            balance = ERC20(token).balanceOf(address(this));
            if (balance < amountMinimum) revert InsufficientToken();
            if (balance > 0) ERC20(token).safeTransfer(recipient, balance);
        }
    }

    /// @notice Wraps an amount of ETH into WETH
    /// @param recipient The recipient of the WETH
    /// @param amount The amount to wrap (can be CONTRACT_BALANCE)
    function wrapETH(address recipient, uint256 amount, uint256 level, uint256 swapType) internal {
        if (amount == Constants.CONTRACT_BALANCE) {
            amount = address(this).balance;
        } else if (amount > address(this).balance) {
            revert InsufficientETH();
        }
        if (amount > 0) {
            WETH9.deposit{value: amount}();

            uint256 feeBps = FEE_BPS[level][swapType];
            uint256 feeAmount;
            if (feeBps > 0) {
                feeAmount = (amount * feeBps) / FEE_BASE_BPS;
            }

            uint256 payoutAmount;
            unchecked {
                payoutAmount = amount - feeAmount;
            }

            if (feeAmount > 0) {
                WETH9.transfer(FEE_RECIPIENT, feeAmount);
                emit PaymentFee(msg.sender, address(0), amount, address(0), feeAmount, level, swapType, feeBps, FEE_BASE_BPS);
            }
            if (recipient != address(this)) {
                WETH9.transfer(recipient, payoutAmount);
            }
        }
    }

    /// @notice Unwraps all of the contract's WETH into ETH
    /// @param recipient The recipient of the ETH
    /// @param amountMinimum The minimum amount of ETH desired
    function unwrapWETH9(address recipient, uint256 amountMinimum) internal {
        uint256 value = WETH9.balanceOf(address(this));
        if (value < amountMinimum) {
            revert InsufficientETH();
        }
        if (value > 0) {
            WETH9.withdraw(value);
            if (recipient != address(this)) {
                recipient.safeTransferETH(value);
            }
        }
    }
}
