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
  function exchange(  address _from, address _to, uint256 _ammount) returns (bool) ;
}
contract AbstractAmmbr{
  function  mint(   address beneficiary, uint256 tokens);
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

contract PublicCrowdsale is Ownable{
    using SafeMath for uint256;
 
    // The token being sold
  AbstractAmmbr public tokenAddress;
  
  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
  
  uint256[] weekBlock;
    
  // address where funds are collected
  address  wallet;
  
  uint256  etherRaiseGoal=0;
  // Set base rate based on ether for bankwire, bitcoin and bitcoin cash

   uint256 public bankwirePerEther;
   uint256 public etherPerBitcoin;
   uint256 public etherPerBitcoinCash;
   uint256 public decimalForBitcoin;
   uint256 public decimalForBitcoinCash;

  AbstractBankwire  ammbr_bankwire;
    // amount of raised money in wei, bankwire, bitcoin and bitcoin cash
  uint256 public weiRaised;
  uint256 public bankwireRaised ;
  uint256 public bitcoinSatoshisRaised;
  uint256 public bitcoinCashSatoshisRaised;
  
  bool isEtherCapReached ;

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

  function PublicCrowdsale(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, address _wallet, address ammbrBankwireAddress, uint256 _bankwirePerEther, uint256 _etherPerBitcoinCash, uint256 _decimalForBitcoinCash, uint256 _etherPerBitcoin, uint256 _decimalForBitcoin) {
 
    require(_wallet != 0x0);
    require(ammbrAddress != 0x0);

    tokenAddress =  AbstractAmmbr(ammbrAddress);
    
    ammbr_bankwire  = AbstractBankwire (ammbrBankwireAddress);
       
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    wallet = _wallet;
    
    bankwirePerEther = _bankwirePerEther;
    etherPerBitcoinCash = _etherPerBitcoinCash;
     decimalForBitcoinCash = _decimalForBitcoinCash;
      decimalForBitcoin = _decimalForBitcoin;
    etherPerBitcoin = _etherPerBitcoin;

    uint256 totalBlockMine = endBlock - startBlock + 1;
    
    uint256 blockMined = _startBlock;
    
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
  //bytes memory  b = msg.data;
   address beneficiary =msg.sender;//getAddressFromByte(b);
    require(validAmountBlockAndEtherPurchase());


    uint256 weiAmount = msg.value;
   
   
    uint256 tokens = (weiAmount) * (tokensPerEther()) ;
    tokens = tokens.div(100); // conversion from 18 decimal to 16 decimal 
  
    weiRaised = weiRaised.add(weiAmount);
    forwardFunds();
    tokenAddress.mint(  beneficiary, tokens);
    TokenPurchase(beneficiary, weiAmount, tokens);
  
  }
  


  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
    

  function tokensPerEther() public constant returns(uint256){
    uint256 current = block.number;
    if(current < weekBlock[0])
	 return 3300;
    else if(current < weekBlock[1])
	return 3000;
    else if(current < weekBlock[2])
	return 2750;
    else 
	return 2500;
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
  
 

function contributeByBankWire( address beneficiary, uint256 amount){
  require(beneficiary != 0x0);
     require(  amount > 0);
    
    require(validEtherCapAndBlockPurchase());
  
    //address beneficiary =getAddressFromByte(transactionData);
   
    
    amount = amount.mul(10000000000000000);
  

    bool exchangeDone = ammbr_bankwire.exchange(  msg.sender,  wallet, amount);
    
    if(!exchangeDone){
        revert();
      }

    uint256 ethers = (amount).div(bankwirePerEther) ;
    

    uint256 tokens = ethers.mul(tokensPerEther());
  
    
    bankwireRaised = bankwireRaised.add(amount);

    tokenAddress.mint(  beneficiary, tokens);
    
    TokenPurchase(beneficiary, amount, tokens);


}

function buyTokensPerBitcoin(address beneficiary, uint256 satoshi, uint8 tokentype) onlyOwner  returns(bool){
          
    require(beneficiary != 0x0);
    require(validEtherCapAndBlockPurchase());
    assert(satoshi > 0);
    
    uint256 rate ;
    uint256 decimal;
    if(tokentype == 1){
	    rate = etherPerBitcoin;
	    bitcoinSatoshisRaised.add(satoshi);
	    decimal = decimalForBitcoin;
   
    }
    else if(tokentype == 2){
    	rate = etherPerBitcoinCash;
    	bitcoinCashSatoshisRaised.add(satoshi);
    	decimal = decimalForBitcoinCash;
    }
    else
	    return false;
    
    uint256 calEther = (satoshi).mul(rate) ; // convert satoshis to ether(with 8 decimal place)
    calEther = calEther.div(decimal);
    calEther = calEther.mul(10000000000); // convert ether to wei 18 decimal places
    
    uint256 tokens = calEther.mul (tokensPerEther()); //convert ether to mesh token
    
    tokens = tokens.div (100); //convert to 16 decimal place
   
    
    tokenAddress.mint(  beneficiary, tokens);
    TokenPurchase(beneficiary, satoshi, tokens);

    return true;
  }
  
 function allocateReservedToken(address beneficiary, uint256 amount) public onlyOwner{
      amount =  amount.mul(10000000000000000);
      tokenAddress.mint( beneficiary, amount);
    }



 function isCapReached() public constant returns (bool ) {
    return isEtherCapReached;
  }
  
  function kill() onlyOwner{
      
       suicide(wallet);
    }
 
}
