// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

// Command implementations
import {Dispatcher} from './base/Dispatcher.sol';
import {RouterParameters} from './base/RouterImmutables.sol';
import {PaymentsImmutables, PaymentsParameters} from './modules/PaymentsImmutables.sol';
import {UniswapImmutables, UniswapParameters} from './modules/uniswap/UniswapImmutables.sol';
import {Commands} from './libraries/Commands.sol';
import {IDexpertUniversalRouter} from './interfaces/IDexpertUniversalRouter.sol';
import {Ownable} from './libraries/Ownable.sol';
import {Fee, FeeParameters} from './modules/Fee.sol';

contract DexpertUniversalRouter is IDexpertUniversalRouter, Dispatcher, Ownable {

    event FeeRecipientUpdated(address indexed msgSender, address feeRecipient);
    event FeeBpsUpdated(address indexed msgSender, uint256 level, uint256 swapType, uint256 feeBps);
    event FeeBaseBpsUpdated(address indexed msgSender, uint256 feeBaseBps);

    error InvalidFeeBps(uint256 feeBps);
    error InvalidFeeBaseBps(uint256 feeBaseBps);
    error FeeRecipientAddressCannotBeZeroAddress();

    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert TransactionDeadlinePassed();
        _;
    }

    constructor(RouterParameters memory params)
        UniswapImmutables(
            UniswapParameters(params.v2Factory)
        )
        PaymentsImmutables(PaymentsParameters(params.permit2, params.weth9))
        Fee(FeeParameters(params.feeRecipient, params.feeBaseBps, params.uniswapV2Router02)) 
    {}

    /// @inheritdoc IDexpertUniversalRouter
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline)
        external
        payable
        checkDeadline(deadline)
    {
        execute(commands, inputs);
    }

    /// @inheritdoc Dispatcher
    function execute(bytes calldata commands, bytes[] calldata inputs) public payable override isNotLocked {
        bool success;
        bytes memory output;
        uint256 numCommands = commands.length;
        if (inputs.length != numCommands) revert LengthMismatch();

        // loop through all given commands, execute them and pass along outputs as defined
        for (uint256 commandIndex = 0; commandIndex < numCommands;) {
            bytes1 command = commands[commandIndex];

            bytes calldata input = inputs[commandIndex];

            (success, output) = dispatch(command, input);

            if (!success && successRequired(command)) {
                revert ExecutionFailed({commandIndex: commandIndex, message: output});
            }

            unchecked {
                commandIndex++;
            }
        }
    }

    function successRequired(bytes1 command) internal pure returns (bool) {
        return command & Commands.FLAG_ALLOW_REVERT == 0;
    }

    function feeRecipient() external view returns (address) {
        return FEE_RECIPIENT;
    }

    function feeBps(uint256 level, uint256 swapType) external view returns (uint256) {
        return FEE_BPS[level][swapType];
    }

    function feeBaseBps() external view returns (uint256) {
        return FEE_BASE_BPS;
    }

    function setFeeRecipient(address feeRecipient) external onlyOwner {
        if (feeRecipient == address(0)) {
            revert FeeRecipientAddressCannotBeZeroAddress();
        }
        FEE_RECIPIENT = feeRecipient;
         emit FeeRecipientUpdated(msg.sender, feeRecipient);
    }

    function setFeeBps(uint256 level, uint256 swapType, uint256 feeBps) external onlyOwner {
        if (feeBps > FEE_BASE_BPS) {
            revert InvalidFeeBps(feeBps);
        }
        FEE_BPS[level][swapType] = feeBps;
        emit FeeBpsUpdated(msg.sender, level, swapType, feeBps);
    }

     function setFeeBaseBps(uint256 feeBaseBps) external onlyOwner {
        if (feeBaseBps < 1000) {
            revert InvalidFeeBaseBps(feeBaseBps);
        }
        FEE_BASE_BPS = feeBaseBps;
         emit FeeBaseBpsUpdated(msg.sender, feeBaseBps);
    }

    /// @notice To receive ETH from WETH and NFT protocols
    receive() external payable {}
}
