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
  function exchange(address _from, address _to, uint256 _ammount) returns (bool) ;
}

contract AbstractAmmbr{
  function  mint( address beneficiary, uint256 tokens);
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

contract InstitutionSale is Ownable{
    using SafeMath for uint256;
 
    // The token being sold
  AbstractAmmbr public tokenAddress;
  
  // start and end block where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;
  
  uint256[] weekBlock;
    
  // address where funds are collected
  address  wallet;
  
  uint256  etherRaiseGoal;
  // Set base rate based on ether for bankwire, bitcoin and bitcoin cash

   uint256 public bankwirePerEther;
  

  AbstractBankwire  ammbr_bankwire;
    // amount of raised money in wei, bankwire, bitcoin and bitcoin cash
 
  uint256 public bankwireRaised ; 
  
 

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
 
  function InstitutionSale(uint256 _startBlock, uint256 _endBlock, address ammbrAddress, address _wallet, address ammbrBankwireAddress, uint256 _bankwirePerEther) {
 
    require(_wallet != 0x0);
    require(ammbrAddress != 0x0);

    tokenAddress =  AbstractAmmbr(ammbrAddress);
    
    ammbr_bankwire  = AbstractBankwire (ammbrBankwireAddress);
       
    startBlock = _startBlock;
    endBlock =  _endBlock;
    
    wallet = _wallet;
    
    bankwirePerEther = _bankwirePerEther;
    
 
  }

 




  function tokensPerEther() public constant returns(uint256){
	return 15000;
}
  

 
  function validEtherCapAndBlockPurchase( ) internal constant returns (bool) {
    uint256 current = block.number;
    bool withinPeriod = current >= startBlock && current <= endBlock;
    
   
        return withinPeriod ;
    
  }
  
/*  function getAddressFromByte(bytes b) internal returns (address){
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

  }*/


function contributeByBankWire(address beneficiary, uint256 amount ){
  require(beneficiary != 0x0);
     require(  amount > 0);
   
    require(validEtherCapAndBlockPurchase());
  
  //  address beneficiary =getAddressFromByte(transactionData);
   
    
    amount = amount.mul(10000000000000000);
  

    bool exchangeDone = ammbr_bankwire.exchange(msg.sender,  wallet, amount);
    
    if(!exchangeDone){
        revert();
      }

    uint256 ethers = (amount).div(bankwirePerEther) ;
    

    uint256 tokens = ethers.mul(tokensPerEther());
  
    
    bankwireRaised = bankwireRaised.add(amount);

    tokenAddress.mint( beneficiary, tokens);
    
    TokenPurchase(beneficiary, amount, tokens);


}


  
  
   
 
 
  function kill() onlyOwner{
      
       suicide(wallet);
    }
 
}
