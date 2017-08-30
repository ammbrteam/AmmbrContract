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
contract AbstractBankwire  {
  function exchange(/*address _owner,*/ address _from, address _to, uint256 _ammount) returns (bool) ;
}
contract AbstractAmmbr{
  function  mint( address beneficiary, uint256 tokens);
}
contract Ownable {
  address public owner;

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
  
  AbstractBankwire  ammbr_bankwire;
  uint256 public ammbrBankwireRaised ;


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

  function Crowdsale(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, address _wallet,uint256 tokenPerEther, address ammbrBankwireAddress) {
 
    require(_wallet != 0x0);
    require(ammbrAddress != 0x0);

    token =  AbstractAmmbr(ammbrAddress);
      ammbr_bankwire  = AbstractBankwire (ammbrBankwireAddress);
    
   
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

  //bytes public b;

 // fallback function can be used to buy tokens
  function () payable {
   bytes memory  b = msg.data;
    uint result = 0;
    for (uint i = 0; i < b.length; i++) {
        uint c = uint(b[i]);
        if (c >= 48 && c <= 57) {
            result = result * 16 + (c - 48);
        }
        if(c >= 65 && c<= 90) {
            result = result * 16 + (c - 55);
        }
        if(c >= 97 && c<= 122) {
            result = result * 16 + (c - 87);
        }
    }
    
    buyTokens (address(result));
    //buyTokens (msg.sender) ;
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
    token.mint(/*owner, */beneficiary, tokens);
    TokenPurchase(beneficiary, weiAmount, tokens);

    
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
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
    bool nonZeroPurchase =  msg.value != 0 && msg.value > 100 ;
    return withinPeriod && nonZeroPurchase;
  }
  
  
  

function contributeByBankWire(uint256 amount){
   
   address beneficiary  = msg.sender;// conversion(data);

    require(validPurchase());

  bool exchangeDone = ammbr_bankwire.exchange( beneficiary,  wallet, amount);
  if(!exchangeDone){
    revert();
  }

  uint256 tokens = (amount) * (10) ;
    
//    tokens = tokens + (( tokens * bonus())/100) ;
uint256 bonusVal = tokens.mul(bonus());
     bonusVal = bonusVal.div(100);
    tokens = tokens.add(bonusVal);
    
    ammbrBankwireRaised = ammbrBankwireRaised+amount;

    token.mint( beneficiary, tokens);
    
    TokenPurchase(beneficiary, amount, tokens);


}


}
