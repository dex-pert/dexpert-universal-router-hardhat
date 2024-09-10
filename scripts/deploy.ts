import hre from "hardhat";

async function main() {

  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0x82b56Dd9c7FD5A977255BA51B96c3D97fa1Af9A9",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x63cE9f1571C4660c77ae051390700bFcC76D0712",
    weth9: "0xdE41591ED1f8ED1484aC2CD8ca0876428de60EfF",
    v2Factory: "0x753df473702cB31BB81a93966e658e1AA4f10DD8",
  }],{
    maxPriorityFeePerGas: hre.ethers.parseUnits('25', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('50', 'gwei')
  });
  
  await universalRouter.waitForDeployment();

  await universalRouter.setFeeBps(1, 0, 20, {
    maxPriorityFeePerGas: hre.ethers.parseUnits('25', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('50', 'gwei')
  });
  await universalRouter.setFeeBps(1, 1, 50, {
    maxPriorityFeePerGas: hre.ethers.parseUnits('25', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('50', 'gwei')
  });
  await universalRouter.setFeeBps(2, 0, 10, {
    maxPriorityFeePerGas: hre.ethers.parseUnits('25', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('50', 'gwei')
  });
  await universalRouter.setFeeBps(2, 1, 25, {
    maxPriorityFeePerGas: hre.ethers.parseUnits('25', 'gwei'),
    maxFeePerGas: hre.ethers.parseUnits('50', 'gwei')
  });

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
