// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery{
    address payable[] players; //list of players who have entered the lottery
    address public manager; // Person who deployed the contract

    constructor () {
        manager= msg.sender; //the deployer becomes the lottery manager
    }

    //The one who sends money gets added to the players list
    receive() external payable { 
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }

    //Lets anyone see how much total Ether is in the pot
    function getBalance() public view returns (uint){
        require(msg.sender==manager);
        return address(this).balance;
    }

    function random() public view returns (uint){
        return uint(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender)));
    }

    function pickWinner() public{
        require(players.length>3);
        require(msg.sender==manager);

        uint r = random();
        address payable winner;

        uint index= r % players.length;
        winner = players[index];

        winner.transfer(getBalance());
        players= new address payable[](0);
    }
}