// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
 
// The Cryptos Token Contract
contract Cryptos is ERC20Interface {
    string public name = "Cryptos";
    string public symbol = "CRPT";
    uint public decimals = 0;
    uint public override totalSupply;
    
    address public founder;
    mapping(address => uint) public balances;
    // Example: balances[0x1111...] = 100;
    
    mapping(address => mapping(address => uint)) allowed;
    // Example: allowed[0x111][0x222] = 100;
    
    constructor(){
        totalSupply = 1000000;
        founder = msg.sender;
        balances[founder] = totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view override returns (uint balance){
        return balances[tokenOwner];
    }
    
    function transfer(address to, uint tokens) public virtual override returns(bool success){
        require(balances[msg.sender] >= tokens, "Insufficient balance");
        
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public view override returns(uint){
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens, "Insufficient balance for approval");
        require(tokens > 0, "Token amount must be greater than zero");
        
        allowed[msg.sender][spender] = tokens;
        
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){
         // Corrected: Check the allowance for msg.sender, not "to"
         require(allowed[from][msg.sender] >= tokens, "Allowance too low");
         require(balances[from] >= tokens, "Balance too low");
         
         balances[from] -= tokens;
         allowed[from][msg.sender] -= tokens;
         balances[to] += tokens;
         
         emit Transfer(from, to, tokens);
         return true;
     }
}
 
 
contract CryptosICO is Cryptos {
    address public admin;
    address payable public deposit;
    uint tokenPrice = 0.001 ether;  // 1 ETH = 1000 CRPT, so 1 CRPT = 0.001 ether
    uint public hardCap = 300 ether;
    uint public raisedAmount; // value in wei
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; // one week
    
    uint public tokenTradeStart = saleEnd + 604800; // tokens transferable one week after saleEnd
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;
    
    enum State { beforeStart, running, afterEnd, halted } // ICO states 
    State public icoState;
    
    constructor(address payable _deposit){
        deposit = _deposit; 
        admin = msg.sender; 
        icoState = State.beforeStart;
    }
 
    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can call this");
        _;
    }
    
    // Emergency stop of the ICO
    function halt() public onlyAdmin{
        icoState = State.halted;
    }
    
    // Resume the ICO after a halt
    function resume() public onlyAdmin{
        icoState = State.running;
    }
    
    // Change the deposit address where funds are forwarded
    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }
    
    // Returns the current state of the ICO
    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        } else if(block.timestamp < saleStart){
            return State.beforeStart;
        } else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        } else {
            return State.afterEnd;
        }
    }
 
    event Invest(address investor, uint value, uint tokens);
    
    // Called when someone invests ETH
    function invest() payable public returns(bool){ 
        icoState = getCurrentState();
        require(icoState == State.running, "ICO is not running");
        require(msg.value >= minInvestment && msg.value <= maxInvestment, "Investment out of bounds");
        
        raisedAmount += msg.value;
        require(raisedAmount <= hardCap, "Hard cap reached");
        
        uint tokens = msg.value / tokenPrice;
 
        // Transfer tokens from founder to investor
        balances[msg.sender] += tokens;
        balances[founder] -= tokens; 
        deposit.transfer(msg.value); // Forward the received ETH to the deposit address
        
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }
   
    // Automatically called when ETH is sent to the contract
    receive () payable external {
        invest();
    }
  
    // Burn any unsold tokens after the ICO has ended
    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd, "ICO is not finished yet");
        // Optionally restrict to admin or founder only:
        require(msg.sender == admin || msg.sender == founder, "Not authorized to burn tokens");
        
        balances[founder] = 0;
        return true;
    }
    
    // Override the transfer function to restrict token transfers until tokenTradeStart
    function transfer(address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStart, "Token trading not started yet");
        return super.transfer(to, tokens);
    }
    
    // Override the transferFrom function similarly
    function transferFrom(address from, address to, uint tokens) public override returns (bool success){
        require(block.timestamp > tokenTradeStart, "Token trading not started yet");
        return super.transferFrom(from, to, tokens);
    }
}
