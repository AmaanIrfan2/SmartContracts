// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    mapping (address => uint) public contributors;
    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public goal;
    uint public deadline;
    uint public raisedAmount;
    struct Request{
        string description;
        address payable recipient;
        uint noOfVoters;
        uint value;
        bool completed;
        mapping (address => bool) voters;
    }

    mapping (uint => Request) public requests; //mapping for a number to a request
    uint public numRequests; //tracks total number of requests created 

    constructor ( uint _goal,uint _deadline) {
        goal= _goal;
        deadline= block.timestamp + _deadline;
        admin = msg.sender;
        minimumContribution= 100 wei;
    }

    event ContributeEvent (address _sender, uint _value);
    event CreateRequestEvent(string _description, address recipient, uint value);
    event MakePaymentEvent(address _recipient, uint value);

    function contribute () payable public {
        require(block.timestamp < deadline);
        require(msg.value >= minimumContribution);

        if(contributors[msg.sender]==0){
            noOfContributors ++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount+= msg.value;

        emit ContributeEvent(msg.sender, msg.value);
    }

    receive() payable external {
       contribute() ;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp >= deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];

        contributors[msg.sender]= 0;
        recipient.transfer(value);
    }

    modifier onlyAdmin(){
        require(msg.sender == admin);
        _;
    }
    
    function createRequest (string memory _description, address payable _recipient, uint _value) public {
        Request storage newRequest= requests[numRequests];
        numRequests++;

        newRequest.description= _description;
        newRequest.recipient= _recipient;
        newRequest.value= _value;
        newRequest.completed= false;
        newRequest.noOfVoters= 0;

        emit CreateRequestEvent(_description, _recipient, _value);
    }

    function voteRequest(uint _requestNo) public {
        require(contributors[msg.sender] > 0);

        Request storage thisRequest = requests[_requestNo];

        require(thisRequest.voters[msg.sender] == false);
        thisRequest.voters[msg.sender]= true;
        thisRequest.noOfVoters++;
    }

    function makePayment(uint _requestNo) public onlyAdmin{
        require(raisedAmount>goal);
        Request storage thisRequest = requests[_requestNo];

        require(thisRequest.completed == false);
        require(thisRequest.noOfVoters > noOfContributors/2);

        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed= true;

        emit MakePaymentEvent(thisRequest.recipient, thisRequest.value);
    }
}