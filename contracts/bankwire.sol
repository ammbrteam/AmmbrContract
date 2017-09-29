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

contract ERC20 {
  // Declaration of variable
  uint256 public totalSupply;
  // Declaration of function
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);

  // declaration of event
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract StandardToken is ERC20 {
  // include Safe math libary
  using SafeMath for uint256;

  // declaration of mapping
  mapping (address => mapping (address => uint256)) allowed;
  mapping(address => uint256) balances;
  
  
 // function StandardToken

  // function defination 
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {

    assert(0 < _value);
    assert(balances[msg.sender] >= _value);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    
    assert (balances[_from] >= _value);
    assert (_allowance >= _value );
    assert ( _value > 0 );
    //assert ( balances[_to] + _value > balances[_to]);
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}




  contract  AmmbrBankwire is StandardToken, Ownable {
 // include Safe math libary
  using SafeMath for uint256;

  uint256 public totalSupply;
  
  address crowdsale_address;

   string public name ='';
   string public symbol = '';
   uint8 public  decimals;
   //mapping(address => uint256) balances;

   bool public mintingFinished = false;
   address wallet;

   event Transfer(address _from,address _to,uint256 _value);
   event Mint(address indexed to, uint256 amount);
   event MintFinished();
   event MintStart();
 

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function allocateBankWire(address _to, uint256 _amount)  onlyOwner canMint returns (bool) {
      _amount = _amount * 10000000000000000;
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function stopAllocation() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
}
    
  function startAllocation() onlyOwner returns (bool) {
    mintingFinished = false;
    MintStart();
    return true;
}


function AmmbrBankwire( string _name, string _symbol, uint8 _decimals, address _wallet){

   name = _name;
   symbol = _symbol;
   decimals = _decimals;    
   wallet =  _wallet;
  
}

/**
  * check wallet address and to address same 
  *
 */
function exchange(address _owner ,address _from, address _to, uint256 _ammount) returns(bool){
        if(_owner == owner){
         
		
            uint256 balance =  balances[_from];
            require((balance >0) &&  (balance >= _ammount) && ( wallet == _to));

            balances[_to] = balances[_to].add(_ammount);
            balances[_from] = balances[_from].sub(_ammount);
            Transfer(_from, _to, _ammount);
            return true;
			}else{
			    return false;
			}
       
 }



}
