import hre from "hardhat";

async function main() {

  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0x7C9BBd6c84D882574898Ce193Ba3caDa6B1DCB49",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x208931C00a31c2C3d0e313d4434DDAEF260a3510",
    weth9: "0x981B2eFF0F890ef6319879284a49A81c149bc770",
    v2Factory: "0x822935C2240E6A0b5C96E3eA355446a83ed12C03",
    pairInitCodeHash: "0x404378a6d60ea6e02ec90b01c6984d452d0741e8305040d2348a0e6a5183509d"
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
