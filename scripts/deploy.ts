import hre from "hardhat";

async function main() {

  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0xA3C957B20779Abf06661E25eE361Be1430ef1038",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x79B861477012D127a9DE00CA8f0ceD28212aa954",
    weth9: "0x0Dc808adcE2099A9F62AA87D9670745AbA741746",
    v2Factory: "0x31a78894a2B5dE2C4244cD41595CD0050a906Db3",
  }]);
  
  await universalRouter.waitForDeployment();

  await universalRouter.setFeeBps(1, 0, 20);
  await universalRouter.setFeeBps(1, 1, 50);
  await universalRouter.setFeeBps(2, 0, 10);
  await universalRouter.setFeeBps(2, 1, 25);

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
