// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {V2SwapRouter} from '../modules/uniswap/v2/V2SwapRouter.sol';
import {BytesLib} from '../modules/uniswap/v2/BytesLib.sol';
import {Payments} from '../modules/Payments.sol';
import {PaymentsImmutables} from '../modules/PaymentsImmutables.sol';
import {Commands} from '../libraries/Commands.sol';
import {LockAndMsgSender} from './LockAndMsgSender.sol';
import {ERC20} from '../libraries/ERC20.sol';
import {IAllowanceTransfer} from '../interfaces/IAllowanceTransfer.sol';
import {ICryptoPunksMarket} from '../interfaces/external/ICryptoPunksMarket.sol';

/// @title Decodes and Executes Commands
/// @notice Called by the UniversalRouter contract to efficiently decode and execute a singular command
abstract contract Dispatcher is Payments, V2SwapRouter, LockAndMsgSender {
    using BytesLib for bytes;

    error InvalidCommandType(uint256 commandType);
    error BuyPunkFailed();
    error BalanceTooLow();
    event Permit2Error(int a);

    /// @notice Decodes and executes the given command with the given inputs
    /// @param commandType The command type to execute
    /// @param inputs The inputs to execute the command with
    /// @dev 2 masks are used to enable use of a nested-if statement in execution for efficiency reasons
    /// @return success True on success of the command, false on failure
    /// @return output The outputs or error messages, if any, from the command
    function dispatch(bytes1 commandType, bytes calldata inputs) internal returns (bool success, bytes memory output) {
        uint256 command = uint8(commandType & Commands.COMMAND_TYPE_MASK);

        success = true;

        if (command < Commands.FOURTH_IF_BOUNDARY) {
            if (command < Commands.SECOND_IF_BOUNDARY) {
                // 0x00 <= command < 0x08
                if (command < Commands.FIRST_IF_BOUNDARY) {
                    if (command == Commands.PERMIT2_TRANSFER_FROM) {
                        // equivalent: abi.decode(inputs, (address, address, uint160))
                        address token;
                        address recipient;
                        uint256 amount;
                        uint256 level;
                        uint256 swapType;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            amount := calldataload(add(inputs.offset, 0x40))
                            level := calldataload(add(inputs.offset, 0x60))
                            swapType := calldataload(add(inputs.offset, 0x80))
                        }
                        permit2TransferFrom(token, lockedBy, map(recipient), amount, level, swapType);
                    } else if (command == Commands.PERMIT2_PERMIT_BATCH) {
                        (IAllowanceTransfer.PermitBatch memory permitBatch,) =
                            abi.decode(inputs, (IAllowanceTransfer.PermitBatch, bytes));
                        bytes calldata data = inputs.toBytes(1);
                        PERMIT2.permit(lockedBy, permitBatch, data);
                    } else if (command == Commands.SWEEP) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint160 amountMin;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            amountMin := calldataload(add(inputs.offset, 0x40))
                        }
                        Payments.sweep(token, map(recipient), amountMin);
                    } else if (command == Commands.TRANSFER) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint256 value;
                        uint256 level;
                        uint256 swapType;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            value := calldataload(add(inputs.offset, 0x40))
                            level := calldataload(add(inputs.offset, 0x60))
                            swapType := calldataload(add(inputs.offset, 0x80))
                        }
                        Payments.pay(token, map(recipient), value, level, swapType);
                    } else if (command == Commands.TRANSFER_FROM) {
                        // equivalent:  abi.decode(inputs, (address, address, uint256))
                        address token;
                        address recipient;
                        uint256 value;
                        assembly {
                            token := calldataload(inputs.offset)
                            recipient := calldataload(add(inputs.offset, 0x20))
                            value := calldataload(add(inputs.offset, 0x40))
                        }
                        Payments.payFrom(token, lockedBy, map(recipient), value);
                    } else {
                        // placeholder area for command 0x07
                        revert InvalidCommandType(command);
                    }
                    // 0x08 <= command < 0x10
                } else {
                    if (command == Commands.V2_SWAP_EXACT_IN) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                        address recipient;
                        uint256 amountIn;
                        uint256 amountOutMin;
                        bool payerIsUser;
                        uint256 level;
                        uint256 swapType;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountIn := calldataload(add(inputs.offset, 0x20))
                            amountOutMin := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            level := calldataload(add(inputs.offset, 0xA0))
                            swapType := calldataload(add(inputs.offset, 0xC0))
                        }
                        address[] calldata path = inputs.toAddressArray(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v2SwapExactInput(map(recipient), amountIn, amountOutMin, path, payer, level, swapType);
                    } else if (command == Commands.V2_SWAP_EXACT_OUT) {
                        // equivalent: abi.decode(inputs, (address, uint256, uint256, bytes, bool))
                        address recipient;
                        uint256 amountOut;
                        uint256 amountInMax;
                        bool payerIsUser;
                        uint256 level;
                        uint256 swapType;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountOut := calldataload(add(inputs.offset, 0x20))
                            amountInMax := calldataload(add(inputs.offset, 0x40))
                            // 0x60 offset is the path, decoded below
                            payerIsUser := calldataload(add(inputs.offset, 0x80))
                            level := calldataload(add(inputs.offset, 0xA0))
                            swapType := calldataload(add(inputs.offset, 0xC0))
                        }
                        address[] calldata path = inputs.toAddressArray(3);
                        address payer = payerIsUser ? lockedBy : address(this);
                        v2SwapExactOutput(map(recipient), amountOut, amountInMax, path, payer, level, swapType);
                    } else if (command == Commands.PERMIT2_PERMIT) {
                        emit Permit2Error(0);
                        // equivalent: abi.decode(inputs, (IAllowanceTransfer.PermitSingle, bytes))
                        IAllowanceTransfer.PermitSingle calldata permitSingle;
                        assembly {
                            permitSingle := inputs.offset
                        }
                        emit Permit2Error(1);
                        bytes calldata data = inputs.toBytes(6); // PermitSingle takes first 6 slots (0..5)
                        emit Permit2Error(2);
                        PERMIT2.permit(lockedBy, permitSingle, data);
                    } else if (command == Commands.WRAP_ETH) {
                        // equivalent: abi.decode(inputs, (address, uint256))
                        address recipient;
                        uint256 amountMin;
                        uint256 level;
                        uint256 swapType;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountMin := calldataload(add(inputs.offset, 0x20))
                            level := calldataload(add(inputs.offset, 0x40))
                            swapType := calldataload(add(inputs.offset, 0x60))
                        }
                        Payments.wrapETH(map(recipient), amountMin, level, swapType);
                    } else if (command == Commands.UNWRAP_WETH) {
                        // equivalent: abi.decode(inputs, (address, uint256))
                        address recipient;
                        uint256 amountMin;
                        assembly {
                            recipient := calldataload(inputs.offset)
                            amountMin := calldataload(add(inputs.offset, 0x20))
                        }
                        Payments.unwrapWETH9(map(recipient), amountMin);
                    } else if (command == Commands.PERMIT2_TRANSFER_FROM_BATCH) {
                        (IAllowanceTransfer.AllowanceTransferDetails[] memory batchDetails) =
                            abi.decode(inputs, (IAllowanceTransfer.AllowanceTransferDetails[]));
                        permit2TransferFrom(batchDetails, lockedBy);
                    } else if (command == Commands.BALANCE_CHECK_ERC20) {
                        // equivalent: abi.decode(inputs, (address, address, uint256))
                        address owner;
                        address token;
                        uint256 minBalance;
                        assembly {
                            owner := calldataload(inputs.offset)
                            token := calldataload(add(inputs.offset, 0x20))
                            minBalance := calldataload(add(inputs.offset, 0x40))
                        }
                        success = (ERC20(token).balanceOf(owner) >= minBalance);
                        if (!success) output = abi.encodePacked(BalanceTooLow.selector);
                    } else {
                        // placeholder area for command 0x0f
                        revert InvalidCommandType(command);
                    }
                }
                // 0x10 <= command
            } else {
                revert InvalidCommandType(command);
            }
            // 0x20 <= command
        } else {
            if (command == Commands.EXECUTE_SUB_PLAN) {
                bytes calldata _commands = inputs.toBytes(0);
                bytes[] calldata _inputs = inputs.toBytesArray(1);
                (success, output) =
                    (address(this)).call(abi.encodeWithSelector(Dispatcher.execute.selector, _commands, _inputs));
            } else if (command == Commands.APPROVE_ERC20) {
                address token;
                address spender;
                assembly {
                    token := calldataload(inputs.offset)
                    spender := calldataload(add(inputs.offset, 0x20))
                }
                Payments.approveERC20(token, spender);
            } else {
                // placeholder area for commands 0x23-0x3f
                revert InvalidCommandType(command);
            }
        }
    }

    /// @notice Executes encoded commands along with provided inputs.
    /// @param commands A set of concatenated commands, each 1 byte in length
    /// @param inputs An array of byte strings containing abi encoded inputs for each command
    function execute(bytes calldata commands, bytes[] calldata inputs) external payable virtual;
}
