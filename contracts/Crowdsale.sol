pragma solidity ^0.4.11;
import './SafeMath.sol';
import './AbstractAmmbr.sol';
import './Ownable.sol';

contract Crowdsale is Ownable{
  using SafeMath for uint256;
  // The token being sold
  AbstractAmmbr public token;
   
  

  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
    uint256[] weekBlock;
  // address where funds are collected
  address  wallet;
 
  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;
  
  


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

  function Crowdsale(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, address _wallet,uint256 tokenPerEther) {
 
    require(_wallet != 0x0);
    require(ammbrAddress != 0x0);

    token =  AbstractAmmbr(ammbrAddress);
  
    
   
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    wallet = _wallet;
    uint256 totalBlockMine = endBlock - startBlock;
    uint256 blockMined = _startBlock;
    rate = tokenPerEther;
    uint256 blockMineInWeek = totalBlockMine.div(4);
    
    for(uint count =0 ; count < 4 ; count++){
        blockMined = blockMined + blockMineInWeek;
        weekBlock.length = count+1;
        weekBlock[count] = blockMined;
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
    assert(weiAmount > 100);
    // calculate token amount to be created 
   
    uint256 tokens = (weiAmount) * (rate) ;
    uint256 bonusTokens = tokens.mul(bonus());
     bonusTokens = bonusTokens.div(100);
    tokens = tokens.add(bonusTokens);
    
     // minimum 0.0000000000000100 ether 
     tokens = tokens.div(100);
    weiRaised = weiRaised+(weiAmount);
    forwardFunds();
    token.mint(beneficiary, tokens);
    TokenPurchase(beneficiary, weiAmount, tokens);

    
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
    bool nonZeroPurchase =  msg.value != 0 && msg.value > 100 ;
    return withinPeriod && nonZeroPurchase;
  }


}
