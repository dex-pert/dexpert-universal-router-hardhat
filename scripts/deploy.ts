import hre from "hardhat";

async function main() {

// conflux testnet
  // const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
  //   uniswapV2Router02: "0x7C9BBd6c84D882574898Ce193Ba3caDa6B1DCB49",
  //   feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
  //   feeBaseBps: 10000,
  //   permit2: "0x208931C00a31c2C3d0e313d4434DDAEF260a3510",
  //   weth9: "0x981B2eFF0F890ef6319879284a49A81c149bc770",
  //   v2Factory: "0x822935C2240E6A0b5C96E3eA355446a83ed12C03",
  //   pairInitCodeHash: "0x404378a6d60ea6e02ec90b01c6984d452d0741e8305040d2348a0e6a5183509d"
  // }]);
  //conflux mainnet
  // const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
  //   uniswapV2Router02: "0x62b0873055Bf896DD869e172119871ac24aEA305",
  //   feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
  //   feeBaseBps: 10000,
  //   permit2: "0xCe2a41B655f9180F02f47DD591c359dae12C043e",
  //   weth9: "0x14b2D3bC65e74DAE1030EAFd8ac30c533c976A9b",
  //   v2Factory: "0xE2a6F7c0ce4d5d300F97aA7E125455f5cd3342F5",
  //   pairInitCodeHash: "0xe9013b07c22e5f47a6c477cffbbef5afdb24c90dedb1e8eacd17963f07186901"
  // }]);
  // bitlayer mainnet
  const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
    uniswapV2Router02: "0xB0Cc30795f9E0125575742cFA8e73D20D9966f81",
    feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
    feeBaseBps: 10000,
    permit2: "0x31972B0F061591A764cA4572d6532659Ac2D7d70",
    weth9: "0xfF204e2681A6fA0e2C3FaDe68a1B28fb90E4Fc5F",
    v2Factory: "0x1037E9078df7ab09B9AF78B15D5E7aaD7C1AfDd0",
    pairInitCodeHash: "0x309c1fab66254fa4cb99ebc7f83ec90232b605e2aa60f1b35ad8ea228cfa3c23"
  }]);
  // bitlayer testnet
  // const universalRouter = await hre.ethers.deployContract("DexpertUniversalRouter", [{
  //   uniswapV2Router02: "0xA16fC83947D26f8a16cA02DC30D95Af5440C38AD",
  //   feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
  //   feeBaseBps: 10000,
  //   permit2: "0x31972B0F061591A764cA4572d6532659Ac2D7d70",
  //   weth9: "0x3e57d6946f893314324C975AA9CEBBdF3232967E",
  //   v2Factory: "0x8e8867CB4f2E4688ec1962d19A654a084659307c",
  //   pairInitCodeHash: "0x309c1fab66254fa4cb99ebc7f83ec90232b605e2aa60f1b35ad8ea228cfa3c23"
  // }]);
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
