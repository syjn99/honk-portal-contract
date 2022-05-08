// SPDX-License_Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract HonkPortal {
  uint256 totalHonks;
  uint256 private seed;
  uint256 prizeAmount = 0.0001 ether;

  mapping (address => uint256) personalHonkCount;
  mapping (address => uint256) lastHonkedAt;
  mapping (address => bool) hasNickname;
  mapping (address => string) nicknames;

  event NewHonk(address indexed from, uint256 timestamp, string message);

  struct Honk {
    address honker;
    string message;
    uint256 timestamp;
  }

  Honk[] honks;

  constructor () payable {
    seed = (block.timestamp + block.difficulty) % 100;
  }

  function honk(string memory _message) public {
    require(lastHonkedAt[msg.sender] + 30 seconds < block.timestamp, "Please wait 30 seconds to honk again!");
    lastHonkedAt[msg.sender] = block.timestamp;

    totalHonks += 1;
    console.log("%s has honked w/ message %s", msg.sender, _message);
    personalHonkCount[msg.sender] += 1;

    honks.push(Honk(msg.sender, _message, block.timestamp));

    seed = (block.difficulty + block.timestamp + seed) % 100;
    console.log("Random # generated: %d", seed);

    if (seed <= 30) {
      console.log("%s won!", msg.sender);
      require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");
      (bool success, ) = (msg.sender).call{value: prizeAmount}("");
      require(success, "Failed to withdraw money from contract");
    }

    emit NewHonk(msg.sender, block.timestamp, _message);    
  }
 
  function getAllHonks() public view returns(Honk[] memory) {
    return honks;
  }

  function getTotalHonks() public view returns (uint256) {
    return totalHonks;
  }

  function getPersonalHonkCount(address _address) public view returns (uint256) {
    return personalHonkCount[_address];
  } 

  function getPrizeAmount() public view returns (uint256) {
    return prizeAmount;
  }

  function setPrizeAmount(uint256 _amount) public {
    prizeAmount = _amount;
  }
  
  function idGenerator() private returns (string memory) {
    bytes memory buffer = abi.encodePacked(bytes2(bytes20(msg.sender)));

    bytes memory id = new bytes(4);
    bytes memory _base = "0123456789abcdef";

    for (uint256 i = 0; i < 2; i++) {
      id[i * 2] = _base[uint8(buffer[i]) / _base.length];
      id[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
    }

    return string(id);
  }

  function getHasNickname(address _address) public view returns (bool) {
    return hasNickname[_address];
  }

  function registerNickname(string memory _nickname) public {
    require( !(hasNickname[msg.sender]), "You already have your own nickname!" );

    string memory id = idGenerator();
    _nickname = string(abi.encodePacked(_nickname, "#", id));
    nicknames[msg.sender] = _nickname;
    hasNickname[msg.sender] = true;
  }

  function changeNickname(string memory _nickname) public {
    require( hasNickname[msg.sender], "You don't have nickname yet!" );

    
    string memory id = idGenerator();
    _nickname = string(abi.encodePacked(_nickname, "#", id));

    require(keccak256(abi.encodePacked(_nickname)) != keccak256(abi.encodePacked(nicknames[msg.sender])), "Same nickname!!!");

    nicknames[msg.sender] = _nickname;
  }

  function getNickname(address _address) public view returns (string memory) {
    require(hasNickname[_address], "You don't have nickname yet!");
    return nicknames[_address];
  }
}