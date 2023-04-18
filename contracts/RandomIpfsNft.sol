// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNft__RangeOutOfBounds();
error RandomIpfsNft__NeedMoreETHsent();
error RandomIpfsNft__TransferFailed();

contract RandomIpfsNft is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
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
  string[] internal s_vicharTokenUris;
  uint256 internal immutable i_mintFee;
  //Events
  event NftRequested(uint256 indexed requestId, address requester);
  event NftMinted(Version vicharVersion, address minter);

  constructor(
    address vrfCoordinatorV2,
    uint64 i_subscriptionId,
    bytes32 i_gasLane,
    uint32 i_callbackGasLimit,
    uint16 REQUEST_CONFIRMATIONS,
    uint32 NUM_WORDS,
    string[3] memory vicharTokenUris,
    uint256 mintFee
  ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
    i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_subscriptionId = subscriptionId;
    i_gasLane = gasLane;
    i_callbackGasLimit = callbackGasLimit;
    s_vicharTokenUris = vicharTokenUris;
    i_mintFee = mintFee;
  }

  function requestNft() public payable returns (uint256 requestId) {
    if (msg.value < i_mintFee) {
      revert RandomIpfsNft__NeedMoreETHsent();
    }
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
    _safeMint(vicharOwner, newTokenId);
    _setTokenURI(newTokenId, s_vicharTokenUris[uint256(vicharVersion)]);
    emit NftMinted(vicharVersion, vicharOwner);
  }

  function withdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    (bool success, ) = payable(msg.sender).call{value: amount}("");
    if (!success) {
      revert RandomIpfsNft__TransferFailed();
    }
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

  function getMintFee() public view returns (uint256) {
    return i_mintFee;
  }

  function getVicharTokenUris(
    uint256 index
  ) public view returns (string memory) {
    return s_vicharTokenUris[index];
  }

  function getTokenCounters() public view returns (uint256) {
    return s_tokenCounter;
  }
}
