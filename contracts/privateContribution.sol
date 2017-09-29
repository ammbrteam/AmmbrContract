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
  function exchange(address _owner, address _from, address _to, uint256 _ammount) returns (bool) ;
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

contract PrivateCrowdsale is Ownable{
    using SafeMath for uint256;
 
    // The token being sold
     AbstractAmmbr public token;
   
  

  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
    uint256[] weekBlock;
    
  // address where funds are collected
  address  wallet;
  
    uint256 public etherRaiseGoal;
  // Set base rate based on ether for bankwire, bitcoin and bitcoin cash

   uint256 public bankwirePerEther;
   uint256 public etherPerBitcoin;
   uint256 public etherPerBitcoinCash;

  AbstractBankwire  ammbr_bankwire;
    // amount of raised money in wei, bankwire, bitcoin and bitcoin cash
  uint256 public weiRaised;
  uint256 public ammbrBankwireRaised ;
  uint256 public bitcoinRaised;
  uint256 public bitcoinCashRaised;
  
   bool isEtherCapReached;


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
function setEtherRaiseGoal(uint256 amount) onlyOwner{
    etherRaiseGoal = amount.mul(1000000000000000000);
    isEtherCapReached = false;
}
  function PrivateCrowdsale(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, address _wallet,/*uint256 tokenPerEther,*/ address ammbrBankwireAddress, uint256 _bankwirePerEther, uint256 _etherPerBitcoinCash, uint256 _etherPerBitcoin) {
 
    require(_wallet != 0x0);
    require(ammbrAddress != 0x0);

    token =  AbstractAmmbr(ammbrAddress);
    
    ammbr_bankwire  = AbstractBankwire (ammbrBankwireAddress);
       
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    wallet = _wallet;
    
    bankwirePerEther = _bankwirePerEther;
    etherPerBitcoinCash = _etherPerBitcoinCash;
    etherPerBitcoin = _etherPerBitcoin;

    uint256 totalBlockMine = endBlock - startBlock + 1;
    
    uint256 blockMined = _startBlock;
  //  rate = tokenPerEther;
    uint256 blockMineInWeek = totalBlockMine.div(4);
    
    for(uint count =0 ; count < 4 ; count++){
        blockMined = blockMined + blockMineInWeek;
        weekBlock.length = count+1;
        weekBlock[count] = blockMined;
    }
    
     uint256 blockleft  = totalBlockMine - blockMined;
 
     weekBlock[3] = weekBlock[3] + blockleft;
 
  }

 

 // fallback function can be used to buy tokens
  function () payable {
   bytes memory  b = msg.data;
   address beneficiary =getAddressFromByte(b);
    buyTokens (beneficiary);
    //buyTokens (msg.sender) ;
  }
  





  // low level token purchase function
  function buyTokens(address beneficiary) internal  {
          
     require(validAmountBlockAndEtherPurchase());


    uint256 weiAmount = msg.value;
   
   
    uint256 tokens = (weiAmount) * (meshPerEther()) ;
   // uint256 bonusTokens = tokens.mul(bonus());
    // bonusTokens = bonusTokens.div(100);
    //tokens = tokens.add(bonusTokens);
    
    
     tokens = tokens.div(100); // conversion from 18 decimal to 16 decimal 
    weiRaised = weiRaised.add(weiAmount);
    forwardFunds();
    token.mint(owner, beneficiary, tokens);
    TokenPurchase(beneficiary, weiAmount, tokens);

    
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
    

  function meshPerEther() constant returns(uint256){
    uint256 current = block.number;
    if(current < weekBlock[0])
	 return 15000;
    else if(current < weekBlock[1])
	return 10000;
    else if(current < weekBlock[2])
	return 7500;
    else 
	return 5000;
}
  

  // @return true if the transaction can buy tokens
  function validAmountBlockAndEtherPurchase() internal constant returns (bool) {
    
    bool withinPeriod = validEtherCapAndBlockPurchase();
    bool nonZeroPurchase =  msg.value != 0 && msg.value > 100 ;
    return withinPeriod && nonZeroPurchase;
  }
 
  function validEtherCapAndBlockPurchase( ) internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    
    if(etherRaiseGoal > 0){
     isEtherCapReached = etherRaiseGoal >  weiRaised;
     return withinPeriod && isEtherCapReached;
    }else{
        return withinPeriod ;
    }
  }
  
  function getAddressFromByte(bytes b) internal returns (address){
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

   return address(result);

  }


function contributeByBankWire(uint256 amount,bytes b){
  
     require(  amount > 0);
   
    require(validEtherCapAndBlockPurchase());
  
    address beneficiary =getAddressFromByte(b);
   
    
    amount = amount.mul(10000000000000000);
  

    bool exchangeDone = ammbr_bankwire.exchange( owner, msg.sender,  wallet, amount);
    
    if(!exchangeDone){
        revert();
      }

    uint256 ethers = (amount).div(bankwirePerEther) ;
    

    uint256 tokens = ethers.mul(meshPerEther());
  
    
    ammbrBankwireRaised = ammbrBankwireRaised+amount;

    token.mint(owner, beneficiary, tokens);
    
    TokenPurchase(beneficiary, amount, tokens);


}

function  buyTokensPerBitcoin(address beneficiary, uint256 satoshi, uint8 tokentype) onlyOwner  returns(bool){
          
    require(beneficiary != 0x0);
    require(validEtherCapAndBlockPurchase());
    assert(satoshi > 0);
    
    uint256 rate ;

    if(tokentype == 1){
	    rate = etherPerBitcoin;
	    bitcoinRaised.add(satoshi);
   
    }
    else if(tokentype == 2){
    	rate = etherPerBitcoinCash;
    	bitcoinCashRaised.add(satoshi);
    }
    else
	    return false;
    
    uint256 calEther = (satoshi).mul(rate) ;
    calEther = calEther.div(100); // convert satoshis to ether(with 8 decimal place)
    calEther = calEther.mul(10000000000); // convert ether to wei 18 decimal places
    uint256 tokens = calEther.mul (meshPerEther()); //convert ether to mesh token
    
    tokens = tokens.div (100); //convert to 16 decimal place
    //tokens = tokens.add(bonusTokens);
    
    //satoshiRaised = satoshiRaised.add(satoshi);
    
    token.mint(owner, beneficiary, tokens);
    TokenPurchase(beneficiary, satoshi, tokens);

    return true;
  }



  function  getBankwirePerEther() constant returns (uint256){
    return bankwirePerEther;
  }
   function  getEtherPerBitcoin() constant returns (uint256){
    return etherPerBitcoin;
  }
   function  getEtherPerBitcoinCash() constant returns (uint256){
    return etherPerBitcoinCash;
  }
 function isCapReached() constant returns (bool ) {
    return isEtherCapReached;
  }
}
