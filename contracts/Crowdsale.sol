pragma solidity ^0.4.11;            
            
import './Ownable.sol';          
            
contract   Crowdsale{            
            
  //using SafeMath for uint256;           
         
  // The token being sold           
 // Ammbr public token;          
   AbstractAmmbr public token;            
            
  // start and end block where investments are allowed (both inclusive)          
  uint256 public startBlock;           
  uint256 public endBlock;          
         
  // address where funds are collected          
  address  wallet;            
  address  deployerAdd;          
         
  // how many token units a buyer gets per wei           
  uint256 public rate;           
         
  // amount of raised money in wei           
  uint256 public weiRaised;            
         
 // mapping(address => uint256) public etherContribute;           
         
 //uint public deadline;            
  /**          
   * event for token purchase logging           
   * @param beneficiary who got the tokens            
   * @param value weis paid for purchase           
   * @param amount amount of tokens purchased            
   */             
  event TokenPurchase( address beneficiary, uint256 value, uint256 amount);            
               
    //mapping(address => uint256) public etherContribute;            
               
    modifier afterDeadline() {            
        uint256 currentBlock = block.number;          
        if (currentBlock > endBlock) _;            
                  
    }          
            
  function Crowdsale(uint256 _startBlock, uint256 _endBlock, address _wallet, address contractAddress) {          
            
    require(_wallet != 0x0);           
    require(contractAddress != 0x0);            
            
    token = AbstractAmmbr(contractAddress);           
    // deadline = now + durationInMinutes * 1 minutes;            
    deployerAdd = msg.sender;          
    startBlock = _startBlock;          
    endBlock =  _endBlock;          
    wallet = _wallet;            
  }            
         
 // fallback function can be used to buy tokens          
  function () payable {          
    buyTokens(msg.sender);          
  }            
         
  // low level token purchase function          
  function buyTokens(address beneficiary) payable {            
    require(beneficiary != 0x0);          
    require(validPurchase());          
            
    uint256 weiAmount = msg.value;           
            
    // calculate token amount to be created           
    uint256 tokens = weiAmount* (rate);            
            
    // update state           
    weiRaised = weiRaised+(weiAmount);          
            
    token.mint(beneficiary, tokens);            
    TokenPurchase(beneficiary, weiAmount, tokens);          
            
    forwardFunds();           
  }            
         
  // send ether to the fund collection wallet            
  // override to create custom fund forwarding mechanisms            
  function forwardFunds() internal {            
    wallet.transfer(msg.value);           
  }            
         
  // @return true if the transaction can buy tokens            
  function validPurchase() internal constant returns (bool) {           
    uint256 current = block.number;          
    bool withinPeriod = current >= startBlock && current <= endBlock;            
    bool nonZeroPurchase = msg.value != 0;            
    return withinPeriod && nonZeroPurchase;           
  }            
         
  // @return true if crowdsale event has ended           
  function hasEnded() public constant returns (bool) {            
    return block.number > endBlock;          
}           
}           
