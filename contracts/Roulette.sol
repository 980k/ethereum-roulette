// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./RandomNumber.sol";

contract Roulette {
    address payable public owner;
    address payable public player;
    address randomNumberGenerator;

    uint public totalWinnings;
    uint public gamesPlayed;

    mapping(address => uint) public depositedFunds;
    mapping(address => gameRound) public playerInput;

    struct gameRound {
        bool betOnRed;
        bool betOnBlack;
        bool betOnGreen;
        bool betPlaced;
        uint betSize;
    }

    constructor(address _randomNumberGenerator) {
        owner = payable(msg.sender);
        randomNumberGenerator = _randomNumberGenerator;
    }

    function depositOwnerFunds() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH");
        depositedFunds[msg.sender] += msg.value;
    }

    function withdrawFunds() external {
        require(playerInput[player].betPlaced == false);
        require(depositedFunds[msg.sender] > 0);

        uint256 funds = depositedFunds[msg.sender];
        depositedFunds[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: funds}("");
        require(success, "ETH transfer failed");
    }

    function placeBet(string memory _color) public payable {
        require(playerInput[player].betPlaced == false);
        require(msg.value >= 0.01 ether && msg.value < 0.1 ether, "Must send valid ETH amount");

        uint playerBetSize = msg.value;

        player = payable(msg.sender);

        depositedFunds[msg.sender] += playerBetSize;
        
        if(keccak256(abi.encodePacked(_color)) == keccak256(abi.encodePacked("red"))) {
            playerInput[msg.sender] = gameRound(true, false, false, true, playerBetSize);
        }
        else if(keccak256(abi.encodePacked(_color)) == keccak256(abi.encodePacked("black"))) {
            playerInput[msg.sender] = gameRound(false, true, false, true, playerBetSize);
        }
        else if(keccak256(abi.encodePacked(_color)) == keccak256(abi.encodePacked("green"))) {
            playerInput[msg.sender] = gameRound(false, false, true, true, playerBetSize);
        }
        else {
            revert();
        }
    }

    function getRandomNumber() public view returns (uint) {
        return RandomNumber(randomNumberGenerator).getRandomNumber();
    }

    function evaluateBet() public onlyOwner() {
        require(playerInput[player].betPlaced == true);

        uint randomNumber = getRandomNumber() % 37;

        if(randomNumber % 2 == 0 && randomNumber != 0 && playerInput[player].betOnRed == true) {
            depositedFunds[owner] -= playerInput[player].betSize;
            depositedFunds[player] += playerInput[player].betSize;
        }
        else if(randomNumber % 2 != 0 && randomNumber != 0 && playerInput[player].betOnBlack == true) {
            depositedFunds[owner] -= playerInput[player].betSize;
            depositedFunds[player] += playerInput[player].betSize;
        }
        else if(randomNumber == 0 && playerInput[player].betOnGreen == true) {
            depositedFunds[owner] -= (playerInput[player].betSize * 17);
            depositedFunds[player] += (playerInput[player].betSize * 16);
        }
        else {
            depositedFunds[owner] += playerInput[player].betSize;
            depositedFunds[player] -= playerInput[player].betSize;
        }

        totalWinnings = depositedFunds[player];
        gamesPlayed++;
        resetGameRound(player);
    }

    function resetGameRound(address user) private {
        playerInput[user] = gameRound(false, false, false, false, 0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}