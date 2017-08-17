pragma solidity ^0.4.11;
import './AbstractAmmbr.sol';


contract Crowdsale{
  //using SafeMath for uint256;
  // The token being sold
  AbstractAmmbr public token;
   //AbstractAmmbr public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
    uint256[] weekBlock;
  // address where funds are collected
  address  wallet;
 // address  deployerAdd;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;
  //uint256 weiInEther= 10000000000000000;
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
        if (currentBlock > endBlock)
         _; 
        
    }

  function Crowdsale(uint256 _startBlock, uint256 _endBlock, address contract_add, address _wallet,uint256 tokenPerEther) {
 
    require(_wallet != 0x0);
    require(contract_add != 0x0);

    token =  AbstractAmmbr(contract_add);
   
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    wallet = _wallet;
    uint256 totalblock = endBlock - startBlock;
    uint256 blockminedInWeek = _startBlock;
    rate = tokenPerEther;
    
    for(uint count =0 ; count < 4 ; count++){
        blockminedInWeek = blockminedInWeek + totalblock;
        weekBlock.length = count+1;
        weekBlock[count] = blockminedInWeek;
    }
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
    uint256 tokens = (weiAmount) * (rate) ;
    
    tokens = tokens + ( tokens * bonus())/100 ;
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
function bonus()internal returns(uint256){
    uint256 current = block.number;
    if(current < weekBlock[0])
    return 30;
    else if(current < weekBlock[1])
    return 20;
    else if(current < weekBlock[2])
    return 10;
    else 
    return 0;
}
  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    bool nonZeroPurchase = true;// msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return block.number > endBlock;
}
}
