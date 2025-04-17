// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract auctionCreator {
    Auction[] public auctions;

    function createAuction() public {
    Auction newAuction= new Auction(msg.sender);
    auctions.push(newAuction);
    }
}

contract Auction {
    address  payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash; //hash that stores the data of auction object in IPFS

    enum State {Started, Running, Ended, Canceled} 
    State public auctionState;

    uint public highestBindingBid;
    address payable public highestBidder;

    mapping (address => uint) bid;
    uint bidIncrement;

    constructor (address eoa) {
        owner = payable(eoa);
        auctionState= State.Running;
        startBlock= block.number;
        endBlock= startBlock + 3;
        ipfsHash= "";
        bidIncrement= 1000000000;
    }

    modifier notOwner (){
        require(owner != msg.sender);
        _;
    }

    modifier onlyOwner() {
        require(owner==msg.sender);
        _;
    }

    modifier afterStart{
        require(block.number >= startBlock);
        _;
    }

        modifier beforeEnd{
        require(block.number <= endBlock);
        _;
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a<=b ? a : b;
    }

    function cancelAuction() public onlyOwner {
        auctionState = State.Canceled;
    }

    function placeBid() public payable notOwner afterStart beforeEnd {
        require(auctionState == State.Running);
        require(msg.value >= 100);

        uint currentBid = bid[msg.sender]+msg.value;
    // Add this new bid to the sender's previous bids

        require(currentBid > highestBindingBid);
    // The new total bid must be higher than the highest binding bid

        bid[msg.sender]= currentBid;
    // Save or update the sender's total bid

        if(currentBid <= bid[highestBidder]){
        // If the bidder is not the highest, just raise the binding bid a little
            highestBindingBid= min(bid[highestBidder], bidIncrement + currentBid);
        } else {
        // If this is the new highest bid, update both binding bid and top bidder
            highestBindingBid= min(bid[highestBidder] + bidIncrement, currentBid);
            highestBidder= payable(msg.sender);
        }
    }

    function finalizeAuction() public {
        require(auctionState == State.Canceled || block.number > endBlock);
        require ( msg.sender == owner || bid[msg.sender] > 0);

        address payable recipient;
        uint value;

        if( auctionState == State.Canceled ){ //auction state is canceled 
        recipient= payable(msg.sender);
        value= bid[msg.sender];
        } else { //auction ended and not canceled 
            if(msg.sender == owner) { //this is the owner 
                recipient = owner;
                value = highestBindingBid;
            } else { // this is the bidder 
                if(msg.sender == highestBidder) {
                    recipient= highestBidder;
                    value= bid[highestBidder] - highestBindingBid;
                } else { // this is neither the owner not the higest bidder 
                recipient = payable (msg.sender);
                value= bid[msg.sender];
                }
            }
        }
        bid[recipient]=0;
        recipient.transfer(value);
    }
}