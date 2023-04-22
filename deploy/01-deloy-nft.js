const { network } = require("hardhat");
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  console.log("++++++++++++++++++++ 01-deploy-nft ++++++++++++++++++++++++");
  args = [];
  const basicNft = await deploy("BasicNFT", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API_KEY
  ) {
    console.log("Verifying !!");
    await verify(basicNft.address, args);
  }
  console.log("++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
};
module.exports.tags = ["all", "basicnft", "main"];
