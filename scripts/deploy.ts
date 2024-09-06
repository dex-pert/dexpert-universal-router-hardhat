import hre from "hardhat";

async function main() {
  // bitlayer mainnet
  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0xB0Cc30795f9E0125575742cFA8e73D20D9966f81",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x9Ba604031d1a00EA253D777035C588C291881204",
    weth9: "0xfF204e2681A6fA0e2C3FaDe68a1B28fb90E4Fc5F",
    v2Factory: "0x1037E9078df7ab09B9AF78B15D5E7aaD7C1AfDd0",
    pairInitCodeHash: "0x309c1fab66254fa4cb99ebc7f83ec90232b605e2aa60f1b35ad8ea228cfa3c23"
  }]);
  await universalRouter.waitForDeployment();

  // await universalRouter.setFeeBps(1, 0, 20);
  // await universalRouter.setFeeBps(1, 1, 50);
  // await universalRouter.setFeeBps(2, 0, 10);
  // await universalRouter.setFeeBps(2, 1, 25);

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
