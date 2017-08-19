pragma solidity ^0.4.11;
import './StandardToken.sol';
import './Ownable.sol';


  contract  Ammbr is StandardToken, Ownable {
    
   string public name ='';
   string public symbol = '';
   uint8 public  decimals =0;
   
     
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


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
  function mint(address _to, uint256 _amount) canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
}
    


function Ammbr( string _name, string _symbol, uint8 _decimals){

   name = _name;
   symbol = _symbol;
   decimals = _decimals;    
  
}

  

}