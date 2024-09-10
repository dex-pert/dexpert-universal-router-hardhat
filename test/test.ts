import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import hre, { ethers } from "hardhat";
import Permi2ABI from "./abi/permi2.json";
import { RoutePlanner, CommandType } from './planner'
import Weth9ABI from "./abi/weth9.json";

const resetFork = async (block: number = 4559860) => {
  await hre.network.provider.request({
    method: 'hardhat_reset',
    params: [
      {
        forking: {
          jsonRpcUrl: `https://rpc.bitlayer.org`,
          blockNumber: block,
        },
      },
    ],
  })
}

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // await resetFork()
    const [owner, otherAccount]: any = await ethers.getSigners();

    const DexpertUniversalRouter = await hre.ethers.getContractFactory("DexpertUniversalRouter");
    const dexpertUniversalRouter = await DexpertUniversalRouter.deploy({
      uniswapV2Router02: "0xB0Cc30795f9E0125575742cFA8e73D20D9966f81",
      feeRecipient: "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
      feeBaseBps: 10000,
      permit2: "0x000000000022d473030f116ddee9f6b43ac78ba3",
      weth9: "0xfF204e2681A6fA0e2C3FaDe68a1B28fb90E4Fc5F",
      v2Factory: "0x1037E9078df7ab09B9AF78B15D5E7aaD7C1AfDd0",
    });

    await dexpertUniversalRouter.setFeeBps(1, 0, 20);
    await dexpertUniversalRouter.setFeeBps(1, 1, 50);
    await dexpertUniversalRouter.setFeeBps(2, 0, 10);
    await dexpertUniversalRouter.setFeeBps(2, 1, 25,)

    const permi2 = new hre.ethers.Contract("0x000000000022d473030f116ddee9f6b43ac78ba3", Permi2ABI.abi)
    const wethContract: any = new hre.ethers.Contract("0xfF204e2681A6fA0e2C3FaDe68a1B28fb90E4Fc5F", Weth9ABI)

    const planner = new RoutePlanner()
    return { dexpertUniversalRouter, permi2, wethContract, planner, owner, otherAccount };
  }

  describe("standardTokenFactory01", function () {
    it("level 0", async function () {
      const { dexpertUniversalRouter, permi2, wethContract, planner, owner, otherAccount } = await loadFixture(deployOneYearLockFixture);
      const amountIn: any = hre.ethers.parseEther("1")
      const DEADLINE = 2000000000
      await wethContract.connect(otherAccount).approve(dexpertUniversalRouter.target, amountIn)
      planner.addCommand(CommandType.V2_SWAP_EXACT_IN, [
        "0x7002421C457b83425293DE5a7BFEB68B01A6f693",
        amountIn,
        0,
        ["0xfF204e2681A6fA0e2C3FaDe68a1B28fb90E4Fc5F", "0xeB0fC98278655697ad8c28b80543B89b86937b7f"],
        true,
        1,
        0
      ])
      const { commands, inputs } = planner

      const receipt = await (await dexpertUniversalRouter['execute(bytes,bytes[],uint256)'](commands, inputs, DEADLINE)).wait()
      console.log("receipt:", receipt)
    });
  })
});
