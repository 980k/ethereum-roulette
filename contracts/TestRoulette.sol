// SPDX-License-Identifier: MIT
// Test roulette contract used for unit testing.
pragma solidity ^0.8.16;

import "./Roulette.sol";
import "./RandomNumber.sol";

contract TestRoulette is Roulette {

    // Placeholder Address
    address emptyAddress = 0x0000000000000000000000000000000000000000;

    uint testNumber;

    constructor() Roulette(emptyAddress) {
        owner = payable(msg.sender);
    }

    // Getter Methods
    function getPseudoRandomNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(owner, block.timestamp)));
    }
 
    function getNumber() public view returns(uint) {
        return testNumber;
    }
    
    function getBetOnRed() public view returns(bool red) {
        return playerInput[player].betOnRed;
    }

    function getBetOnBlack() public view returns(bool black) {
        return playerInput[player].betOnBlack;
    }

    function getBetOnGreen() public view returns(bool green) {
        return playerInput[player].betOnGreen;
    }

    function getBetPlaced() public view returns(bool bet) {
        return playerInput[player].betPlaced;
    }

    function getBetSize() public view returns(uint size) {
        return playerInput[player].betSize;
    }
    
    // Setter Methods
    function setNumber(uint256 number) public {
        testNumber = number;
    }    
}