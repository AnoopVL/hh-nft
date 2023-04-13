// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

error RandomIpfsNft__RangeOutOfBounds();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721 {
  //type declaration
  enum Version {
    LATEST,
    RETRO,
    FIRST
  }
  VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
  uint64 private immutable i_subscriptionId;
  bytes32 private immutable i_gasLane;
  uint32 private immutable i_callbackGasLimit;
  uint16 private constant REQUEST_CONFIRMATIONS = 3;
  uint32 private constant NUM_WORDS = 1;
  //VRF variables
  mapping(uint256 => address) public s_requestIdToSender;
  //NFT variables
  uint256 public s_tokenCounter;
  uint256 internal constant MAX_CHANCE_VALUE = 100;

  constructor(
    address vrfCoordinatorV2,
    uint64 i_subscriptionId,
    bytes32 i_gasLane,
    uint32 i_callbackGasLimit,
    uint16 REQUEST_CONFIRMATIONS,
    uint32 NUM_WORDS
  ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_subscriptionId = subscriptionId;
    i_gasLane = gasLane;
    i_callbackGasLimit = callbackGasLimit;
  }

  function requestNft() public returns (uint256 requestId) {
    requestId = i_vrfCoordinator.requestRandomWords(
      i_gasLane,
      i_subscriptionId,
      REQUEST_CONFIRMATIONS,
      i_callbackGasLimit,
      NUM_WORDS
    );
    s_requestIdToSender[requestId] = msg.sender;
  }

  function fullfilRandomWords(
    uint256 requestId,
    uint256[] memory randomWords
  ) internal override {
    address vicharOwner = s_requestIdToSender[requestId];
    uint256 newTokenId = s_tokenCounter;

    uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
    Version vicharVersion = getVersionfromModdedRng(moddedRng);
    _safeMint(vicharOwner, s_tokenCounter);
  }

  function getVersionfromModdedRng(
    uint256 moddedRng
  ) public pure returns (Version) {
    uint256 cumulativeSum = 0;
    uint256[3] memory chanceArray = getChanceArray();
    for (uint256 i = 0; i < chanceArray.length; i++) {
      if (
        moddedRng <= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]
      ) {
        return Version(i);
      }
      cumulativeSum += chanceArray[i];
    }
    revert RandomIpfsNft__RangeOutOfBounds();
  }

  function getChanceArray() public pure returns (uint256[3] memory) {
    return [10, 30, MAX_CHANCE_VALUE];
    //index 0 has 10% , 1 has 30-10 = 20% and index 2 has 100-(30+10)= 60% chance
  }

  function tokenURI(uint256) public view override returns (string memory) {}
}
