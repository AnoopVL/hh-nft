const pinataSDK = require("@pinata/sdk");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

const pinataApiKey = process.env.PINATA_API_KEY;
const pinataApiSecret = process.env.PINATA_API_SECRET;
const pinata = pinataSDK(pinataApiKey, pinataApiSecret);

async function storeImages(imagesFilePath) {
  const fullImagesPath = path.resolve(imagesFilePath);
  const files = fs.readdirSync(fullImagesPath);
  let response = [];
  console.log("+++++++++++ Uploading to IPFS +++++++++++");
  for (fileIndex in files) {
    console.log(`Working on ${fileIndex} !!`);
    const readableStreamForFile = fs.createReadStream(
      `${fullImagesPath}/${files[fileIndex]}`
    );
    try {
      const response = await pinata.pinFileToIPFS(readableStreamForFile);
      responses.push(response);
    } catch (error) {
      console.log(error);
    }
  }
  return { responses, files };
}

module.exports = { storeImages };
