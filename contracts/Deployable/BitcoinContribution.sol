pragma solidity ^0.4.11;


library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract AbstractAmmbr{
  function  mint( address _owner, address beneficiary, uint256 tokens);
}
contract Ownable {
  address  owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

contract BitcoinContribution is Ownable{
  using SafeMath for uint256;
 
  // The token being sold
  AbstractAmmbr public token;
   
  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
  uint256[] weekBlock;
  
  address  wallet;
 
  // how many token units a buyer gets per wei
  uint256 public tokenPerBitcoin;

  // amount of raised money in satoshi
  uint256 public satoshiRaised;


  /**
   * event for token purchase logging
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase( address beneficiary, uint256 value, uint256 amount);
    
    
    
    modifier afterDeadline() { 
        uint256 currentBlock = block.number;
        if (currentBlock > endBlock)
         _; 
        
    }

  function BitcoinContribution(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, uint256 _tokenPerBitcoin) {
 
    
    require(ammbrAddress != 0x0);

    token =  AbstractAmmbr(ammbrAddress);
  
    
   
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    
    uint256 totalBlockMine = endBlock - startBlock;
    uint256 blockMined = _startBlock;
    tokenPerBitcoin = _tokenPerBitcoin;
    uint256 blockMineInWeek = totalBlockMine.div(4);
    
    for(uint count =0 ; count < 4 ; count++){
        blockMined = blockMined + blockMineInWeek;
        weekBlock.length = count+1;
        weekBlock[count] = blockMined;
    }
    
    uint256 blockleft  = totalBlockMine - blockMined;
    
    weekBlock[3] = weekBlock[3] + blockleft;
    
  }

 
 // low level token purchase function
  function buyTokens(address beneficiary, uint256 satoshi)  {
          
    require(beneficiary != 0x0);
    require(validPurchase());
    assert(satoshi > 0);
    
    
    uint256 tokens = (satoshi).mul(tokenPerBitcoin) ;
    tokens = tokens.mul(100000000);
    uint256 bonusTokens = tokens.mul (bonus());
    
    bonusTokens = bonusTokens.div (100);
    tokens = tokens.add(bonusTokens);
    
    satoshiRaised = satoshiRaised.add(satoshi);
    
    token.mint(owner, beneficiary, tokens);
    TokenPurchase(beneficiary, satoshi, tokens);

    
  }


  
function bonus() constant returns(uint256){
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
    return withinPeriod;
  }
  
  


}
