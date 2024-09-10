import hre from "hardhat";

async function main() {

  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0xA16fC83947D26f8a16cA02DC30D95Af5440C38AD",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x31972B0F061591A764cA4572d6532659Ac2D7d70",
    weth9: "0x3e57d6946f893314324C975AA9CEBBdF3232967E",
    v2Factory: "0x8e8867CB4f2E4688ec1962d19A654a084659307c",
  }],{
    maxPriorityFeePerGas: hre.ethers.parseUnits('0.1', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('1', 'gwei')
  });
  
  await universalRouter.waitForDeployment();

  // await universalRouter.setFeeBps(1, 0, 20, {
  //   maxPriorityFeePerGas: hre.ethers.parseUnits('0.1', 'gwei'),
  //   maxFeePerGas: hre.ethers.parseUnits('1', 'gwei')
  // });
  // await universalRouter.setFeeBps(1, 1, 50, {
  //   maxPriorityFeePerGas: hre.ethers.parseUnits('0.1', 'gwei'),
  //   maxFeePerGas: hre.ethers.parseUnits('1', 'gwei')
  // });
  // await universalRouter.setFeeBps(2, 0, 10, {
  //   maxPriorityFeePerGas: hre.ethers.parseUnits('0.1', 'gwei'),
  //   maxFeePerGas: hre.ethers.parseUnits('1', 'gwei')
  // });
  // await universalRouter.setFeeBps(2, 1, 25, {
  //   maxPriorityFeePerGas: hre.ethers.parseUnits('0.1', 'gwei'),
  //   maxFeePerGas: hre.ethers.parseUnits('1', 'gwei')
  // });

  console.log(
    `deployed to ${universalRouter.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
