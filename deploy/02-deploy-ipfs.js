const { network } = require("hardhat");
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");
const storeImages = require("../utils/uploadToPinanta");

const imageLocation = "../images/randomNFT";

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  //we use pinata to upload our nfts
  //then we need to get the hashes of out nfts
  if (process.env.UPLOAD_TO_PINATA == "true") {
    tokenUris = await handleTokenUris();
  }

  let vrfCoordinatorV2Address, subscriptionId;

  if (developmentChains.includes(network.name)) {
    const vrfCoordinatorV2Mock = await ethers.getContract(
      "VRFCoordinatorV2Mock"
    );
    vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
    const tx = await vrfCoordinatorV2Mock.createSubscription();
    const txReceipt = await tx.wait(1);
    subscriptionId = txReceipt.events[0].args.subId;
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2;
    subscriptionId = networkConfig[chainId].subscriptionId;
  }

  console.log("++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  await storeImages("");
  // const args = [
  //   vrfCoordinatorV2Address,
  //   subscriptionId,
  //   networkConfig[chainId].gasLane,
  //   networkConfig[chainId].callbackGasLimit,
  //   //
  //   networkConfig[chainId].mintFee,
  // ];
};

async function handleTokenUris() {
  tokenUris = [];
  //store the image in IPFS
  //store the metadata in IPFS
  return tokenUris;
}

module.exports.tags = ["all", "randomipfs", "mocks"];
